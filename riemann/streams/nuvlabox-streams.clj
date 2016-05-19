(require '[sixsq.slipstream.api.service-offer :as service-offer])

;(logging/init {:file "/var/log/riemann/riemann.log"})
;
;(let [host "0.0.0.0"]
;     (tcp-server {:host host})
;     (udp-server {:host host})
;     (ws-server  {:host host}))

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
           (warn (str "Unable to get connectors: " (.getMessage t))
                 {}))))

(def initial-states (try-get-connectors))
(def states (atom initial-states))
(info "states " @states)

(defn- update-state
       [name id state]
       (io (service-offer/update-connector {:id id :state state}))
       (swap! states #(assoc-in % [name :state] state))
       (info "State changed for " name "id: " id ", new state: " state))

(defn- receive-state
       [event state]
       (let [name (-> event :nuvlabox-name keyword)
             states @states
             current-state (get-in states [name :state])
             id (get-in states [name :id])]
            (if-not id
                    (info "unknown name " name)
                    (if-not (= state current-state)
                            (update-state name id state)
                            (info "No change for " name ", state: " state)))))

(defn- initial-update-all-to-nok
       []
       (doseq [[name id-state] @states]
              (update-state name (:id id-state) :nok)))

(let [index (default :ttl default-ttl (index))]

     (initial-update-all-to-nok)

     (streams
       index
       #(info "got event:" %)
       (where
         (and (tagged [nuvlabox-tag]) (service nuvlabox-ping-service))
         (tap :test-index index)
         #(receive-state % (if (expired? %) :nok :ok)))))
