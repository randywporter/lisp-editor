(cl:in-package #:common-lisp-user)

(defpackage #:lisp-editor
  (:use)
  (:export
   #:app-main))

(defpackage #:lisp-editor-base
  (:use #:common-lisp #:clim)
  (:export))
