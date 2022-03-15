 F12::
 ;OPEN SKETCH


saveSKTasJPEG() {
Inputbox,string,Enter file to search for
Inputbox,filename,Enter new filename,,,,,,,,,%string%
send, !i
sleep 200
send, {down 8}{enter}
sleep,200
WinWaitActive,ahk_class #32770
winget,hdialog,id,a
sleep 200
ControlSetText,Edit1,%string%,ahk_id %hdialog%
ControlFocus,Button1,ahk_id %hdialog%
ControlSend, ahk_parent,{Enter},ahk_id %hdialog%
WinWaitActive, ahk_exe SketchToolApplication.exe
send, !F{enter}
WinWaitActive,ahk_class #32770
ControlSetText,Edit1,filename,ahk_class #32770
Control,Choose,4,ComboBox2,ahk_class #32770
ControlSend,ahk_parent,{enter},ahk_class #32770
}
 
 
 
 
 