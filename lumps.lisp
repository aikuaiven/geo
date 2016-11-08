((= umsg +wm-initdialog+)
		   (let ((cmd-line-template (memory-placing (list ;;command line template
							     (list :int32 (+ +ws-child+ +ws-border+ +ws-visible+) #x1 'style)
							     '(:int32 #x0 #x1 'exstyle)
							     '(:int16 #x0 #x1 'cdit)
							     '(:int16 #x0 #x1 'x) '(:int16 #xe0 #x1 'y) '(:int16 #x100 #x1 'cx) '(:int16 #x20 #x1 'cy)
							     '(:int16 #x0 #x1 'array-menu) '(:int16 #x0 #x1 'array-class)
							     '((:string . :utf-16le) "" #x1 'title)))))
		       ;;(foreign-funcall ("SendMessageA" :convention :stdcall) :int32 hwnd :int32 #x18 :int32 #x1 :int32 #x0 :int32) ;;WM_SHOWWINDOW SW_SHOWNORMAL
		       (if (zerop (setq *hcmd* (foreign-funcall ("CreateDialogIndirectParamA" :convention :stdcall)
								:int32 *hinstance* :pointer cmd-line-template :int32 hwnd :pointer (get-callback 'command-line-proc) :int32 #x0 :int32)))
			   (error-message)
			   (foreign-free cmd-line-template)))
		   )
