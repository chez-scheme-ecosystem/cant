;; More primitive functions. I forget just why these aren't grouped
;; with nonmeta-primitives.scm -- maybe they should be?

(library (player primitives)
(export char-compare number-compare string-compare hashmap-place
        as-link box<- vector-append subvector copy-range! vector-move!
        maybe-macroexpand-expr maybe-macroexpand-patt prim-halp-log
        prim-nano-now prim-nanosleep prim-*/mod prim-string-maps? 
        prim-substring prim-vector-maps? prim-read-all prim-display
        )
(import (chezscheme) (player util) (player equality) (player parse))

;; Compare primitives

(define (char-compare x y)
  (and (char? x) (char? y)      ;; XXX raise an error instead?
       (cond ((char<? x y) -1)
             ((char=? x y)  0)
             (else         +1))))

(define (number-compare x y)
  (and (number? x) (number? y)      ;; XXX raise an error instead?
       (cond ((< x y) -1)
             ((= x y)  0)
             (else    +1))))

(define (string-compare x y)
  (and (string? x) (string? y)      ;; XXX raise an error instead?
       (cond ((string<? x y) -1)
             ((string=? x y)  0)
             (else           +1))))


;; Misc primitives

(define (hashmap-place key keys none deleted)
  (let* ((m (vector-length keys))
         (mask (- m 1)))
    (let walking ((i0 (hash key))
                  (q 0)      ;iteration number for quadratic probing, d(q) = 0.5(q + q*q)
                  (slot #f)) ;if integer, then where to put the key if missing
      (let* ((i (logand mask i0))
             (k (vector-ref keys i)))
        (cond ((eq? k none)
               (term<- 'missing-at (or slot i)))
              ((cant=? k key)
               (term<- 'at i))
              ((= q m)
               (if slot
                   (term<- 'missing-at slot)
                   (error 'hashmap-place "Can't happen")))
              (else
               (walking (+ i (+ q 1))
                        (+ q 1)
                        (or slot (and (eq? k deleted) i)))))))))

(define (as-link x)
  (and (pair? x)
       (term<- 'link (car x) (cdr x))))

(define box<- box)
      
(define (vector-append v1 v2)
  (let ((n1 (vector-length v1))
        (n2 (vector-length v2)))
    (let ((result (make-vector (+ n1 n2))))
      (copy-range! result  0 v1 0 n1)
      (copy-range! result n1 v2 0 n2)
      result)))

(define (subvector v lo hi)
  (let ((n (max 0 (- hi lo))))
    (let ((result (make-vector n)))
      (copy-range! result 0 v lo n)
      result)))
  
(define (copy-range! dest d source s n)
  (do ((i (- n 1) (- i 1)))
      ((< i 0))
    (vector-set! dest (+ d i)
                 (vector-ref source (+ s i)))))

;; TODO reconcile with copy-range!
;; TODO range-check first
;; TODO no-op if in range and (dest,d) == (src,lo)
(define (vector-move! dest d source lo bound)
  (let ((diff (- d lo)))
    (if (<= d lo)
        (do ((i lo (+ i 1)))
            ((<= bound i))
          (vector-set! dest (+ i diff)
                       (vector-ref source i)))
        (do ((i (- bound 1) (- i 1)))
            ((< i lo))
          (vector-set! dest (+ i diff)
                       (vector-ref source i))))))

(define (maybe-macroexpand-expr e)
  (cond ((and (pair? e) (look-up-macro (car e)))
         => (lambda (expander)
              (term<- 'ok (expander e))))
        (else #f)))

(define (maybe-macroexpand-patt e)
  (cond ((and (pair? e) (look-up-pat-macro (car e)))
         => (lambda (expander)
              (term<- 'ok (expander e))))
        (else #f)))

(define (prim-halp-log start end result)
  (format #t "Halp ~w..~w: ~w\n" start end result) ;TODO actual format
  result)

(define (prim-nano-now)
  (let ((t (current-time)))
    (+ (* 1000000000 (time-second t))
       (time-nanosecond t))))

(define (prim-nanosleep nsec)
  ;; XXX untested
  (let* ((n (modulo nsec 1000000000))
         (nsec (- nsec n)))
    (sleep (make-time 'time-duration n (quotient nsec 1000000000)))))

(define (prim-*/mod n1 n2 d)
  (call-with-values (lambda () (div-and-mod (* n1 n2) d))
    (lambda (d m) (make-term '~ (list d m))))) ;TODO define tuple stuff in utils.scm

(define (prim-string-maps? me i)
  (and (integer? i)
       (< -1 i (string-length me))))

(define (prim-substring me lo bound)
  (if (< lo (string-length me))
      (substring me lo (min bound (string-length me)))
      ""))

(define (prim-vector-maps? me i)
  (and (integer? i)
       (< -1 i (vector-length me))))

(define (prim-read-all port)
  (let reading ((cs '()))
    (let ((c (read-char port)))
      (if (eof-object? c)
          (list->string (reverse cs))
          (reading (cons c cs))))))

(define (prim-display x sink)
  (cond ((or (char? x) (string? x) (symbol? x) (number? x))
         (display x sink)
         #t)
        (else #f)))

)
