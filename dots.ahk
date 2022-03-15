#include canvas.ahk

	Gui, +LastFound
	;WinSet, TransColor, EEAA99


	hwnd1 := WinExist()
	i := new Canvas.Surface(600,600)
	v := new Canvas.Viewport(hwnd1).Attach(i)
	r := new Canvas.Brush(0x00FF000000)
	Gui, Show, w600 h600

	i.Clear(0x00000000)
	i.FillEllipse(r,500,500,5,5)
	v.Refresh()

