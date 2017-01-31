(ns sixsq.slipstream.api.service-offer
    (:require
      [environ.core :as env]
      [clojure.set :as set]
      [clj-http.client :as client]
      [clojure.data.json :as json] [clojure.set :as set]))

(defn- json->edn [json]
       (when json (json/read-str json :key-fn keyword)))

(defn edn->json [edn]
      (json/write-str edn))

(def slipstream-endpoint        (env/env :slipstream-endpoint))
(def slipstream-super-password  (env/env :slipstream-super-password))

(println "Using SlipStream endpoint : " slipstream-endpoint)

(defn- cookie-store-authn
       []
       (let [my-cs (clj-http.cookies/cookie-store)
             _ (client/post (str slipstream-endpoint "/auth/login?user-name=super&password=" slipstream-super-password)
                            {:cookie-store my-cs :insecure? true})]
            {:cookie-store my-cs :insecure? true}))

(defn list-connectors
      []
      (-> (client/get (str slipstream-endpoint "/api/service-offer") (cookie-store-authn))
          :body
          json->edn
          :serviceOffers))

(defn update-connector
      [c]
      (let [doc (merge (cookie-store-authn)
                   {:body
                    (edn->json
                      (-> (select-keys c [:state :last-online])
                          (set/rename-keys {:state        :schema-org:state
                                            :last-online  :schema-org:last-online})))}
                   {:headers {"Content-type" ["application/json"]}})]
           (try
             (client/put (str slipstream-endpoint "/api/" (:id c)) doc)
             (catch Exception e
               (println "exc " e)))))
