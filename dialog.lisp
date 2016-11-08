
(ql:quickload :cffi)
(defpackage :aiku (:use :common-lisp :cffi))
(in-package :aiku)
(load "~/project/askew-system/askew-system.lisp")

(defparameter *hpen* (foreign-funcall "ExtCreatePen"
				      :int32 (+ #x10000 #x0 #x100 #x1000) :int32 #x1
				      :pointer (memory-placing '((:int32 #x0 #x1 "brush style") (:int32 #x00909090 #x1 "brush color") (:int32 #x0 #x1 "hatch style")))
				      :int32 #x0 :int32 #x0 :int32)
  "pen style PS_GEOMETRIC+PS_SOLID+PS_ENDCAP_SQUARE+PS_JOIN_BEVEL width #x1 logbrush: BS_SOLID,0x<90,90,90>,0 0x0,0x0 - non PS_USERSTYLE")
(defparameter *hbrsysgray* (foreign-funcall "CreateSolidBrush" :int32 (foreign-funcall "GetSysColor" :int32 #x30 :int32) :int32) "system color menu bar as grey color")
(defparameter *hbrsyswhite* (foreign-funcall "CreateSolidBrush" :int32 (foreign-funcall "GetSysColor" :int32 #x5 :int32) :int32) "system window background color as white color")

(defparameter *hinstance* (foreign-funcall "GetModuleHandleA" :int32 #x0 :int32))
(defparameter *hdlg* #x0)
(defparameter *hcmd* #x0)
(defparameter *cdc* #x0)

(defparameter *dlg-client-rect* (foreign-alloc '(:struct rect)))
(defparameter *cmd-window-info* (foreign-alloc '(:struct windowinfo)))

(defparameter *lf-consolas* (foreign-funcall "CreateFontIndirectA"
					     :pointer (setf (get '*lf-consolas* 'pointer)
							    (make-cstruct '(:struct logfont)
									  '((lfhight #x14 :int32)
									    (lfwidth #x0 :int32) (lfescapement #x0 :int32) (lforientation #x0 :int32)
									    (lfweight 400 :int32 "FW_NORMAL")
									    (lfitalic #x0 :int8) (lfunderline #x0 :int8) (lfstrikeout #x0 :int8) 
									    (lfcharset 204 :uint8 "RUSSIAN_CHARSET")
									    (lfoutprecision #x0 :int8) (lfclipprecision #x0 :int8) (lfquality #x0 :int8)
									    (lfpitchandfamily #x30 :int8 "DEFAULT_PITCH+FF_MODERN")
									    (lffacename "Consolas" :ascii))))
					     :int32))

(defparameter *tm-consolas* (foreign-alloc '(:struct textmetric)))

(defstruct caret-position
  "x-position y-position"
  (x-position 0 :type (integer 0 #xffff))
  (y-position 0 :type (integer 0 #xffff)))

(defparameter *string-height* 0)
(defparameter *cmd-caret-position* (make-caret-position))

(defparameter *cmd-string* "Выполнить: ")
(defparameter *cmd-list* nil)
(defconstant +cmd-chema+ '(("в" "" "ыйти" '(("д" "а" 'cmd-exit) ("н" "ет" 'cmd-return) ". Подтверждаете? [Да Нет]: "))))

;;(recognize-input (template previous current input))

(defun draw-text (cdc cmd-string pointer-rect flags &aux (calc-text-rect (foreign-alloc '(:struct rect))))
    "calc and out text string => nil"
    (declare (optimize (debug 3) (safety 3)))
    (with-foreign-string (p-str cmd-string :encoding :windows-1251)
	(foreign-funcall "DrawTextA"
			 :int32 cdc
			 :pointer p-str
			 :int32 (length cmd-string)
			 :pointer (make-cstruct '(:struct rect)
						(list (list 'left (mem-ref pointer-rect :int32) :int32)
						      (list 'top (mem-ref (inc-pointer pointer-rect #x4) :int32) :int32)
						      (list 'right (mem-ref (inc-pointer pointer-rect #x8) :int32) :int32)
						      (list 'bottom (mem-ref (inc-pointer pointer-rect #xc) :int32) :int32))
						calc-text-rect)
			 :int32 (+ flags) ;;DT_CALCRECT
			 :int32)
	(foreign-funcall "DrawTextA"
			 :int32 cdc
			 :pointer p-str
			 :int32 (length cmd-string)
			 :pointer pointer-rect
			 :int32 flags
			 :int32))
    (foreign-funcall "SetCaretPos" :int32 (setf (slot-value *cmd-caret-position* 'x-position) (foreign-slot-value calc-text-rect '(:struct rect) 'right))
				   :int32 (setf (slot-value *cmd-caret-position* 'y-position) (- (foreign-slot-value calc-text-rect '(:struct rect) 'bottom)
												 *string-height*))
				   :int32)
    (foreign-free calc-text-rect)
    nil)

(defcallback (command-line-proc :convention :stdcall) :int32 ((hwnd :int32) (umsg :int32) (wparam :int32) (lparam :int32))
    (declare (optimize (debug 3) (safety 3)))
    (let* ((result 1))
	(cond ((= #x000f umsg) ;;WM_PAINT
	       (let ((hdc (foreign-funcall "GetDC" :int32 hwnd :int32)))
		   (foreign-funcall "BitBlt"
				    :int32 hdc
				    :int32 #x0
				    :int32 #x0 
				    :int32 (foreign-slot-value *cmd-window-info* '(:struct windowinfo) 'client-right)
				    :int32 (foreign-slot-value *cmd-window-info* '(:struct windowinfo) 'client-bottom)
				    :int32 *cdc*
				    :int32 #x0
				    :int32 #x0
				    :int32 #x00cc0020 ;;SRCCOPY
				    :int32)
		   (foreign-funcall "ReleaseDC" :int32 hwnd :int32 hdc :int32))
	       (setq result 0))
	      ((= #x0100 umsg)  ;;WM_KEYDOWN
	       (foreign-funcall "PatBlt" :int32 *cdc*
					     :int32 #x0
					     :int32 #x0
					     :int32 (foreign-slot-value *cmd-window-info* '(:struct windowinfo) 'client-right)
					     :int32 (foreign-slot-value *cmd-window-info* '(:struct windowinfo) 'client-bottom)
					     :int32 #x00f00021  ;;PATCOPY
					     :int32)
		   (draw-text *cdc*
			      (setq *cmd-string* (recognize-input *cmd-string* wparam))
			      (inc-pointer *cmd-window-info* (foreign-slot-offset '(:struct windowinfo) 'client-left))
			      (+ #x0 #x0 #x10 #x200))  ;;DT_LEFT+DT_TOP+DT_WORDBREAK+DT_EXTERNALLEADING
	       (foreign-funcall "SendMessageA" :int32 hwnd :int32 #xf :int32 #x0 :int32 #x0 :int32) ;;WM_PAINT
	       (format-message "cmd-message" hwnd umsg wparam lparam))
	      ((= #x0110 umsg) ;;WM_INITDIALOG
	       (let ((hdc (foreign-funcall "GetDC" :int32 hwnd :int32))
		     hbm auxi)
		   (setq *cdc* (foreign-funcall "CreateCompatibleDC" :int32 hdc :int32))
		   (foreign-funcall "GetWindowInfo" :int32 hwnd :pointer *cmd-window-info* :int32)
		   (foreign-funcall "SelectObject" :int32 *cdc* :int32 *lf-consolas* :int32)
		   (foreign-funcall "GetTextMetricsA" :int32 *cdc* :pointer *tm-consolas* :int32)
		   (foreign-funcall "CreateCaret" :int32 hwnd :int32 #x0 :int32 #x1 :int32 (setq auxi (foreign-slot-value *tm-consolas* '(:struct textmetric) 'tmheight)) :int32)
		   (setf (foreign-slot-value *cmd-window-info* '(:struct windowinfo) 'window-left) #x0
			 (foreign-slot-value *cmd-window-info* '(:struct windowinfo) 'client-left) #x0
			 (foreign-slot-value *cmd-window-info* '(:struct windowinfo) 'client-top) #x0
			 (foreign-slot-value *cmd-window-info* '(:struct windowinfo) 'window-top)
			 (- (foreign-slot-value *dlg-client-rect* '(:struct rect) 'bottom)
			    (setq auxi (* 2 (set '*string-height*
						 (+ auxi
						    (foreign-slot-value *tm-consolas* '(:struct textmetric) 'tmexternalleading)))))
			    (* 2 (foreign-slot-value *cmd-window-info* '(:struct windowinfo) 'cx-window-borders)))
			 (foreign-slot-value *cmd-window-info* '(:struct windowinfo) 'client-bottom) auxi
			 (foreign-slot-value *cmd-window-info* '(:struct windowinfo) 'window-right) (setq auxi (foreign-slot-value *dlg-client-rect* '(:struct rect) 'right))
			 (foreign-slot-value *cmd-window-info* '(:struct windowinfo) 'client-right) (- (foreign-slot-value *dlg-client-rect* '(:struct rect) 'bottom)
													     (* 2 (foreign-slot-value *cmd-window-info* '(:struct windowinfo) 'cy-window-borders))))
		   (foreign-funcall "MoveWindow"
				    :int32 hwnd
				    :int32 (foreign-slot-value *cmd-window-info* '(:struct windowinfo) 'window-left)
				    :int32 (foreign-slot-value *cmd-window-info* '(:struct windowinfo) 'window-top)
				    :int32 (foreign-slot-value *cmd-window-info* '(:struct windowinfo) 'window-right)
				    :int32 (foreign-slot-value *cmd-window-info* '(:struct windowinfo) 'window-bottom)
				    :int32)
		   (foreign-funcall "SelectObject"
				    :int32 *cdc*
				    :int32 (setq hbm (foreign-funcall "CreateCompatibleBitmap"
								      :int32 hdc
								      :int32 (foreign-slot-value *cmd-window-info* '(:struct windowinfo) 'client-right)
								      :int32 (foreign-slot-value *cmd-window-info* '(:struct windowinfo) 'client-bottom)
								      :int32))
				    :int32)
		   (foreign-funcall "ReleaseDC" :int32 hwnd :int32 hdc :int32)
		   (foreign-funcall "DeleteObject" :int32 hbm :int32)
		   (foreign-funcall "SetBkColor" :int32 *cdc* :int32 #x5 :int32) ;;COLOR_WINDOW
		   (foreign-funcall "SetBkMode" :int32 *cdc* :int32 #x1 :int32) ;;TRANSPARENT
		   (foreign-funcall "SelectObject" :int32 *cdc* :int32 *hbrsyswhite* :int32)
		   (foreign-funcall "PatBlt" :int32 *cdc*
					     :int32 #x0
					     :int32 #x0
					     :int32 (foreign-slot-value *cmd-window-info* '(:struct windowinfo) 'client-right)
					     :int32 (foreign-slot-value *cmd-window-info* '(:struct windowinfo) 'client-bottom)
					     :int32 #x00f00021  ;;PATCOPY
					     :int32)
		   (foreign-funcall "SetTextAlign" :int32 *cdc* :int32 #x0 :int32) ;;TA_NOUPDATECP
		   (draw-text *cdc*
			      *cmd-string*
			      (inc-pointer *cmd-window-info* (foreign-slot-offset '(:struct windowinfo) 'client-left))
			      (+ #x0 #x0 #x10 #x200)) ;;DT_LEFT+DT_TOP+DT_WORDBREAK+DT_EXTERNALLEADING
		   (foreign-funcall "SendMessageA" :int32 hwnd :int32 #x6 :int32 #x1 :int32 #x0 :int32)  ;;WM_ACTIVATE WA_ACTIVE
		   (foreign-funcall "ShowCaret" :int32 hwnd :int32)))
	      (t (setq result 0)))
	result))

(defcallback (dialog-proc :convention :stdcall) :int32 ((hwnd :int32) (umsg :int32) (wparam :int32) (lparam :int32))
    (declare (optimize (debug 3) (safety 3)))
    (let* ((result 1))
	(cond ((= #x0110 umsg) ;;WM_INITDIALOG
	       (foreign-funcall "GetClientRect" :int32 hwnd :pointer *dlg-client-rect* :int32)
	       (let ((cmd-line-template (memory-placing (list ;;command line template
							 '(:int32 #x50800000 #x1 'style) ;;WS_CHILD+WS_BORDER+WS_VISIBLE
							 '(:int32 #x0 #x1 'exstyle)
							 '(:int16 #x0 #x1 'cdit)
							 '(:int16 #x0 #x1 'x) '(:int16 #xe0 #x1 'y)
							 (list :int16 (foreign-slot-value *dlg-client-rect* '(:struct rect) 'right) #x1 'cx)
							 '(:int16 #x20 #x1 'cy)
							 '(:int16 #x0 #x1 'array-menu) '(:int16 #x0 #x1 'array-class)
							 '((:string . :utf-16le) "" #x1 'title)))))
		   (if (zerop (setq *hcmd* (foreign-funcall "CreateDialogIndirectParamA"
							    :int32 *hinstance* :pointer cmd-line-template :int32 hwnd :pointer (get-callback 'command-line-proc) :int32 #x0 :int32)))
		       (error-message "dialog")
		       (foreign-free cmd-line-template))))
	      ((= #x0002 umsg) ;;WM_DESTROY
	       (foreign-funcall "PostQuitMessage" :int32 #x0 :int32))
	      ((= #x0010 umsg) ;;WM_CLOSE
	       (foreign-free *dlg-client-rect*)
	       (mapcar (function (lambda (object) (foreign-funcall "DeleteObject" :int32 object :int32)))
		       (list *hbrsysgray* *hbrsyswhite* *cdc* *hpen*))
	       (foreign-funcall "DestroyWindow" :int32 hwnd :int32))
	      (t (setq result 0)))
	result))

(defun dialog ()
    (let* ((dlg-template (memory-placing (list ;;dlg temlate
					  '(:int32 #x12cb0000 #x1 'style) ;;WS_CAPTION+WS_CLIPCHILDREN+WS_MAXIMIZEBOX+WS_MINIMIZEBOX+WS_SYSMENU+WS_VISIBLE
					  '(:int32 #x0 #x1 'exstyle)
					  '(:int16 #x0 #x1 'cdit)
					  '(:int16 #x100 #x1 'x) '(:int16 #x100 #x1 'y) '(:int16 #x100 #x1 'cx) '(:int16 #x100 #x1 'cy)
					  '(:int16 #x0 #x1 'array-menu) '(:int16 #x0 #x1 'array-class)
					  '((:string . :utf-16le) "DETERMINATE" #x1 'title)
					  '(:int16 #x0 #x1 'font))))
	   (wmsg (foreign-alloc '(:struct msg))))
	(if (zerop (setq *hdlg* (foreign-funcall "CreateDialogIndirectParamA"
						 :int32 *hinstance* :pointer dlg-template :int32 #x0 :pointer (get-callback 'dialog-proc) :int32 #x0 :int32)))
	    (error-message "dialog")
	    (progn (foreign-free dlg-template)
		   (foreign-funcall "ShowWindow" :int32 *hdlg* :int32 #x1 :int32) ;;SW_NORMAL
		   (loop until (zerop (foreign-funcall "GetMessageA" :pointer wmsg :int32 *hdlg* :int #x0 :int #x0 :int32))
			 do (when (zerop (foreign-funcall "IsDialogMessage" :int32 *hdlg* :pointer wmsg :int32))
				(foreign-funcall "TranslateMessage" :pointer wmsg :int32)
				(foreign-funcall "DispatchMessageA" :pointer wmsg :int32)))))
	(let ((exitcode (foreign-slot-value wmsg '(:struct msg) 'wparam)))
	    (foreign-free wmsg)
	    (foreign-funcall "ExitProcess" :int32 exitcode :int32))))
(dialog)
(save-lisp-and-die "dialog.exe" :executable t :toplevel #'dialog)
