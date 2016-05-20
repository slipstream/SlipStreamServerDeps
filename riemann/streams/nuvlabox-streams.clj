(require '[sixsq.slipstream.api.service-offer :as service-offer])

;;(logging/init {:file "/var/log/riemann/riemann.log"})
;;
;;(let [host "0.0.0.0"]
;;     (tcp-server {:host host})
;;     (udp-server {:host host})
;;     (ws-server  {:host host}))


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

(defn- name-id-state
  [connector]
  [(get-in connector [:connector :href])
   (:id connector)
   (if (= :ok (-> connector :state keyword)) :ok :nok)])

(defn- record-connector
  [m [name id state]]
  (assoc m (keyword name) {:id id :state state}))

(defn- fetch-topology
  []
  (info "Fetching map states")
  (->>  (try-get-connectors)
        (map name-id-state)
        (reduce record-connector {})))

(defn- all-states-nok
  [map-states]
       (into {} (map (fn[[k v]]
                        [k (assoc v :state :nok)]) map-states)))

(defn- build-topology!
       [& [{:keys [force-nok]}]]
       (let [topology (cond-> (fetch-topology)
                    force-nok all-states-nok)]
    (reset! states topology)
    (info "Map states " (if force-nok "force all to nok" "") ":" @states)
    @states))

(defn- update-state
  [name id state]
  (io (service-offer/update-connector {:id id :state state}))
  (swap! states #(assoc-in % [name :state] state))
  (info "State changed for " name "id: " id ", new state: " state))

(defn- receive-state
  [event state]
  (let [name           (-> event :nuvlabox-name keyword)
        states         @states
        states         (if-not (contains? states name) (build-topology!) states)
        current-state  (get-in states [name :state])
        id             (get-in states [name :id])]

    (if-not id
      (warn "Unknown name : " name)
      (if-not (= state current-state)
                       (update-state name id state)
                       (info "No change for " name ", state: " state)))))

(defn- update-all
  []
  (doseq [[name {:keys [id state]}] @states]
         (update-state name id state)))

(let [index (default :ttl default-ttl (index))]

  (build-topology! {:force-nok true})

  (update-all)

  (streams
    index
    #(info "got event:" %)
    (where
      (and (tagged [nuvlabox-tag]) (service nuvlabox-ping-service))
      (tap :test-index index)
      #(receive-state % (if (expired? %) :nok :ok)))))
