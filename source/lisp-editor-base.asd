(cl:in-package #:asdf-user)

(defsystem #:lisp-editor-base
  :depends-on (#:mcclim
	       #:cluffer
	       #:text.editing
               #:text.editor-buffer)
  
  :serial t
  :components
  ((:file "packages")
   (:file "config")
   (:file "text-bufs")
   (:file "commands")
   (:file "main"
          )))
