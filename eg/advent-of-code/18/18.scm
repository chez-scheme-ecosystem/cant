;; (Use run.scm to run this.)

(import (use 'grid-2d)
  grid-2d<-)

(let input (with-input-file _.read-lines data-file))

(let width input.first.count)
(let height input.count)
(let bottom-right (_ width.- height.-))

(let input-grid (grid-2d<- (_ 0 0) bottom-right
                           {map (on ((_ x y)) ((input y) x))}))

(to (show grid)
  (grid .show (on (row)
                (each! display row)
                (newline)))
  (newline))

(show input-grid)
;; open ground (.), trees (|), or a lumberyard (#)


(display "\nPart 1\n")

(to (part-1)
  (result-code (for foldl ((grid input-grid) (_ (1 .to 10)))
                 (show grid)
                 (step grid))))

(to (result-code grid)
  (let bag (bag<- grid.values))
  (* (bag #\#) (bag #\|)))

(to (step grid)
  (grid-2d<- (_ 0 0) bottom-right {map (update grid)}))

(to ((update grid) p)
  ;; Somewhat clumsy code for 'speed'
  (let wood (box<- 0))
  (let lumber (box<- 0))
  (to (count-at x1 y1)
    (may (grid .get (_ x1 y1))
      (be #\.)
      (be #\| (wood .update _.+))
      (be #\# (lumber .update _.+))
      (else)))
  (let (_ x y) p)
  (count-at x.- y.-)
  (count-at x   y.-)
  (count-at x.+ y.-)
  (count-at x.- y)
  ;; leaving out (count-at x y)
  (count-at x.+ y)
  (count-at x.- y.+)
  (count-at x   y.+)
  (count-at x.+ y.+)

  (may (grid p)
    (be #\. (if (<= 3 wood.^) #\| #\.))
    (be #\| (if (<= 3 lumber.^) #\# #\|))
    (be #\# (if (and (<= 1 lumber.^)
                     (<= 1 wood.^))
                #\#
                #\.))))

(format "~w\n" (part-1))


(display "\nPart 2\n")

(to (part-2)
  (begin stepping ((t 0) (grid input-grid))
    (let bag (bag<- grid.values))
    (format "After ~w minutes: ~w trees, ~w lumber\n" t (bag #\|) (bag #\#))
    (stepping t.+ (step grid))))

(format "~w\n" (part-2))
