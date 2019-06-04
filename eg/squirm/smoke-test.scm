(to (main)
  (let pid (spawn (given ()
                    (report "hey")
                    (report "dud")
                    (? (msg (report ['got msg])))
                    (report "dude")
                    (report (fact 15)))))
  (report ['pid pid])
  (! pid 'yoohoo)
  (report (fact 10)))

(to (report x)
  (print [(me) x]))

(to (fact n)
  (if (= n 0)
      1
      (do (let x (fact (- n 1)))
          (* n x))))
