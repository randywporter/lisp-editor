(cl:in-package #:lisp-editor-base)

;;;;

;; so in funcs new and open file, setq forms dont work because the gadget-val form isnt a pointer?

;;;;

(defmacro lisp-editor-base:my-make-command (n &key (com-behavior '(placeholder-do-nothing)) (args nil))
  `(define-superapp-command (,n :name t)
       (,@args)
     ,com-behavior))

;; this type of window is basically a big output text that
;; we append some gadgets to
;; string prompt
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

;; these functions called by commands are solely side-effects lwky

;; all these need to be rewritten with buffers when we get there

;; with implemented buffers, this would create a new buffer with name,
;; and open a new window in said buffer
;; for now, clears my-text-editor pane
;; also asks the question of implementing "Did you save all files?" before exiting
;; DEPRECATED
;; reimplementing all the text editor functions, so all of these are useless atm
(defun my-new-file ()
  (setf (gadget-value (find-pane-named *application-frame* 'my-text-editor))
        ""))

(defun my-open-file ()
  (with-open-file (from-file-stream
                   (get-pathname-popup "Enter filename of existing file")
                   :direction :input
                   :if-does-not-exist :error)
    (setf (gadget-value (find-pane-named *application-frame* 'my-text-editor))
          (let ((string (make-string (file-length from-file-stream))))
            (read-sequence string from-file-stream)
            string))))

;; implement GET-BUFFER-NAME here for the default filename
;; vice versa with com-open and com-new, when making buffers
;; done!

;DEPRECATED - KEEPING FOR NOW BECAUSE ITS A GOOD TEMPLATE
(defun overwrite-or-new-ver (&key (stream *query-io*) (ow t))
  (let ((choice "New Version"))
    (accepting-values (stream :resynchronize-every-pass t :own-window ow)
      (terpri stream)
      (setq choice (accept '(member "Overwrite" "New Version")
                           :prompt "File exists, overwrite or new version?"
                           :view 'radio-box-view
                           :default choice
                           :stream stream))
      (terpri stream))
    choice))

(defmacro over-or-nv-loadcf ()
  (if (eql (get-config-val "over-or-nv") "overwrite")
      :overwrite
      :new-version))

(defun my-save-file ()
  (let ((filespec (get-pathname-popup "Where would you like to save to?")))
    (with-open-file (to-file-stream
                     filespec
                     :direction :output
                     :if-does-not-exist :create
                     :if-exists (over-or-nv-loadcf))
      (format to-file-stream (gadget-value
                              (find-pane-named *application-frame* 'my-text-editor))))))


;; FOR NOW, CLOSE IS FUNCTIONALLY THE SAME AS NEW, SINCE WE ONLY HAVE ONE 'BUFFER'


(defun placeholder-do-nothing ()
  (princ "I haven't been implemented!" *query-io*))

(defun update-text-style ()
  (setq *default-text-style* (make-text-style :serif :roman *editor-text-size*))
  (redisplay-frame-panes *application-frame* :force-p t))

(defun my-zoom (change)
  (setq *editor-text-size* (+ change *editor-text-size*))
  (update-text-style))


(defun init-commands ()
  (my-make-command com-quit
                   :com-behavior (frame-exit *application-frame*))
  
  (my-make-command com-copy)

  (my-make-command com-paste)

  (my-make-command com-undo)

  (my-make-command com-redo)

  (my-make-command com-list-buffers)

  ;;; FIXME wrong command???
  
  (my-make-command com-close
                   :com-behavior (my-new-file))

  (my-make-command com-new
                   :com-behavior (my-new-file))

  (my-make-command com-save
                   :com-behavior (my-save-file))

  (my-make-command com-open
                   :com-behavior (my-open-file))
  
  )
