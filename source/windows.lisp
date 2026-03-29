(cl:in-package #:lisp-editor-base)

(defmacro init-screen-params ()
  `(progn
     (defparameter *width* 500)
     (defparameter *height* 700)
     (defparameter *screen-bounds* (make-rectangle* 0 0 *width* *height*))
     )
  )

(defclass screen-pane (application-pane)
  (:default-initargs :background +gray90+
   (windows :accessor screen-windows
            :initarg '()))
  )

(defclass window ()
  ((buffer :accessor window-buffer
           :initarg :buffer)
   (pos :accessor window-pos
        :initarg :pos
        :initform '(0 0))
   (size :accessor window-size
         :initarg :size
         :initform '(10 10))))

(defun draw-window (frame pane)
  (let* ((window screen-window)
         (name (window-filestring window))
         (str (window-string window))
         (pos (window-pos window))
         (size (window-size window)))
    ))

(defun get-window-filestring (window)
  (namestring (buffer-file (window-buffer window))))


