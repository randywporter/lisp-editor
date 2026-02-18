(in-package "lisp-editor")


;; load other systems here

(clim:define-application-frame lisp-editor-frame () ()
  (:menu-bar nil)
  (:panes
 ;  (floating-window (make-pane 'application-pane
 ;                              :width :compute
;                               :height :compute
  ; ))
  
   (screen :application
           :display-time t
           :text-style (make-text-style :sans-serif :roman :normal))
   ))


(defun main-app ()
  (run-frame-top-level (make-application-frame 'lisp-editor-frame)))
;; this main function looks bad but it's simply meant to call a function of MCCLIM, and thats it
