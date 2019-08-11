;; Parsing

(to (seq-parse lexps)
  (seq-parsing lexps lexps))

(to (exp-parse lexp)
  (exp-parsing lexp lexp))

(to (seq-parsing lexps srcs)
  (may lexps
    (be '((the-environment))  {the-env})   ;TODO not meant as part of the actual language
    (be `(,e)                 (exp-parsing e srcs.first))
    (be `((let ,p ,e) ,@es)   (exp-parsing `(([,p] ,@es) ,e) `(do ,@srcs)))
    (be `((to ,@_) ,@_)       (def-parsing lexps.first lexps.rest srcs))
    ))

(to (def-parsing def seq srcs)
  (may def
    (be `(to (,(? symbol? name) ,@params) ,@body)
      (let ps (array<-list params))
      (seq-parsing `((let ,name (,ps ,@body))
                     ,@seq)
                   srcs))))

(to (exp-parsing lexp src)
  (may lexp
    (be (? symbol?)           {var lexp})
    (be (? self-evaluating?)  {const lexp})
    (be `',c                  {const c})
    (be `(do ,@es)            (seq-parsing es (src-do-parts src)))
    (be `(,(? array?) ,@_)    (lambda-parsing lexp src))
    (be `(,operator ,e)       {app (exp-parse operator) ;TODO try to pass along (src 0) pre-expansion 
                                   (exp-parse e)
                                   src})
    (be `(,operator ,e1 ,@es) (exp-parse `((,operator ,e1) ,@es))))) ;TODO ditto

(to (src-do-parts src)
  (may src
    (be `(do ,@es) es)
    (else (error "I don't know how to unparse this sequence" src))))

(to (lambda-parsing `(,[(? symbol? v) @vs] ,@body) src)
  ;; TODO adjust src in the curried case
  (let parsed-body (if vs.none?
                       (seq-parse body)
                       (exp-parse `(,(array<-list vs) ,@body))))
  {lam v parsed-body src})

(export seq-parse exp-parse)
