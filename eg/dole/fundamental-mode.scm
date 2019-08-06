;; Hi, I'd like a buffer with all the usuals, please.

(import (use "eg/dole/buffer")  buffer<-)
(import (use "eg/dole/key-map") ctrl)

(let C ctrl)

(to (fundamental-mode<-)
  (let buffer (buffer<-))

  (to (backward-char _) (buffer .move-char -1))
  (to (forward-char _)  (buffer .move-char  1))

  (let bindings
    `((,(C #\B)  ,backward-char)
      (left      ,backward-char)
      (,(C #\F)  ,forward-char)
      (right     ,forward-char)
      (,(C #\N)  ,(-> (buffer .next-line)))
      (down      ,(-> (buffer .next-line)))
      (,(C #\P)  ,(-> (buffer .previous-line)))
      (up        ,(-> (buffer .previous-line)))
      (,(C #\Q)  exit)
      (,(C #\M)  ,(-> (buffer .insert "\n")))
      (backspace ,(-> (buffer .backward-delete-char)))
      (del       ,(-> (buffer .forward-delete-char)))
      (end       ,(-> (buffer .end-of-line)))
      (home      ,(-> (buffer .beginning-of-line)))
      (pg-up     ,(-> (buffer .previous-page)))
      (pg-dn     ,(-> (buffer .next-page)))))

  (for each! ((`(,key ,command) bindings)) ;TODO should be a key-map method
    (buffer.key-map .set! key command))
      
  buffer)

(export fundamental-mode<-)
