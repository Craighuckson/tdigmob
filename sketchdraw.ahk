#Warn All
#Include Canvas.ahk
;setup GUI

CoordMode, Client

black := 0xff000000
s := new Canvas.Surface(600,600)
b := new Canvas.Brush(0xffffffff)
bp := new Canvas.Pen(0xff000000)
road := bp.Width(3)
rd := new Canvas.Brush(0xffff0000)
bluedraw = new Canvas.Brush(0xff0000ff)

s.Clear(0xffffffff)
;draw the background
;s.FillRectangle(b,0,0,600,600)



;draw a road



Gui, +LastFound
v := new Canvas.Viewport(WinExist()).Attach(s)

Gui, Show, w600 h600, Canvas Demo
return

GuiClose:
ExitApp

Space::
MouseGetPos,mousex,mousey
mousex -= 3
mousey -= 25
;red dot on pressing space
MsgBox % mousex . "`n" . mousey
s.FillEllipse(rd,mousex,mousey,10,10)
v.Refresh()
return

^d::
points := getPoints("Click line start","Click line end")
startx := points[1]-3
starty := points[2] -25
endx := points[3]-3
endy := points[4]-25
sleep 100
s.Push()
l := s.Line(bp,startx,starty,endx,endy)
s.Pop()
v.Refresh()
if l = False
MsgBox, there was an error
;v.Refresh()
return

^w:: ;Wipe
s.Clear(0xffffffff)
v.Refresh()
return

g::
;draw a grid
x := 0
y := 0
end := 600
While x < end
{
	While y < end
	{
		s.SetPixel(x,y,black)
		y += 20
	}
	y := 0
	x +=20
}
v.Refresh()
return

RButton::
while GetKeyState("RButton","p")
{
MouseGetPos,mousex,mousey
s.FillEllipse(rd,mousex-3,mousey-25,5,5)
v.Refresh(mousex-5,mousey-30,10,10)
}

getPoints(inst1, inst2) {
	ToolTip, % inst1
	;KeyWait, LButton, D
	Loop
	{
		if (GetKeyState("LButton") = 1)
		{
			MouseGetPos, x1, y1
			ToolTip,
			Break
		}
		else if (GetKeyState("Esc") = 1)
		{
			Tooltip
			Return
		}
	}
	Sleep, 175
	Tooltip, % inst2
	Loop
	{
		if (GetKeyState("LButton") = 1)
		{
			MouseGetPos, x2, y2
			ToolTip,
			Break
		}
		else if (GetKeyState("Esc") = 1)
		{
			ToolTip
			Return
		}
	}
	;KeyWait, LButton, D
	;MouseGetPos, x2, y2
	;Tooltip,
	coordinates := [x1, y1, x2, y2]
	return coordinates
}