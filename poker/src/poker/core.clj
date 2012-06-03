(ns poker.core
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


(def
  ^{:dynamic true
    :doc "Assigns a numeric value to each poker hand.
          Actual values are arbitrary - they are only meaningful relative
          to each other."}
  *rankings*
  {:straight-flush 100
   :four-of-a-kind 90
   :full-house 80
   :flush 70
   :straight 60
   :three-of-a-kind 50
   :two-pair 40
   :one-pair 30
   :high-card 20
   })


(defn ranked-groups
  "Return ranked list of pairs, triples, etc.
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
  [n hand]
  (->> hand
       ranked-groups
       (filter (fn [[count val]] (= n count)))))


(defn- match-straight-impl [hand]
  (let [vals (sort (map :value hand))
        diffs (for [[a b] (partition 2 1 vals)]
                (- b a))]
    (if (every? #(= 1 %) diffs)
      [(*rankings* :straight) (last vals)])))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Matchers for actual poker hands, in ascending
;; order of value.

(defn match-high-card [hand]
  ())

(defn match-pair [hand]
  nil)

(defn match-two-pair [hand]
  nil)

(defn match-three-of-a-kind [hand]
  (if-let [[_ v] (->> hand
                      (match-n-of-a-kind 3)
                      first)]
    [(*rankings* :three-of-a-kind) v]))

(defn match-straight [hand]
  (let [ace-low (fn [{:keys [value suit]}]
                  {:suit suit :value (if (= value 14) 1 value)})]
    (or (match-straight-impl hand)
        (match-straight-impl (map ace-low hand)))))

(defn match-flush [hand]
  (apply = (map :suit hand)))

(defn match-full-house [hand]
  nil)

(defn match-four-of-a-kind [hand]
  (if-let [[_ v] (->> hand
                      (match-n-of-a-kind 4)
                      first)]
    [(*rankings* :four-of-a-kind) [v]]))

(defn match-straight-flush [hand]
  (if-let [[_ high-card] (and (match-flush hand) (match-straight hand))]
    [(*rankings* :straight-flush) high-card]))


(defn value
  "Returns the value of the hand as a vector containing:
    1) The value associated with the type of hand (see *rankings*)
    2) A vector of card-values.
  For example, a full-house of fives over jacks would have the
  value [80 [5 11]], while a pair of threes would have [30 [3]].
  Values are represented this way to allow the natural sorting
  order of clojure vectors to properly rank hands."
  [hand]
  (let [matchers [match-straight-flush
                  match-four-of-a-kind
                  match-full-house
                  match-flush
                  match-straight
                  match-three-of-a-kind
                  match-two-pair
                  match-pair
                  match-high-card
                  ]
        matches (remove nil? (for [m matchers] (m hand)))]
    (first matches)))
