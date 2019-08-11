;; Generic sorting

(make sort
  (to (_ xs)
    (sort-by identity xs))
  (to (_ xs {reverse})          ;TODO design a better keyword-args scheme
    ;; TODO sort by 'negation' of key instead, but allowing for
    ;; non-numbers. Make up a negation-wrapper type?
    (reverse (sort-by identity xs))) 
  ;; ...
  )

(to (sort-by key<- sequence)

  (to (merge-sort seq)
    (begin splitting ((seq seq) (xs '()) (ys '()))
      (hm (unless seq.none?
            (splitting seq.rest ys (link seq.first xs)))
          (when xs.none?
            ys)
          (else
            (merge (merge-sort xs) (merge-sort ys))))))

  (to (merge xs ys)
    (hm (if xs.none? ys)
        (if ys.none? xs)
        (if (<= (key<- xs.first) (key<- ys.first))
            (link xs.first (merge xs.rest ys)))
        (else
            (link ys.first (merge xs ys.rest)))))

  (merge-sort sequence))

(export
  sort sort-by)
