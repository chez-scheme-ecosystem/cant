;; Norvig's (simpler) spelling corrector
;; http://norvig.com/spell-correct.html
;; TODO: Try imitating https://en.wikibooks.org/wiki/Clojure_Programming/Examples/Norvig_Spelling_Corrector

;; Try to find a word in `lexicon` that's similar to `word`.
;; Prefer the most common word with the fewest edits.
(to (correct word)
  (or (pick-known-word `(,word))
      (pick-known-word (let neighbors1 (edits1 word)))
      (pick-known-word (gather edits1 neighbors1))
      word))

(to (pick-known-word candidates)
  (let best (max-by lexicon candidates))
  (and (lexicon .maps? best) best))

(to (edits1 word)
  (let splits     (for each ((i (0 .to word.count)))
                    (_ (word .slice 0 i)
                       (word .slice i))))
  (let inserts    (for gather (((_ a b) splits))
                    (for each ((c alphabet))
                      (chain a c b))))
  (let del-splits (for those (((_ a b) splits))
                    b.some?))
  (let deletes    (for each (((_ a b) del-splits))
                    (chain a (b .slice 1))))
  (let replaces   (for gather (((_ a b) del-splits))
                    (for each ((c alphabet))
                      (chain a c (b .slice 1)))))
  (let swaps      (for yeahs (((_ a b) del-splits))
                    (and (< 1 b.count)
                         (chain a (string<- (b 1) (b 0)) (b .slice 2)))))
  (uniquify (chain inserts deletes replaces swaps)))

(to (uniquify xs)
  xs.range.keys)

(let alphabet (each string<- (#\a .to #\z)))

(to (words<-string string)
  ;;  (re:findall "[a-z]+" string.lowercase))  ;TODO
  string.lowercase.split)

(let lexicon
  (bag<- (words<-string (with-input-file _.read-all "eg/text/spelling.train.text"))))

(to (main _)
  (each! (compose print correct) (words<-string "a lowsy spelur zzz")))
