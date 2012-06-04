(ns ^{:doc "Functions for scoring poker hands.
            Disclaimer: Everything I know about poker I learned from  http://en.wikipedia.org/wiki/List_of_poker_hands"}
  poker.core
  (:require [clojure [string :as s]]))

(defn parse-card
  "Parse a string such as \"3h\" or \"Ks\" as a card. "
  [s]
  (if-let [[_ value suit] (re-matches #"([AKQJ2-9]|10)([cdhs])" s)]
    {:suit (keyword suit)
     :value (or (get {"A" 14 "K" 13 "Q" 12 "J" 11} value)
                (Integer/parseInt value))}
    (throw (IllegalArgumentException. (str "Illegal card: " s)))))

(defn parse-hand
  "Parse a string representation of some cards into a vector of
   two-element vectors, each of which has a keyword ,:h :s :c or :d, as
   its first element, and the numeric value of the card as the second
   element."
  [hand]
  (->> (s/split hand #"\s+")
       (map parse-card)
       (into [])))


(defn ranked-groups
  "Returns a ranked list of pairs, triples, etc. in descending
   order of value. Pairs are [count card-value].
   Example: (ranked-groups (parse-hand \"5s Ah 5c Kh 5d\")) =>
            [[3 5] [1 14] [1 13]] "
  [hand]
  (->> hand
       (map :value)
       frequencies
       (map (fn [[val count]] [count val]))
       sort
       reverse))

(defn- match-n-of-a-kind
  [n]
  (fn [hand]
   (let [[[count value] & _] (ranked-groups hand)]
     (if (= n count)
       [value]))))


(defn- match-straight-impl [hand]
  (let [vals (sort (map :value hand))
        diffs (for [[a b] (partition 2 1 vals)]
                (- b a))]
    (if (every? #(= 1 %) diffs)
      [(last vals)])))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Matchers for actual poker hands, in ascending
;; order of value.

(defn match-high-card [hand]
  [(apply max (map :value hand))])

(def match-one-pair (match-n-of-a-kind 2))

(defn match-two-pair [hand]
  (let [[[c1 v1] [c2 v2] & _] (ranked-groups hand)]
    (if (= 2 c1 c2)
      [v1 v2])))

(def match-three-of-a-kind (match-n-of-a-kind 3))

(defn match-straight [hand]
  (let [ace-low (fn [{:keys [value suit]}]
                  {:suit suit :value (if (= value 14) 1 value)})]
    (or (match-straight-impl hand)
        (match-straight-impl (map ace-low hand)))))

(defn match-flush [hand]
  (if (apply = (map :suit hand))
    (match-high-card hand)))

(defn match-full-house [hand]
  (let [[[c1 v1] [c2 v2] & _] (ranked-groups hand)]
    (if (and (= 3 c1) (= 2 c2))
      [v1 v2])))

(def match-four-of-a-kind (match-n-of-a-kind 4))

(defn match-straight-flush [hand]
  (and (match-flush hand) (match-straight hand)))


(def
  ^{:doc "Assigns a numeric value to each hand in standard poker rules.
          Actual values are arbitrary - they are only meaningful relative
          to each other."}
  standard-poker
  [{:value 100 :matcher match-straight-flush}
   {:value 90  :matcher match-four-of-a-kind}
   {:value 80  :matcher match-full-house}
   {:value 70  :matcher match-flush}
   {:value 60  :matcher match-straight}
   {:value 50  :matcher match-three-of-a-kind}
   {:value 40  :matcher match-two-pair}
   {:value 30  :matcher match-one-pair}
   {:value 20  :matcher match-high-card}
   ])

(def
  ^{:dynamic true
    :doc "The current set of poker rules in use."}
  *game* standard-poker)

(defn value
  "Returns the value of the hand as a vector containing:
    1) The value associated with the type of hand (see *rankings*)
    2) A vector of card-values.
  For example, a full-house of fives over jacks would have the
  value [80 [5 11]], while a pair of threes would have [30 [3]].
  Values are represented this way to allow the natural sorting
  order of clojure vectors to properly rank hands."
  ([hand]
     (value hand *game*))
  ([hand game]
     ;; Sort game-rules in descending order of value. Try matching
     ;; rules to the hand one at a time until we get a non-nil result.
     (let [rules (->> *game* (sort-by :value) reverse)]
       (loop [[{:keys [value matcher]} & rules] rules]
         (if-let [card-value (matcher hand)]
           [value card-value]
           (recur rules))))))
