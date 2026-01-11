(defsystem "lisp-editor-mcclim"
	; mimicking .asd of Second Climacs for placeholding
	:depends-on ("mcclim"
				 "lisp-editor-core")
	
	; executable
	:build-operation asdf:program-op
	:build-pathname "lisp-editor"
	:entry-point "lisp-editor-mcclim:main")