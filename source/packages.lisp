(in-package #:common-lisp-user)

(defpackage #:lisp-editor
  (:use :clim :clim-lisp)
  (:export
   #:run-editor))

(defpackage #:lisp-editor-base
  (:use :clim :clim-lisp)
  (:export))
