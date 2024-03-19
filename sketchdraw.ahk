
#Include Canvas.ahk
;setup GUI


black := 0xff000000
s := new Canvas.Surface(600,600)
b := new Canvas.Brush(0xffffffff)
bp := new Canvas.Pen(0xff000000)
road := bp.Width(3)


;rd := new Canvas.Brush(0x00fa00ff)
;rd a red brush
rd := new Canvas.Brush(0xaaff0000)
bl := new Canvas.Brush(0x100000ff)
bluedraw = new Canvas.Brush(0xff0000ff)
f := new Canvas.Font("Arial",12)

s.Clear(0xffffffff)
s.Smooth := "Best"
;draw the background
;s.FillRectangle(b,0,0,600,600)



;draw a road



Gui, +LastFound
v := new Canvas.Viewport(WinExist()).Attach(s)

Gui,Add,Text,vLblState x300 y50 w50,Edit
Gui, Add, Text, vCoords x500 w50, 
Gui, Show, w600 h600, Canvas Demo
SetTimer,updatepos,100
return

GuiClose:
ExitApp

Esc::
GuiControl,Text,LblState,EDIT
state := "edit"
return

l::
GuiControl,Text, LblState, LINE
state := "draw_line"
return

r::
GuiControl,Text, LblState, RECT
state := "draw_rect"
return
	

Space::
MouseGetPos,mousex,mousey
mousex -= 3
mousey -= 25
;red dot on pressing space
;MsgBox % mousex . "`n" . mousey
s.FillEllipse(rd,mousex,mousey,10,10)
v.Refresh()
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
s.FillEllipse(rd,mousex-3,mousey-25,30,30)
v.Refresh(mousex-5,mousey-30,10,10)
}
return

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

q::
inputbox, quit, Quit?
if (quit = "y")
	ExitApp
return




updatepos:
	mousegetpos, mx1, mx2
	GuiControl,Text,Coords,%mx1%`,%mx2%
	return


LButton::

	;setup before drawing to get initial point
	mousegetpos,x1,y1
	ClonedSurface := s.Clone().draw(s)


	while GetKeyState("LButton","P") && state = "draw_line"
	{
		MouseGetPos,x2,y2
		s.draw(ClonedSurface)
		s.Line(bp,x1,y1,x2,y2)
		v.refresh()
	}

	while GetKeyState("LButton","P") && state = "edit"
		return

	while GetKeyState("LButton","P") && state = "draw_rect"	
	{
		MouseGetPos,x2,y2
		w:=abs(x2-x1)										; calculate the width (w) of the rectangle in absolute value abs()
		h:=abs(y2-y1)										; calculate the height (h) of the rectangle in absolute value abs()
		s.draw(ClonedSurface)						; draw the cloned surface first 
	        .drawRectangle(bp,(x2-x1)>0?x1:X2,(y2-y1)>0?y1:y2,w,h) ; then draw the rectangle taking into account the direction
    	v.Refresh()									; refresh the viewport to see the changes	
	}
	return