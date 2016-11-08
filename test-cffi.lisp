(defpackage :aiku (:use :common-lisp :cffi))
(in-package :aiku)
(defun-foreign-library user32  (t "user32.dll"))
(use-foreign-library user32)
(defcfun ("MessageBoxA" message-box :convention :stdcall :library user32)
    :boolean
    (hinstance :pointer ))
;;(defcstruct dlgtemplate (style :int32) (extendedstyle :int32) (cdit :int16) (x :short) (y :short) (cx :short) (cy :short))
;;(foreign-funcall ("CreateDialogParamA" :convention :stdcall) :int32 hinstance :pointer (mem-ref dlgtemp '(:struct dlgtemplate)) :pointer (callback dialogproc) :int32 #x0 :int32)
		 