;; XXX comment
;; ~/git/superbench/superopt/circuitoptimizer.scm

(load "stdlib.scm")

(define (superopt truth-table max-gates)
  (let ((n-inputs (int-log2 ('count truth-table))))
    (find-circuits ('parse-int truth-table 2) n-inputs max-gates)))

;; XXX ugly and silly prelims

(define (int-log2 n)
  (if (is? n 1) 0
      (if (is? n 2) 1
          (if (is? n 4) 2
              (if (is? n 8) 3
                  (if (is? n 16) 4
                      (if (is? n 32) 5
                          (error "Bad argument" n))))))))

(define say
  (make
    ('run (a b c d)     (for-each display (list<- a b c d)))
    ('run (a b c d e f) (for-each display (list<- a b c d e f)))
    ))

;; OK now:

(define (pow2 n)
  ('<< 1 n))

(define (find-circuits wanted n-inputs max-gates)
  (let ((inputs (vector<-list (tabulate-inputs n-inputs)))
        (mask ('- (pow2 (pow2 n-inputs)) 1)))

    (let ((print-formula
           (lambda (L-input R-input)
             (let ((v-name (chain ('slice "ABCDEF" 0 n-inputs)
                                  ('slice "abcdefghijklmnopqrstuvwxyz"
                                          n-inputs))))
               (for-each (lambda (i)
                           (say (v-name ('+ i n-inputs))
                                " = "  (v-name (L-input i))
                                " ~& " (v-name (R-input i))
                                "; "))
                         (range<- ('count L-input))))
             (newline))))

      (letrec
          ((find-for-n
            (lambda (n-gates)
              (say "Trying " n-gates " gates..." #\newline)
              (let ((n-wires ('+ n-inputs n-gates))
                    (L-input (vector<-count n-gates #f))
                    (R-input (vector<-count n-gates #f))
                    (found?  (box<- #f)))
                (let ((wire (chain inputs L-input)))
                  (letrec
                      ((sweeping
                        (lambda (gate)
                          (for-each
                           (lambda (L)
                             (let ((L-wire (wire L)))
                               ('set! L-input gate L)
                               (for-each
                                (lambda (R)
                                  (let ((value (nand L-wire (wire R))))
                                    ('set! R-input gate R)
                                    ('set! wire ('+ n-inputs gate) value)
                                    (if (< ('+ gate 1) n-gates)
                                        (sweeping ('+ gate 1))
                                        (if (= wanted ('bit-and mask value))
                                            (begin
                                              ('set! found? #t)
                                              (print-formula L-input R-input))
                                            'pass))))
                                (range<- ('+ L 1)))))
                           (range<- ('+ n-inputs gate))))))
                    (sweeping 0)))
                (found?)))))
        (some? find-for-n (range<- 1 ('+ max-gates 1)))))))

(define (nand x y)
  ('bit-not ('bit-and x y)))

(define (tabulate-inputs n-inputs)
  ;; An inputs vector is a vector of n-inputs bitvectors. It holds all
  ;; possible input patterns 'transposed': that is, the kth test case
  ;; can be formed out of bit #k of each the list's elements, one
  ;; element per circuit input. Transposed is the most useful form
  ;; because we can compute all test cases in parallel with bitwise
  ;; operators.
  (if (= n-inputs 0)
      '()
      (let ((shift (pow2 ('- n-inputs 1))))
        (cons ('- (pow2 shift) 1)
              (map (lambda (iv) ('bit-or iv ('<< iv shift)))
                   (tabulate-inputs ('- n-inputs 1)))))))

;(superopt "0110" 3)
(superopt "0110" 4)