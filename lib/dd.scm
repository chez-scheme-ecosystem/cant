;; Decision diagrams
;; Choice nodes select a branch by the value of a variable, from 0 to
;; #branches-1. Each variable is also represented by a number, its 'rank'
;; -- lower rank numbers are placed nearer the root of the tree.

(import (use 'memoize) memoize)

(let infinity 999999)  ;; N.B. we don't have floats yet

(make none)  ;; Disjoint from all the values of constants.

(to (constant<- value)
  (surely (not= value none) "That can't be a constant value -- it's reserved")
  (make
    (to _.rank            infinity)
    (to _.constant-value  value)
    (to (_ .evaluate env) value)
    (to (_ @nodes)        (nodes value))))

(to (all-same? xs)
  (= 1 xs.range.count))

(to (choice<- rank branches)
  (surely (< rank infinity))
  (make choice
    (to _.rank            rank)
    (to _.constant-value  none)
    (to (_ .evaluate env) ((branches (env rank)) .evaluate env))
    (to _.branches        branches)
    (to (_ @nodes)        (hm (if (all-same? nodes)
                                  nodes.first)
                              ;; TODO how to write this elegantly?
                              ;; Can't be this because it requires comparability of constants/none:
                              ;; ((<=> nodes.keys (each _.constant-value nodes))
                              ;; This is ok but wordier:
                              ;; ((for every ((`(,i ,node) nodes.items)) (= i node.constant-value))
                              ;; So for now we end up with:
                              (if (= (as-list nodes.keys) (each _.constant-value nodes))
                                  choice)
                              (else
                                  (memo-choice choice nodes))))))

(let memo-node (memoize choice<-))

(to (variable<- rank arity)
  (memo-node rank (each constant<- (range<- arity))))

(let memo-choice
  (memoize
   (on (node branches)
     (let top (min-by _.rank `(,node ,@branches)))
     (let rank top.rank)
     (make-node rank
                (for each ((c top.branches.keys))
                  ((subst rank c node) @(subst-each rank c branches)))))))

(to (make-node rank branches)
  (if (all-same? branches)
      branches.first
      (memo-node rank branches)))

(to (subst-each rank value nodes)
  (for each ((e nodes)) (subst rank value e)))

(to (subst rank value node)
  (be (rank .compare node.rank)
    (-1 node) ; N.B. node must be a constant, iff we arrived here (XXX why?)
    ( 0 (node.branches value))
    (+1 (make-node node.rank
                   (subst-each rank value node.branches)))))

(to (valid? node)
  (not (satisfy node 0)))

(to (satisfy node goal)
  (let env (map<-))
  (begin walking ((node node))
    (if (not= none node.constant-value)
        (and (= goal node.constant-value)
             env)
        (for foldr/lazy ((`(,value ,branch) node.branches.items)
                         (try-remaining-branches (: #no)))
          (if (`(,none ,goal) .find? branch.constant-value)
              (do (env .set! node.rank value)
                  (walking branch))
              (try-remaining-branches))))))

(export constant<- variable<- satisfy valid?)
