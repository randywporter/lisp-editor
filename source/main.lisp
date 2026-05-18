(in-package #:lisp-editor)

;; text window things

(defclass editor-buffer (text.editing:multiple-site-mixin
                         text.editing:site-mixin
                         cluffer-standard-buffer:buffer)
  ())

(defun make-editor-buffer (&key (contents ""))
  (let ((buf (make-instance 'editor-buffer
                            :initial-line (make-instance 'cluffer-standard-line:closed-line))))
    (when (> (length contents) 0)
      (setf (text.editing:items (text.editing:point buf)
                                text.editing:buffer
                                :forward)
            contents))
    buf))

(defun make-view-site (buffer)
  (text.editing:push-site-at buffer 0 0))

(defun site->string (site)
  (coerce (text.editing:items (text.editing:point site)
                              text.editing:buffer
                              :forward)
          'string))

(defclass editor-window ()
  ((title
    :initarg :title
    :accessor window-title
    :initform "Untitled")

   (buffer
    :initarg :buffer
    :accessor window-buffer)

   (site
    :accessor window-site
    :initarg :site
    :initform nil)

   (view-site
    :initarg :view-site
    :accessor window-view-site
    :initform nil)

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
    :initform 200)

   (height
    :initarg :height
    :accessor window-height
    :initform 150)))

(defun window-point (window)
  (text.editing:point (window-site window))
  (text.editing:move (window-view-site window)
                     text.editing:item
                     :forward))

(defun insert-string-at-point (window string)
  (text.editing:insert-items (window-point window) string))

(defun delete-backward-at-point (window)
  (text.editing:perform (window-point window)
                        'text.editing:delete
                        text.editing:item
                        :backward))

(defun delete-forward-at-point (window)
  (text.editing:perform (window-point window)
                        'text.editing:delete
                        text.editing:item
                        :forward))

(defun move-caret (window unit direction)
  (text.editing:perform (window-point window)
                        'text.editing:move
                        unit
                        direction))

(defun window-right (window)
  (+ (window-x window)
     (window-width window)))

(defun window-bottom (window)
  (+ (window-y window)
     (window-height window)))

(defun point-inside-rectangle-p (px py x1 y1 x2 y2)
  (and (<= x1 px x2)
       (<= y1 py y2)))

(defun make-editor-window (&key
                             (title "Untitled")
                             (contents "")
                             (x 50)
                             (y 50)
                             (width 200)
                             (height 150))
  (let ((buf (make-editor-buffer :contents contents)))
    (make-instance 'editor-window
                   :title title
                   :buffer buf
                   :site (text.editing:site buf)
                   :view-site (make-view-site buf)
                   :x x
                   :y y
                   :width width
                   :height height)))

;; app frame things

(defclass screen-pane (application-pane) ()
  (:default-initargs :background clim:+black+))

(make-command-table 'my-file-menu :errorp nil :menu
                    '(("New" :command com-new)
                      ("Open" :command com-open)
                      ("Save" :command com-save)
                      ("Quit" :command com-quit)))
(make-command-table 'my-edit-menu :errorp nil :menu
                    '(("Copy" :command com-copy)
                      ("Paste" :command com-paste)
                      ("Undo" :command com-undo)
                      ("Redo" :command com-redo)))
(make-command-table 'my-menu-bar :errorp nil :menu
                    '(("File" :menu my-file-menu)
                      ("Edit" :menu  my-edit-menu)))

(define-application-frame editor-frame ()
  ((windows
    :initform nil
    :initarg :windows
    :accessor frame-windows)
   (edit-window
    :initform nil
    :accessor frame-edit-window)
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

  (:menu-bar my-menu-bar)

  (:panes
   (screen
    (make-pane 'screen-pane
               :height 600
               :width 800
               :display-function #'display-editor)))

  (:layouts
   (default
    (vertically ()
      screen))))

;; presentation types

(define-presentation-type window-body ())
(define-presentation-type window-topbar ())
(define-presentation-type window-close-button ())

;; drawing the windows

(defparameter *titlebar-height* 24)
(defparameter *close-button-size* 18)

(defun draw-window-frame (pane window)
  (let* ((x (window-x window))
         (y (window-y window))
         (right (window-right window))
         (bottom (window-bottom window))
         (titlebar-bottom (+ y *titlebar-height*)))

    ;; buffer + body
    (with-output-as-presentation
        (pane window 'window-body)

      (draw-rectangle* pane
                       x y right bottom
                       :filled t
                       :ink clim:+dark-green+)

      (draw-text* pane
                  (site->string (window-view-site window))
                  (+ x 10)
                  (+ y 40)
                  :ink clim:+white+
                  :toward-x (- right 10)
                  :toward-y (- bottom 10)))

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
                       :ink clim:+green4+)

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

    ))

(defun display-editor (frame pane)
  (dolist (window (frame-windows frame))
     (draw-window-frame pane window)))

;; command time

(defun get-pathname-popup (prompt &key (stream *query-io*) (ow t) (tempfn "Untitled.txt"))
  (let ((pathname (merge-pathnames (parse-namestring "Downloads/") (user-homedir-pathname)))
        (filename (parse-namestring tempfn)))
    (clim:accepting-values (stream :own-window ow :initially-select-query-identifier 'dir)
                           (format stream prompt)
                           (terpri stream)
                           (setq pathname (clim:accept 'pathname :prompt "Enter directory"
                                                                 :stream stream
                                                                 :query-identifier 'dir
                                                                 :default pathname))
                           (terpri stream)
                           (setq filename (clim:accept 'pathname :prompt "Enter filename"
                                                                 :stream stream
                                                                 :default filename)))
    (merge-pathnames filename pathname)))


(defun current-edit-window ()
  (or (frame-edit-window *application-frame*)
      (first (frame-windows *application-frame*))))

(defun my-save-file ()
  (let ((window (current-edit-window)))
    (when window
      (let ((filespec (get-pathname-popup "Where would you like to save to?")))
        (with-open-file (to-file-stream
                         filespec
                         :direction :output
                         :if-does-not-exist :create
                         :if-exists :supersede)
          (write-string (site->string (window-view-site window))
                        to-file-stream))))))
(defun my-open-file ()
  (let ((window (or (current-edit-window)
                    (let ((new (make-editor-window)))
                      (push new (frame-windows *application-frame*))
                      new))))
    (let ((filespec (get-pathname-popup "Enter filename of existing file")))
      (with-open-file (from-file-stream
                       filespec
                       :direction :input
                       :if-does-not-exist :error)
                       (let ((string (make-string (file-length from-file-stream))))
                         (read-sequence string from-file-stream)
                         (let ((buf (make-editor-buffer :contents string)))
                           (setf (window-buffer window) buf
                                 (window-site window) (text.editing:site buf)
                                 (window-view-site window) (make-view-site buf)
                                 (window-title window) (file-namestring filespec)
                                 (frame-edit-window *application-frame*) window)))))
    (focus-editor-pane))
  (redisplay-frame-panes *application-frame*))

(defun my-new-file ()
  (let ((window (make-editor-window :title "Untitled" :contents "" :x 50 :y 50)))
    (push window (frame-windows *application-frame*))
    (setf (frame-edit-window *application-frame*) window)
    (focus-editor-pane)
    (redisplay-frame-panes *application-frame*)))

(defun focus-editor-pane ()
  (clim:stream-set-input-focus (get-frame-pane *application-frame* 'screen)))

(define-editor-frame-command (com-quit :name t)
    ()
  (frame-exit *application-frame*))

(define-editor-frame-command (com-new :name t)
    ()
  (my-new-file))

(define-editor-frame-command (com-save :name t)
    ()
  (my-save-file))

(define-editor-frame-command (com-open :name t)
    ()
  (my-open-file))


(define-editor-frame-command (com-close-window :name t)
    ((window 'editor-window))
  (setf (frame-windows *application-frame*)
        (remove window
                (frame-windows *application-frame*)))

  (if (eql (frame-edit-window *application-frame*)
           window)
      (setf (frame-edit-window *application-frame*) nil))

  (redisplay-frame-panes *application-frame*))

(define-editor-frame-command (com-start-drag :name nil)
    ((window 'editor-window)
     (pointer-x 'integer)
     (pointer-y 'integer))

  (setf (frame-drag-window *application-frame*) window
        (frame-drag-offset-x *application-frame*)
        (- pointer-x (window-x window))

        (frame-drag-offset-y *application-frame*)
        (- pointer-y (window-y window))))

(define-editor-frame-command (com-start-edit :name nil)
    ((window 'editor-window))
  (setf (frame-edit-window *application-frame*) window)
  (focus-editor-pane))


(define-editor-frame-command (com-stop-drag :name nil) ()
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

(define-presentation-to-command-translator edit-window-translator
    (window-body
     com-start-edit
     editor-frame
     :gesture :select)

    (object)
  (list object))

(defun maybe-edit-key-character (event)
  (clim:keyboard-event-character event))

(defun maybe-edit-key-name (event)
  (clim:keyboard-event-key-name event))

(defmethod handle-event ((pane screen-pane)
                         (event key-press-event))
  (let* ((frame *application-frame*)
         (window (frame-edit-window frame)))
    (when window
      (let ((ch (maybe-edit-key-character event))
            (key (maybe-edit-key-name event)))
        (cond
          ((graphic-char-p ch)
           (insert-string-at-point window (string ch))
           (redisplay-frame-panes frame))

          ((or (eql ch #\Newline)
               (member key '(:return :enter)))
           (text.editing:insert-newline (window-point window))
           (redisplay-frame-panes frame))

          ((member key '(:backspace :rubout))
           (delete-backward-at-point window)
           (redisplay-frame-panes frame))

          ((member key '(:delete))
           (delete-forward-at-point window)
           (redisplay-frame-panes frame))

          ((eq key :left)
           (move-caret window 'text.editing:item :backward)
           (redisplay-frame-panes frame))
          ((eq key :right)
           (move-caret window 'text.editing:item :forward)
           (redisplay-frame-panes frame))
          ((eq key :up)
           (move-caret window 'text.editing:line :backward)
           (redisplay-frame-panes frame))
          ((eq key :down)
           (move-caret window 'text.editing:line :forward)
           (redisplay-frame-panes frame))
          (t
           (call-next-method)))))))


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
  
  (setf (frame-drag-window *application-frame*) nil))


(defun make-demo-windows ()
  (list
   (make-editor-window
    :title "scratch.lisp"
    :contents "(format t \"Hello\")"
    :x 50
    :y 50)

   (make-editor-window
    :title "notes.txt"
    :contents "McCLIM prototype"
    :x 200
    :y 180)))

(defun run-editor ()
  (run-frame-top-level
   (make-application-frame
    'editor-frame
    :windows (make-demo-windows))))
