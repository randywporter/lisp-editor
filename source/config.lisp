(cl:in-package #:lisp-editor-base)

(defparameter *editor-config*
  '(("over-or-nv" . "overwrite")))

(defun get-config-val (key)
  (cdr (assoc key *editor-config*)))
