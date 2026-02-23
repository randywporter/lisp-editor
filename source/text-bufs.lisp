(cl:in-package #:lisp-editor-base)

(defmacro init-buffers ()
  `(defvar *buffers*
     '((*scratch* . (text.editor-buffer:make-buffer :initial-contents ";; this is a scratch buffer ~%;; hopefully it works!"
                                                    :line-separator "~%")))))

(defmacro init-cursor ()
  `(defvar *cursor*
     (make-instance 'text.editor-buffer.standard-line:right-sticky-cursor)))

(defun return-buffer-of-name (bufs &key (name *scratch*))
  (cdr (assoc name bufs)))

(defun get-num-of-bufs (bufs)
  (length bufs))

(defun create-new-buf (bufs &key (initial-conts "") (name (format nil "new-buffer-~A" (+ 1 (get-num-of-bufs)))))
  (append bufs '((name . (text.editor-buffer:make-buffer :initial-contents initial-conts)))))

(defun get-all-live-buffers (bufs)
  (let* ((rl '())
         (res (dolist (item bufs rl)
                (append rl '(items)))))
    res))

(defun convert-buffer-to-string (buf)
  (placeholder-do-nothing))

(defun convert-string-to-buffer (str)
  (placeholder-do-nothing))

