#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include .\Lib\ahkez_debug.ahk
class Notify
{

  Display(t) {
    DebugGui.Splash(" ",t,3000,1000,50,,50)
  }
}



;VIM modes for Teldig Mobile
mode := "normal"
;normal mode

#If WinActive("ahk_exe mobile.exe") && mode = "normal"
i::
mode := "insert"
Notify.Display("INSERT MODE")
Return

/::
Click, 467,119
return

j::Down
k::Up
h::Left
l::Right
n::Tab
c::return
s::return
v::Return
q::Esc
u::PgUp
d::PgDn
x::BackSpace
$::End
0::Home

[::
Send, {WheelDown 5}
Return

]::
Send, {WheelUp 5}
Return

t::
Send,{Blind}{Ctrl Down}
Sleep,50
Send, {Tab}
Sleep, 50
Send, {Ctrl Up}
return

g::
Click, 472,140
return

#If
;insert mode

#If WinActive("ahk_exe mobile.exe") && mode = "insert"
esc::
mode := "normal"
Notify.Display("NORMAL MODE")
#If

;notifier
