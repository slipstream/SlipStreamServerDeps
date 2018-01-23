(def +version+ "3.44-SNAPSHOT")

;; FIXME: Provide HTTPS access to Nexus.
(require 'cemerick.pomegranate.aether)
(cemerick.pomegranate.aether/register-wagon-factory!
  "http" #(org.apache.maven.wagon.providers.http.HttpWagon.))

(defproject
  com.sixsq.slipstream/SlipStreamRiemann-jar
  "3.44-SNAPSHOT"
  :license
  {"commercial" "http://sixsq.com"}

  :plugins [[lein-parent "0.3.2"]
            [lein-localrepo "0.5.4"]]

  :parent-project {:coords  [com.sixsq.slipstream/parent "3.44-SNAPSHOT"]
                   :inherit [:min-lein-version :managed-dependencies :repositories :deploy-repositories]}

  :pom-location "target/"

  :source-paths ["src"]

  :aot :all

  :dependencies
  [[org.clojure/clojure]
   [clj-http]
   [environ]
   [org.clojure/data.json]]

  :aliases {"install" [["do"
                        ["uberjar"]
                        ["pom"]
                        ["localrepo" "install" "-p" "target/pom.xml"
                         ~(str "target/SlipStreamRiemann-jar-" +version+ "-standalone.jar")
                         "com.sixsq.slipstream/SlipStreamRiemann-jar"
                         ~+version+]]]}

  )
