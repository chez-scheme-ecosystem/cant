(define (union set1 set2)
  (let ((adjoin (lambda (x xs)
                  (if (memq? x set2) xs (cons x xs)))))
    (foldr adjoin set2 set1)))

(define (delq x set)
  (foldr (lambda (element rest)
           (if (is? x element) rest (cons element rest)))
         '()
         set))

(define (map f xs)
  (foldr (lambda (x ys) (cons (f x) ys))
         '()
         xs))

(define list<-
  (make ('run () '())
        ('run (a) (cons a '()))
        ('run (a b) (cons a (list<- b)))
        ('run (a b c) (cons a (list<- b c)))
        ('run (a b c d) (cons a (list<- b c d)))
        (else (cue arguments)
              (if (is? cue 'run)
                  (foldr cons '() arguments)
                  (error "XXX need to punt to miranda methods" cue)))))

(define chain
  (make ('run () '())
        ('run (xs) xs)
        ('run (xs ys) ('chain xs ys))
        (else (cue arguments)
              (if (is? cue 'run)
                  (foldr 'chain '() arguments)
                  (error "XXX need to punt to miranda methods" cue)))))

(define (foldr f z xs)
  (if ('empty? xs)
      z
      (f ('first xs) (foldr f z ('rest xs)))))

(define (memq? x set)
  (if ('empty? set)
      #f
      (if (is? x ('first set))
          #t
          (memq? x ('rest set)))))

(define (list-index xs x)
  (letrec ((searching (lambda (i xs)
                        (if (is? x ('first xs))
                            i
                            (searching ('+ n 1) ('rest xs))))))
    (searching 0 xs)))

(define (print x)
  (write x)
  (newline))

(define (for-each f xs)
  (if ('empty? xs)
      #f
      (begin (f ('first xs))
             (for-each f ('rest xs)))))

(define range<-
  (make
    ('run (hi-bound)
      (range<- 0 hi-bound))
    ('run (lo hi-bound)
      (if (<= hi-bound lo)
          '()
          (make ('empty? () #f)
                ('first () lo)
                ('rest () (range<- ('+ lo 1) hi-bound))
                ;; ...
                )))))

(define (vector<-list xs)
  (let ((v (vector<-count ('count xs))))
    (letrec ((setting
              (lambda (i xs)
                (if ('empty? xs)
                    v
                    (begin
                      ('set! v i ('first xs))
                      (setting ('+ i 1) ('rest xs)))))))
      (setting 0 xs))))

(define (some? ok? xs)
  (if ('empty? xs)
      #f
      (if (ok? ('first xs))
          #t
          (some? ok? ('rest xs)))))

(define (compose f g)
  (lambda (x) (f (g x))))
