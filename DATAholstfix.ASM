section '.data' data readable writeable

  ListClassName db 'SysListView32',0x0
  TabClassName db 'SysTabControl32',0x0
  RichClassName db 'RichEdit20A',0x0
  StaticClassName db 'STATIC',0x0
  RichEdDLL db 'RICHED20.DLL',0x0
  FontName db 'Courier New',0x0
  patchfini db 'holstfix.ini',0x0
  HeaderTabCommon db 'общее',0x0
  HeaderTabPlain db 'полевое',0x0
  NumberHolst db 'номер скважины',0x0

  errmsg dd 0x0
  _error db 'Ошибка, б...',0x0
  _nowork db 'Пока нету...',0x0
 label _work
        db 0x8 dup 0x0
        db 0x0d,0x0a
        db 0x9 dup 0x0

  dwIndex dd 0x0
  dwItems dd 0x0
  fileOpened dd 0x0
  sizeOfFile dd 0x0
 virtual
        align 0x4
        lenalign=$-$$
 end virtual
 if lenalign <> 0
        db lenalign dup 0x0
 end if
 label objectproperties
        dd idenoname,0x4,idenoname,0x4,idenoname,0x4,idenoname,0x4,idbproject,0x4,idbproject,0x4,\
           idecodeobj,0x30,idetitleobj,0xc0,idenameobj,0x90,idealiasobj,0x30,\
           ideexec010,0x10,ideexec011,0x10,ideexec020,0x10,ideexec021,0x10,ideexec030,0x10,ideexec031,0x10,ideexec040,0x10,ideexec041,0x10,ideexec050,0x10,ideexec051,0x10,ideexec060,0x10,ideexec061,0x10,ideexec070,0x10,ideexec071,0x10,ideexec080,0x10,ideexec081,0x10,ideexec090,0x10,ideexec091,0x10,ideexec0a0,0x10,ideexec0a1,0x10
resmem idecodeobj,0x30,idetitleobj,0xc0,idenameobj,0x90,idealiasobj,0x30,\
        ideexec010,0x10,ideexec011,0x10,ideexec020,0x10,ideexec021,0x10,ideexec030,0x10,ideexec031,0x10,ideexec040,0x10,ideexec041,0x10,ideexec050,0x10,ideexec051,0x10,ideexec060,0x10,ideexec061,0x10,ideexec070,0x10,ideexec071,0x10,ideexec080,0x10,ideexec081,0x10,ideexec090,0x10,ideexec091,0x10,ideexec0a0,0x10,ideexec0a1,0x10,\
        idbproject,0x4,idenoname,0x4

 label holstfixMainMenu ;align to double word
        dw 0x1    ; menu template version
        dw 0x4    ; offset from end of this word to menu item list
        dd 0x0    ; menu bar help ID

        dd MFT_STRING,MFS_ENABLED,IDM_HOLSTALL
        dw MFR_POPUP,'&',С,к,в,а,ж,и,н,а,0x0,0x0
        dd 0x0                           ; popup help ID
        dd MFT_STRING,MFS_GRAYED,IDM_HOLSTNEW
        Ф=0x041d
        dw 0x0,'&',Н,о,в,а,я,0x0
        dd MFT_STRING,MFS_GRAYED,IDM_HOLSTOPEN
        dw 0x0,'&',О,т,к,р,ы,т,ь,0x0
        dd MFT_STRING,MFS_GRAYED,IDM_HOLSTSAVE
        dw 0x0,'&',С,о,х,р,а,н,и,т,ь,0x0
        dd MFT_SEPARATOR,0x0,0x0
        dd 0x0
        dd MFT_STRING,MFS_GRAYED,IDM_HOLSTPROPERTIES
        dw 0x0,'&',С,в,о,й,с,т,в,а,0x0,0x0
        dd MFT_STRING,MFS_GRAYED,IDM_HOLSTEXPORT
        dw 0x0,'&',П,е,р,е,в,е,с,т,и,0x0
        dd MFT_STRING,MFS_GRAYED,IDM_HOLSTEXPORTALL
        dw 0x0,'&',П,е,р,е,в,е,с,т,и,' ',в,с,е,0x0
        dd MFT_SEPARATOR,0x0,0x0
        dd 0x0
        dd MFT_STRING,MFS_ENABLED,IDM_EXIT
        dw MFR_END,'&',В,ы,х,о,д,0x0

        dd MFT_STRING,MFS_ENABLED,IDM_OBJECTALL
        dw MFR_POPUP,'&',О,б,ъ,е,к,т,0x0,0x0
        dd 0x0
        dd MFT_STRING,MFS_ENABLED,IDM_OBJECTNEW
        dw 0x0,'&',Н,о,в,ы,й,0x0
        dd MFT_STRING,MFS_ENABLED,IDM_OBJECTOPEN
        dw 0x0,'&',О,т,к,р,ы,т,ь,0x0
        dd MFT_SEPARATOR,0x0,0x0
        dd 0x0
        dd MFT_STRING,MFS_GRAYED,IDM_OBJECTPROPERTIES
        dw MFR_END,'&',С,в,о,й,с,т,в,а,0x0,0x0

        dd MFT_STRING,MFS_GRAYED,IDM_LABORATORYALL
        dw MFR_POPUP,'&',Л,а,б,о,р,а,т,о,р,и,я,0x0
        dd 0x0
        dd MFT_STRING,MFS_ENABLED,IDM_LABORATORYEDGE
        dw 0x0,'&',Д,о,б,а,в,и,т,ь,0x0,0x0
        dd MFT_STRING,MFS_ENABLED,IDM_LABORATORYEXPORT
        dw 0x0,'&',П,е,р,е,в,е,с,т,и,0x0
        dd MFT_STRING,MFS_ENABLED,IDM_LABORATORYIMPORT
        dw MFR_END,'&',П,р,о,ч,е,с,т,ь,0x0,0x0

        dd MFT_STRING,MFS_ENABLED,IDM_HELP
        dw MFR_POPUP+MFR_END,'&',П,о,м,о,щ,ь,0x0,0x0
        dd 0x0
        dd MFT_STRING,MFS_ENABLED,IDM_OPTIONS
        dw 0x0,'&',Н,а,с,т,р,о,й,к,и,0x0
        dd MFT_STRING,MFS_ENABLED,IDM_CONTENT
        dw 0x0,'&',С,о,д,е,р,ж,а,н,и,е,0x0,0x0
        dd MFT_STRING,MFS_ENABLED,IDM_ABOUT
        dw MFR_END,'&',О,б,' ',э,т,о,м,0x002e,0x002e,0x002e,0x0,0x0

section '.udata' data readable writeable

 lenpatch db ?
 patchfallobj db LENINI dup (?)

 WWndproc dd ?
 WTabproc dd ?

 FileSizeLow dd ?

 hInstance dd ?
 hDlg dd ?
 hOp dd ?
 hList dd ?
 hTab dd ?
 hIcon dd ?
 hStatic dd ?
 hFile dd ?
 hFileIni dd ?
 hFileHe dd ?
 hREdit dd ?
 hREditNum dd ?
 hREdDll dd ?
 hFont dd ?
 hMemoryWrite dd ?
 hMemoryWriteNum dd ?
 hDc dd ?
 hMemDC dd ?
 hMap dd ?
 hfallobj dd ?

 lpPageFile dd ?
 lpNumberOfBytes dd ?
 pMemoryFile dd ?

 lineIndex dd ?
 charIndex dd ?
 firstChar dd ?

 ofn OPENFILENAME
 wc WNDCLASSEX
 msg MSG
 rect RECT
 point POINT
 tcitemheader TC_ITEMHEADER
 tcitem TC_ITEM
 lf LOGFONT
 ps PAINTSTRUCT
 icc INITCOMMONCONTROLSEX
