(ns poker.test.core
  (:use [poker [core :as p]])
  (:use [clojure.test]))


(def h p/parse-hand)

(deftest test-parse
  (is (= [{:suit :c, :value 2}
          {:suit :d, :value 3}
          {:suit :h, :value 4}
          {:suit :s, :value 5}
          {:suit :c, :value 6}]
         (h "2c 3d 4h 5s 6c")))
  
  (is (= [{:suit :c, :value 14}
          {:suit :d, :value 13}
          {:suit :h, :value 12}
          {:suit :s, :value 11}
          {:suit :c, :value 10}]
         (h "Ac Kd Qh Js 10c")))
  )

(deftest ranking
  (is (= [[3 5] [1 14] [1 13]]
         (p/ranked-groups (h "5s Ah 5c Kh 5d")))))


(deftest test-high-card
  (is (= [9] (p/match-high-card (h "2c 8s 9c 6h 5d")))))

(deftest test-pair
  (is (= [12] (p/match-pair (h "Qh Ad Ks Qd 3c")))))

(deftest test-two-pair
  (is (= [14 7] (p/match-two-pair (h "7c Ad 7h 9s 7d")))))

(deftest test-tree-of-a-kind
  (is (= [6] (p/match-three-of-a-kind (h "As 6c 6d 7h 6h")))))

(deftest test-straight
  (is (= [11] (p/match-straight (h "Jc 7c 9s 8d 10c"))))
  (is (= [14] (p/match-straight (h "10s Ah Qs Kc Js"))))
  (is (= [5]  (p/match-straight (h "Ah 2d 5c 3d 4s"))))
  )

(deftest test-flush
  (is (= [12] (p/match-flush (h "5s 6s 2s Qs 10s")))))

(deftest test-full-house
  (is (= [5 9] (p/match-full-house (h "9d 5d 5s 9h 5c"))))
  (is (= [9 5] (p/match-full-house (h "9d 5d 5s 9h 9c"))))
  )

(deftest test-four-of-a-kind
  (is (= [2] (p/match-four-of-a-kind (h "2c Js 2d 2h 2s")))))

(deftest test-straight-flush
  (is (= [11] (p/match-straight (h "Jc 7c 9c 8c 10c"))))
  (is (= [14] (p/match-straight (h "10s As Qs Ks Js"))))
  (is (= [5]  (p/match-straight (h "Ad 2d 5d 3d 4d"))))
  )


