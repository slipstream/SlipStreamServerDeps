(def +version+ "3.50")

(defproject com.sixsq.slipstream/SlipStreamRiemann-jar "3.50"

  :description "Riemann Server for Autoscaling"

  :url "https://github.com/slipstream/SlipStreamServerDeps"

  :license {:name "Apache 2.0"
            :url "http://www.apache.org/licenses/LICENSE-2.0.txt"
            :distribution :repo}

  :plugins [[lein-parent "0.3.2"]
            [lein-localrepo "0.5.4"]]

  :parent-project {:coords  [sixsq/slipstream-parent "5.1.1"]
                   :inherit [:min-lein-version
                             :managed-dependencies
                             :repositories
                             :deploy-repositories]}

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
