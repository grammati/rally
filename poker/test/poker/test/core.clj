(ns poker.test.core
  (:use [poker [core :as p]])
  (:use [clojure.test]))

(deftest test-parse
  (is (= [[:c 2] [:d 3] [:h 4] [:s 5] [:c 6]]
         (p/parse-hand "2c 3d 4h 5s 6c")))
  (is (= [[:c 14] [:d 13] [:h 12] [:s 11] [:c 10]]
         (p/parse-hand "Ac Kd Qh Js 10c")))
  )


