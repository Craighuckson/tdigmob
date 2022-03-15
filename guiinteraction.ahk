Winactivate,ahk_class TkTopLevel
hwnd := WinExist("a")
ControlSend,ahk_parent,c,ahk_id %hwnd%
ControlClick,x422 y200, ahk_id %hwnd%
sleep 300
Click 421,557