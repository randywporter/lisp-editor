(cl:in-package #:lisp-editor-base)

(defclass screen-pane (clim:application-pane)
  ((windows :accessor screen-windows
            :initform '()))
  (:default-initargs :background clim:+gray90+))

;; deprecated
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
        :initform (clim:make-point 0 0))
   (size :accessor window-size
         :initarg :size
         :initform  (clim:make-point 10 10))
   (topbar :accessor window-topbar
           :initarg :topbar
           :initform (make-instance 'topbar-draggable-window))
   (close-button :accessor window-close-button
                 :initarg :close-button
                 :initform (make-instance button-close-window))
   (text-field :accessor window-text-field
               :initarg :text-button
               :initform AAAA)))


(defclass topbar-draggable-window (clim:standard-bounding-rectangle)
  ()
  (:documentation "class for the top bar of a window to drag")
  )

(defclass button-close-window (clim:standard-bounding-rectangle)
  ()
  (:documentation "class for the button that closes windows")
  )


(defun get-pointer-position (pane)
  (multiple-value-bind (x y) (clim:stream-pointer-position pane)
    (clim:make-point x y)))

;; trans is a faux point to translate the original point by
(defun translate-point (org trans)
  (clim:make-point (+ (clim:point-x org) (clim:point-x trans))
                   (+ (clim:point-y org) (clim:point-y trans))))

;; this draws one window, actual drawing function should call this over
;; windows in memory
(defun draw-window (app-frame drawing-pane window &optional init-pos)
    (let* ((name (window-filestring window))
           (str (window-string window))
           (pos (if init-pos
                    init-pos
                    (window-pos window)))
           (size (if init-pos
                     (lisp-editor-base:translate-point (window-size window) init-pos)
                     (window-size window))))
      (draw-plain-window pos size drawing-pane)
      (draw-window-name pos size name drawing-pane)
      (draw-window-close-button pos size window)
      (draw-window-string pos size str window)))

(defun draw-plain-window (pos size pane)
  (clim:draw-rectangle pane pos size :filled t :line-thickness 3))

(defun draw-window-name (pos size name pane)
  (let ((x (clim:point-x pos))
        (y (clim:point-y pos))
        (tx (clim:point-x size))
        (ty (+ 10 (clim:point-y pos))))
    (clim:draw-rectangle* pane x y tx ty
                          :filled t
                          :line-thickness 1
                          :ink clim:+dark-gray+)
    (clim:draw-text* pane name x y :toward-x tx :toward-y ty)))


(defun draw-window-string (pos size sequence window)
  "pos is top left xy, size is bottom right xy, sequence is a sequence of char types, window is window to be drawn in"
  (let ((new-pos (clim:make-point
                  (clim:point-x pos)
                  (+ (clim:point-y pos) 20))))
    (clim:draw-text window sequence new-pos :toward-point size)))

(defun draw-window-close-button (pos size window)
  (clim:draw-rectangle window ))

(defun close-window (pane pos-click)
  )

(defgeneric search-for-parent-window (child windows)
  (:documentation "finds the parent window object of a child object"))

;;; FIXME: are these the right equality operators for this operation?

(defmethod search-for-parent-window ((child topbar-draggable-window) windows)
  (loop for window in windows
        do (if (eq child
                   (window-topbar window))
               (return window))))

(defmethod search-for-parent-window ((child button-close-window) windows)
  (loop for window in windows
        do (if (eq child
                   (window-close-button window))
               (return window))))

;;; updates window pos and size values by translation of new-x and
;;; new-y when dragged
;;; FIXME tester is shamelessly copied and might not work in this very case
;;; FIXME convert object to window that parents
(clim:define-presentation-to-command-translator translator-drag-window
    (topbar-draggable-window
     com-drag-window superapp
     :documentation "drag a window"
     :tester
     ((object)
      (let ((frame *application-frame*))
        (eq (clim:pointer-sheet (clim:port-pointer (clim:port frame)))
            (clim:get-frame-pane frame 'screen-pane)))))
    (object)
  (search-for-parent-window object (let ((frame *application-frame*))
                                     (clim:get-frame-pane frame 'screen-pane)))
  )

;; the use of the same drawing command here is so that the dragging
;; action seems seamless, but this could change to an outline that snaps
;; to regions of the screen, an eventual goal
;;;; FIXME this isnt finished...
(lisp-editor-base:my-make-command
 com-drag-window
 :com-behavior (let ((pane (get-frame-pane *application-frame* 'screen-pane)))
                 (multiple-value-bind (nx ny)
                     (clim:dragging-output (pane :finish-on-release t
                                                 :repaint t)
                       (draw-window *application-frame*
                                    pane
                                    window)
                       (setf nx (clim:point-x (get-pointer-position pane))
                             ny (clim:point-y (get-pointer-position pane))))
                   (setf (window-pos window) '(clim:make-point nx ny))))
 :args (window 'window))


;;; converts click on button-window-close to command com-window-quit
;(clim:define-presentation-to-command-translator translator-close-window())

;;;; FIXME make com-window-quit

(defun window-filestring (window)
  (namestring (buffer-file (window-buffer window))))


