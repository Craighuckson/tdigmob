#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#include <uia_interface>

uia := uia_interface()
win := uia.ElementFromHandle(WinExist("ahk_exe U2Drawx64.exe"))

;HOTKEYS
#IFWinActive,Utilocate Draw

Delete::
win.FindFirstBy("Automationid=btnDelete").click() ;delete
return


c::
win.FindFirstBy("automationid=btnStraightLine").click() ;cable
win.FindFirstBy("automationid=btnDash").click()
win.FindFirstBy("automationid=btnSize1").click()
return

+c::
win.FindFirstBy("automationid=btnAngledLines").click() ;straight cable
win.FindFirstBy("automationid=btnDash").click()
win.FindFirstBy("automationid=btnSize1").click()
return

e::
InputBox,text,,Enter text
if (ErrorLevel)
	return
win.FindFirstBy("automationid=btnext").click()
win.FindFirstBy("automationid=btnSize3").click()
MouseGetPos,mx,my
MouseClickDrag,l,%mx%,%my%,% mx + 20, % my + 20,5
Send,%text%{esc}
return

t::
Inputbox,text,,Enter text
if (ErrorLevel)
	return
win.FindFirstBy("automationid=btnext").click()
win.FindFirstBy("automationid=btnSize1").click()
MouseGetPos,mx,my
MouseClickDrag,l,%mx%,%my%,% mx + 20, % my + 20,5
Send,%text%{esc}
return

R::
win.FindFirstBy("automationid=btnStraightLine").click() ;road
win.FindFirstBy("automationid=btnSolid").click()
win.FindFirstBy("automationid=btnSize2").click()
return

+R::
win.FindFirstBy("automationid=btnAngledLines").click()
win.FindFirstBy("automationid=btnSolid").click()
win.FindFirstBy("automationid=btnSize2").click()
return

a::
win.FindFirstBy("automationid=btnMeasuringLines").click() ;meas
return

=::
win.FindFirstBy("automationid=btnSelect").click() ;select
return

^r::
win.FindFirstBy("automationid=btnRotate").click()
return

1::
win.FindFirstBy("Automationid=btnSymbol").click()
win.FindFirstBy("Automationid=Pedestal").click()
return

2::
win.FindFirstBy("Automationid=btnSymbol").click()
win.FindFirstBy("Automationid=Pole").click()
return

3::
win.FindFirstBy("Automationid=btnSymbol").click()
win.FindFirstBy("Automationid=Transformer").click()
return

4::
win.FindFirstBy("Automationid=btnSymbol").click()
win.FindFirstBy("Automationid=CatchBasin").click()
return

5::
win.FindFirstBy("Automationid=btnSymbol").click()
win.FindFirstBy("Automationid=Manhole").click()
return

6::
win.FindFirstBy("Automationid=btnSymbol").click()
win.FindFirstBy("Automationid=Hydrant").click()
return

#IFWinActive



