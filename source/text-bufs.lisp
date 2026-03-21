(cl:in-package #:lisp-editor-base)

(defclass my-buffer (text.editor-buffer.standard-buffer:buffer)
  (
   (file :accessor get-buffer-file
             :initarg :file)
   ))

;; dont think that initial contents works...

(defun make-buffer (&key (file (user-homedir-pathname)) (initial-line-conts ""))
  (let* ((line (make-instance 'text.editor-buffer.standard-line:line :contents initial-line-conts))
         (buf (make-instance 'my-buffer :initial-line line :file file)))
    buf
    ))

(defun create-new-buffer (glob-buffs &key (file (user-homedir-pathname)) (initial-line-conts ""))
  (append glob-buffs `((,(namestring file) . ,(make-buffer :file file :initial-line-conts initial-line-conts)))))

(defmacro init-buffers ()
  `(defvar *buffers*
     '(("scratch" . (make-buffer)))))

(defmacro init-cursor ()
  `(defvar *cursor*
     (make-instance 'text.editor-buffer.standard-line:right-sticky-cursor)))

(defun return-buffer-of-name (bufs &key (name "scratch"))
  (cdr (assoc name bufs)))

(defun get-num-of-bufs (bufs)
  (length bufs))

(defun get-all-live-buffers (bufs)
  (let* ((rl '())
         (res (dolist (item bufs rl)
                (append rl `(,item)))))
    res))

(defun get-buffer-lines (buffer)
  (text.editor-buffer:items buffer))

(defun get-line-chars (line)
  (text.editor-buffer:items line))

(defun get-buffer-conts-to-string (buffer)
  )

(defun get-buffer-name (buffer)
  (namestring (get-buffer-file buffer)))
