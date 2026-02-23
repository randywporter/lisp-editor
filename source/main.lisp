(cl:in-package #:lisp-editor-base)

;; FOR NOW, NOT MORE THAN ONE FILE CAN EXIST AT A TIME (WAITING ON BUFFER IMPLEMENTATIONS)

(defclass editor-view (textual-view)
  ())

(defparameter +editor-view+ (make-instance 'editor-view))

(defparameter *editor-text-size* 20)

(defparameter *editor-text-style* (make-text-style :serif :roman *editor-text-size*))

(define-application-frame superapp ()
  ()
  (:menu-bar my-menubar)
  (:pointer-documentation t)
  (:panes
   (my-text-editor :text-editor
                   :value ""
                   :nlines 10
                   :ncolumns 40)
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
  (my-make-com-tab 'my-view-menu nil
                   '(("Zoom In" :command com-zoom-in)
                     ("Zoom Out" :command com-zoom-out)))
  (my-make-com-tab 'my-buffer-menu nil
                   '(("List Buffers" :command com-list-buffers)))
    (my-make-com-tab 'my-menubar nil
     '(("File" :menu my-file-menu)
       ("Edit" :menu  my-edit-menu)
       ("View" :menu my-view-menu)
       ("Buffers" :menu my-buffer-menu))))

(defun lisp-editor:app-main ()
  (init-commands)
  (make-menu-bar)
  (init-buffers)
  (run-frame-top-level (make-application-frame 'superapp)))

