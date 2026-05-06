(cl:in-package #:lisp-editor-base)

;;; FIXME ;;;
;; many of the drawing functions here
;; were not made with the time taken
;; to differentiate between mediums, sheets, and panes
;; so panes are most likely used where they should'nt
;; and coordinates assuming the unchanging coordinate system of
;; the pane behind it all
;;;;




;; these might not get used...
;; deprecated 
(defmacro init-screen-params ()
  `(progn
     (defparameter *width* 500)
     (defparameter *height* 700)
     (defparameter *screen-bounds* (clim:make-rectangle* 0 0 *width* *height*))
     )
  )

(defclass screen-pane (clim:application-pane)
  ((windows :accessor screen-windows
            :initform '()))
  (:default-initargs :background clim:+gray90+))

;; coming with great inspiration from clim-fig and draggable-graph
;; in the mcclim source
(defclass move-event ()
  ((record :initarg :record :reader record)
   (delta-x :initarg :delta-x :reader delta-x :initform 0)
   (delta-y :initarg :delta-y :reader delta-y :initform 0))
  (:default-initargs
   :record (error "move-event needs a record")))

(defun get-pointer-position (pane)
  (multiple-value-bind (x y) (stream-pointer-position pane)
    (clim:make-point x y)))


;;; FIXME active and dragging deprecated 
(defclass window ()
  ((buffer :accessor window-buffer
           :initarg :buffer)
   (pos :accessor window-pos
        :initarg :pos
        :initform (clim:make-point 0 0))
   (size :accessor window-size
         :initarg :size
         :initform  (clim:make-point 10 10))
   (active :accessor window-active
           :initarg :active
           :initform nil)
   (dragging :accessor window-dragging
             :initform nil)
   (topbar :accessor window-topbar
           :initarg window-topbar)
   (close-button :accessor window-close-button
                 :initarg close-button)
   (text-field :accessor window-text-field
               :initarg text-button)))

(defun make-window-active (window)
  (setq (window-active window) t))


;; trans is a faux point to translate the original point by
(defun lisp-edior-base:translate-point (org trans)
  (clim:make-point (+ (clim:point-x org) (clim:point-x trans))
                   (+ (clim:point-y org) (clim:point-y trans))))

;; HARD functional abstraction here, still figuring out
;; low level details, but the idea here is solid
;; actually isnt that low level, just complicated to draw
;;; FIXME remove the dolist, thisll get called externally on each window
;; init-pos is a clim standard point
(defun draw-window (frame pane &optional init-pos))
  (dolist (window (screen-windows pane) nil)
    (let* ((window screen-window)
           (name (window-filestring window))
           (str (window-string window))
           (pos (if init-pos
                    init-pos
                    (window-pos window)))
           (size (if init-pos
                     (lisp-editor-base:translate-point size init-pos))))
;;; if !active, quit? or only run if active
      (window-clear pane)
      (draw-plain-window pos size pane)
      (draw-window-name pos name)
      (draw-window-close-button pos size window)
      (draw-window-string pos size str window)
      ))

(defun draw-plain-window (pos size pane)
  (clim:draw-rectangle pane pos size :filled t :line-thickness 3))

(defun draw-window-name (pos name)
  )


;; text will be 25x40 pixel?
;; sounds too big, we try 15x24, no spacing

;; PRAISE BE THERE'S A BUILT IN FUNCTION

(defun draw-window-string (pos size sequence window)
  "pos is top left xy, size is bottom right xy, sequence is a sequence of char types, window is window to be drawn in"
  (let ((new-pos (clim:make-point
                  (clim:point-x pos)
                  (+ (clim:point-y 20)))))
    (clim:draw-text window sequence new-pos :toward-point size)))

(defun draw-window-close-button (pos size window)
  )

(defun close-window (pane pos-click)
  )

(defclass lisp-editor-base:topbar-draggable-window (clim:standard-bounding-rectangle)
  (window )
  :documentation "class for the top bar of a window to drag"
  )

(defclass lisp-editor-base:button-close-window (clim:standard-bounding-rectangle)
  ()
  :documentation "class for the button that closes windows"
  )

(defgeneric lisp-editor-base:search-for-parent-window (child windows)
  (:documentation "finds the parent window object of a child object"))

;;; FIXME: are these the right equality operators for this operation?

(defmethod lisp-editor-base:search-for-parent-window ((child lisp-editor-base:topbar-draggable-window) windows)
  (loop for window across windows
        (if (eq child
                (window-topbar window))
            (return window))))

(defmethod lisp-editor-base:search-for-parent-window ((child lisp-editor-base:button-close-window) windows)
  (loop for window across window
        (if (eq child
                (window-close-button window))
            (return window))))

;;; updates window pos and size values by translation of new-x and
;;; new-y when dragged
;;; FIXME tester is shamelessly copied and might not work in this very case
;;; FIXME convert object to window that parents
(clim:define-presentation-to-command-translator translator-drag-window
    (lisp-editor-base:topbar-draggable-window
     com-drag-window superapp
     :documentation "drag a window"
     :tester
     ((object)
      (let ((frame *application-frame*))
        (eq (clim:pointer-sheet (clim:port-pointer (clim:port frame)))
            (clim:get-frame-pane frame 'screen-pane)))))
    (object)
  (lisp-editor-base:search-for-parent-window object)
    )

;; the use of the same drawing command here is so that the dragging
;; action seems seamless, but this could change to an outline that snaps
;; to regions of the screen, an eventual goal
;;;; FIXME this isnt finished...
(lisp-editor-base:my-make-command
 com-drag-window
 :com-behavior (let ((pane (get-frame-pane *application-frame* 'screen-pane)))
                 (multiple-value-bind (x y)
                     (clim:dragging-output (pane :finish-on-release t
                                                 :repaint t)
                       (lisp-editor-base:draw-window *application-frame*
                                                     pane)))))

;;; converts click on button-window-close to command com-window-quit
(clim:define-presentation-to-command-translator translator-close-window
    ())

;;;; FIXME make com-window-quit

;; this might not work at all
(defmethod window-clear ((pane screen-pane))
  (call-next-method)
  (clim:handle-repaint pane (clim:sheet-region pane)))

(defun window-filestring (window)
  (namestring (buffer-file (window-buffer window))))


