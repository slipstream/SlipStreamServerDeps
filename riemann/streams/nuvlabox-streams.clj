(require '[sixsq.slipstream.api.service-offer :as service-offer])

;; (logging/init {:file "/var/log/riemann/riemann.log"})
;; 
;; (let [host "0.0.0.0"]
;;      (tcp-server {:host host})
;;      (udp-server {:host host})
;;      (ws-server  {:host host}))

(def expiration-watch       1)
(def default-ttl            5)
(def nuvlabox-tag           "nuvlabox")
(def nuvlabox-ping-service  "load/load/shortterm")

(instrumentation {:enabled? false})
(periodically-expire expiration-watch {:keep-keys [:nuvlabox-name :service :tags]})

(defn- try-get-connectors
       []
       (try
         (service-offer/list-connectors)
         (catch Throwable t
           (warn (str "Unable to get connectors: " (.getMessage t)))
           {})))

(def states (atom {}))

(defn- name-id-state-last-online
       [connector]
       {:name         (keyword (get-in connector [:connector :href]))
        :id           (:id connector)
        :state        (if (= :ok (-> connector :state keyword)) :ok :nok)
        :last-online  (:last-online connector)})

(defn- record-connector
       [m name-id-state-last-online]
       (assoc
         m
         (:name name-id-state-last-online)
         (dissoc name-id-state-last-online :name)))

(defn- fetch-topology
       []
       (info "Fetching map states")
       (->>  (try-get-connectors)
             (map name-id-state-last-online)
             (reduce record-connector {})))

(defn- all-states-nok
       [map-states]
       (into {} (map (fn[[k v]] [k (assoc v :state :nok)]) map-states)))

(defn- build-topology!
       [& [{:keys [force-nok]}]]
       (let [topology (cond-> (fetch-topology)
                              force-nok all-states-nok)]
            (reset! states topology)
            (info "Map states " (if force-nok "force all to nok" "") ":" @states)
            @states))

(defn- update-state!
  [name state]
  (swap! states #(assoc-in % [name :state] state))
  (info "State changed for " name ", new state: " state))

(defn- update-last-online!
  [name state]
  (when (= :ok state)
    (let [new-last-online (str (java.util.Date.))]
      (swap! states #(assoc-in % [name :last-online] new-last-online))
      (info "Last online changed for " name " with: " new-last-online))))

(defn- send-state
       [name id-state-last-online]
       (io (service-offer/update-connector id-state-last-online))
       (info "State sent for " name ": " id-state-last-online))

(defn- update-send-state!
       [name id state last-online]
       (update-state! name state)
       (update-last-online! name state)
       (send-state name (name @states)))

(defn- receive-state
       [event state]
       (let [name           (-> event :nuvlabox-name keyword)
             states         @states
             states         (if-not (contains? states name) (build-topology!) states)
               current-state  (get-in states [name :state])
             id             (get-in states [name :id])
             last-online    (get-in states [name :last-online])]
            (if-not id
                    (warn "Unknown name : " name)
                    (if-not (= state current-state)
                      (update-send-state! name id state last-online)
                      (update-last-online! name state)))))

(defn- send-all-states
       []
       (doseq [[name id-state-last-online] @states]
              (send-state name id-state-last-online)))

(let [index (default :ttl default-ttl (index))]

     (build-topology! {:force-nok true})

     (send-all-states)

     (streams
       index
       #(info "got event:" %)
       (where
         (and (tagged [nuvlabox-tag]) (service nuvlabox-ping-service))
         (tap :test-index index)
         #(receive-state % (if (expired? %) :nok :ok)))))
