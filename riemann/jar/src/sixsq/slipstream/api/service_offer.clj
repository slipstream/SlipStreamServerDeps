(ns sixsq.slipstream.api.service-offer
    (:require
    [environ.core :as env]
    [clj-http.client :as client]
    [clojure.data.json :as json]))

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
  (try
    (client/put (str slipstream-endpoint "/api/" (:id c))
                (merge (cookie-store-authn)
                       {:body (edn->json (select-keys c [:state]))}
                       {:headers {"Content-type" ["application/json"]}}))
    (catch Exception e
      (println "exc " e))))
