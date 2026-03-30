(cl:in-package #:lisp-editor-base)


;; these might not get used...
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

;; coming with great inspiration from clim-fig and draggable-graph
;; in the mcclim source
(defclass move-event ()
  ((record :initarg :record :reader record)
   (delta-x :initarg :delta-x :reader delta-x :initform 0)
   (delta-y :initarg :delta-y :reader delta-y :initform 0))
  (:default-initargs
   :record (error "move-event needs a record")))

(defclass window ()
  ((buffer :accessor window-buffer
           :initarg :buffer)
   (pos :accessor window-pos
        :initarg :pos
        :initform '(0 0))
   (size :accessor window-size
         :initarg :size
         :initform '(10 10))
   (active :accessor window-active
           :initarg :active
           :initform nil)
   (dragging :accessor window-dragging
             :initform nil)))

(defun make-window-active (window)
  (setq (window-active window) t))



;; HARD functional abstraction here, still figuring out
;; low level details, but the idea here is solid
(defun draw-window (frame pane)
  (let* ((window screen-window)
         (name (window-filestring window))
         (str (window-string window))
         (pos (window-pos window))
         (size (window-size window)))
    (clear-or-reset-canvas)
    (draw-plain-window pos size)
    (draw-window-name pos name)
    (draw-window-close-button pos size window)
    (draw-window-string pos size str)
    ))

(defun window-filestring (window)
  (namestring (buffer-file (window-buffer window))))


