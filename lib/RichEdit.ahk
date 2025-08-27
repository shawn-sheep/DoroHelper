; ======================================================================================================================
; Scriptname:     RichEdit.ahk
; Namespace:      RichEdit
; Author:         just me
; AHK Version:    2.0.2 (Unicode)
; OS Version:     Win 10 Pro (x64)
; Function:       The class provides some wrapper functions for rich edit controls (v4.1 Unicode).
; Change History:
;    1.0.00.00    2023-05-23/just me - initial release
; Credits:
;    corrupt for cRichEdit:
;       http://www.autohotkey.com/board/topic/17869-crichedit-standard-richedit-control-for-autohotkey-scripts/
;    jballi for HE_Print:
;       http://www.autohotkey.com/board/topic/45513-function-he-print-wysiwyg-print-for-the-hiedit-control/
;    majkinetor for Dlg:
;       http://www.autohotkey.com/board/topic/15836-module-dlg-501/
; ======================================================================================================================
#Requires AutoHotkey v2.0
#DllLoad "Msftedit.dll"
; ======================================================================================================================
class RichEdit {
    ; ===================================================================================================================
    ; Class variables - do not change !!!
    ; ===================================================================================================================
    ; Callback functions for RichEdit
    static GetRTFCB := 0
    static LoadRTFCB := 0
    static SubclassCB := 0
    ; Initialize the class on startup
    static __New() {
        ; RichEdit.SubclassCB := CallbackCreate(RichEdit_SubclassProc)
        RichEdit.GetRTFCB := CallbackCreate(ObjBindMethod(RichEdit, "GetRTFProc"), , 4)
        RichEdit.LoadRTFCB := CallbackCreate(ObjBindMethod(RichEdit, "LoadRTFProc"), , 4)
        RichEdit.SubclassCB := CallbackCreate(ObjBindMethod(RichEdit, "SubclassProc"), , 6)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    static GetRTFProc(dwCookie, pbBuff, cb, pcb) { ; Callback procedure for GetRTF
        static RTF := ""
        if (cb > 0) {
            RTF .= StrGet(pbBuff, cb, "CP0")
            return 0
        }
        if (dwCookie = "*GetRTF*") {
            Out := RTF
            VarSetStrCapacity(&RTF, 0)
            RTF := ""
            return Out
        }
        return 1
    }
    ; -------------------------------------------------------------------------------------------------------------------
    static LoadRTFProc(FileHandle, pbBuff, cb, pcb) { ; Callback procedure for LoadRTF
        return !DllCall("ReadFile", "Ptr", FileHandle, "Ptr", pbBuff, "UInt", cb, "Ptr", pcb, "Ptr", 0)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    static SubclassProc(H, M, W, L, I, R) { ; RichEdit subclassproc
        ; See -> docs.microsoft.com/en-us/windows/win32/api/commctrl/nc-commctrl-subclassproc
        ; WM_GETDLGCODE = 0x87, DLGC_WANTALLKEYS = 4
        return (M = 0x87) ? 4 : DllCall("DefSubclassProc", "Ptr", H, "UInt", M, "Ptr", W, "Ptr", L, "Ptr")
    }
    ; ===================================================================================================================
    ; CONSTRUCTOR
    ; ===================================================================================================================
    __New(GuiObj, Options, MultiLine := True) {
        static WS_TABSTOP := 0x10000, WS_HSCROLL := 0x100000, WS_VSCROLL := 0x200000, WS_VISIBLE := 0x10000000,
            WS_CHILD := 0x40000000,
            WS_EX_CLIENTEDGE := 0x200, WS_EX_STATICEDGE := 0x20000,
            ES_MULTILINE := 0x0004, ES_AUTOVSCROLL := 0x40, ES_AUTOHSCROLL := 0x80, ES_NOHIDESEL := 0x0100,
            ES_WANTRETURN := 0x1000, ES_DISABLENOSCROLL := 0x2000, ES_SUNKEN := 0x4000, ES_SAVESEL := 0x8000,
            ES_SELECTIONBAR := 0x1000000
        static MSFTEDIT_CLASS := "RICHEDIT50W" ; RichEdit v4.1+ (Unicode)
        ; Specify default styles & exstyles
        Styles := WS_TABSTOP | WS_VISIBLE | WS_CHILD | ES_AUTOHSCROLL
        if (MultiLine)
            Styles |= WS_HSCROLL | WS_VSCROLL | ES_MULTILINE | ES_AUTOVSCROLL | ES_NOHIDESEL | ES_WANTRETURN |
                ES_DISABLENOSCROLL | ES_SAVESEL ; | ES_SELECTIONBAR ; does not work properly
        ExStyles := WS_EX_STATICEDGE
        ; Create the control
        CtrlOpts := "Class" . MSFTEDIT_CLASS . " " . Options . " +" . Styles . " +E" . ExStyles
        This.RE := GuiObj.AddCustom(CtrlOpts)
        ; Initialize control
        ; EM_SETLANGOPTIONS = 0x0478 (WM_USER + 120)
        ; IMF_AUTOKEYBOARD = 0x01, IMF_AUTOFONT = 0x02
        ; SendMessage(0x0478, 0, 0x03, This.HWND) ; commented out
        ; Subclass the control to get Tab key and prevent Esc from sending a WM_CLOSE message to the parent window.
        ; One of majkinetor's splendid discoveries!
        ; DllCall("SetWindowSubclass", "Ptr", This.HWND, "Ptr", RichEdit.SubclassCB, "Ptr", This.HWND, "Ptr", 0)
        This.MultiLine := !!MultiLine
        This.DefFont := This.GetFont(1)
        This.DefFont.Default := 1
        This.BackColor := DllCall("GetSysColor", "Int", 5, "UInt") ; COLOR_WINDOW
        This.TextColor := This.DefFont.Color
        This.TxBkColor := This.DefFont.BkColor
        ; Additional settings for multiline controls
        if (MultiLine) {
            ; Adjust the formatting rectangle
            RC := This.GetRect()
            This.SetRect(RC.L + 6, RC.T + 2, RC.R, RC.B)
            ; Set advanced typographic options
            ; EM_SETTYPOGRAPHYOPTIONS = 0x04CA (WM_USER + 202)
            ; TO_ADVANCEDTYPOGRAPHY	= 1, TO_ADVANCEDLAYOUT = 8 ? not documented
            SendMessage(0x04CA, 1, 1, This.HWND)
        }
        ; Correct AHK font size setting, if necessary
        if (Round(This.DefFont.Size) != This.DefFont.Size) {
            This.DefFont.Size := Round(This.DefFont.Size)
            This.SetDefaultFont()
        }
        ; Initialize the print margins
        This.GetMargins()
        ; Initialize the text limit
        This.LimitText(2147483647)
    }
    ; ===================================================================================================================
    ; DESTRUCTOR
    ; ===================================================================================================================
    __Delete() {
        ; 安全地移除窗口子类化
        try {
            if (this.Hwnd && DllCall("IsWindow", "Ptr", this.Hwnd) && RichEdit.SubclassCB) {
                DllCall("RemoveWindowSubclass", "Ptr", this.Hwnd, "Ptr", RichEdit.SubclassCB, "Ptr", this.Hwnd)
            }
        }
        this.RE := 0
    }
    ; ===================================================================================================================
    ; GUICONTROL PROPERTIES =============================================================================================
    ; ===================================================================================================================
    ClassNN => This.RE.ClassNN
    Enabled => This.RE.Enabled
    Focused => This.RE.Focused
    Gui => This.RE.Gui
    Hwnd => This.RE.Hwnd
    Name {
        Get => This.RE.Name
        Set => This.RE.Name := Value
    }
    Visible => This.RE.Visible
    ; ===================================================================================================================
    ; GUICONTROL METHODS ================================================================================================
    ; ===================================================================================================================
    Focus() => This.RE.Focus()
    GetPos(&X?, &Y?, &W?, &H?) => This.RE.GetPos(&X?, &Y?, &W?, &H?)
    Move(X?, Y?, W?, H?) => This.RE.Move(X?, Y?, W?, H?)
    OnCommand(Code, Callback, AddRemove?) => This.RE.OnCommand(Code, Callback, AddRemove?)
    OnNotify(Code, Callback, AddRemove?) => This.RE.OnNotify(Code, Callback, AddRemove?)
    Opt(Options) => This.RE.Opt(Options)
    Redraw() => This.RE.Redraw()
    ; ===================================================================================================================
    ; PUBLIC METHODS ====================================================================================================
    ; ===================================================================================================================
    ; ===================================================================================================================
    ; Methods to be used by advanced users only
    ; ===================================================================================================================
    GetCharFormat() { ; Retrieves the character formatting of the current selection
        ; For details see http://msdn.microsoft.com/en-us/library/bb787883(v=vs.85).aspx.
        ; Returns a 'CF2' object containing the formatting settings.
        ; EM_GETCHARFORMAT = 0x043A
        CF2 := RichEdit.CHARFORMAT2()
        SendMessage(0x043A, 1, CF2.Ptr, This.HWND)
        return (CF2.Mask ? CF2 : False)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetCharFormat(CF2) { ; Sets character formatting of the current selection
        ; For details see http://msdn.microsoft.com/en-us/library/bb787883(v=vs.85).aspx.
        ; CF2 : CF2 object like returned by GetCharFormat().
        ; EM_SETCHARFORMAT = 0x0444
        return SendMessage(0x0444, 1, CF2.Ptr, This.HWND)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    GetParaFormat() { ; Retrieves the paragraph formatting of the current selection
        ; For details see http://msdn.microsoft.com/en-us/library/bb787942(v=vs.85).aspx.
        ; Returns a 'PF2' object containing the formatting settings.
        ; EM_GETPARAFORMAT = 0x043D
        PF2 := RichEdit.PARAFORMAT2()
        SendMessage(0x043D, 0, PF2.Ptr, This.HWND)
        return (PF2.Mask ? PF2 : False)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetParaFormat(PF2) { ; Sets the  paragraph formatting for the current selection
        ; For details see http://msdn.microsoft.com/en-us/library/bb787942(v=vs.85).aspx.
        ; PF2 : PF2 object like returned by GetParaFormat().
        ; EM_SETPARAFORMAT = 0x0447
        return SendMessage(0x0447, 0, PF2.Ptr, This.HWND)
    }
    ; ===================================================================================================================
    ; Control specific
    ; ===================================================================================================================
    IsModified() { ; Has the control been  modified?
        ; EM_GETMODIFY = 0xB8
        return SendMessage(0xB8, 0, 0, This.HWND)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetModified(Modified := False) {  ; Sets or clears the modification flag for an edit control
        ; EM_SETMODIFY = 0xB9
        return SendMessage(0xB9, !!Modified, 0, This.HWND)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetEventMask(Events?) { ; Set the events which shall send notification codes control's owner
        ; Events : Array containing one or more of the keys defined in 'ENM'.
        ; For details see http://msdn.microsoft.com/en-us/library/bb774238(v=vs.85).aspx
        ; EM_SETEVENTMASK	= 	0x0445
        static ENM := { NONE: 0x00, CHANGE: 0x01, UPDATE: 0x02, SCROLL: 0x04, SCROLLEVENTS: 0x08, DRAGDROPDONE: 0x10,
            PARAGRAPHEXPANDED: 0x20, PAGECHANGE: 0x40, KEYEVENTS: 0x010000, MOUSEEVENTS: 0x020000,
            REQUESTRESIZE: 0x040000, SELCHANGE: 0x080000, DROPFILES: 0x100000, PROTECTED: 0x200000,
            LINK: 0x04000000 }
        if !IsSet(Events) || (Type(Events) != "Array")
            Events := ["NONE"]
        Mask := 0
        for Each, Event In Events {
            if ENM.HasProp(Event)
                Mask |= ENM.%Event%
            else
                return False
        }
        return SendMessage(0x0445, 0, Mask, This.HWND)
    }
    ; ===================================================================================================================
    ; Loading and storing RTF format
    ; ===================================================================================================================
    GetRTF(Selection := False) { ; Gets the whole content of the control as rich text
        ; Selection = False : whole contents (default)
        ; Selection = True  : current selection
        ; EM_STREAMOUT = 0x044A
        ; SF_TEXT = 0x1, SF_RTF = 0x2, SF_RTFNOOBJS = 0x3, SF_UNICODE = 0x10, SF_USECODEPAGE =	0x0020
        ; SFF_PLAINRTF = 0x4000, SFF_SELECTION = 0x8000
        ; UTF-8 = 65001, UTF-16 = 1200
        ; Static GetRTFCB := CallbackCreate(RichEdit_GetRTFProc)
        Flags := 0x4022 | (1200 << 16) | (Selection ? 0x8000 : 0)
        ES := Buffer((A_PtrSize * 2) + 4, 0)                  ; EDITSTREAM structure
        NumPut("UPtr", This.HWND, ES)                         ; dwCookie
        NumPut("UPtr", RichEdit.GetRTFCB, ES, A_PtrSize + 4)  ; pfnCallback
        SendMessage(0x044A, Flags, ES.Ptr, This.HWND)
        return RichEdit.GetRTFProc("*GetRTF*", 0, 0, 0)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    LoadRTF(FilePath, Selection := False) { ; Loads RTF file into the control
        ; FilePath = file path
        ; Selection = False : whole contents (default)
        ; Selection = True  : current selection
        ; EM_STREAMIN = 0x0449
        ; SF_TEXT = 0x1, SF_RTF = 0x2, SF_RTFNOOBJS = 0x3, SF_UNICODE = 0x10, SF_USECODEPAGE =	0x0020
        ; SFF_PLAINRTF = 0x4000, SFF_SELECTION = 0x8000
        ; UTF-16 = 1200
        ; Static LoadRTFCB := CallbackCreate(RichEdit_LoadRTFProc)
        Flags := 0x4002 | (Selection ? 0x8000 : 0) ; | (1200 << 16)
        if !(File := FileOpen(FilePath, "r"))
            return False
        ES := Buffer((A_PtrSize * 2) + 4, 0)                     ; EDITSTREAM structure
        NumPut("UPtr", File.Handle, ES)                          ; dwCookie
        NumPut("UPtr", RichEdit.LoadRTFCB, ES, A_PtrSize + 4)    ; pfnCallback
        Result := SendMessage(0x0449, Flags, ES.Ptr, This.HWND)
        File.Close()
        return Result
    }
    ; ===================================================================================================================
    ; Scrolling
    ; ===================================================================================================================
    GetScrollPos() { ; Obtains the current scroll position
        ; Returns on object with keys 'X' and 'Y' containing the scroll position.
        ; EM_GETSCROLLPOS = 0x04DD
        PT := Buffer(8, 0)
        SendMessage(0x04DD, 0, PT.Ptr, This.HWND)
        return { X: NumGet(PT, 0, "Int"), Y: NumGet(PT, 4, "Int") }
    }
    ; ------------------------------------------------------------------------------------------------------------------
    SetScrollPos(X, Y) { ; Scrolls the contents of a rich edit control to the specified point
        ; X : x-position to scroll to.
        ; Y : y-position to scroll to.
        ; EM_SETSCROLLPOS = 0x04DE
        PT := Buffer(8, 0)
        NumPut("Int", X, "Int", Y, PT)
        return SendMessage(0x04DE, 0, PT.Ptr, This.HWND)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    ScrollCaret() { ; Scrolls the caret into view
        ; EM_SCROLLCARET = 0x00B7
        SendMessage(0x00B7, 0, 0, This.HWND)
        return True
    }
    ; -------------------------------------------------------------------------------------------------------------------
    ShowScrollBar(SB, Mode := True) { ; Shows or hides one of the scroll bars of a rich edit control
        ; SB   : Identifies which scroll bar to display: horizontal or vertical.
        ;        This parameter must be 1 (SB_VERT) or 0 (SB_HORZ).
        ; Mode : Specify TRUE to show the scroll bar and FALSE to hide it.
        ; EM_SHOWSCROLLBAR = 0x0460 (WM_USER + 96)
        SendMessage(0x0460, SB, !!Mode, This.HWND)
        return True
    }
    ; ===================================================================================================================
    ; Text and selection
    ; ===================================================================================================================
    FindText(Find, Mode?) { ; Finds Unicode text within a rich edit control
        ; Find : Text to search for.
        ; Mode : Optional array containing one or more of the keys specified in 'FR'.
        ;        For details see http://msdn.microsoft.com/en-us/library/bb788013(v=vs.85).aspx.
        ; Returns True if the text was found; otherwise false.
        ; EM_FINDTEXTEXW = 0x047C, EM_SCROLLCARET = 0x00B7
        static FR := { DOWN: 1, WHOLEWORD: 2, MATCHCASE: 4 }
        Flags := 0
        if IsSet(Mode) && (Type(Mode) = "Array") {
            for Each, Value In Mode
                if FR.HasProp(Value)
                    Flags |= FR[Value]
        }
        Sel := This.GetSel()
        Min := (Flags & FR.DOWN) ? Sel.E : Sel.S
        Max := (Flags & FR.DOWN) ? -1 : 0
        FTX := Buffer(16 + A_PtrSize, 0)
        NumPut("Int", Min, "Int", Max, "UPtr", StrPtr(Find), FTX)
        SendMessage(0x047C, Flags, FTX.Ptr, This.HWND)
        S := NumGet(FTX, 8 + A_PtrSize, "Int"), E := NumGet(FTX, 12 + A_PtrSize, "Int")
        if (S = -1) && (E = -1)
            return False
        This.SetSel(S, E)
        This.ScrollCaret()
        return True
    }
    ; -------------------------------------------------------------------------------------------------------------------
    ; Finds the next word break before or after the specified character position or retrieves information about
    ; the character at that position.
    FindWordBreak(CharPos, Mode := "Left") {
        ; CharPos : Character position.
        ; Mode    : Can be one of the keys specified in 'WB'.
        ; Returns the character index of the word break or other values depending on 'Mode'.
        ; For details see http://msdn.microsoft.com/en-us/library/bb788018(v=vs.85).aspx.
        ; EM_FINDWORDBREAK = 0x044C (WM_USER + 76)
        static WB := { LEFT: 0, RIGHT: 1, ISDELIMITER: 2, CLASSIFY: 3, MOVEWORDLEFT: 4, MOVEWORDRIGHT: 5, LEFTBREAK: 6, RIGHTBREAK: 7 }
        Option := WB.HasProp(Mode) ? WB[Mode] : 0
        return SendMessage(0x044C, Option, CharPos, This.HWND)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    GetSelText() { ; Retrieves the currently selected text as plain text
        ; Returns selected text.
        ; EM_GETSELTEXT = 0x043E, EM_EXGETSEL = 0x0434
        Txt := ""
        CR := This.GetSel()
        TxtL := CR.E - CR.S + 1
        if (TxtL > 1) {
            VarSetStrCapacity(&Txt, TxtL)
            SendMessage(0x043E, 0, StrPtr(Txt), This.HWND)
            VarSetStrCapacity(&Txt, -1)
        }
        return Txt
    }
    ; -------------------------------------------------------------------------------------------------------------------
    GetSel() { ; Retrieves the starting and ending character positions of the selection in a rich edit control
        ; Returns an object containing the keys S (start of selection) and E (end of selection)).
        ; EM_EXGETSEL = 0x0434
        CR := Buffer(8, 0)
        SendMessage(0x0434, 0, CR.Ptr, This.HWND)
        return { S: NumGet(CR, 0, "Int"), E: NumGet(CR, 4, "Int") }
    }
    ; -------------------------------------------------------------------------------------------------------------------
    GetText() {  ; Gets the whole content of the control as plain text
        ; EM_GETTEXTEX = 0x045E
        Txt := ""
        if (TxtL := This.GetTextLen() + 1) {
            GTX := Buffer(12 + (A_PtrSize * 2), 0) ; GETTEXTEX structure
            NumPut("UInt", TxtL * 2, GTX) ; cb
            NumPut("UInt", 1200, GTX, 8)  ; codepage = Unicode
            VarSetStrCapacity(&Txt, TxtL)
            SendMessage(0x045E, GTX.Ptr, StrPtr(Txt), This.HWND)
            VarSetStrCapacity(&Txt, -1)
        }
        return Txt
    }
    ; -------------------------------------------------------------------------------------------------------------------
    ; GetTextColors() { ; Gets the text and background colors - not implemented
    ; }
    ; -------------------------------------------------------------------------------------------------------------------
    GetTextLen() { ; Calculates text length in various ways
        ; EM_GETTEXTLENGTHEX = 0x045F
        GTL := Buffer(8, 0)     ; GETTEXTLENGTHEX structure
        NumPut("UInt", 1200, GTL, 4)  ; codepage = Unicode
        return SendMessage(0x045F, GTL.Ptr, 0, This.HWND)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    ; Retrieves the position of the first occurence of the specified text within the specified range.
    GetTextPos(Find, Min := 0, Max := -1, Mode := 1) {
        ; Find : Text to search for.
        ; Min  : Character position index immediately preceding the first character in the range.
        ;        Integer value to store as cpMin in the CHARRANGE structure.
        ;        Default: 0 - first character
        ; Max  : Character position immediately following the last character in the range.
        ;        Integer value to store as cpMax in the CHARRANGE structure.
        ;        Default: -1 - last character
        ; Mode : Any combination of the following values:
        ;        0 : search backward, 1 : search forward, 2 : match whole word only, 4 : case-sensitive
        ; Returns an object containing the keys S (start of text) and E (end of text) if found, otherwise False.
        ; EM_FINDTEXTEXW = 0x047C
        Flags := Mode & 0x07
        FTX := Buffer(16 + A_PtrSize, 0)
        NumPut("Int", Min, "Int", Max, "UPtr", StrPtr(Find), FTX)
        P := SendMessage(0x047C, Flags, FTX.Ptr, This.Hwnd) << 32 >> 32
        return (P = -1) ? False : { S: NumGet(FTX, 8 + A_PtrSize, "Int"), E: NumGet(FTX, 12 + A_PtrSize, "Int") }
    }
    ; -------------------------------------------------------------------------------------------------------------------
    GetTextRange(Min, Max) { ; Retrieves a specified range of characters from a rich edit control
        ; Min : Character position index immediately preceding the first character in the range.
        ;       Integer value to store as cpMin in the CHARRANGE structure.
        ; Max : Character position immediately following the last character in the range.
        ;       Integer value to store as cpMax in the CHARRANGE structure.
        ; CHARRANGE -> http://msdn.microsoft.com/en-us/library/bb787885(v=vs.85).aspx
        ; EM_GETTEXTRANGE = 0x044B
        if (Max <= Min)
            return ""
        Txt := ""
        VarSetStrCapacity(&Txt, Max - Min)
        TR := Buffer(8 + A_PtrSize, 0) ; TEXTRANGE Struktur
        NumPut("UInt", Min, "UInt", Max, "UPtr", StrPtr(Txt), TR)
        SendMessage(0x044B, 0, TR.Ptr, This.HWND)
        VarSetStrCapacity(&Txt, -1)
        return Txt
    }
    ; -------------------------------------------------------------------------------------------------------------------
    HideSelection(Mode) { ; Hides or shows the selection
        ; Mode : True to hide or False to show the selection.
        ; EM_HIDESELECTION = 0x043F (WM_USER + 63)
        SendMessage(0x043F, !!Mode, 0, This.HWND)
        return True
    }
    ; -------------------------------------------------------------------------------------------------------------------
    LimitText(Limit) { ; Sets an upper limit to the amount of text the user can type or paste into a rich edit control
        ; Limit : Specifies the maximum amount of text that can be entered.
        ;         If this parameter is zero, the default maximum is used, which is 64K characters.
        ; EM_EXLIMITTEXT =  0x435 (WM_USER + 53)
        SendMessage(0x0435, 0, Limit, This.HWND)
        return True
    }
    ; -------------------------------------------------------------------------------------------------------------------
    ReplaceSel(Text := "") { ; Replaces the selected text with the specified text
        ; EM_REPLACESEL = 0xC2
        return SendMessage(0xC2, 1, StrPtr(Text), This.HWND)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetText(Text := "", Mode?) { ; Replaces the selection or the whole content of the control
        ; Mode : Array of option flags. It can be any reasonable combination of the keys defined in 'ST'.
        ; For details see http://msdn.microsoft.com/en-us/library/bb774284(v=vs.85).aspx.
        ; EM_SETTEXTEX = 0x0461, CP_UNICODE = 1200
        ; ST_DEFAULT = 0, ST_KEEPUNDO = 1, ST_SELECTION = 2, ST_NEWCHARS = 4 ???
        static ST := { DEFAULT: 0, KEEPUNDO: 1, SELECTION: 2 }
        Flags := 0
        if IsSet(Mode) && (Type(Mode) = "Array") {
            for Value In Mode
                if ST.HasProp(Value)
                    Flags |= ST[Value]
        }
        CP := 1200
        TxtPtr := StrPtr(Text)
        ; RTF formatted text has to be passed as ANSI!!!
        if (SubStr(Text, 1, 5) = "{\rtf") || (SubStr(Text, 1, 5) = "{urtf") {
            Buf := Buffer(StrPut(Text, "CP0"), 0)
            StrPut(Text, Buf, "CP0")
            TxtPtr := Buf.Ptr
            CP := 0
        }
        STX := Buffer(8, 0)     ; SETTEXTEX structure
        NumPut("UInt", Flags, "UInt", CP, STX) ; flags, codepage
        return SendMessage(0x0461, STX.Ptr, TxtPtr, This.HWND)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetSel(Start, End) { ; Selects a range of characters
        ; Start : zero-based start index
        ; End   : zero-beased end index (-1 = end of text))
        ; EM_EXSETSEL = 0x0437
        CR := Buffer(8, 0)
        NumPut("Int", Start, "Int", End, CR)
        return SendMessage(0x0437, 0, CR.Ptr, This.HWND)
    }
    ; ===================================================================================================================
    ; Appearance, styles, and options
    ; ===================================================================================================================
    AutoURL(Mode := 1) { ; En- or disable AutoURLDetection
        ; Mode   :  one or a combination of the following values:
        ; Disable                  0
        ; AURL_ENABLEURL           1
        ; AURL_ENABLEEMAILADDR     2     ; Win 8+
        ; AURL_ENABLETELNO         4     ; Win 8+
        ; AURL_ENABLEEAURLS        8     ; Win 8+
        ; AURL_ENABLEDRIVELETTERS  16    ; WIn 8+
        ; EM_AUTOURLDETECT = 0x45B
        RetVal := SendMessage(0x045B, Mode & 0x1F, 0, This.HWND)
        WinRedraw(This.HWND)
        return RetVal
    }
    ; -------------------------------------------------------------------------------------------------------------------
    GetRect(&RC := "") { ; Retrieves the rich edit control's formatting rectangle
        ; Returns an object with keys L (eft), T (op), R (ight), and B (ottom).
        ; If a variable is passed in the Rect parameter, the complete RECT structure will be stored in it.
        RC := Buffer(16, 0)
        if !This.MultiLine
            return False
        SendMessage(0x00B2, 0, RC.Ptr, This.HWND)
        return { L: NumGet(RC, 0, "Int"), T: NumGet(RC, 4, "Int"), R: NumGet(RC, 8, "Int"), B: NumGet(RC, 12, "Int") }
    }
    ; -------------------------------------------------------------------------------------------------------------------
    GetOptions(&Options := "") { ; Retrieves the rich edit control`s options
        ; Returns an array of currently set options as the keys defined in 'ECO'.
        ; If a variable is passed in the Option parameter, the combined numeric value of the options will be stored in it.
        ; For details see http://msdn.microsoft.com/en-us/library/bb774178(v=vs.85).aspx.
        ; EM_GETOPTIONS = 0x044E
        static ECO := { AUTOWORDSELECTION: 0x01, AUTOVSCROLL: 0x40, AUTOHSCROLL: 0x80, NOHIDESEL: 0x100,
            READONLY: 0x800, WANTRETURN: 0x1000, SAVESEL: 0x8000, SELECTIONBAR: 0x01000000,
            VERTICAL: 0x400000 }
        Options := SendMessage(0x044E, 0, 0, This.HWND)
        O := []
        for Key, Value In ECO.OwnProps()
            if (Options & Value)
                O.Push(Key)
        return O
    }
    ; -------------------------------------------------------------------------------------------------------------------.
    GetStyles(&Styles := "") { ; Retrieves the current edit style flags
        ; Returns an object containing keys as defined in 'SES'.
        ; If a variable is passed in the Styles parameter, the combined numeric value of the styles will be stored in it.
        ; For details see http://msdn.microsoft.com/en-us/library/bb788031(v=vs.85).aspx.
        ; EM_GETEDITSTYLE	= 0x04CD (WM_USER + 205)
        static SES := { 1: "EMULATESYSEDIT", 1: "BEEPONMAXTEXT", 4: "EXTENDBACKCOLOR", 32: "NOXLTSYMBOLRANGE",
            64: "USEAIMM", 128: "NOIME", 256: "ALLOWBEEPS", 512: "UPPERCASE", 1024: "LOWERCASE",
            2048: "NOINPUTSEQUENCECHK", 4096: "BIDI", 8192: "SCROLLONKILLFOCUS", 16384: "XLTCRCRLFTOCR",
            32768: "DRAFTMODE", 0x0010000: "USECTF", 0x0020000: "HIDEGRIDLINES", 0x0040000: "USEATFONT",
            0x0080000: "CUSTOMLOOK", 0x0100000: "LBSCROLLNOTIFY", 0x0200000: "CTFALLOWEMBED",
            0x0400000: "CTFALLOWSMARTTAG", 0x0800000: "CTFALLOWPROOFING" }
        Styles := SendMessage(0x04CD, 0, 0, This.HWND)
        S := []
        for Key, Value In SES.OwnProps()
            if (Styles & Key)
                S.Push(Value)
        return S
    }
    ; -------------------------------------------------------------------------------------------------------------------
    GetZoom() { ; Gets the current zoom ratio
        ; Returns the zoom ratio in percent.
        ; EM_GETZOOM = 0x04E0
        N := Buffer(4, 0), D := Buffer(4, 0)
        SendMessage(0x04CD, N.Ptr, D.Ptr, This.HWND)
        N := NumGet(N, 0, "Int"), D := NumGet(D, 0, "Int")
        return (N = 0) && (D = 0) ? 100 : Round(N / D * 100)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetBkgndColor(Color) { ; Sets the background color
        ; Color : RGB integer value or HTML color name or
        ;         "Auto" to reset to system default color.
        ; Returns the prior background color.
        ; EM_SETBKGNDCOLOR = 0x0443
        if (Color = "Auto")
            System := True, Color := 0
        else
            System := False, Color := This.GetBGR(Color)
        Result := SendMessage(0x0443, System, Color, This.HWND)
        return This.GetRGB(Result)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetOptions(Options, Mode := "SET") { ; Sets the options for a rich edit control
        ; Options : Array of options as the keys defined in 'ECO'.
        ; Mode    : Settings mode: SET, OR, AND, XOR
        ; For details see http://msdn.microsoft.com/en-us/library/bb774254(v=vs.85).aspx.
        ; EM_SETOPTIONS = 0x044D
        static ECO := { AUTOWORDSELECTION: 0x01, AUTOVSCROLL: 0x40, AUTOHSCROLL: 0x80, NOHIDESEL: 0x100, READONLY: 0x800, WANTRETURN: 0x1000, SAVESEL: 0x8000, SELECTIONBAR: 0x01000000, VERTICAL: 0x400000 }
        , ECOOP := { SET: 0x01, OR: 0x02, AND: 0x03, XOR: 0x04 }
        if (Type(Options) != "Array") || !ECOOP.HasProp(Mode)
            return False
        O := 0
        for Each, Option In Options {
            if ECO.HasProp(Option)
                O |= ECO.%Option%
            else
                return False
        }
        return SendMessage(0x044D, ECOOP.%Mode%, O, This.HWND)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetRect(L, T, R, B) { ; Sets the formatting rectangle of a multiline edit control
        ; L (eft), T (op), R (ight), B (ottom)
        ; Set all parameters to zero to set it to its default values.
        ; Returns True for multiline controls.
        if !This.MultiLine
            return False
        if (L + T + R + B) = 0
            RC := { Ptr: 0 }
        else {
            RC := Buffer(16, 0)
            NumPut("Int", L, "Int", T, "Int", R, "Int", B, RC)
        }
        SendMessage(0xB3, 0, RC.Ptr, This.HWND)
        return True
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetStyles(Styles) { ; Sets the current edit style flags for a rich edit control.
        ; Styles : Object containing on or more of the keys defined in 'SES'.
        ;          If the value is 0 the style will be removed, otherwise it will be added.
        ; For details see http://msdn.microsoft.com/en-us/library/bb774236(v=vs.85).aspx.
        ; EM_SETEDITSTYLE	= 0x04CC (WM_USER + 204)
        static SES := { EMULATESYSEDIT: 1, BEEPONMAXTEXT: 2, EXTENDBACKCOLOR: 4, NOXLTSYMBOLRANGE: 32, USEAIMM: 64,
            NOIME: 128, ALLOWBEEPS: 256, UPPERCASE: 512, LOWERCASE: 1024, NOINPUTSEQUENCECHK: 2048,
            BIDI: 4096, SCROLLONKILLFOCUS: 8192, XLTCRCRLFTOCR: 16384, DRAFTMODE: 32768,
            USECTF: 0x0010000, HIDEGRIDLINES: 0x0020000, USEATFONT: 0x0040000, CUSTOMLOOK: 0x0080000,
            LBSCROLLNOTIFY: 0x0100000, CTFALLOWEMBED: 0x0200000, CTFALLOWSMARTTAG: 0x0400000,
            CTFALLOWPROOFING: 0x0800000 }
        if (Type(Styles) != "Object")
            return False
        Flags := Mask := 0
        for Style, Value In Styles.OwnProps() {
            if SES.HasProp(Style) {
                Mask |= SES.%Style%
                if (Value != 0)
                    Flags |= SES.%Style%
            }
        }
        return Mask ? SendMessage(0x04CC, Flags, Mask, This.HWND) : False
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetZoom(Ratio := "") { ; Sets the zoom ratio of a rich edit control.
        ; Ratio : Float value between 100/64 and 6400; a ratio of 0 turns zooming off.
        ; EM_SETZOOM = 0x4E1
        return SendMessage(0x04E1, (Ratio > 0 ? Ratio : 100), 100, This.HWND)
    }
    ; ===================================================================================================================
    ; Copy, paste, etc.
    ; ===================================================================================================================
    CanRedo() { ; Determines whether there are any actions in the control redo queue.
        ; EM_CANREDO = 0x0455 (WM_USER + 85)
        return SendMessage(0x0455, 0, 0, This.HWND)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    CanUndo() { ; Determines whether there are any actions in an edit control's undo queue.
        ; EM_CANUNDO = 0x00C6
        return SendMessage(0x00C6, 0, 0, This.HWND)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    Clear() {
        ; WM_CLEAR = 0x303
        return SendMessage(0x0303, 0, 0, This.HWND)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    Copy() {
        ; WM_COPY = 0x301
        return SendMessage(0x0301, 0, 0, This.HWND)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    Cut() {
        ; WM_CUT = 0x300
        return SendMessage(0x0300, 0, 0, This.HWND)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    Paste() {
        ; WM_PASTE = 0x302
        return SendMessage(0x0302, 0, 0, This.HWND)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    Redo() {
        ; EM_REDO := 0x454
        return SendMessage(0x0454, 0, 0, This.HWND)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    Undo() {
        ; EM_UNDO = 0xC7
        return SendMessage(0x00C7, 0, 0, This.HWND)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SelAll() {
        ; Select all
        return This.SetSel(0, -1)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    Deselect() {
        ; Deselect all
        Sel := This.GetSel()
        return This.SetSel(Sel.S, Sel.S)
    }
    ; ===================================================================================================================
    ; Font & colors
    ; ===================================================================================================================
    ChangeFontSize(Diff) { ; Change font size
        ; Diff : any positive or negative integer, positive values are treated as +1, negative as -1.
        ; Returns new size.
        ; EM_SETFONTSIZE = 0x04DF
        ; Font size changes by 1 in the range 4 - 11 pt, by 2 for 12 - 28 pt, afterward to 36 pt, 48 pt, 72 pt, 80 pt,
        ; and by 10 for > 80 pt. The maximum value is 160 pt, the minimum is 4 pt
        Font := This.GetFont()
        if (Diff > 0 && Font.Size < 160) || (Diff < 0 && Font.Size > 4)
            SendMessage(0x04DF, (Diff > 0 ? 1 : -1), 0, This.HWND)
        else
            return False
        Font := This.GetFont()
        return Font.Size
    }
    ; -------------------------------------------------------------------------------------------------------------------
    GetFont(Default := False) { ; Get current font
        ; Set Default to True to get the default font.
        ; Returns an object containing current options (see SetFont())
        ; EM_GETCHARFORMAT = 0x043A
        ; BOLD_FONTTYPE = 0x0100, ITALIC_FONTTYPE = 0x0200
        ; CFM_BOLD = 1, CFM_ITALIC = 2, CFM_UNDERLINE = 4, CFM_STRIKEOUT = 8, CFM_PROTECTED = 16, CFM_SUBSCRIPT = 0x30000
        ; CFM_BACKCOLOR = 0x04000000, CFM_CHARSET := 0x08000000, CFM_FACE = 0x20000000, CFM_COLOR = 0x40000000
        ; CFM_SIZE = 0x80000000
        ; CFE_SUBSCRIPT = 0x10000, CFE_SUPERSCRIPT = 0x20000, CFE_AUTOBACKCOLOR = 0x04000000, CFE_AUTOCOLOR = 0x40000000
        ; SCF_SELECTION = 1
        static Mask := 0xEC03001F
        static Effects := 0xEC000000
        CF2 := RichEdit.CHARFORMAT2()
        CF2.Mask := Mask
        CF2.Effects := Effects
        SendMessage(0x043A, (Default ? 0 : 1), CF2.Ptr, This.HWND)
        Font := {}
        Font.Name := CF2.FaceName
        Font.Size := CF2.Height / 20
        CFS := CF2.Effects
        Style := (CFS & 1 ? "B" : "") . (CFS & 2 ? "I" : "") . (CFS & 4 ? "U" : "") . (CFS & 8 ? "S" : "")
        . (CFS & 0x10000 ? "L" : "") . (CFS & 0x20000 ? "H" : "") . (CFS & 16 ? "P" : "")
        Font.Style := Style = "" ? "N" : Style
        Font.Color := This.GetRGB(CF2.TextColor)
        if (CF2.Effects & 0x40000000)  ; CFE_AUTOCOLOR
            Font.Color := "Auto"
        else
            Font.Color := This.GetRGB(CF2.TextColor)
        if (CF2.Effects & 0x04000000) ; CFE_AUTOBACKCOLOR
            Font.BkColor := "Auto"
        else
            Font.BkColor := This.GetRGB(CF2.BackColor)
        Font.CharSet := CF2.CharSet
        return Font
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetDefaultFont(Font := "") { ; Set default font
        ; Font : Optional object - see SetFont().
        if IsObject(Font) {
            for Key, Value In Font.OwnProps()
                if This.DefFont.HasProp(Key)
                    This.DefFont.%Key% := Value
        }
        return This.SetFont(This.DefFont)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetFont(Font) { ; Set current/default font
        ; Font : Object containing the following keys
        ;        Name    : optional font name
        ;        Size    : optional font size in points
        ;        Style   : optional string of one or more of the following styles
        ;                  B = bold, I = italic, U = underline, S = strikeout, L = subscript
        ;                  H = superschript, P = protected, N = normal
        ;        Color   : optional text color as RGB integer value or HTML color name
        ;                  "Auto" for "automatic" (system's default) color
        ;        BkColor : optional text background color (see Color)
        ;                  "Auto" for "automatic" (system's default) background color
        ;        CharSet : optional font character set
        ;                  1 = DEFAULT_CHARSET, 2 = SYMBOL_CHARSET
        ;        Empty parameters preserve the corresponding properties
        ; EM_SETCHARFORMAT = 0x0444
        ; SCF_DEFAULT = 0, SCF_SELECTION = 1
        if (Type(Font) != "Object")
            return False
        CF2 := RichEdit.CHARFORMAT2()
        Mask := Effects := 0
        if Font.HasProp("Name") && (Font.Name != "") {
            Mask |= 0x20000000, Effects |= 0x20000000 ; CFM_FACE, CFE_FACE
            CF2.FaceName := Font.Name
        }
        if Font.HasProp("Size") && (Font.Size != "") {
            Size := Font.Size
            if (Size < 161)
                Size *= 20
            Mask |= 0x80000000, Effects |= 0x80000000 ; CFM_SIZE, CFE_SIZE
            CF2.Height := Size
        }
        if Font.HasProp("Style") && (Font.Style != "") {
            Mask |= 0x3001F           ; all font styles
            if InStr(Font.Style, "B")
                Effects |= 1           ; CFE_BOLD
            if InStr(Font.Style, "I")
                Effects |= 2           ; CFE_ITALIC
            if InStr(Font.Style, "U")
                Effects |= 4           ; CFE_UNDERLINE
            if InStr(Font.Style, "S")
                Effects |= 8           ; CFE_STRIKEOUT
            if InStr(Font.Style, "P")
                Effects |= 16          ; CFE_PROTECTED
            if InStr(Font.Style, "L")
                Effects |= 0x10000     ; CFE_SUBSCRIPT
            if InStr(Font.Style, "H")
                Effects |= 0x20000     ; CFE_SUPERSCRIPT
        }
        if Font.HasProp("Color") && (Font.Color != "") {
            Mask |= 0x40000000        ; CFM_COLOR
            if (Font.Color = "Auto")
                Effects |= 0x40000000  ; CFE_AUTOCOLOR
            else
                CF2.TextColor := This.GetBGR(Font.Color)
        }
        if Font.HasProp("BkColor") && (Font.BkColor != "") {
            Mask |= 0x04000000        ; CFM_BACKCOLOR
            if (Font.BkColor = "Auto")
                Effects |= 0x04000000  ; CFE_AUTOBACKCOLOR
            else
                CF2.BackColor := This.GetBGR(Font.BkColor)
        }
        if Font.HasProp("CharSet") && (Font.CharSet != "") {
            Mask |= 0x08000000, Effects |= 0x08000000 ; CFM_CHARSET, CFE_CHARSET
            CF2.CharSet := Font.CharSet = 2 ? 2 : 1 ; SYMBOL|DEFAULT
        }
        if (Mask != 0) {
            Mode := Font.HasProp("Default") ? 0 : 1
            CF2.Mask := Mask
            CF2.Effects := Effects
            return SendMessage(0x0444, Mode, CF2.Ptr, This.HWND)
        }
        return False
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetFontStyles(Styles, Default := False) { ; Set the font styles for the current selection or the default font
        ; Styles : a string containing one or more of the following styles
        ;          B = bold, I = italic, U = underline, S = strikeout, L = subscript, H = superschript, P = protected,
        ;          N = normal (reset all other styles)
        ; EM_GETCHARFORMAT = 0x043A, EM_SETCHARFORMAT = 0x0444
        ; CFM_BOLD = 1, CFM_ITALIC = 2, CFM_UNDERLINE = 4, CFM_STRIKEOUT = 8, CFM_PROTECTED = 16, CFM_SUxSCRIPT = 0x30000
        ; CFE_SUBSCRIPT = 0x10000, CFE_SUPERSCRIPT = 0x20000, SCF_SELECTION = 1
        static FontStyles := { N: 0, B: 1, I: 2, U: 4, S: 8, P: 16, L: 0x010000, H: 0x020000 }
        CF2 := RichEdit.CHARFORMAT2()
        CF2.Mask := 0x3001F ; FontStyles
        if InStr(Styles, "N")
            CF2.Effects := 0
        else
            for Style In StrSplit(Styles)
                CF2.Effects |= FontStyles.HasProp(Style) ? FontStyles.%Style% : 0
        return SendMessage(0x0444, !Default, CF2.Ptr, This.HWND)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    ToggleFontStyle(Style) { ; Toggle single font style
        ; Style : one of the following styles
        ;         B = bold, I = italic, U = underline, S = strikeout, L = subscript, H = superschript, P = protected,
        ;         N = normal (reset all other styles)
        ; EM_GETCHARFORMAT = 0x043A, EM_SETCHARFORMAT = 0x0444
        ; CFM_BOLD = 1, CFM_ITALIC = 2, CFM_UNDERLINE = 4, CFM_STRIKEOUT = 8, CFM_PROTECTED = 16, CFM_SUBSCRIPT = 0x30000
        ; CFE_SUBSCRIPT = 0x10000, CFE_SUPERSCRIPT = 0x20000, SCF_SELECTION = 1
        static FontStyles := { N: 0, B: 1, I: 2, U: 4, S: 8, P: 16, L: 0x010000, H: 0x020000 }
        if !FontStyles.HasProp(Style)
            return False
        CF2 := This.GetCharFormat()
        CF2.Mask := 0x3001F ; FontStyles
        if (Style = "N")
            CF2.Effects := 0
        else
            CF2.Effects ^= FontStyles.%Style%
        return SendMessage(0x0444, 1, CF2.Ptr, This.HWND)
    }
    ; ===================================================================================================================
    ; Paragraph formatting
    ; ===================================================================================================================
    AlignText(Align := 1) { ; Set paragraph's alignment
        ; Note:  Values greater 3 doesn't seem to work though they should as documented
        ; Align: may contain one of the following numbers:
        ;        PFA_LEFT             1
        ;        PFA_RIGHT            2
        ;        PFA_CENTER           3
        ;        PFA_JUSTIFY          4 // New paragraph-alignment option 2.0 (*)
        ;        PFA_FULL_INTERWORD   4 // These are supported in 3.0 with advanced
        ;        PFA_FULL_INTERLETTER 5 // typography enabled
        ;        PFA_FULL_SCALED      6
        ;        PFA_FULL_GLYPHS      7
        ;        PFA_SNAP_GRID        8
        ; EM_SETPARAFORMAT = 0x0447, PFM_ALIGNMENT = 0x08
        static PFA := { LEFT: 1, RIGHT: 2, CENTER: 3, JUSTIFY: 4 }
        if PFA.HasProp(Align)
            Align := PFA.%Align%
        if (Align >= 1) && (ALign <= 8) {
            PF2 := RichEdit.PARAFORMAT2() ; PARAFORMAT2 struct
            PF2.Mask := 0x08              ; dwMask
            PF2.Alignment := Align        ; wAlignment
            SendMessage(0x0447, 0, PF2.Ptr, This.HWND)
            return True
        }
        return False
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetBorder(Widths, Styles) { ; Set paragraph's borders
        ; Borders are not displayed in RichEdit, so the call of this function has no visible result.
        ; Even WordPad distributed with Win7 does not show them, but e.g. Word 2007 does.
        ; Widths : Array of the 4 border widths in the range of 1 - 15 in order left, top, right, bottom; zero = no border
        ; Styles : Array of the 4 border styles in the range of 0 - 7 in order left, top, right, bottom (see remarks)
        ; Note:
        ; The description on MSDN at http://msdn.microsoft.com/en-us/library/bb787942(v=vs.85).aspx is wrong!
        ; To set borders you have to put the border width into the related nibble (4 Bits) of wBorderWidth
        ; (in order: left (0 - 3), top (4 - 7), right (8 - 11), and bottom (12 - 15). The values are interpreted as
        ; half points (i.e. 10 twips). Border styles are set in the related nibbles of wBorders.
        ; Valid styles seem to be:
        ;     0 : \brdrdash (dashes)
        ;     1 : \brdrdashsm (small dashes)
        ;     2 : \brdrdb (double line)
        ;     3 : \brdrdot (dotted line)
        ;     4 : \brdrhair (single/hair line)
        ;     5 : \brdrs ? looks like 3
        ;     6 : \brdrth ? looks like 3
        ;     7 : \brdrtriple (triple line)
        ; EM_SETPARAFORMAT = 0x0447, PFM_BORDER = 0x800
        if (Type(Widths) != "Array") || (Type(Styles) != "Array") || (Widths.Length != 4) || (Styles.Length != 4)
            return False
        W := S := 0
        for I, V In Widths {
            if (V)
                W |= V << ((A_Index - 1) * 4)
            if Styles[I]
                S |= Styles[I] << ((A_Index - 1) * 4)
        }
        PF2 := RichEdit.PARAFORMAT2()
        PF2.Mask := 0x800
        PF2.BorderWidth := W
        PF2.Borders := S
        return SendMessage(0x0447, 0, PF2.Ptr, This.HWND)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetLineSpacing(Lines) { ; Sets paragraph's line spacing.
        ; Lines : number of lines as integer or float.
        ; SpacingRule = 5:
        ; The value of dyLineSpacing / 20 is the spacing, in lines, from one line to the next. Thus, setting
        ; dyLineSpacing to 20 produces single-spaced text, 40 is double spaced, 60 is triple spaced, and so on.
        ; EM_SETPARAFORMAT = 0x0447, PFM_LINESPACING = 0x100
        PF2 := RichEdit.PARAFORMAT2()
        PF2.Mask := 0x100
        PF2.LineSpacing := Abs(Lines) * 20
        PF2.LineSpacingRule := 5
        return SendMessage(0x0447, 0, PF2.Ptr, This.HWND)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetParaIndent(Indent := "Reset") { ; Sets space left/right of the paragraph.
        ; Indent : Object containing up to three keys:
        ;          - Start  : Optional - Absolute indentation of the paragraph's first line.
        ;          - Right  : Optional - Indentation of the right side of the paragraph, relative to the right margin.
        ;          - Offset : Optional - Indentation of the second and subsequent lines, relative to the indentation
        ;                                of the first line.
        ;          Values are interpreted as centimeters/inches depending on the user's locale measurement settings.
        ;          Call without passing a parameter to reset indentation.
        ; EM_SETPARAFORMAT = 0x0447
        ; PFM_STARTINDENT  = 0x0001
        ; PFM_RIGHTINDENT  = 0x0002
        ; PFM_OFFSET       = 0x0004
        static PFM := { STARTINDENT: 0x01, RIGHTINDENT: 0x02, OFFSET: 0x04 }
        Measurement := This.GetMeasurement()
        PF2 := RichEdit.PARAFORMAT2()
        if (Indent = "Reset")
            PF2.Mask := 0x07 ; reset indentation
        else if !IsObject(Indent)
            return False
        else {
            PF2.Mask := 0
            if (Indent.HasProp("Start")) {
                PF2.Mask |= PFM.STARTINDENT
                PF2.StartIndent := Round((Indent.Start / Measurement) * 1440)
            }
            if (Indent.HasProp("Offset")) {
                PF2.Mask |= PFM.OFFSET
                PF2.Offset := Round((Indent.Offset / Measurement) * 1440)
            }
            if (Indent.HasProp("Right")) {
                PF2.Mask |= PFM.RIGHTINDENT
                PF2.RightIndent := Round((Indent.Right / Measurement) * 1440)
            }
        }
        if (PF2.Mask)
            return SendMessage(0x0447, 0, PF2.Ptr, This.HWND)
        return False
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetParaNumbering(Numbering := "Reset") {
        ; Numbering : Object containing up to four keys:
        ;             - Type  : Options used for bulleted or numbered paragraphs.
        ;             - Style : Optional - Numbering style used with numbered paragraphs.
        ;             - Tab   : Optional - Minimum space between a paragraph number and the paragraph text.
        ;             - Start : Optional - Sequence number used for numbered paragraphs (e.g. 3 for C or III)
        ;             Tab is interpreted as centimeters/inches depending on the user's locale measurement settings.
        ;             Call without passing a parameter to reset numbering.
        ; EM_SETPARAFORMAT = 0x0447
        ; PARAFORMAT numbering options
        ; PFN_BULLET   1 ; tomListBullet
        ; PFN_ARABIC   2 ; tomListNumberAsArabic:   0, 1, 2,	...
        ; PFN_LCLETTER 3 ; tomListNumberAsLCLetter: a, b, c,	...
        ; PFN_UCLETTER 4 ; tomListNumberAsUCLetter: A, B, C,	...
        ; PFN_LCROMAN  5 ; tomListNumberAsLCRoman:  i, ii, iii,	...
        ; PFN_UCROMAN  6 ; tomListNumberAsUCRoman:  I, II, III,	...
        ; PARAFORMAT2 wNumberingStyle options
        ; PFNS_PAREN     0x0000 ; default, e.g.,                 1)
        ; PFNS_PARENS    0x0100 ; tomListParentheses/256, e.g., (1)
        ; PFNS_PERIOD    0x0200 ; tomListPeriod/256, e.g.,       1.
        ; PFNS_PLAIN     0x0300 ; tomListPlain/256, e.g.,        1
        ; PFNS_NONUMBER  0x0400 ; used for continuation w/o number
        ; PFNS_NEWNUMBER 0x8000 ; start new number with wNumberingStart
        ; PFM_NUMBERING      0x0020
        ; PFM_NUMBERINGSTYLE 0x2000
        ; PFM_NUMBERINGTAB   0x4000
        ; PFM_NUMBERINGSTART 0x8000
        static PFM := { Type: 0x0020, Style: 0x2000, Tab: 0x4000, Start: 0x8000 }
        static PFN := { Bullet: 1, Arabic: 2, LCLetter: 3, UCLetter: 4, LCRoman: 5, UCRoman: 6 }
        static PFNS := { Paren: 0x0000, Parens: 0x0100, Period: 0x0200, Plain: 0x0300, None: 0x0400, New: 0x8000 }
        PF2 := RichEdit.PARAFORMAT2()
        if (Numbering = "Reset")
            PF2.Mask := 0xE020
        else if !IsObject(Numbering)
            return False
        else {
            if (Numbering.HasProp("Type")) {
                PF2.Mask |= PFM.Type
                PF2.Numbering := PFN.%Numbering.Type%
            }
            if (Numbering.HasProp("Style")) {
                PF2.Mask |= PFM.Style
                PF2.NumberingStyle := PFNS.%Numbering.Style%
            }
            if (Numbering.HasProp("Tab")) {
                PF2.Mask |= PFM.Tab
                PF2.NumberingTab := Round((Numbering.Tab / This.GetMeasurement()) * 1440)
            }
            if (Numbering.HasProp("Start")) {
                PF2.Mask |= PFM.Start
                PF2.NumberingStart := Numbering.Start
            }
        }
        if (PF2.Mask)
            return SendMessage(0x0447, 0, PF2.Ptr, This.HWND)
        return False
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetParaSpacing(Spacing := "Reset") { ; Set space before / after the paragraph
        ; Spacing : Object containing one or two keys:
        ;           - Before : additional space before the paragraph in points
        ;           - After  : additional space after the paragraph in points
        ;           Call without passing a parameter to reset spacing to zero.
        ; EM_SETPARAFORMAT = 0x0447
        ; PFM_SPACEBEFORE  = 0x0040
        ; PFM_SPACEAFTER   = 0x0080
        static PFM := { Before: 0x40, After: 0x80 }
        PF2 := RichEdit.PARAFORMAT2()
        if (Spacing = "Reset")
            PF2.Mask := 0xC0 ; reset spacing
        else if !IsObject(Spacing)
            return False
        else {
            if Spacing.HasProp("Before") && (Spacing.Before >= 0) {
                PF2.Mask |= PFM.Before
                PF2.SpaceBefore := Round(Spacing.Before * 20)
            }
            if Spacing.HasProp("After") && (Spacing.After >= 0) {
                PF2.Mask |= PFM.After
                PF2.SpaceAfter := Round(Spacing.After * 20)
            }
        }
        if (PF2.Mask)
            return SendMessage(0x0447, 0, PF2.Ptr, This.HWND)
        return False
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetDefaultTabs(Distance) { ; Set default tabstops
        ; Distance will be interpreted as inches or centimeters depending on the current user's locale.
        ; EM_SETTABSTOPS = 0xCB
        static DUI := 64      ; dialog units per inch
            , MinTab := 0.20 ; minimal tab distance
            , MaxTab := 3.00 ; maximal tab distance
        IM := This.GetMeasurement()
        Distance := StrReplace(Distance, ",", ".")
        Distance := Round(Distance / IM, 2)
        if (Distance < MinTab)
            Distance := MinTab
        else if (Distance > MaxTab)
            Distance := MaxTab
        TabStops := Buffer(4, 0)
        NumPut("Int", Round(DUI * Distance), TabStops)
        Result := SendMessage(0x00CB, 1, TabStops.Ptr, This.HWND)
        DllCall("UpdateWindow", "Ptr", This.HWND)
        return Result
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SetTabStops(TabStops := "Reset") { ; Set paragraph's tabstobs
        ; TabStops is an object containing the integer position as hundredth of inches/centimeters as keys
        ; and the alignment ("L", "C", "R", or "D") as values.
        ; The position will be interpreted as hundredth of inches or centimeters depending on the current user's locale.
        ; Call without passing a  parameter to reset to default tabs.
        ; EM_SETPARAFORMAT = 0x0447, PFM_TABSTOPS = 0x10
        static MinT := 30                ; minimal tabstop in hundredth of inches
        static MaxT := 830               ; maximal tabstop in hundredth of inches
        ; left aligned (default)
        ;centered
        ;right aligned
        ;decimal tabstop
        static Align := { L: 0x00000000, C: 0x01000000, R: 0x02000000, D: 0x03000000 }
        static MAX_TAB_STOPS := 32
        static MAX_TAB_STOPS := 32
        IC := This.GetMeasurement()
        PF2 := RichEdit.PARAFORMAT2()
        PF2.Mask := 0x10
        if (TabStops = "Reset")
            return !!SendMessage(0x0447, 0, PF2.Ptr, This.HWND)
        if !IsObject(TabStops)
            return False
        Tabs := []
        for Position, Alignment In TabStops.OwnProps() {
            Position /= IC
            if (Position < MinT) Or (Position > MaxT) ||
            !Align.HasProp(Alignment) Or (A_Index > MAX_TAB_STOPS)
                return False
            Tabs.Push(Align.%Alignment% | Round((Position / 100) * 1440))
        }
        if (Tabs.Length) {
            PF2.Tabs := Tabs
            return SendMessage(0x0447, 0, PF2.Ptr, This.HWND)
        }
        return False
    }
    ; ===================================================================================================================
    ; Line handling
    ; ===================================================================================================================
    GetCaretLine() { ; Get the line containing the caret
        ; EM_LINEINDEX = 0xBB, EM_EXLINEFROMCHAR = 0x0436
        Result := SendMessage(0x00BB, -1, 0, This.HWND)
        return SendMessage(0x0436, 0, Result, This.HWND) + 1
    }
    ; -------------------------------------------------------------------------------------------------------------------
    GetLineCount() { ; Get the total number of lines
        ; EM_GETLINECOUNT = 0xBA
        return SendMessage(0x00BA, 0, 0, This.HWND)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    GetLineIndex(LineNumber) { ; Get the index of the first character of the specified line.
        ; EM_LINEINDEX := 0x00BB
        ; LineNumber   -  zero-based line number
        return SendMessage(0x00BB, LineNumber, 0, This.HWND)
    }
    ; ===================================================================================================================
    ; Statistics
    ; ===================================================================================================================
    GetStatistics() { ; Get some statistic values
        ; Get the line containing the caret, it's position in this line, the total amount of lines, the absulute caret
        ; position and the total amount of characters.
        ; EM_GETSEL = 0xB0, EM_LINEFROMCHAR = 0xC9, EM_LINEINDEX = 0xBB, EM_GETLINECOUNT = 0xBA
        Stats := {}
        SB := Buffer(A_PtrSize, 0)
        SendMessage(0x00B0, SB.Ptr, 0, This.Hwnd)
        LI := This.GetLineIndex(-1)
        Stats.LinePos := NumGet(SB, "Ptr") - LI + 1
        Stats.Line := SendMessage(0x00C9, -1, 0, This.HWND) + 1
        Stats.LineCount := This.GetLineCount()
        Stats.CharCount := This.GetTextLen()
        return Stats
    }
    ; ===================================================================================================================
    ; Layout
    ; ===================================================================================================================
    WordWrap(On) { ; Turn wordwrapping on/off
        ; EM_SCROLLCARET = 0xB7
        Sel := This.GetSel()
        SendMessage(0x0448, 0, On ? 0 : -1, This.HWND)
        This.SetSel(Sel.S, Sel.E)
        SendMessage(0x00B7, 0, 0, This.HWND)
        return On
    }
    ; -------------------------------------------------------------------------------------------------------------------
    WYSIWYG(On) { ; Show control as printed (WYSIWYG)
        ; Text measuring is based on the default printer's capacities, thus changing the printer may produce different
        ; results. See remarks/comments in Print() also.
        ; EM_SCROLLCARET = 0xB7, EM_SETTARGETDEVICE = 0x0448
        ; PD_RETURNDC = 0x0100, PD_RETURNDEFAULT = 0x0400
        static PDC := 0
        static PD_Size := (A_PtrSize = 4 ? 66 : 120)
        static OffFlags := A_PtrSize * 5
        Sel := This.GetSel()
        if !(On) {
            DllCall("LockWindowUpdate", "Ptr", This.HWND)
            DllCall("DeleteDC", "Ptr", PDC)
            SendMessage(0x0448, 0, -1, This.HWND)
            This.SetSel(Sel.S, Sel.E)
            SendMessage(0x00B7, 0, 0, This.HWND)
            DllCall("LockWindowUpdate", "Ptr", 0)
            return True
        }
        PD := Buffer(PD_Size, 0)
        Numput("UInt", PD_Size, PD)
        NumPut("UInt", 0x0100 | 0x0400, PD, A_PtrSize * 5) ; PD_RETURNDC | PD_RETURNDEFAULT
        if !DllCall("Comdlg32.dll\PrintDlg", "Ptr", PD.Ptr, "Int")
            return
        DllCall("GlobalFree", "Ptr", NumGet(PD, A_PtrSize * 2, "UPtr"))
        DllCall("GlobalFree", "Ptr", NumGet(PD, A_PtrSize * 3, "UPtr"))
        PDC := NumGet(PD, A_PtrSize * 4, "UPtr")
        DllCall("LockWindowUpdate", "Ptr", This.HWND)
        Caps := This.GetPrinterCaps(PDC)
        ; Set up page size and margins in pixel
        UML := This.Margins.LT                   ; user margin left
        UMR := This.Margins.RT                   ; user margin right
        PML := Caps.POFX                         ; physical margin left
        PMR := Caps.PHYW - Caps.HRES - Caps.POFX ; physical margin right
        LPW := Caps.HRES                         ; logical page width
        ; Adjust margins
        UML := UML > PML ? (UML - PML) : 0
        UMR := UMR > PMR ? (UMR - PMR) : 0
        LineLen := LPW - UML - UMR
        SendMessage(0x0448, PDC, LineLen, This.HWND)
        This.SetSel(Sel.S, Sel.E)
        SendMessage(0x00B7, 0, 0, This.HWND)
        DllCall("LockWindowUpdate", "Ptr", 0)
        return True
    }
    ; ===================================================================================================================
    ; File handling
    ; ===================================================================================================================
    LoadFile(File, Mode := "Open") { ; Load file
        ; File : file name
        ; Mode : Open / Add / Insert
        ;        Open   : Replace control's content
        ;        Append : Append to conrol's content
        ;        Insert : Insert at / replace current selection
        if !FileExist(File)
            return False
        Ext := ""
        SplitPath(File, , , &Ext)
        if (Ext = "rtf") {
            switch Mode {
                case "Open":
                    Selection := False
                case "Insert":
                    Selection := True
                case "Append":
                    This.SetSel(-1, -2)
                    Selection := True
            }
            This.LoadRTF(File, Selection)
        }
        else {
            Text := FileRead(File)
            switch Mode {
                case "Open":
                    This.SetText(Text)
                case "Insert":
                    This.ReplaceSel(Text)
                case "Append":
                    This.SetSel(-1, -2)
                    This.ReplaceSel(Text)
            }
        }
        return True
    }
    ; -------------------------------------------------------------------------------------------------------------------
    SaveFile(File) { ; Save file
        ; File : file name
        ; Returns True on success, otherwise False.
        This.Gui.Opt("+OwnDialogs")
        Ext := ""
        SplitPath(File, , , &Ext)
        Text := Ext = "rtf" ? This.GetRTF() : This.GetText()
        try {
            FileObj := FileOpen(File, "w")
            FileObj.Write(Text)
            FileObj.Close()
            return True
        }
        catch as Err {
            MsgBox 16, A_ThisFunc, "Couldn't save '" . File . "'!`n`n" . Type(Err) ": " Err.Message
            return False
        }
    }
    ; ===================================================================================================================
    ; Printing
    ; THX jballi ->  http://www.autohotkey.com/board/topic/45513-function-he-print-wysiwyg-print-for-the-hiedit-control/
    ; ===================================================================================================================
    Print() {
        ; EM_FORMATRANGE = 0x0439, EM_SETTARGETDEVICE = 0x0448
        ; ----------------------------------------------------------------------------------------------------------------
        ; Static variables
        static PD_ALLPAGES := 0x00, PD_SELECTION := 0x01, PD_PAGENUMS := 0x02, PD_NOSELECTION := 0x04
            , PD_RETURNDC := 0x0100, PD_USEDEVMODECOPIES := 0x040000, PD_HIDEPRINTTOFILE := 0x100000
            , PD_NONETWORKBUTTON := 0x200000, PD_NOCURRENTPAGE := 0x800000
            , MM_TEXT := 0x1
            , DocName := "AHKRichEdit"
            , PD_Size := (A_PtrSize = 8 ? (13 * A_PtrSize) + 16 : 66)
        ErrorMsg := ""
        ; ----------------------------------------------------------------------------------------------------------------
        ; Prepare to call PrintDlg
        ; Define/Populate the PRINTDLG structure
        PD := Buffer(PD_Size, 0)
        Numput("UInt", PD_Size, PD)  ; lStructSize
        Numput("UPtr", This.Gui.Hwnd, PD, A_PtrSize) ; hwndOwner
        ; Collect Start/End select positions
        Sel := This.GetSel()
        ; Determine/Set Flags
        Flags := PD_ALLPAGES | PD_RETURNDC | PD_USEDEVMODECOPIES | PD_HIDEPRINTTOFILE | PD_NONETWORKBUTTON
            | PD_NOCURRENTPAGE
        if (Sel.S = Sel.E)
            Flags |= PD_NOSELECTION
        else
            Flags |= PD_SELECTION
        Offset := A_PtrSize * 5
        ; Flags, pages, and copies
        NumPut("UInt", Flags, "UShort", 1, "UShort", 1, "UShort", 1, "UShort", -1, "UShort", 1, PD, Offset)
        ; Note: Use -1 to specify the maximum page number (65535).
        ; Programming note: The values that are loaded to these fields are critical. The Print dialog will not
        ; display (returns an error) if unexpected values are loaded to one or more of these fields.
        ; ----------------------------------------------------------------------------------------------------------------
        ; Print dialog box
        ; Open the Print dialog.  Bounce If the user cancels.
        if !DllCall("Comdlg32.dll\PrintDlg", "Ptr", PD, "UInt")
            throw Error("Function: " . A_ThisFunc . " - DLLCall of 'PrintDlg' failed.", -1)
        ; Get the printer device context.  Bounce If not defined.
        if !(PDC := NumGet(PD, A_PtrSize * 4, "UPtr")) ; hDC
            throw Error("Function: " . A_ThisFunc . " - Couldn't get a printer's device context.", -1)
        ; Free global structures created by PrintDlg
        DllCall("GlobalFree", "Ptr", NumGet(PD, A_PtrSize * 2, "UPtr"))
        DllCall("GlobalFree", "Ptr", NumGet(PD, A_PtrSize * 3, "UPtr"))
        ; ----------------------------------------------------------------------------------------------------------------
        ; Prepare to print
        ; Collect Flags
        Offset := A_PtrSize * 5
        Flags := NumGet(PD, OffSet, "UInt")           ; Flags
        ; Determine From/To Page
        if (Flags & PD_PAGENUMS) {
            PageF := NumGet(PD, Offset += 4, "UShort") ; nFromPage (first page)
            PageL := NumGet(PD, Offset += 2, "UShort") ; nToPage (last page)
        }
        else
            PageF := 1, PageL := 65535
        ; Collect printer capacities
        Caps := This.GetPrinterCaps(PDC)
        ; Set up page size and margins in Twips (1/20 point or 1/1440 of an inch)
        UML := This.Margins.LT                   ; user margin left
        UMT := This.Margins.TT                   ; user margin top
        UMR := This.Margins.RT                   ; user margin right
        UMB := This.Margins.BT                   ; user margin bottom
        PML := Caps.POFX                         ; physical margin left
        PMT := Caps.POFY                         ; physical margin top
        PMR := Caps.PHYW - Caps.HRES - Caps.POFX ; physical margin right
        PMB := Caps.PHYH - Caps.VRES - Caps.POFY ; physical margin bottom
        LPW := Caps.HRES                         ; logical page width
        LPH := Caps.VRES                         ; logical page height
        ; Adjust margins
        UML := UML > PML ? (UML - PML) : 0
        UMT := UMT > PMT ? (UMT - PMT) : 0
        UMR := UMR > PMR ? (UMR - PMR) : 0
        UMB := UMB > PMB ? (UMB - PMB) : 0
        ; Define/Populate the FORMATRANGE structure
        FR := Buffer((A_PtrSize * 2) + (4 * 10), 0)
        NumPut("UPtr", PDC, "UPtr", PDC, FR) ; hdc , hdcTarget
        ; Define FORMATRANGE.rc
        ; rc is the area to render to (rcPage - margins), measured in twips (1/20 point or 1/1440 of an inch).
        ; If the user-defined margins are smaller than the printer's margins (the unprintable areas at the edges
        ; of each page), the user margins are set to the printer's margins. In addition, the user-defined margins
        ; must be adjusted to account for the printer's margins.
        ; For example: If the user requests a 3/4 inch (19.05 mm) left margin but the printer's left margin is
        ; 1/4 inch (6.35 mm), rc.Left is set to 720 twips (1/2 inch or 12.7 mm).
        Offset := A_PtrSize * 2
        NumPut("Int", UML, "Int", UMT, "Int", LPW - UMR, "Int", LPH - UMB, FR, Offset)
        ; Define FORMATRANGE.rcPage
        ; rcPage is the entire area of a page on the rendering device, measured in twips (1/20 point or 1/1440 of an inch)
        ; Note: rc defines the maximum printable area which does not include the printer's margins (the unprintable areas
        ; at the edges of the page). The unprintable areas are represented by PHYSICALOFFSETX and PHYSICALOFFSETY.
        Offset += 16
        NumPut("Int", 0, "Int", 0, "Int", LPW, "Int", LPH, FR, Offset)
        ; Determine print range.
        ; If "Selection" option is chosen, use selected text, otherwise use the entire document.
        if (Flags & PD_SELECTION)
            PrintS := Sel.S, PrintE := Sel.E
        else
            PrintS := 0, PrintE := -1            ; (-1 = Select All)
        Offset += 16
        Numput("Int", PrintS, "Int", PrintE, FR, OffSet) ; cr.cpMin , cr.cpMax
        ; Define/Populate the DOCINFO structure
        DI := Buffer(A_PtrSize * 5, 0)
        NumPut("UPtr", A_PtrSize * 5, "UPtr", StrPtr(DocName), "UPtr", 0, DI) ; lpszDocName, lpszOutput
        ; Programming note: All other DOCINFO fields intentionally left as null.
        ; Determine MaxPrintIndex
        if (Flags & PD_SELECTION)
            PrintM := Sel.E
        else
            PrintM := This.GetTextLen()
        ; Be sure that the printer device context is in text mode
        DllCall("SetMapMode", "Ptr", PDC, "Int", MM_TEXT)
        ; ----------------------------------------------------------------------------------------------------------------
        ; Print it!
        ; Start a print job.  Bounce If there is a problem.
        PrintJob := DllCall("StartDoc", "Ptr", PDC, "Ptr", DI.Ptr, "Int")
        if (PrintJob <= 0)
            throw Error("Function: " . A_ThisFunc . " - DLLCall of 'StartDoc' failed.", -1)
        ; Print page loop
        PageC := 0 ; current page
        PrintC := 0 ; current print index
        while (PrintC < PrintM) {
            PageC++
            ; Are we done yet?
            if (PageC > PageL)
                break
            if (PageC >= PageF) && (PageC <= PageL) {
                ; StartPage function.  Break If there is a problem.
                if (DllCall("StartPage", "Ptr", PDC, "Int") <= 0) {
                    ErrorMsg := "Function: " . A_ThisFunc . " - DLLCall of 'StartPage' failed."
                    break
                }
            }
            ; Format or measure page
            if (PageC >= PageF) && (PageC <= PageL)
                Render := True
            else
                Render := False
            PrintC := SendMessage(0x0439, Render, FR.Ptr, This.HWND)
            if (PageC >= PageF) && (PageC <= PageL) {
                ; EndPage function. Break If there is a problem.
                if (DllCall("EndPage", "Ptr", PDC, "Int") <= 0) {
                    ErrorMsg := "Function: " . A_ThisFunc . " - DLLCall of 'EndPage' failed."
                    break
                }
            }
            ; Update FR for the next page
            Offset := (A_PtrSize * 2) + (4 * 8)
            Numput("Int", PrintC, "Int", PrintE, FR, Offset) ; cr.cpMin, cr.cpMax
        }
        ; ----------------------------------------------------------------------------------------------------------------
        ; End the print job
        DllCall("EndDoc", "Ptr", PDC)
        ; Delete the printer device context
        DllCall("DeleteDC", "Ptr", PDC)
        ; Reset control (free cached information)
        SendMessage(0x0439, 0, 0, This.HWND)
        ; Return to sender
        if (ErrorMsg)
            throw Error(ErrorMsg, -1)
        return True
    }
    ; -------------------------------------------------------------------------------------------------------------------
    GetMargins() { ; Get the default print margins
        static PSD_RETURNDEFAULT := 0x00000400, PSD_INTHOUSANDTHSOFINCHES := 0x00000004
            , I := 1000 ; thousandth of inches
            , M := 2540 ; hundredth of millimeters
            , PSD_Size := (4 * 10) + (A_PtrSize * 11)
            , PD_Size := (A_PtrSize = 8 ? (13 * A_PtrSize) + 16 : 66)
            , OffFlags := 4 * A_PtrSize
            , OffMargins := OffFlags + (4 * 7)
        if !This.HasOwnProp("Margins") {
            PSD := Buffer(PSD_Size, 0) ; PAGESETUPDLG structure
            NumPut("UInt", PSD_Size, PSD)
            NumPut("UInt", PSD_RETURNDEFAULT, PSD, OffFlags)
            if !DllCall("Comdlg32.dll\PageSetupDlg", "Ptr", PSD, "UInt")
                return false
            DllCall("GlobalFree", "UInt", NumGet(PSD, 2 * A_PtrSize, "UPtr"))
            DllCall("GlobalFree", "UInt", NumGet(PSD, 3 * A_PtrSize, "UPtr"))
            Flags := NumGet(PSD, OffFlags, "UInt")
            Metrics := (Flags & PSD_INTHOUSANDTHSOFINCHES) ? I : M
            Offset := OffMargins
            This.Margins := {}
            This.Margins.L := NumGet(PSD, Offset += 0, "Int")           ; Left
            This.Margins.T := NumGet(PSD, Offset += 4, "Int")           ; Top
            This.Margins.R := NumGet(PSD, Offset += 4, "Int")           ; Right
            This.Margins.B := NumGet(PSD, Offset += 4, "Int")           ; Bottom
            This.Margins.LT := Round((This.Margins.L / Metrics) * 1440) ; Left in twips
            This.Margins.TT := Round((This.Margins.T / Metrics) * 1440) ; Top in twips
            This.Margins.RT := Round((This.Margins.R / Metrics) * 1440) ; Right in twips
            This.Margins.BT := Round((This.Margins.B / Metrics) * 1440) ; Bottom in twips
        }
        return True
    }
    ; -------------------------------------------------------------------------------------------------------------------
    GetPrinterCaps(DC) { ; Get printer's capacities
        static HORZRES := 0x08, VERTRES := 0x0A
            , LOGPIXELSX := 0x58, LOGPIXELSY := 0x5A
            , PHYSICALWIDTH := 0x6E, PHYSICALHEIGHT := 0x6F
            , PHYSICALOFFSETX := 0x70, PHYSICALOFFSETY := 0x71
        Caps := {}
        ; Number of pixels per logical inch along the page width and height
        LPXX := DllCall("GetDeviceCaps", "Ptr", DC, "Int", LOGPIXELSX, "Int")
        LPXY := DllCall("GetDeviceCaps", "Ptr", DC, "Int", LOGPIXELSY, "Int")
        ; The width and height of the physical page, in twips.
        Caps.PHYW := Round((DllCall("GetDeviceCaps", "Ptr", DC, "Int", PHYSICALWIDTH, "Int") / LPXX) * 1440)
        Caps.PHYH := Round((DllCall("GetDeviceCaps", "Ptr", DC, "Int", PHYSICALHEIGHT, "Int") / LPXY) * 1440)
        ; The distance from the left/right edge (PHYSICALOFFSETX) and the top/bottom edge (PHYSICALOFFSETY) of the
        ; physical page to the edge of the printable area, in twips.
        Caps.POFX := Round((DllCall("GetDeviceCaps", "Ptr", DC, "Int", PHYSICALOFFSETX, "Int") / LPXX) * 1440)
        Caps.POFY := Round((DllCall("GetDeviceCaps", "Ptr", DC, "Int", PHYSICALOFFSETY, "Int") / LPXY) * 1440)
        ; Width and height of the printable area of the page, in twips.
        Caps.HRES := Round((DllCall("GetDeviceCaps", "Ptr", DC, "Int", HORZRES, "Int") / LPXX) * 1440)
        Caps.VRES := Round((DllCall("GetDeviceCaps", "Ptr", DC, "Int", VERTRES, "Int") / LPXY) * 1440)
        return Caps
    }
    ; ===================================================================================================================
    ; Internally used classes *
    ; ===================================================================================================================
    ; CHARFORMAT2 structure -> docs.microsoft.com/en-us/windows/win32/api/richedit/ns-richedit-charformat2w_1
    class CHARFORMAT2 Extends Buffer {
        Size {
            Get => NumGet(This, 0, "UInt")
            Set => NumPut("UInt", Value, This, 0)
        }
        Mask {
            Get => NumGet(This, 4, "UInt")
            Set => NumPut("UInt", Value, This, 4)
        }
        Effects {
            Get => NumGet(This, 8, "UInt")
            Set => NumPut("UInt", Value, This, 8)
        }
        Height {
            Get => NumGet(This, 12, "Int")
            Set => NumPut("Int", Value, This, 12)
        }
        Offset {
            Get => NumGet(This, 16, "Int")
            Set => NumPut("Int", Value, This, 16)
        }
        TextColor {
            Get => NumGet(This, 20, "UInt")
            Set => NumPut("UInt", Value, This, 20)
        }
        CharSet {
            Get => NumGet(This, 24, "UChar")
            Set => NumPut("UChar", Value, This, 24)
        }
        PitchAndFamily {
            Get => NumGet(This, 25, "UChar")
            Set => NumPut("UChar", Value, This, 25)
        }
        FaceName {
            Get => StrGet(This.Ptr + 26, 32)
            Set => StrPut(Value, This.Ptr + 26, 32)
        }
        Weight {
            Get => NumGet(This, 90, "UShort")
            Set => NumPut("UShort", Value, This, 90)
        }
        Spacing {
            Get => NumGet(This, 92, "Short")
            Set => NumPut("Short", Value, This, 92)
        }
        BackColor {
            Get => NumGet(This, 96, "UInt")
            Set => NumPut("UInt", Value, This, 96)
        }
        LCID {
            Get => NumGet(This, 100, "UInt")
            Set => NumPut("UInt", Value, This, 100)
        }
        Cookie {
            Get => NumGet(This, 104, "UInt")
            Set => NumPut("UInt", Value, This, 104)
        }
        Style {
            Get => NumGet(This, 108, "Short")
            Set => NumPut("Short", Value, This, 108)
        }
        Kerning {
            Get => NumGet(This, 110, "UShort")
            Set => NumPut("UShort", Value, This, 110)
        }
        UnderlineType {
            Get => NumGet(This, 112, "UChar")
            Set => NumPut("UChar", Value, This, 112)
        }
        Animation {
            Get => NumGet(This, 113, "UChar")
            Set => NumPut("UChar", Value, This, 113)
        }
        RevAuthor {
            Get => NumGet(This, 114, "UChar")
            Set => NumPut("UChar", Value, This, 114)
        }
        UnderlineColor {
            Get => NumGet(This, 115, "UChar")
            Set => NumPut("UChar", Value, This, 115)
        }
        ; ----------------------------------------------------------------------------------------------------------------
        __New() {
            static CF2_Size := 116
            Super.__New(CF2_Size, 0)
            This.Size := CF2_Size
        }
    }
    ; -------------------------------------------------------------------------------------------------------------------
    ; PARAFORMAT2 structure -> docs.microsoft.com/en-us/windows/win32/api/richedit/ns-richedit-paraformat2_1
    class PARAFORMAT2 Extends Buffer {
        Size {
            Get => NumGet(This, 0, "UInt")
            Set => NumPut("UInt", Value, This, 0)
        }
        Mask {
            Get => NumGet(This, 4, "UInt")
            Set => NumPut("UInt", Value, This, 4)
        }
        Numbering {
            Get => NumGet(This, 8, "UShort")
            Set => NumPut("UShort", Value, This, 8)
        }
        StartIndent {
            Get => NumGet(This, 12, "Int")
            Set => (NumPut("Int", Value, This, 12), Value)
        }
        RightIndent {
            Get => NumGet(This, 16, "Int")
            Set => NumPut("Int", Value, This, 16)
        }
        Offset {
            Get => NumGet(This, 20, "Int")
            Set => NumPut("Int", Value, This, 20)
        }
        Alignment {
            Get => NumGet(This, 24, "UShort")
            Set => NumPut("UShort", Value, This, 24)
        }
        TabCount => NumGet(This, 26, "UShort")
        Tabs {
            Get {
                TabCount := This.TabCount
                Addr := This.Ptr + 28 - 4
                Tabs := Array()
                Tabs.Length := TabCount
                loop TabCount
                    Tabs[A_Index] := NumGet(Addr += 4, "UInt")
                return Tabs
            }
            Set {
                static ErrMsg := "Requires a value of type Array but got type "
                if (Type(Value) != "Array")
                    throw TypeError(ErrMsg . Type(Value) . "!", -1)
                DllCall("RtlZeroMemory", "Ptr", This.Ptr + 28, "Ptr", 128)
                TabCount := Value.Length
                Addr := This.Ptr + 28
                for I, Tab In Value
                    Addr := NumPut("UInt", Tab, Addr)
                NumPut("UShort", TabCount, This, 26)
                return Value
            }
        }
        SpaceBefore {
            Get => NumGet(This, 156, "Int")
            Set => NumPut("Int", Value, This, 156)
        }
        SpaceAfter {
            Get => NumGet(This, 160, "Int")
            Set => NumPut("Int", Value, This, 160)
        }
        LineSpacing {
            Get => NumGet(This, 164, "Int")
            Set => NumPut("Int", Value, This, 164)
        }
        Style {
            Get => NumGet(This, 168, "Short")
            Set => NumPut("Short", Value, This, 168)
        }
        LineSpacingRule {
            Get => NumGet(This, 170, "UChar")
            Set => NumPut("UChar", Value, This, 170)
        }
        OutlineLevel {
            Get => NumGet(This, 171, "UChar")
            Set => NumPut("UChar", Value, This, 171)
        }
        ShadingWeight {
            Get => NumGet(This, 172, "UShort")
            Set => NumPut("UShort", Value, This, 172)
        }
        ShadingStyle {
            Get => NumGet(This, 174, "UShort")
            Set => NumPut("UShort", Value, This, 174)
        }
        NumberingStart {
            Get => NumGet(This, 176, "UShort")
            Set => NumPut("UShort", Value, This, 176)
        }
        NumberingStyle {
            Get => NumGet(This, 178, "UShort")
            Set => NumPut("UShort", Value, This, 178)
        }
        NumberingTab {
            Get => NumGet(This, 180, "UShort")
            Set => NumPut("UShort", Value, This, 180)
        }
        BorderSpace {
            Get => NumGet(This, 182, "UShort")
            Set => NumPut("UShort", Value, This, 182)
        }
        BorderWidth {
            Get => NumGet(This, 184, "UShort")
            Set => NumPut("UShort", Value, This, 184)
        }
        Borders {
            Get => NumGet(This, 186, "UShort")
            Set => NumPut("UShort", Value, This, 186)
        }
        ; ----------------------------------------------------------------------------------------------------------------
        __New() {
            static PF2_Size := 188
            Super.__New(PF2_Size, 0)
            This.Size := PF2_Size
        }
    }
    ; ===================================================================================================================
    ; Internally called methods *
    ; ===================================================================================================================
    GetBGR(RGB) { ; Get numeric BGR value from numeric RGB value or HTML color name
        static HTML := { BLACK: 0x000000, SILVER: 0xC0C0C0, GRAY: 0x808080, WHITE: 0xFFFFFF, MAROON: 0x000080, RED: 0x0000FF, PURPLE: 0x800080, FUCHSIA: 0xFF00FF, GREEN: 0x008000, LIME: 0x00FF00, OLIVE: 0x008080, YELLOW: 0x00FFFF, NAVY: 0x800000, BLUE: 0xFF0000, TEAL: 0x808000, AQUA: 0xFFFF00 }
        if HTML.HasProp(RGB)
            return HTML.%RGB%
        return ((RGB & 0xFF0000) >> 16) + (RGB & 0x00FF00) + ((RGB & 0x0000FF) << 16)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    GetRGB(BGR) {  ; Get numeric RGB value from numeric BGR-Value
        return ((BGR & 0xFF0000) >> 16) + (BGR & 0x00FF00) + ((BGR & 0x0000FF) << 16)
    }
    ; -------------------------------------------------------------------------------------------------------------------
    GetMeasurement() { ; Get locale measurement (metric / inch)
        ; LOCALE_USER_DEFAULT = 0x0400, LOCALE_IMEASURE = 0x0D, LOCALE_RETURN_NUMBER = 0x20000000
        static Metric := 2.54  ; centimeters
            , Inches := 1.00  ; inches
            , Measurement := ""
        if (Measurement = "") {
            LCD := Buffer(4, 0)
            DllCall("GetLocaleInfo", "UInt", 0x400, "UInt", 0x2000000D, "Ptr", LCD, "Int", 2)
            Measurement := NumGet(LCD, 0, "UInt") ? Inches : Metric
        }
        return Measurement
    }
}
