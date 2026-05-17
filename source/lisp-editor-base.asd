(cl:in-package #:asdf-user)

(defsystem #:lisp-editor-base
  :depends-on (#:mcclim
	       #:cluffer
	       #:text.editing)
  
  :serial t
  :components
  ((:file "packages")
   (:file "main")))
