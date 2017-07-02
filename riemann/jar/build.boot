(def +version+ "3.32-SNAPSHOT")

(set-env!
  :project 'com.sixsq.slipstream/SlipStreamRiemann-jar
  :version +version+
  :license {"commercial" "http://sixsq.com"}
  :edition "community"

  :dependencies '[[org.clojure/clojure "1.9.0-alpha17"]
                  [sixsq/build-utils "0.1.4" :scope "test"]])

(require '[sixsq.build-fns :refer [merge-defaults
                                   sixsq-nexus-url
                                   lein-generate]])

(set-env!
  :repositories
  #(reduce conj % [["sixsq" {:url (sixsq-nexus-url)}]])

  :dependencies
  #(vec (concat %
                (merge-defaults
                 ['sixsq/default-deps (get-env :version)]
                 '[[org.clojure/clojure]
                   
                   [clj-http]
                   [environ]
                   [org.clojure/data.json]]))))

(set-env!
  :source-paths #{}
  :resource-paths #{"src"})

(task-options!
  pom {:project (get-env :project)
       :version (get-env :version)}
  install {:pom "com.sixsq.slipstream/SlipStreamRiemann-jar"}
  push {:pom "com.sixsq.slipstream/SlipStreamRiemann-jar"
        :repo "sixsq"})

(deftask build []
         (comp
           (aot :all true)
           (sift :include #{#"pom\.xml"} :invert true)
           (pom)
           (uber)
           (jar)))

(deftask mvn-build
         "build full project through maven"
         []
         (comp
           (build)
           (install)
           (if (= "true" (System/getenv "BOOT_PUSH"))
             (push)
             identity)))
