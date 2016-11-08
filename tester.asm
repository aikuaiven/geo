format PE GUI 4.0
entry _holst
use64

	IDD_DLG = 0x1111
	IDE_COMMA = 0x2222
	DWLP_DLGPROC = 8
  include '%Include%\win32a.inc'
  include '%Adding%\askewwinerror.inc'
  include '%Adding%\askewmissing.inc'
  include '%Adding%\askewunicode.inc'
  include '%Adding%\keyboardscancode.inc'
  include '%Adding%\askewmacroandstruc.inc'
  include '%Include%\ENCODING\win1251.inc'


section '.text' code readable executable
 _holst:
	invoke GetModuleHandle,0x0
	mov [hInstance],eax
	invoke CreateDialogIndirectParam,[hInstance],dialog,0x0,dlgproc,0x0
	test eax,eax
	jz ..error
	mov [hDlg],eax
 .msgloop:
	invoke GetMessage,msg,[hDlg],0x0,0x0
	test eax,eax
	jz .endloop
	inc eax
	jz ..error
	invoke IsDialogMessage,[hDlg],msg
	test eax,eax
	jnz .msgloop
	invoke TranslateMessage,msg
	invoke DispatchMessage,msg
	jmp .msgloop
 ..error:
	stdcall ..errormsg
 .endloop:
	invoke ExitProcess,[msg.wParam]
	ret

proc dlgproc hwnd,umsg,wparam,lparam
	push ebx esi edi
	;stdcall ..hexascii,eax
	mov eax,[umsg]
	cmp eax,WM_INITDIALOG
	je .wminitdialog
	cmp eax,WM_DESTROY
	je .wmdestroy
	cmp eax,WM_CLOSE
	jz .wmclose
	xor eax,eax
	jmp .finish

  .wminitdialog:
	invoke GetClientRect,[hwnd],dlgclientrect
	invoke CreateDialogIndirectParam,[hInstance],commandline,[hwnd],commandproc,0x0
	test eax,eax
	jz ..error
	mov [hCmd],eax
	jmp .processed

  .wmclose:
	invoke DeleteObject,[hFontcons]
	invoke DeleteObject,[hBrsyswhite]
	invoke DeleteObject,[hBrsysgray]
	invoke DeleteObject,[hPen]
	invoke DeleteObject,[cDc]
	invoke DeleteObject,[hDc]
	invoke DestroyWindow,[hwnd]
	jmp .processed
  .wmdestroy:
	invoke PostQuitMessage,0x0
	jmp .processed
  .nowork:
	invoke MessageBox,0x0,_nowork,0x0,MB_ICONWARNING+MB_OK
  .processed:
	mov eax,0x1
  .finish:
	pop ebx esi edi
	ret
endp

proc commandproc hwnd,umsg,wparam,lparam
	mov eax,[umsg]
	cmp eax,WM_PAINT
	je .wmpaint
	cmp eax,WM_LBUTTONDOWN
	je .wmlbuttonwoun
	cmp eax,WM_INITDIALOG
	je .wminitdialog
	cmp eax,WM_KEYDOWN
	je .keydown
	xor eax,eax
	jmp .finish

  .wmpaint:
	invoke GetDC,[hwnd]
	mov dword[hDc],eax
	invoke BitBlt,eax,0x0,0x0,[pwiCmd.rcClient+0x2*0x4],[pwiCmd.rcClient+0x3*0x4],[cDc],0x0,0x0,SRCCOPY
	invoke ReleaseDC,[hwnd],[hDc]
	jmp .processed
  .wmlbuttonwoun:
  .keydown:
	invoke PatBlt,[cDc],0x0,0x0,[pwiCmd.rcClient+0x2*0x4],[pwiCmd.rcClient+0x3*0x4],PATCOPY
	invoke DrawText,[cDc],_nowork,0xffffffff,outextrect,DT_LEFT+DT_TOP+DT_WORDBREAK+DT_EXTERNALLEADING+DT_CALCRECT
	invoke DrawText,[cDc],_nowork,0xffffffff,pwiCmd.rcClient,DT_LEFT+DT_TOP+DT_WORDBREAK+DT_EXTERNALLEADING
	invoke SetCaretPos,[outextrect.right],[outextrect.top]
	invoke SendMessage,[hwnd],WM_PAINT,0x0,0x0
	jmp .processed
  .wminitdialog:
	invoke CreateFontIndirectA,lfcons
	mov dword[hFontcons],eax
	invoke GetSysColor,COLOR_MENUBAR
	invoke CreateSolidBrush,eax
	mov dword[hBrsysgray],eax
	invoke GetSysColor,COLOR_WINDOW
	invoke CreateSolidBrush,eax
	mov dword[hBrsyswhite],eax

	invoke GetWindowInfo,[hwnd],pwiCmd
	mov eax,[pwiCmd.cxWindowBorders]
	mov edx,dword[dlgclientrect.right]
	shl eax,0x1
	mov dword[pwiCmd.rcWindow+0x2*0x4],edx
	mov dword[outextrect.left],0x0
	sub edx,eax
	mov dword[outextrect.top],0x0
	mov dword[pwiCmd.rcClient+0x2*0x4],edx
	mov dword[outextrect.right],edx
	invoke GetDC,[hCmd]
	mov dword[hDc],eax
	invoke CreateCompatibleDC,[hDc]
	mov dword[cDc],eax
	invoke SelectObject,[cDc],[hFontcons]
	invoke GetTextMetrics,[cDc],tmc
	mov eax,dword[tmc.tmHeight]
	xor ebx,ebx
	add eax,dword[tmc.tmExternalLeading]
	mov edx,[pwiCmd.cyWindowBorders]
	shl eax,0x1 ;высота в две строки
	mov dword[pwiCmd.rcWindow+0x0*0x4],ebx
	shl edx,0x1
	mov dword[pwiCmd.rcClient+0x3*0x4],eax
	mov dword[outextrect.bottom],eax
	mov dword[pwiCmd.rcClient+0x0*0x4],ebx
	add eax,edx
	mov ecx,dword[dlgclientrect.bottom]
	mov dword[pwiCmd.rcClient+0x1*0x4],ebx
	sub ecx,eax
	mov dword[pwiCmd.rcWindow+0x1*0x4],ecx
	invoke MoveWindow,[hwnd],[pwiCmd.rcWindow+0x0*0x4],[pwiCmd.rcWindow+0x1*0x4],[pwiCmd.rcWindow+0x2*0x4],[pwiCmd.rcWindow+0x3*0x4],0x0
	invoke CreateCompatibleBitmap,[hDc],[pwiCmd.rcClient+0x2*0x4],[pwiCmd.rcClient+0x3*0x4]
	mov dword[hBm],eax
	invoke ReleaseDC,[hwnd],[hDc]
	invoke SelectObject,[cDc],[hBm]
	invoke DeleteObject,[hBm]
	invoke SetBkColor,[cDc],COLOR_WINDOW

	invoke SetBkMode,[cDc],TRANSPARENT
	invoke SetTextAlign,[cDc],TA_NOUPDATECP

	invoke SelectObject,[cDc],[hBrsyswhite]
	invoke PatBlt,[cDc],0x0,0x0,[pwiCmd.rcClient+0x2*0x4],[pwiCmd.rcClient+0x3*0x4],PATCOPY

	invoke DrawText,[cDc],_no,-1,pwiCmd.rcClient,DT_LEFT+DT_CENTER+DT_WORDBREAK+DT_EXTERNALLEADING

	invoke CreateCaret,[hwnd],0x0,0x1,[tmc.tmHeight]
	invoke ShowCaret,[hwnd]
	invoke SendMessage,[hwnd],WM_ACTIVATE,WA_ACTIVE,0x0
	jmp .processed

  .processed:
	xor eax,0x1
  .finish:
	ret
endp


proc ..errormsg
	pushad
	invoke GetLastError
	invoke FormatMessage,FORMAT_MESSAGE_ALLOCATE_BUFFER+FORMAT_MESSAGE_FROM_SYSTEM+FORMAT_MESSAGE_IGNORE_INSERTS,0x0,eax,0x0,errmsg,0x0,0x0
	invoke MessageBox,0x0,[errmsg],0x0,0x0
	invoke LocalFree,[errmsg]
	popad
	ret
endp

proc ..hexascii значение
	push eax
	push ecx
	mov eax,dword[значение]
	push edx
	mov edx,eax
	mov ecx,0x7
      @@:
	mov al,dl
	and al,0xf
	cmp al,0xa
	sbb al,0x69
	das
	mov byte[числовascii+ecx],al
	shr edx,0x4
	dec ecx
	jns @b
	invoke MessageBox,0x0,числовascii,_значение,MB_APPLMODAL+MB_ICONASTERISK+MB_OK
	pop edx
	pop ecx
	pop eax
	ret
endp



section '.data' data readable writeable

	_nowork db 'Пока нету...',0x0
	_no db 'Бля...',0x0
	_значение db 'значение',0x0
	числовascii dd 0x2 dup 0x0
	  db 0x0
	lfcons LOGFONT 0x14,,,,FW_NORMAL,,,,RUSSIAN_CHARSET,,,,DEFAULT_PITCH+FF_MODERN,'Consolas'

	align 0x4
  label dialog
	  dd WS_CAPTION+WS_CLIPCHILDREN+WS_MAXIMIZEBOX+WS_MINIMIZEBOX+WS_SIZEBOX+WS_SYSMENU+WS_VISIBLE;+DS_SETFONT ;style WS_CLIPSIBLINGS+
	  dd 0x0;;WS_EX_OVERLAPPEDWINDOW+WS_EX_APPWINDOW+WS_EX_CONTEXTHELP ;exstyle
	  dw 0x0 ;item
	  dw 0x100,0x100,0x100,0x100 ;x,y,cx,cy
	  dw 0x0 ;array menu
	  dw 0x0 ;array class
	  du "determinate",0x0 ;title
	  du 0x0,0x0 ;font size, font name

	align 0x10
  label commandline
	  dd WS_CHILD+WS_VISIBLE+WS_BORDER+CS_OWNDC;+DS_NOIDLEMSG;+DS_SETFONT ;style
	  dd 0x0 ;exstyle WS_EX_NOPARENTNOTIFY+
	  dw 0x0 ;item
	  dw 0x0,0x0,0x0,0x0 ;x,y,cx,cy
	  dw 0x0 ;array menu
	  dw 0x0 ;array class
	  du 0x0 ;title
	  du 0x0 ;font size, font name


section '.udata' data readable writeable

	msg MSG

	errmsg dd ?

	hInstance dd ?
	hDlg dd ?
	hCmd dd ?
	hDc dd ?
	hFontcons dd ?
	hPen dd ?
	cDc dd ?
	hBm dd ?
	hBrsyswhite dd ?
	hBrsysgray dd ?

	dlgclientrect RECT
	pwiCmd WINDOWINFO
	outextrect RECT
	caretpos POINT
	tmc TEXTMETRIC


section '.idata' import data readable writeable

  library kernel32,'kernel32.dll',\
	  user32,'user32.dll',\
	  gdi32,'gdi32.dll',\
	  convert,'convert.dll'
;	   comdlg32,'comdlg32.dll',\
;	   comctl32,'comctl32.dll',\
;	   askewauxiliary,'askewauxiliary.DLL'

  include '%Include%\api\kernel32.inc'
  include '%Include%\api\user32.inc'
  include '%Include%\api\gdi32.inc'
;  include '%Include%\api\comdlg32.inc'
;  include '%Include%\api\comctl32.inc'
;  include '%Adding%\askewauxiliary.inc'
