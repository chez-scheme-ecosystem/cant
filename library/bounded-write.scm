;; Write `thing` into a string, but give up and truncate if it
;; overflows `width`.
(to (write-to-bounded-string thing width)
  (let buffer (flexarray<-))
  (let total (box<- 0)) ;; Kept equal to (tally buffer.values), i.e. sum of lengths
  (to (output)
    (let s ("" .join buffer.values))
    ;; TODO make it unambiguous whether it's truncated, somehow
    (if (< total.^ width)
        s
        (chain (s .slice 0 (- width 2)) "..")))
  (with-ejector
   (on (ejector)
     (let ss (string-sink<-))
     (to (cut-off)
       (buffer .push! ss.output-string) ;TODO worth checking to skip if output-string empty?
       (total .^= (+ total.^ buffer.last.count))
       (when (<= width total.^)
         (ejector .eject (output))))
     (make bounded-sink
       (to (_ .display a)   (ss .display a)   (cut-off))
       (to (_ .write-u8 u8) (ss .write-u8 u8) (cut-off))
       (to (_ .write a)     (a .selfie bounded-sink))
       (to _.close          ss.close))
     (bounded-sink .write thing)
     (output))))
       
(export write-to-bounded-string)
