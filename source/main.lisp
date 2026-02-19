(cl:in-package #:lisp-editor-base)

(define-application-frame superapp ()
  ()
  (:panes
   (window :text-editor
                    :width 10
                    :height 12)
   )
  (:layouts
   (default window))
  )

(defun lisp-editor:app-main ()
  (run-frame-top-level (make-application-frame 'superapp)))

