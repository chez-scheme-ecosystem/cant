(to (main)
  (let pid (spawn (given ()
                    (report (or #no "hey"))
                    (report "dud")
                    (! (me) 'not-this)
                    (? ('not-this (report "not this")))
                    (? (msg (report ['got msg])))
                    (report "dude")
                    (report (factorial 15)))))
  (report ['pid pid])
  ((eval '!) pid 'yoohoo)
  (report (apply factorial '(10)))
  (report (match pid
            ('42 'nope)
            ((: factorial) 'nope-nope)
            ((: pid) 'yep))))

(to (report x)
  (print [(me) x]))

(to (factorial n)
  (match n
    (0 1)
    (_ (let x (factorial (- n 1)))
       (* n x))))