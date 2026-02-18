;; lisp-editor project

(defsystem "lisp-editor"
  :version "0.1"
  :author "Randolph W. Porter Jr."
  :license "GPL-3.0"
  :depends-on ("mcclim"
               "cluffer"
               "text.editing"
               "alexandria")
  
  :components ((:module "source"
                :serial t
                :components
                        ((:file main))))
  :description "project for EYW III by Randolph W. Porter Jr."
 )
