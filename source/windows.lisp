(cl:in-package #:lisp-editor-base)

(defclass screen-pane (application-pane)
  (:default-initargs :background +gray90+)
  )

(defclass window ()
  ((buffer :accessor get-window-buffer
           :initarg :buffer
           :initform (create-new-buffer *buffers*))
   (pos :accessor get-window-pos
        :initarg :pos
        :initform '(0 0))
   (size :accessor get-window-size
         :initarg :size
         :initform '(10 10))))

(defun draw-window (window screen)
  (let* ((name (get-window-filestring window))
         (str (get-window-string window))
         (pos (get-window-pos window))
         (size (get-window-size window)))
    ))

(defun get-window-filestring (window)
  (namestring (get-buffer-file (get-window-buffer window))))


