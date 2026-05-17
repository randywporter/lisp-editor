(in-package #:lisp-editor)

(defclass editor-window ()
  ((title
    :initarg :title
    :accessor window-title
    :initform "Untitled")

   (buffer
    :initarg :buffer
    :accessor window-buffer
    :initform "")

   ;; top-left corner
   (x
    :initarg :x
    :accessor window-x
    :initform 50)

   (y
    :initarg :y
    :accessor window-y
    :initform 50)

   ;; dimensions
   (width
    :initarg :width
    :accessor window-width
    :initform 400)

   (height
    :initarg :height
    :accessor window-height
    :initform 300)))

(defun window-right (window)
  (+ (window-x window)
     (window-width window)))

(defun window-bottom (window)
  (+ (window-y window)
     (window-height window)))

(defun point-inside-rectangle-p (px py x1 y1 x2 y2)
  (and (<= x1 px x2)
       (<= y1 py y2)))

(defclass screen-pane (application-pane)
  ())

(define-application-frame editor-frame ()
  ((windows
    :initform nil
    :accessor frame-windows)

   ;; drag state
   (drag-window
    :initform nil
    :accessor frame-drag-window)

   (drag-offset-x
    :initform 0
    :accessor frame-drag-offset-x)

   (drag-offset-y
    :initform 0
    :accessor frame-drag-offset-y))

  (:panes
   (screen
    (make-pane 'screen-pane
               :display-function #'display-editor)))

  (:layouts
   (default screen)))

(define-presentation-type window-body ())
(define-presentation-type window-topbar ())
(define-presentation-type window-close-button ())

(defparameter *titlebar-height* 24)
(defparameter *close-button-size* 18)

(defun draw-window-frame (pane window)
  (let* ((x (window-x window))
         (y (window-y window))
         (right (window-right window))
         (bottom (window-bottom window))
         (titlebar-bottom (+ y *titlebar-height*)))

    ;; outer frame
    (draw-rectangle* pane
                     x y right bottom
                     :filled t
                     :ink +gray90+)

    ;; border
    (draw-rectangle* pane
                     x y right bottom
                     :filled nil
                     :line-thickness 2
                     :ink +black+)

    ;; title bar
    (with-output-as-presentation
        (pane window 'window-topbar)

      (draw-rectangle* pane
                       x y right titlebar-bottom
                       :filled t
                       :ink +dark-slate-gray+)

      (draw-text* pane
                  (window-title window)
                  (+ x 8)
                  (+ y 16)
                  :ink +white+))

    ;; close button
    (let* ((bx (- right *close-button-size* 4))
           (by (+ y 3))
           (bx2 (+ bx *close-button-size*))
           (by2 (+ by *close-button-size*)))

      (with-output-as-presentation
          (pane window 'window-close-button)

        (draw-rectangle* pane
                         bx by bx2 by2
                         :filled t
                         :ink +red+)

        (draw-text* pane
                    "X"
                    (+ bx 5)
                    (+ by 14)
                    :ink +white+)))

    ;; buffer/body
    (with-output-as-presentation
        (pane window 'window-body)

      (draw-text* pane
                  (window-buffer window)
                  (+ x 10)
                  (+ y 40)
                  :toward-x (- right 10)
                  :toward-y (- bottom 10)))))

(defun display-editor (frame pane)
  (declare (ignore pane))

  (dolist (window (frame-windows frame))
    (draw-window-frame
     (get-frame-pane frame 'screen)
     window)))

(define-editor-command (com-close-window :name t)
    ((window 'editor-window))
  (setf (frame-windows *application-frame*)
        (remove window
                (frame-windows *application-frame*)))

  (redisplay-frame-panes *application-frame*))

(define-editor-command (com-start-drag :name nil)
    ((window 'editor-window)
     (pointer-x 'integer)
     (pointer-y 'integer))

  (setf (frame-drag-window *application-frame*) window
        (frame-drag-offset-x *application-frame*)
        (- pointer-x (window-x window))

        (frame-drag-offset-y *application-frame*)
        (- pointer-y (window-y window))))

(define-editor-command (com-stop-drag :name nil) ()
  (setf (frame-drag-window *application-frame*) nil))

(define-presentation-to-command-translator close-window-translator
    (window-close-button
     com-close-window
     editor-frame
     :gesture :select)

    (object)
  (list object))

(define-presentation-to-command-translator drag-window-translator
    (window-topbar
     com-start-drag
     editor-frame
     :gesture :select)

    (object)
  (multiple-value-bind (x y)
      (stream-pointer-position
       (get-frame-pane *application-frame* 'screen))

    (list object x y)))


(defmethod handle-event ((pane screen-pane)
                         (event pointer-motion-event))

  (call-next-method)

  (let* ((frame *application-frame*)
         (window (frame-drag-window frame)))

    (when window
      (multiple-value-bind (x y)
          (stream-pointer-position pane)

        (setf (window-x window)
              (- x (frame-drag-offset-x frame))

              (window-y window)
              (- y (frame-drag-offset-y frame)))

        (redisplay-frame-panes frame)))))

(defmethod handle-event ((pane screen-pane)
                         (event pointer-button-release-event))

  (call-next-method)

  (declare (ignore pane event))

  (setf (frame-drag-window *application-frame*) nil))

(defun make-demo-windows ()
  (list
   (make-instance 'editor-window
                  :title "scratch.lisp"
                  :buffer "(format t \"Hello\")"
                  :x 50
                  :y 50)

   (make-instance 'editor-window
                  :title "notes.txt"
                  :buffer "McCLIM prototype"
                  :x 200
                  :y 180)))

(defun run-editor ()
  (run-frame-top-level
   (make-application-frame
    'editor-frame
    :windows (make-demo-windows))))