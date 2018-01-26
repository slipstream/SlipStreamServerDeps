(def +version+ "3.45-SNAPSHOT")

(defproject
  com.sixsq.slipstream/SlipStreamRiemann-jar
  "3.45-SNAPSHOT"
  :license
  {"commercial" "http://sixsq.com"}

  :plugins [[lein-parent "0.3.2"]
            [lein-localrepo "0.5.4"]]

  :parent-project {:coords  [com.sixsq.slipstream/parent "3.45-SNAPSHOT"]
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
