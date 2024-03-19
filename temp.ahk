#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%


#include <uia_interface>

winactivate, ahk_exe locateaccess.exe
uia := uia_interface()
win := uia.ElementFromHandle()
msgbox % win.FindFirstBy("AutomationId=Ticket.Address").Value