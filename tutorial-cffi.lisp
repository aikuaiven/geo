(defpackage :aiku (:use :common-lisp :cffi))
(in-package :aiku)
(mapcar #'load-foreign-library '("user32" "kernel32"))
(defun error-message ()
    (let ((errmsg (foreign-alloc :pointer)))
	(foreign-funcall ("FormatMessageA" :convention :stdcall)
		     :int32 #x1300
		     :pointer (null-pointer)
		     :int32 (foreign-funcall "GetLastError" :int32)
		     :int32 #x0
		     :pointer errmsg
		     :int32 #x0
		     :int32 #x0
		     :int32)
	(foreign-funcall "MessageBoxA"
			 :int32 #x0
			 :pointer (mem-ref errmsg :pointer)
			 :int32 #x0
			 :int32 #x0
			 :boolean)
	(foreign-free errmsg)))
(error-message)
