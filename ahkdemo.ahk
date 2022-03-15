#Warn All
#Warn LocalSameAsGlobal, Off
#Include,Canvas.ahk

i := new Canvas.Surface
i.Load(A_ScriptDir . "\Earthrise.jpg")
s := new Canvas.Surface(400,400)
s.Draw(i)
f := new Canvas.Font("Georgia",18)
s.Text(new Canvas.Brush(0xFFFFFFFF),f,"Earthrise: Dawn of a new era",30,80)
Gui, +LastFound
v := new Canvas.Viewport(WinExist()).Attach(s)
p := new Canvas.Pen(0x80FF0000,10)
t := new Canvas.Pen(0xFF00FF00,1)
b := new Canvas.Brush(0xAA0000FF)
Gui, Show, w400 h400, Canvas Demo
Return
GuiClose:
ExitApp
Tab::
f.Measure("Earthrise: Dawn of a new era",W,H)
s.DrawRectangle(t,30,80,W,H)
v.Refresh()
Return
Space::
s.Clear(0xFFFFFF00)
 .Push()
 .Translate(50,50)
 .Rotate(60)
 .FillRectangle(b,0,0,50,50)
 .Pop()
 .DrawEllipse(p,70,70,100,100)
 .DrawCurve(t,[[10,10],[50,10],[10,50]],True)
 .FillPie(b,100,100,50,50,0,270)
v.Refresh()
Return