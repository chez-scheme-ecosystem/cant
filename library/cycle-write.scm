;; Write structures with cyclic references cut short.
;; E.g.:
;; > (let a (box<- 42))
;; > (a .^= a)
;; > (cycle-write a)
;; #1=<box #1>

;; cycle-sink<- could be generalized to support a stream of writes on
;; separate occasions, with the id #s keeping the same meaning. It
;; seems it'd be trickier in that an object could get flushed into an
;; output before its second appearance, so in that output it would not
;; be given an ID -- it wouldn't get an ID until it appeared twice in
;; the *same* flushed chunk of output. Perhaps not a big deal, but
;; this wrinkle and the faceting below are why I'm not bothering to
;; engineer a general cycle-sink object. TODO revisit this

;; There's also a matter of POLA-separating the flushing from the
;; writing. I bothered to do that here, but maybe that's kind of
;; gilding the lily, when string-sinks aren't faceted in the same way,
;; and neither is _.close.

;; TODO better names?

(to (cycle-write thing @(optional sink-arg))
  (let (_ cycle-sink flush-to) (cycle-sink<-))
  (cycle-sink .print thing)             ;TODO name it .write
  (flush-to (or sink-arg out))
  flush-to.close)

(to (cycle-sink<-)

  ;; The buffer accumulates a sequence of procedures to send the final
  ;; formatted text to the destination sink.
  ;; TODO I think this logic could be simpler
  ;;   e.g. use a flexarray of (either id thing) instead of procedures
  (let buffer (flexarray<-))

  (make flush-to

    (to (_ sink)
      (hey sink @buffer.values)
      buffer.clear!)

    (to _.close
      buffer.clear!
      tags.clear!))

  ;; The tags map has a tag for each object the cycle-sink visits. The
  ;; tag is 0 after the first visit; then, on the second and thereafter,
  ;; a positive integer identifying the object.
  
  ;; TODO exclude known-to-be-acyclic types from the tags map

  (let tags (map<-))
  (let id-counter (box<- 0))    ; The highest unique id needed so far.

  (make cycle-sink

    (to (and (_ .display atom) message)
      (buffer .push! message))

    (to (and (_ .write-u8 u8) message)
      (buffer .push! message))

    (to (_ .print thing)
      (if (or (symbol? thing) (self-evaluating? thing))  ;; TODO skip other atom types
          (thing .selfie cycle-sink)
          (may (tags .get thing)
            (be #no
              ;; First visit.
              (tags .set! thing 0)
              (buffer .push! (on (sink)
                               ;;TODO avoid this extra lookup, via
                               ;;bookkeeping work on the second visit
                               (let id (tags thing))
                               (unless (= 0 id)
                                 (format .to-sink sink "#~w=" id))))
              (thing .selfie cycle-sink))
            (be tag
              (let id (may tag
                        (be 0   ;; Second visit. Give thing a fresh id:
                          (hey (id-counter .update _.+)
                               (-> (tags .set! thing it))))
                        (else   ;; Thereafter, just use that one:
                          tag)))
              (buffer .push! (on (sink)
                               (format .to-sink sink "#~w" id)))))))
  
    (to _.close
      tags.clear!))

  (_ cycle-sink flush-to))

(export cycle-write)
