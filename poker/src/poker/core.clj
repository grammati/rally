(ns poker.core
  (:require [clojure [string :as s]]))

(defn parse-card
  "Parse a string such as "
  [s]
  (if-let [[_ value suit] (re-matches #"([AKQJ2-9]|10)([cdhs])" s)]
    [(keyword suit)
     (or (get {"A" 14 "K" 13 "Q" 12 "J" 11} value)
         (Integer/parseInt value))]
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

