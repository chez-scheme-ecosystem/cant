;; Elementary cellular automata

(to (snil if-link if-nil) if-nil)
(to (slink h t if-link if-nil) (if-link h t))

(to (each! f)
  (fix ([walking slist]
        (slist ([h t]
                (let _ (f h))
                (walking t))
               'ok))))

(to (show bits)                         ;TODO: center
  (let _ (each! ([bit] (display (if bit "*" "-")))
                bits))
  (display "\n"))

(to (update rule bits)
  (fix ([neighing a b bits]
        (bits ([first rest]
               (slink (rule a b first)
                      (neighing b first rest)))
              (slink (rule a b no) (slink (rule b no no) snil))))
       no
       no
       bits))

(to (run rule start-bits n-steps)
  (to (step bits)
    (let _ (show bits))
    (update rule bits))
  (show (n-steps step start-bits)))

;; rule 110: 0110 1110
(to (rule-110 a b c)
  (if a
      (if b (not c) c)
      (or b c)))

(run rule-110 (slink yes snil) (church<-count 10))
