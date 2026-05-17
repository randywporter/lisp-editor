(cl:in-package #:asdf-user)

(defsystem #:lisp-editor-base
  :depends-on (#:mcclim
               #:text.editor-buffer
	       #:text.editing)
  
  :serial t
  :components
  ((:file "packages")
   (:file "main")))
