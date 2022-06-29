#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

#Include, <uia_interface>
#include, <uia_constants>
#include, <obj2string>

UIA := UIA_Interface()
;Winactivate, ahk_exe mobile.exe
mobEl := UIA.ElementFromHandle(WinExist("ahk_exe mobile.exe"))
mobEl.FindFirstByNameAndType("Request status:","ComboBox").SetValue("PENDING")
