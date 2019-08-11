;; (Use run.scm to run this.)

(let input (take (with-input-file read data-file)
                 (-> it.name.values)))

(to (reacts? c d)
  (and (= c.uppercase d.uppercase)
       (not= c d)))

(to (reduce polymer)
  (for foldr ((c polymer) (r '()))
    (if (and (not r.none?) (reacts? c r.first))
        r.rest
        `(,c ,@r))))

(let reduced (reduce input))
(format "part 1 ~w\n" reduced.count)

(to (scour atom)
  (for those ((c reduced))
    (not= atom c.uppercase)))

(to (try atom)
  (_.count (reduce (scour atom))))

(format "part 2 ~w\n" (min @(each try (#\A .to #\Z))))
