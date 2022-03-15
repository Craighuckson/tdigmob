;multiviewer hotkeys
#IfWinActive ahk_exe LACMultiViewer.exe
^d:: ; show details Ctrl-D
	MouseClick,R
	Sleep 300
	picSearchSelect("details.png")
return

^t:: ; cable trace Ctrl-T
	click, R
	Sleep 500
	picSearchSelect("cabletrace.png")
return

f2:: ;rename tab f2
	click, R
	Sleep 300
	Send, {Down}{Enter}
return

^w:: ;close tab
	ControlClick,x29 y28,ahk_exe lacmultiviewer.exe,,R
	ControlSend,,{down 3}{enter},ahk_exe lacmultiviewer.exe
return

NumpadSub::
	Click, 1329, 57
return

NumpadAdd::
	Click, 1266, 64
return

#IfWinActive
