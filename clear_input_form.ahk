;clear input form gui
#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

Gui Add, Text, x168 y40 w117 h21 +0x200, Ticket Number:
Gui Add, Text, x168 y80 w117 h21 +0x200, Total Pages:
Gui Add, Text, x168 y120 w117 h21 +0x200, North Boundary:
Gui Add, Text, x168 y160 w117 h21 +0x200, South Boundary:
Gui Add, Text, x168 y200 w117 h21 +0x200, West Boundary:
Gui Add, Text, x168 y240 w117 h21 +0x200, East Boundary:
Gui Add, Edit, vEdtTotalPages x344 y80 w120 h21
Gui Add, Edit, vEdtTicketNumber x344 y40 w120 h21
Gui Add, Edit, vEditNBound x344 y120 w120 h21
Gui Add, Edit, x344 y160 w120 h21
Gui Add, Edit, x344 y200 w120 h21
Gui Add, Edit, x344 y240 w120 h21
Gui Add, Button, gButtonSubmit x280 y352 w80 h23, &Submit

Gui Show, w620 h420, Rogers Clear Input Form
Return

ButtonSubmit:
Gui, Submit

GuiEscape:
GuiClose:
    ExitApp


