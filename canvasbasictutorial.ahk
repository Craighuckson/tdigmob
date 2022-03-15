; =================================================================================================================================
; Name: AHK-CANVAS Basic tutorial 2
; Description: Show basic usage of Uberi's Canvas Library
; Credits: Speedmaster
; Topic: https://www.autohotkey.com/boards/viewtopic.php?f=7&t=95971&p=426681#p426681
; Sript version:  1.0
; AHK Version:    1.1.31.01 Unicode x32
; Tested on:      WIN_7 64bit 
; =================================================================================================================================

#SingleInstance force
#include <canvas>  ; initiate Canvas Class
; Library >> https://github.com/Uberi/Canvas-AHK
; Documentation >> https://github.com/Uberi/Canvas-AHK/blob/master/Documentation/Main.md
;Canvas library is splitted in 6 files: Brush.ahk, Canvas.ahk, Font.ahk, Pen.ahk, Surface.ahk and Viewport.ahk
;Put these six files in your default library or create a "Lib" folder in your script folder

;------------------------ CREATE PENS AND BRUSHES --------------------------------------------------------
; create pens for drawing (to use only to draw lines and borders) 
; (ARGB Hex Colors) Transparency is controlled by the alpha channel (AA in #AARRGGBB)
; all pens have a thickness set by default to 6
AQUA_pen	:= new Canvas.Pen(0xFF00FFFF, 6) 
BLACK_pen	:= new Canvas.Pen(0xFF000000, 6) 	; Pen(ARGB_color, thickness)
BLUE_pen	:= new Canvas.Pen(0xFF0000FF, 6) 
FUCHSIA_pen	:= new Canvas.Pen(0xFFFF00FF, 6) 
GRAY_pen	:= new Canvas.Pen(0xFF808080, 6) 
GREEN_pen	:= new Canvas.Pen(0xFF008000, 6) 
LIME_pen	:= new Canvas.Pen(0xFF00FF00, 6) 
MAROON_pen	:= new Canvas.Pen(0xFF800000, 6) 
NAVY_pen	:= new Canvas.Pen(0xFF000080, 6) 
OLIVE_pen	:= new Canvas.Pen(0xFF808000, 6) 
PURPLE_pen	:= new Canvas.Pen(0xFF800080, 6) 
RED_pen		:= new Canvas.Pen(0xFFFF0000, 6) 
SILVER_pen	:= new Canvas.Pen(0xFFC0C0C0, 6) 
TEAL_pen	:= new Canvas.Pen(0xFF008080, 6) 
WHITE_pen	:= new Canvas.Pen(0xFFFFFFFF, 6) 
YELLOW_pen	:= new Canvas.Pen(0xFFFFFF00, 6) 

; create some brushes (to use only with filled forms)
; (ARGB Hex Colors) Transparency is controlled by the alpha channel (AA in #AARRGGBB)
; all brushes have a transparency set by default to AA (semi-transparent)
AQUA_brush		:= new Canvas.Brush(0xAA00FFFF) 
BLACK_brush		:= new Canvas.Brush(0xAA000000)	  ; Brush(ARGB_color)
BLUE_brush		:= new Canvas.Brush(0xAA0000FF) 
FUCHSIA_brush	:= new Canvas.Brush(0xAAFF00FF) 
GRAY_brush		:= new Canvas.Brush(0xAA808080) 
GREEN_brush		:= new Canvas.Brush(0xAA008000) 
LIME_brush		:= new Canvas.Brush(0xAA00FF00) 
MAROON_brush	:= new Canvas.Brush(0xAA800000) 
NAVY_brush		:= new Canvas.Brush(0xAA000080) 
OLIVE_brush		:= new Canvas.Brush(0xAA808000) 
PURPLE_brush	:= new Canvas.Brush(0xAA800080) 
RED_brush		:= new Canvas.Brush(0xAAFF0000) 
SILVER_brush	:= new Canvas.Brush(0xAAC0C0C0) 
TEAL_brush		:= new Canvas.Brush(0xAA008080) 
WHITE_brush		:= new Canvas.Brush(0xAAFFFFFF) 
YELLOW_brush	:= new Canvas.Brush(0xAAFFFF00) 

gui, font, s14
gui, add, text, ym cblue, Draw shapes manually (Ctrl + Left Mouse)

;------------------------ CREATE A GUI TEXT OR PICTURE CONTROL -----------------------------------------------------------------
; One of the big advantages of Canvas is that you can very easily use it to draw in a Gui control.

gui, add, text, w500 h500 x50 y50 vmainbox hwndMainBox border,       ;create a container control  (a Gui or a Gui contol that will receive all the drawings)  for ex. a gui picture or text control and specify an hwnd name for it (for ex: "hwndMy_container_box_name")

; ----------------------- CREATE RADIO BUTTONS ---------------------------------------------------------------------------

Gui, Add, Radio, x+20 yp checked1 vSelectedradio, DrawLine
Gui, Add, Radio,, FillRectangle
Gui, Add, Radio,, DrawRectangle
Gui, Add, Radio,, FillEllipse
Gui, Add, Radio,, DrawEllipse

; ----------------------- CLEAR BUTTON -----------------------------------------------------------------
GUI, add, button, gclear, CLEAR

;------------------------ SHOW THE GUI -----------------------------------------------------------------

gui, +resize
gui, show, w800 h600, UBERIS CANVAS BASIC TUTORIAL 1 by Speedmaster

;------------------------ CREATE A SURFACE (LAYER) -------------------------------------------------------

surface1 := new Canvas.Surface(500,500)		;create a new drawing area (= a new layer for drawing)
surface1.Clear(0xFFFFFF99)					;clear the surface and color it with ARGB lightYellow (0xFFFF99)
surface1.Smooth := "Best"					;antialiasing (improves the image rendering) .Smooth := "None" "Good" or "Best"

;------------------------ CREATE A VIEWPORT --------------------------------------------------------------

Viewport := new Canvas.Viewport(MainBox).Attach(Surface1)   ;attach the drawing area (surface) to the gui text control (MainBox)

;------------------------ REFRESH THE VIEWPORT --------------------------------------------------------------

Viewport.Refresh()  ; update the vieuwport to see the changes in the gui. 

;------------------------- MESSAGE BOX COMMENT (Msgbox 1) ---------------------------------------------------------

msgbox,, AHK-CANVAS TUTORIAL 2 , Downloard and include Uberi's Canvas (6 AHK files)`n Create Pen and Brush colors `n Create a Surface `n Create a GUI text box (Main box) `n Create a Viewport `n Attach the viewport to the Main box `n Refresh the viewport`n`n If all went well you should see a yellow square `n`nSet the COORDMODE of the MOUSE to CLIENT `n`nPress Ctrl + Left Mouse to draw the selected shape`n`nBefore drawing:`nCapture the mouse pointer position X1 Y1`nSubtract the control margin (position X and Y of the main box)`nClone the surface to save it`n`nWhile drawing: `nCapture the mouse pointer position X2 Y2`nSubtract the control margin (Main box X and Y) `nDraw back the previously cloned surface `nthen draw the shape`nRefresh the viewport to see the changes



;----------------------- GET THE MARGING (position X and Y of the main control) ------------------------------------------ 
guicontrolget, MainBox, pos, % mainbox                       ; We need to know MainboxX and MainboxY


;---------------------- SET COORDMODE OF THE MOUSE TO CLIENT -------------------------------------------------------------

coordmode, mouse, client

;------------------------ MANUALLY DRAW SHAPES IN THE SURFACE (Ctrl Left Mouse)  ------------------------------------------

^lbutton::												; Press control + left mouse											

; BEFORE DRAWING

	MouseGetPos, x1, y1									; capture the position of the first click   
	x1 -= MainBoxX, y1 -= MainBoxY 			  			; remove the control margin (position x and y of the main box) from the captured pos X1 and X2
	ClonedSurface:=Surface1.clone().draw(Surface1)		; clone the current surface to save it
	
;------------------------ CHECK THE SELECTED RADIO BUTTON  ---------------------
gui, submit, nohide				 ; select a shape to draw (radio buttons)
if (SelectedRadio==1)
	gosub draw_line
else if (SelectedRadio==2)
	goto draw_filled_rectangle
else if (SelectedRadio==3)
	goto draw_rectangle
else if (SelectedRadio==4)
	goto draw_Filled_Ellipse
else if (SelectedRadio==5)
	goto draw_Ellipse
else
	return


; WHILE DRAWING

;-------- DRAW LINES -----------------------------------------------------------------
draw_line:
while getKeyState("LButton", "P")
{
    MouseGetPos, x2, y2									; while the left mouse button is pressed capture the mouse pointer
	x2 -= MainBoxX, y2 -= MainBoxY						; subtract the control margin (position x and y of the main box)
	Surface1.draw(ClonedSurface)						; draw the cloned surface first
	        .Line(Red_pen,x1,y1,x2,y2)					; then draw the line
    Viewport.Refresh()									; refresh the viewport to see the changes	
}
return


;-------- DRAW FILLED RECTANGLE -----------------------------------------------------------------
draw_filled_rectangle:
while getKeyState("LButton", "P")
{
    MouseGetPos, x2, y2									; while the left mouse button is pressed capture the mouse pointer
	x2 -= MainBoxX, y2 -= MainBoxY						; subtract the control margin (position x and y of the main box)	
	w:=abs(x2-x1)										; calculate the width (w) of the rectangle in absolute value abs()
	h:=abs(y2-y1)										; calculate the height (h) of the rectangle in absolute value abs()
	Surface1.draw(ClonedSurface).FillRectangle(Green_Brush,(x2-x1)>0?x1:X2,(y2-y1)>0?y1:y2,w,h) ; then draw the rectangle taking into account the direction
    Viewport.Refresh()									; refresh the viewport to see the changes	
	
}
return

;-------- DRAW RECTANGLE -----------------------------------------------------------------
draw_rectangle:
while getKeyState("LButton", "P")
{
    MouseGetPos, x2, y2									; while the left mouse button is pressed capture the mouse pointer
	x2 -= MainBoxX, y2 -= MainBoxY						; subtract the control margin (position x and y of the main box)	
	w:=abs(x2-x1)										; calculate the width (w) of the rectangle in absolute value abs()
	h:=abs(y2-y1)										; calculate the height (h) of the rectangle in absolute value abs()
	Surface1.draw(ClonedSurface)						; draw the cloned surface first 
	        .drawRectangle(AQUA_Pen,(x2-x1)>0?x1:X2,(y2-y1)>0?y1:y2,w,h) ; then draw the rectangle taking into account the direction
    Viewport.Refresh()									; refresh the viewport to see the changes	
}
return

;-------- DRAW FILLED ELLIPSE -----------------------------------------------------------------
draw_filled_ellipse:
while getKeyState("LButton", "P")
{
    MouseGetPos, x2, y2									; while the left mouse button is pressed capture the mouse pointer
	x2 -= MainBoxX, y2 -= MainBoxY						; subtract the control margin (position x and y of the main box)	
	w:=abs(x2-x1)										; calculate the width (w) of the Ellipse in absolute value abs()
	h:=abs(y2-y1)										; calculate the height (h) of the Ellipse in absolute value abs()
	Surface1.draw(ClonedSurface).FillEllipse(Purple_Brush,(x2-x1)>0?x1:X2,(y2-y1)>0?y1:y2,w,h) ; then draw the Ellipse taking into account the direction
    Viewport.Refresh()									; refresh the viewport to see the changes	
	
}
return

;-------- DRAW ELLIPSE -----------------------------------------------------------------
draw_Ellipse:
while getKeyState("LButton", "P")
{
    MouseGetPos, x2, y2									; while the left mouse button is pressed capture the mouse pointer
	x2 -= MainBoxX, y2 -= MainBoxY						; subtract the control margin (position x and y of the main box)	
	w:=abs(x2-x1)										; calculate the width (w) of the Ellipse in absolute value abs()
	h:=abs(y2-y1)										; calculate the height (h) of the Ellipse in absolute value abs()
	Surface1.draw(ClonedSurface)						; draw the cloned surface first 
	        .drawEllipse(FUCHSIA_Pen,(x2-x1)>0?x1:X2,(y2-y1)>0?y1:y2,w,h) ; then draw the Ellipse taking into account the direction
    Viewport.Refresh()									; refresh the viewport to see the changes	
}
return



;------------------------ CLEAR THE DRAWING --------------------------------------------------------------
clear:
surface1.Clear(0xFFFFFF99)		;clear the surface with ARGB lightYellow (0xFFFF99)
Viewport.Refresh()  ; update the vieuwport to see the changes in the gui.


;------------------------ MESSAGE BOX COMMENT (Msgbox 2)--------------------------------------------------------------
msgbox,, AHK-CANVAS TUTORIAL 2 , Feel free to modify and test. `nGood Luck :) `n`n End of the basic tutorial 2`n by Speedmaster


;------------------------ EXIT THE SCRIPT -------------------------------------------------------------------
return
guiclose:
esc::
exitapp
