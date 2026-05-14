(cl:in-package #:common-lisp-user)

(defpackage #:lisp-editor
  (:use)
  (:export
   #:app-main))

(defpackage #:lisp-editor-base
  (:use #:common-lisp #:clim)
  (:export
   #:my-make-command
   #:draw-window
   #:translate-point
   #:topbar-draggable-window
   #:button-close-window
   #:search-for-parent-window))

