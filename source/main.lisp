(cl:in-package #:lisp-editor-base)

;; FOR NOW, NOT MORE THAN ONE FILE CAN EXIST AT A TIME (WAITING ON BUFFER IMPLEMENTATIONS)

(defclass editor-view (textual-view)
  ())

(defparameter +editor-view+ (make-instance 'editor-view))

(defparameter *default-text-style* (make-text-style :serif :roman 20)
  )

(define-application-frame superapp ()
  ((my-var 5))
  (:menu-bar my-menubar)
  (:pointer-documentation t)
  (:panes
   (screen (make-pane 'screen-pane
                      :width :compute
                      :height :compute
                      :display-function 'draw-screen
                      :display-time t))
   (my-int :interactor
        :width 400
        :height 100)
   )
  (:layouts
   (default my-text-editor my-int)
   )
  )

(defmacro my-make-com-tab (name error-action commands-list)
  `(make-command-table ,name
		       :errorp ,error-action
		       :menu ,commands-list))

(defun make-menu-bar ()
  (my-make-com-tab 'my-file-menu nil
                   '(("New" :command com-new)
                     ("Open" :command com-open)
                     ("Save" :command com-save)
                     ("Close" :command com-close)
                     ("Quit" :command com-quit)))
  (my-make-com-tab 'my-edit-menu nil
                   '(("Copy" :command com-copy)
                     ("Paste" :command com-paste)
                     ("Undo" :command com-undo)
                     ("Redo" :command com-redo)))
  (my-make-com-tab 'my-buffer-menu nil
                   '(("List Buffers" :command com-list-buffers)))
    (my-make-com-tab 'my-menubar nil
     '(("File" :menu my-file-menu)
       ("Edit" :menu  my-edit-menu)
       ("Buffers" :menu my-buffer-menu))))

;;; might not implement view
;(my-make-com-tab 'my-view-menu nil
;      '(("Zoom in" :command com-zoom-in)
;        ("Zoom out" :command com-zoom-out)))
;
(defun lisp-editor:app-main ()
  (init-commands)
  (make-menu-bar)
  (init-buffers)
  (run-frame-top-level (make-application-frame 'superapp)))

