(cl:in-package #:asdf-user)

(defsystem #:lisp-editor-base
  :depends-on (#:mcclim
               #:text.editor-buffer
	       #:text.editing)
  
  :serial t
  :components
  ((:file "packages")
   (:file "config")
   (:file "text-bufs")
   (:file "commands")
   (:file "windows")
   (:file "main")))
