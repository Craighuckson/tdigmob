
;TELDIG MASTER SCRIPT;

;TODO - ADD APTUM TO TIMESHEET, UPDATE PYTHON TIMESHEET AS WELL
; TAKE HOTSTRINGS OUT OF MULTIVIEWER.AHK AND ADD TO MAIN SCRIPT
; SPLIT SCRIPT INTO MAIN WORK SCRIPT AND THEN INDIVIDUAL PROGRAMS ETC

;~ /* ;AUTOEXECUTE SECTION  */

#NoEnv
#Persistent
ListLines, On
#MenuMaskKey,VK07
#include <findtext>
#include <DebugWindow>
;#include <V2TOV1FUNC>
;#include json.ahk
#include <acc>
#include scrollbox.ahk
#include <cpuload>
#include <AHKEZ>
#Include <AHKEZ_Debug>
#Include Canvas.ahk
#Include <printstack>
;#Include multiviewer.ahk
#Include vpn.ahk
BlockInput, SendAndMouse
SetControlDelay, 50
Menu, Tray, Icon, %A_ScriptDir%\tico.png

;Runs on startup to preload variables
iniread, form, C:\Users\Cr\teldig\teldig.ini, variables, form, ""
iniread, stationcode, C:\Users\Cr\teldig\teldig.ini, variables, stationcode, ""
iniread, bellmarked, C:\Users\Cr\teldig\teldig.ini, variables, bellmarked, ""
iniread, bellclear, C:\Users\Cr\teldig\teldig.ini, variables, bellclear, ""
iniread, rogersclear, C:\Users\Cr\teldig\teldig.ini, variables, rogersclear, ""
iniread, rogersmarked, C:\Users\Cr\teldig\teldig.ini, variables, rogersmarked, ""
iniread, locationdataobtained, C:\Users\Cr\teldig\teldig.ini, variables, locationdataobtained, 0
iniread, street, C:\Users\Cr\teldig\teldig.ini, variables, street, ""
iniread, intersection, C:\Users\Cr\teldig\teldig.ini, variables, intersection, ""
iniread, currentpage, C:\Users\Cr\teldig\teldig.ini, variables, currentpage, ""
iniread, totalpages, C:\Users\Cr\teldig\teldig.ini, variables, totalpages, "

;CONSTANTS

; used for on the go hotStrings
tempvar1 := ""
tempvar2 := ""
tempvar3 := ""
tempvar4 := ""
tempvar5 := ""

today:= A_DD . " " . A_MM . " " . A_YYYY
sketch_bounds := {ulx:192, uly:512,lrx:948,lry:1152,width:756,height:640}
YorkMaps := "https://maps.york.ca/Html5ViewerPublic/Index.html?viewer=GeneralInteractiveMap.YorkMaps"

;setup of GUI for Bell primary sheet
Gui, Add, CheckBox, x172 y80 w100 h30 vbellhydro, Bell Hydro
Gui, Add, CheckBox, x172 y110 w100 h30 vbridgealert, Bridge Alert
Gui, Add, CheckBox, x172 y140 w150 h30 vcableconduit, Cables May or May Not Be in Conduit
Gui, Add, CheckBox, x172 y170 w100 h30 vhanddig, Hand Dig Only
Gui, Add, CheckBox, x172 y200 w100 h30 vprioritycable, Priority Cable Present
Gui, Add, CheckBox, x172 y230 w100 h30 vemptyconduit, Unable to Locate Empty Ducts
Gui, Add, CheckBox, x172 y260 w100 h30 vunlocateable, Unlocatable Future Use
Gui, Add, Button, x82 y310 w100 h30 , OK
Gui, Add, Button, x272 y310 w100 h30 , Cancel
Gui, Add, CheckBox, x72 y20 w100 h30 VCABLE, Cable
Gui, Add, CheckBox, x272 y20 w100 h30 VCONDUIT, Conduit

;setup of GUI for Rogers warnings rog gui
Gui,2: Add, CheckBox, x172 y80 w100 h30 vfibreonly, Fibre Only
Gui,2: Add, CheckBox, x172 y110 w100 h30 vftth, FTTH
Gui,2: Add, CheckBox, x172 y140 w150 h30 vhighriskfibre, High Risk Fibre
Gui,2: Add, CheckBox, x172 y170 w100 h30 vinaccuraterecords, Inaccurate Records
Gui,2: Add, CheckBox, x172 y200 w100 h30 vrailway, Railway
Gui,2: Add, Button, x82 y310 w100 h30 , OK
Gui,2: Add, Button, x272 y310 w100 h30 , Cancel

; SETUP OF MENU FOR SKETCH TOOL
Menu, Mobile, Add, &New Page, newpage
Menu, Mobile, Add, &Records Lookup, recordsLookup
Menu, mobile, Add, &Sketch Autofill, sketchAutoFill
Menu, mobile, Add, Radius Autofill, radiusProject
Menu, Mobile, Add, Add List to Streets and Trips,writedirectionlist
Menu, Mobile, Add, Add New Timesheet &Entry, newtimesheetentry
Menu, Mobile, Add, Add To &Timesheet, addtotimesheet
Menu, Mobile, Add, Autofill CUA,autofillCUA
Menu, Mobile, Add, Create new Project, newproj
;Menu, Mobile, Add, Get Rogers Primary Sheet, getRogPrimForm
Menu, Mobile, Add, Finish &Without Email, finishwithoutemail
Menu, Mobile, Add, Finish and &Email, finishandemail
Menu, mobile, Add, Get Ticket Picture, getticketpicture
Menu, Mobile, Add, Load from Project, autoinsertSketches
Menu, mobile, Add, Mark &job number as 2(clear), markJobNumberas2Clear
Menu, mobile, Add, Open Sketch E&ditor, openSketchEditor
Menu, Mobile, Add, &Write Template File, writeTemplateFile
Menu("Mobile","Add","Load From Template","AFFromClearTemplate")
Menu, Mobile, Add, Regular Sync, mobilesyncr
Menu, mobile, Add, Reset Form&Var, resetFormVar
Menu,mobile, Add, View ticket count, utilCount
Menu,mobile,Add, Search for Sketch, sketchSearch

Menu, forms, Add, Bell Auxilliary, 2buttonbaux
Menu, forms, Add, Bell Primary, 2buttonbprim
Menu, forms, Add, Rogers Auxilliary, 2buttonraux
Menu, forms, Add, Rogers Primary, 2buttonrprim
Menu, drawingtools, Add, Horizontal Arrow Tool, HorizontalArrowTool
Menu, drawingtools, Add, Vertical Arrow Tool, VerticalArrowTool
Menu, drawingtools, Add, Building, 2buttonbuilding
Menu, drawingtools, Add, Horizontal Cable, drawHorizontalCable
Menu, drawingtools, Add, Vertical Cable, drawVerticalCable
Menu, drawingtools, Add, Insert Ez draw sketch rp, insertEZDrawRP
Menu, drawingtools, Add, Insert EZ Draw Sketch BA, insertEZDrawBA
Menu, drawingtools, Add, Dig Box, digbox
Menu, drawingtools, Add, Corner Tool, drawCorner
Menu, drawingtools, Add, Delete Sketch Contents,deleteoldbell
Menu, drawingtools, Add, Clear Rogers From Bell, clearRogersFromBell
Menu, drawingtools, Add, Rogers Aux Dig Area Shift,radigsh
Menu, warninglabels, Add, Rogers Clear, 2buttonrogersclear
Menu, warninglabels, Add, Rogers FTTH, 2buttonrogersftth
Menu, warninglabels, Add, Fibre Only, 2buttonfibreonly
Menu, warninglabels, Add, Bell Clear, 2buttonbellclear
Menu, warninglabels, Add, Inaccurate, 2buttoninaccurate
Menu, warninglabels, Add, See Auxilliary, 2buttonseeauxilliary
Menu, ST, Add, Form Data, :forms
Menu, ST, Add, Warning Labels, :warninglabels
Menu, ST, Add, Drawing Tools, :drawingtools
Menu, ST, Add, Bell Stickers, 2buttonbellstickers
Menu, ST, Add, Dig Area, 2buttondigarea
Menu, ST, Add, Load Sketch, 2buttoninsertsketch
Menu, ST, Add, Save Sketch, 2buttonsavesketch
Menu, ST, Add, Emergency, emergency
Menu, ST, Add, Save and Exit, 2buttonsaveandexit
Menu, ST, Add, HotString list, showHotStrings

; mobile menu

;Menu, Mobile, Add,

;SKETCHTOOL SPECIFIC HOTKEYS/BUTTON HANDLERS
#IfWinActive ahk_exe SKETCHTOOLAPPLICATION.EXE

	#D::
	::dgarea::
		writeDigArea()
	return

	F10::
		autoinsertSketches()
	return

	MButton::
		Menu, ST, Show
	return

	;SKETCHTOOL HOTSTRINGS

	::autocua::
		autofillCUA()
	return

#IfWinActive

;SKETCHTOOL FUNCTIONS

autofillCUA()
{
	global totalpages
	setform()

	if (stationcode = "BCGN01") or if (stationcode = "BCGN02")
		loadImage("bell cua.skt")
	else
		loadImage("cua rogers.skt")
	Sleep 200
	CUASAVEEXIT()
	MsgBox, Done!
}

bellPrimaryPoleAutofill()
{
	global
	bell_stickers()
	WinWaitClose, Please select all that apply
}

bellPrimStart()
{
	WinGet,stpid,PID,A
	global bellclear
	MsgBox,36,Load Previous?,Load previous sketch?
	focusSketchTool()
	ifMsgBox,Yes
	{
		autofillExistingSketch()
		newPagePrompt()
		pagetimeend := ((A_TickCount - timestart) / 1000)
		FileAppend, %ticketnumber% p.%currentpage% - %pagetimeend%`n, timelog.txt
	return
}
bellclear := InputBox("Ticket Clear? Y / N")
if (bellclear = "y")
{
	ST_SAVEEXIT()
	newPagePrompt()
	pagetimeend := ((A_TickCount - timestart) / 1000)
	FileAppend, %ticketnumber% p.%currentpage% - %pagetimeend%`n, timelog.txt
}
else if (bellclear = "n")
{
	bell_stickers()
	;waitCloseDialogBox()
	;ST_SAVEEXIT()
	WinWaitClose, ahk_exe SketchToolApplication.exe
	newPagePrompt()
	pagetimeend := ((A_TickCount - timestart) / 1000)
	FileAppend, %ticketnumber% p.%currentpage% - %pagetimeend%`n, timelog.txt
}
else
	bellPrimStart()
}

newPagePrompt()
{
	global
	;MsgBox, 4132, New Page?, Start a new page?
	if (currentpage < totalpages)
	{
		sketchAutoFill()
	}
	else
	{
		MsgBox % "Continue to Timesheet / Email"
	return
}
}

getRegDA()
{
	global
	Gui,DA: Add, Text ,, North:
	Gui,DA: Add, Text,, South:
	Gui,DA: Add, Text,, West:
	Gui,DA: Add, Text,, East:
	Gui,DA: Add, Edit,Uppercase w400 ys vnorth
	Gui,DA: Add, Edit,Uppercase wp vsouth
	Gui,DA: Add, Edit,Uppercase wp vwest
	Gui,DA: Add, Edit,Uppercase wp veast
	Gui,DA: Add, Button, Default W80, OK
	Gui,DA: Show, ,Enter Dig Area
	WinWaitClose, Enter Dig Area

	digarea := {}
	;~ INPUTBOX, north, Dig Box, ENTER THE NORTH MOST BOUNDARY,,,,,,,,%NORTH%
	;~ StringUpper, north, north
	;~ if ErrorLevel
	;~ Return
	;~ INPUTBOX, south, Dig Box, ENTER THE SOUTH MOST BOUNDARY,,,,,,,,%SOUTH%
	;~ StringUpper, south, south
	;~ if ErrorLevel
	;~ Return
	;~ INPUTBOX, west, Dig Box, ENTER THE WEST MOST BOUNDARY,,,,,,,,%WEST%
	;~ Stringupper, west, west
	;~ if ErrorLevel
	;~ Return
	;~ inputbox, east, Dig Box, ENTER THE EAST MOST BOUNDARY,,,,,,,,%EAST%
	;~ StringUpper, east, east
	;~ if ErrorLevel
	;~ Return
	digarea["north"] := north
	digarea["south"] := south
	digarea["west"] := west
	digarea["east"] := east
	return digarea

}

isErrorNoSketchTemplate(path)
{

	if !FileExist("C:\Users\Cr\Documents\" path)
	{
		Msgbox, Unable to load sketch (template not created)
	return
}
}

killTemplate()
{
	If WinExist("Sketch template ahk_class #32770 ahk_exe SKETCHTOOLAPPLICATION.EXE")
	{
		WinClose
		SetTimer,,Off
	}
}

rogClear()
{
	MsgBox,36,Clear?,Ticket Clear?
	focusSketchTool()
	ifMsgBox, Yes
	{
		rclear:=1
	return rclear
}
}

aptClear()
{
	MsgBox,36,Clear?,Ticket Clear?
	focusSketchTool()
	ifMsgBox, Yes
	{
		aptClear := 1
	return aptClear
}
}

rogersWarning()
{
	global rclear, waitstate
	GUIHWND := WinExist()
	GuiControl, 2:, fibreonly, 0
	GuiControl, 2:, ftth, 0
	GuiControl, 2:, highriskfibre,0
	GuiControl, 2:, inaccuraterecords,0
	GuiControl, 2:, railway, 0
	Gui, 2: Show, x411 y174 h383 w483, Please select all that apply
	WinWaitClose, ahk_id %GUIHWND%
	return
}

setBLToBLDA()
{
	;building line to building line dig area
	global
	landbase := getlandbase() ;NSEW etc (String)
	num := getBLNum() ;is an array
	if !(num[2])
	{
		choice := "SINGLE"
	}
	fixstreetName()
	if landbase contains nw,sw,se,ne,NW,SW,SE,NE
	{
		intdir := InputBox("Horizontal (H), Vertical (V), Both(B)?")
		loop
		{
			if(intdir="h")
				Break
			else if(intdir="v")
				Break
			;else if(intdir="b")
			;Break
			else Continue
			}
		InputBox, xstreet,,Horizontal Street? `n1 = %street%`n2 = %intersection%`n3 = %intersection2%
		if(xstreet = "1")
			xstreet := street
		else if(xstreet = "2")
			xstreet := intersection
		else if(xstreet = "3")
			xstreet := intersection2
		InputBox, vstreet,,Vertical Street? `n1 = %street%`n2 = %intersection%`n3 = %intersection2%
		if(vstreet = "1")
			vstreet := street
		else if(vstreet = "2")
			vstreet := intersection
		else if(vstreet = "3")
			vstreet := intersection2
		;xstreet := InputBox("Which is the horizontal street?`n1=" street"`n2=" intersection"`n3=" intersection2)
		;ystreet := InputBox("Which is the vertical street?`n1=" street"`n2=" intersection"`n3=" intersection2)
	}
	else
	{
		if !(choice)
		{
			choice := InputBox("Which configuration (I = inside, O = outside, NW = samenw, SE = samese)")
		}
	}

	;returns String for choice
	;dig area made up of landbase+num+choice, set digarea needs template which is a String
	;inside is default
	Switch landbase
	{
	Case "n":
		north := "NBL " num.1 " " street
		south := "NCL " street
		west := "EBL " num.1 " " street
		east := "WBL " num.2 " " street
		if (choice = "single")
		{
			west := "WBL " num.1 " " street
			east := "EBL " num.1 " " street
		}
		if(choice = "o")
		{
			west := "WBL " num.1 " " street
			east := "EBL " num.2 " " street
		}
		if(choice = "nw")
		{
			west := "WBL " num.1 " " street
		}
		if(choice = "se")
		{
			east := "EBL " num.2 " " street
		}
	Case "s":
		north := "SCL " street
		south := "SBL " num.1 " " street
		west := "EBL " num.1 " " street
		east := "WBL " num.2 " " street
		if (choice = "single")
		{
			west := "WBL " num.1 " " street
			east := "EBL " num.1 " " street
		}
		if(choice = "o")
		{
			west := "WBL " num.1 " " street
			east := "EBL " num.2 " " street
		}
		if(choice = "nw"){
			west := "WBL " num.1 " " street
		}
		if(choice = "se"){
			east := "EBL " num.2 " " street
		}
	Case "w":
		north := "SBL " num.1 " " street
		south := "NBL " num.2 " " street
		west := "WBL " num.1 " " street
		east := "WCL " street
		if (choice = "single")
		{
			north := "NBL " num.1 " " street
			south := "SBL " num.1 " " street
		}
		if(choice = "o"){
			north := "NBL " num.1 " " street
			south := "SBL " num.2 " " street
		}
		if(choice = "nw"){
			north := "NBL " num.1 " " street
		}
		if(choice = "se"){
			south := "SBL " num.2 " "street
		}
	Case "e":
		north := "SBL " num.1 " " street
		south := "NBL " num.2 " " street
		west := "ECL " street
		east := "EBL " num.1 " " street
		if (choice = "single")
		{
			north := "NBL " num.1 " " street
			south := "SBL " num.1 " " street
		}
		if(choice = "o"){
			north := "NBL " num.1 " " street
			south := "SBL " num.2 " " street
		}
		if(choice = "nw"){
			north := "NBL " num.1 " " street
		}
		if(choice = "se"){
			south := "SBL " num.2 " "street
		}
	Case "se":
		north := "SCL " xstreet
		west := "ECL " vstreet
		if(intdir = "h") {
			south := "NBL " num.1 " " xstreet, east := "EBL " num.1 " " xstreet
		}
		else {
			south := "NBL " num.1 " " vstreet, east := "EBL " num.1 " " vstreet
		}
	Case "sw":
		north := "SCL " xstreet, east := "WCL " vstreet
		if(intdir = "h") {
			south := "NBL " num.1 " " xstreet, west := "WBL " num.1 " " xstreet
		}
		else {
			south := "NBL " num.1 " " vstreet, west := "WBL " num.1 " " vstreet
		}
	Case "ne":
		south := "NCL " xstreet
		west := "ECL " vstreet
		if(intdir = "h") {
			north := "SBL " num.1 " " xstreet, east := "EBL " num.1 " " xstreet
		}
		Else
		{
			north := "SBL " num.1 " " vstreet, east := "WBL " num.1 " " vstreet
		}
	Case "nw":
		south := "NCL " xstreet
		east := "WCL " vstreet
		if(intdir = "h")
		{
			north := "SBL " num.1 " " xstreet, west := "WBL " num.1 " " xstreet
		}
		;else if(intdir="b")
		;north := "NBL " num.2 " " vstreet, west:="WBL " num.1 " " xstreet
		Else
		{
			north := "NBL " num.1 " " vstreet, west := "EBL " num.1 " " vstreet
		}
	}

	if (form = "RA")
	{
		setTemplateText("RANBoundary.skt", north)
		setTemplateText("RASBoundary.skt", south)
		setTemplateText("RAWBoundary.skt", west)
		setTemplateText("RAEBoundary.skt", east)
	}
	else
	{
		setTemplateText("NBoundary.skt", north) ; ie HERE, this writes the dig area
		setTemplateText("SBoundary.skt", south)
		setTemplateText("WBoundary.skt", west)
		setTemplateText("EBoundary.skt", east)
	}
}

setBLtoBLSketch(landbase,intdir){
	global
	if (stationcode="ROGYRK01") or if (stationcode = "ROGSIM01")
	{
		rclear := rogclear()
		if(rclear)
		{
			clearreason := Inputbox("Clear reason","Regular (r)`nFTTH (f)`nClear For Fibre Only(c)")
			switch clearreason
			{
				case "r": loadImage("rogclear.skt")
				case "f": loadImage("ftth.skt")
				case "c": loadImage("exclusion agreement r.skt")
			}
			return
		}
	}
	if (intdir)
	{
		;if !FileExist("C:\Users\Cr\Documents\" landbase "CLTOBL" intdir ".skt")
		;{
		;Msgbox, Unable to load sketch (template not created)
		;return
		;}
		loadImage(landbase "CLTOBL" intdir ".skt")
	}
	else
	{
		switch choice
		{
			Case "i", "i": loadImage(landbase "BLTOBLI.SKT")
			Case "o", "o": loadImage(landbase "BLTOBLO.SKT")
			Case "nw", "nw": loadImage(landbase "BLTOBLNW.SKT")
			Case "se", "se": loadImage(landbase "BLTOBLSE.SKT")
			Case "single", "SINGLE": loadImage(landbase "BLTOBLSINGLE.SKT")
			Default: return
		}

	}
}

setCornerDigArea()
{
	global
	Loop
	{
		landbase := getLandbase()
	}
	Until (landbase = "NE" || landbase = "NW" || landbase = "SE" || landbase = "SW")
	fixstreetName()
	inter := isInterText()

	Loop
	{
		Inputbox, bounds,,Boundaries (PL/BL)
	}
	until (bounds = "PL" || bounds = "BL")
	if (bounds = "BL")
	{
		Inputbox, haddress,House address, Enter house address
	}

	switch landbase
	{
	case "NW":
		north := (bounds = "BL") ? "NBL " . haddress : "NPL " . inter.x
		south := (bounds = "BL") ? "CENTRE LINE " . inter.x : "CENTRE LINE " . inter.x
		west := (bounds = "BL") ? "WBL " . haddress : "WPL " . inter.y
		east := "CENTRE LINE " . inter.y

	case "NE":
		north := (bounds = "BL") ? "NBL " . haddress : "NPL " . inter.x
		south := (bounds = "BL") ? "CENTRE LINE " . inter.x : "CENTRE LINE " . inter.x
		west := "CENTRE LINE " . inter.y
		east := (bounds = "BL") ? "EBL " . haddress : "EPL " . inter.y

	case "SW":
		north := (bounds = "BL") ? "CENTRE LINE " . inter.x : "CENTRE LINE " . inter.x
		south := (bounds = "BL") ? "SBL " . haddress : "SPL " . inter.x
		west := (bounds = "BL") ? "WBL " . haddress : "WPL " . inter.y
		east := "CENTRE LINE" . inter.y

	case "SE":
		north := (bounds = "BL") ? "CENTRE LINE " . inter.x :"CENTRE LINE " . inter.x
		south := (bounds = "BL") ? "SBL " . haddress : "SPL " . inter.x
		west := "CENTRE LINE " . inter.y
		east := (bounds = "BL") ? "EBL " . haddress : "EPL" . inter.y
	}

	if (form = "RA")
	{
		setTemplateText("RANboundary.skt",north)
		setTemplateText("RAsboundary.skt",south)
		setTemplateText("RAWBoundary.skt",west)
		setTemplateText("RAEBoundary.skt",east)
	}
	else
	{
		setTemplateText("Nboundary.skt", north)
		setTemplateText("SBoundary.skt", south)
		setTemplateText("Wboundary.skt", west)
		setTemplateText("EBoundary.skt", east)
	}
}

setDWToDWDA()
;needs cleanup, can be condensed
{
	global
	Gui, DW:Add, Edit, x242 y50 w150 h30 vlandbase,
	Gui, DW:Add, Edit, x242 y130 w150 h30 vDWnum1,
	Gui, DW:Add, Edit, x242 y210 w150 h30 vDWnum2,
	Gui, DW:Add, Edit, x242 y290 w150 h30 vstreet, %street%
	Gui, DW:Add, Text, x112 y50 w100 h30 , Landbase
	Gui, DW:Add, Text, x112 y130 w100 h30 , DW 1
	Gui, DW:Add, Text, x112 y210 w100 h30 , DW 2
	Gui, DW:Add, Text, x112 y290 w100 h30 , Street
	Gui, DW:Add, Button, x220 y360 w90 h30 +Center, OK
	Gui, DW:Show, w534 h433, DW to DW Generator
	WinWaitClose, DW to DW Generator

	num1 := DWnum1
	num2 := DWnum2
	num := [num1,num2]
	fixstreetName()
	if(landbase = "nw" || landbase = "ne" || landbase = "se" || landbase = "sw")
	{
		xstreet := "", vstreet := ""
		intdir := InputBox("Horizontal (H), Vertical (V)") ;, Both(B)?")
		loop
		{
			if(intdir="h")
				Break
			else if(intdir="v")
				Break
			;else if(intdir="b")
			;Break
			else Continue
			}
		InputBox, xstreet,,Horizontal Street? `n1 = %street%`n2 = %intersection%`n3 = %intersection2%
		if(xstreet = "1")
			xstreet := street
		else if(xstreet = "2")
			xstreet := intersection
		else if(xstreet = "3")
			xstreet := intersection2
		InputBox, vstreet,,Vertical Street? `n1 = %street%`n2 = %intersection%`n3 = %intersection2%
		if(vstreet = "1")
			vstreet := street
		else if(vstreet = "2")
			vstreet := intersection
		else if(vstreet = "3")
			vstreet := intersection2
		;xstreet := InputBox("Which is the horizontal street?`n1=" street"`n2=" intersection"`n3=" intersection2)
		;ystreet := InputBox("Which is the vertical street?`n1=" street"`n2=" intersection"`n3=" intersection2)
	}

	signs := INPUTBOX("Signs? ")
	if (signs = "y"){
		signs := true
	}
	if signs {
		signdist := InputBox("Distance from curb? ")
	}

	switch landbase
	{
	Case "n":
		if signs {
			north := signdist . " N/NCL " . street
		}
		else {
			north := "NPL " street
		}
		south := "NCL " street
		west := "ERE DW " num.1 " " street
		east := "ERE DW " num.2 " " street

	Case "nrc":
		if signs {
			north := signdist . " N/NCL " . street
		}
		else {
			north := "NPL " street
		}
		south := "SCL " street
		west := "ERE DW " num.1 " " street
		east := "ERE DW " num.2 " " street

	Case "nw":
		if (intdir = "h")
		{
			north :="NPL " xstreet
			south :="NCL " xstreet
			west :="ERE DW " num.1 " " xstreet
			east :="WCL " vstreet
		}
		else
		{
			north :="NRE DW " num.1 " " vstreet
			south :="NCL " xstreet
			west :="WPL " vstreet
			east :="WCL " vstreet
		}

	Case "ne":
		if (intdir = "h")
		{
			north :="NPL " xstreet
			south :="NCL " xstreet
			west :="ERE DW " num.1 " " xstreet
			east :="ECL " vstreet
		}
		else
		{
			north :="NRE DW " num.1 " " vstreet
			south :="NCL " xstreet
			west :="EPL " vstreet
			east :="ECL " vstreet
		}

	Case "s":
		north := "SCL " street
		if signs {
			south := signdist . " S/SCL " . street
		}
		else {
			south := "SPL " street
		}
		west := "ERE of DW" . num1 . " " . street
		east := "ERE of DW " . num.2 . " " . street

	Case "src":
		north := "NCL " street
		if signs {
			south := signdist . " S/SCL " . street
		}
		else {
			south := "SPL " street
		}
		west := "ERE of DW" . num1 . " " . street
		east := "ERE of DW " . num.2 . " " . street

	Case "se":
		if (intdir = "h")
		{
			north :="SCL " xstreet
			south :="SPL " xstreet
			west :="ERE DW " num.1 " " xstreet
			east :="ECL " vstreet
		}
		else
		{
			south :="NRE DW " num.1 " " vstreet
			north :="SCL " xstreet
			west :="EPL " vstreet
			east :="ECL " vstreet
		}

	Case "SW":
		if (intdir = "h")
		{
			south :="SPL " xstreet
			north :="SCL " xstreet
			west :="ERE DW " num.1 " " xstreet
			east :="WCL " vstreet
		}
		else
		{
			north :="NRE DW " num.1 " " vstreet
			south :="SCL " xstreet
			west :="WPL " vstreet
			east :="WCL " vstreet
		}

	Case "w":
		north := "WCL " street
		if signs
		{
			south := signdist . " W/WCL " . street
		}
		Else
			south := "WPL " street
		west := "NRE of DW " . num.1 . " " . street
		east := "NRE of DW " . num.2 . " " . street

	Case "e":
		north := "ECL " street
		if signs
		{
			south := signdist . " E/ECL " . street
		}
		else
			south := "EPL " street
		west := "NRE of DW " . num.1 . " " . street
		east := "NRE of DW " . num.2 . " " . street
	}

	if (form = "RA")
	{
		setTemplateText("RANBoundary.skt", north)
		setTemplateText("RASBoundary.skt", south)
		setTemplateText("RAWBoundary.skt", west)
		setTemplateText("RAEBoundary.skt", east)
	}
	else
	{
		setTemplateText("NBoundary.skt", north) ; ie HERE, this writes the dig area
		setTemplateText("SBoundary.skt", south)
		setTemplateText("WBoundary.skt", west)
		setTemplateText("EBoundary.skt", east)
	}
}

setDWToDWSketch()
{
	global
	if (stationcode="ROGYRK01") or if (stationcode = "ROGSIM01")
	{
		rclear := rogclear()
		if(rclear)
		{
			clearreason := Inputbox("Clear reason","Regular (r)`nFTTH (f)`nClear For Fibre Only(c)")
			switch clearreason
			{
				case "r": loadImage("rogclear.skt")
				case "f": loadImage("ftth.skt")
				case "c": loadImage("exclusion agreement r.skt")
			}
			return
		}
	}
	if(intdir)
		loadimage(landbase "dwtodw" intdir ".skt")
	Else
		loadImage(landbase "dwtodw.skt")
	wait()
}

setPL4DigArea(num1:="", num2:="")
{
	global
	;Inputbox, dwgcount, Drawing count, How many drawings?,,,,,,,,1
	; Generated using SmartGUI Creator for SciTE
	;GUI FOR PL4
	Gui, PL4:Add, Edit, x252 y40 w180 h20 vlandbase ,
	Gui, PL4:Add, Edit, x252 y100 w180 h20 vPL4num1 ,
	Gui, PL4:Add, Edit, x252 y170 w180 h20 vPL4num2,
	Gui, PL4:Add, Edit, x252 y240 w180 h20 vstreet , %street%
	Gui, PL4:Add, Text, x102 y40 w120 h20 , Landbase
	Gui, PL4:Add, Text, x102 y100 w120 h20 , Address 1
	Gui, PL4:Add, Text, x102 y170 w120 h20 , Address 2
	Gui, PL4:Add, Text, x102 y240 w120 h20 , Street
	Gui, PL4:Add, Button, x222 y320 w80 h30 , OK
	Gui, PL4:Show, w479 h379, PL to PL Generator
	WinWaitClose, PL to PL Generator

	; Gui, PL4: Destroy
	;landbase:=getLandbase()
	;num:=getBLNum()
	fixstreetName()
	;Inputbox,street,Street,Enter street name,,,,,,,,%street%
	num1 := pl4num1, num2 := pl4num2
	num := [num1,num2]
	switch landbase
	{

	case "n":
		north:="NPL " num.1 " " street
		south:="SPL " num.1 " "street
		west:="WPL " num.1 " " street
		(num.2)?(east:="EPL " num.2 " " street):(east:= "EPL " num.1 " " street)

	case "s":
		north:="SPL " num.1 " " street
		south:="NPL " num.1 " " street
		west:="WPL " num.1 " " street
		;east:="EPL " num.2 " " street
		(num.2)?(east:="EPL " num.2 " " street):(east:= "EPL " num.1 " " street)

	case "w":
		north:="NPL " num.1 " " street
		south:="SPL " num.2 " " street
		(num.2)?(south:="SPL " num.2 " " street):(south:= "SPL " num.1 " " street)
		west:="WPL " num.1 " " street
		east:="EPL " num.1 " " street

	case "e":
		north:="NPL " num.1 " " street
		;south:="SPL " num.2 " " street
		(num.2)?(south:="SPL " num.2 " " street):(south:= "SPL " num.1 " " street)
		west:="WPL " num.1 " "street
		east:="EPL " num.1 " " street

	case "nw":
		north:="NPL " num.1 " " street,south:= "SPL " num.1 " " street, west:="WPL " num.1 " " street, east:="EPL " num.1 " " street

	case "sw":
		north:="NPL " num.1 " " street, south:= "SPL " num.1 " " street, west:= "WPL " num.1 " " street, east:="EPL " num.1 " " street

	case "ne":
		north:="NPL " num.1 " " street,south:= "SPL " num.1 " " street, west:="WPL " num.1 " " street, east:="EPL " num.1 " " street

	case "se":
		north:="NPL " num.1 " " street,south:= "SPL " num.1 " " street, west:="WPL " num.1 " " street, east:="EPL " num.1 " " street
	}

	IF (FORM = "RA")
	{
		setTemplateText("RANboundary.skt",north)
		setTemplateText("RAsboundary.skt",south)
		setTemplateText("RAWBoundary.skt",west)
		setTemplateText("RAEBoundary.skt",east)
	}
	else
	{
		setTemplateText("Nboundary.skt",north)
		setTemplateText("sboundary.skt",south)
		setTemplateText("WBoundary.skt",west)
		setTemplateText("EBoundary.skt",east)
	}
}

setStreetToStreetDigArea()
{
	global
	northxstreet:="",southxstreet:="",ystreet:="", westystreet:="", eastystreet:="",xstreet:=""
	fixstreetName()
	landbase := InputBox(,"Enter landbase? N/E/S/W")
	if(landbase = "w" || landbase = "e")
	{
		northxstreet := InputBox(,"Enter north X street `n 1 = " street "`n2 = " intersection "`n3 = " intersection2)
		if(northxstreet = "1")
			northxstreet := street
		else if(northxstreet = "2")
			northxstreet := intersection
		else if(northxstreet = "3")
			northxstreet := intersection2

		southxstreet := InputBox(,"Enter south X street `n 1 = " street "`n2 = " intersection "`n3 = " intersection2)
		if(southxstreet = "1")
			southxstreet := street
		else if(southxstreet = "2")
			southxstreet := intersection
		else if(southxstreet = "3")
			southxstreet := intersection2

		ystreet := InputBox(,"Enter Y street `n 1 = " street "`n2 = " intersection "`n3 = " intersection2)
		if(ystreet = "1")
			ystreet := street
		else if(ystreet = "2")
			ystreet := intersection
		else if(ystreet = "3")
			ystreet := intersection2
	}
	else if(landbase = "n" || landbase = "s")
	{
		westystreet := InputBox(,"Enter west Y street `n 1 = " street "`n2 = " intersection "`n3 = " intersection2)
		if(westystreet = "1")
			westystreet := street
		else if(westystreet = "2")
			westystreet := intersection
		else if(westystreet = "3")
			westystreet := intersection2

		eastystreet := InputBox(,"Enter east Y `n 1 = " street "`n2 = " intersection "`n3 = " intersection2)
		if(eastystreet = "1")
			eastystreet := street
		else if(eastystreet = "2")
			eastystreet := intersection
		else if(eastystreet = "3")
			eastystreet := intersection2

		xstreet := InputBox(,"Enter X street `n 1 = " street "`n2 = " intersection "`n3 = " intersection2)
		if(xstreet = "1")
			xstreet := street
		else if(xstreet = "2")
			xstreet := intersection
		else if(xstreet = "3")
			xstreet := intersection2
	}
	else
		setStreetToStreetDigArea()

	altchoice:= InputBox(,"1 = centre line to centre line`n2 = PL to PL`n3= CL to CL")
	altchoice2 := InputBox(,"1 = centre line to PL`n2 = CL to PL")
	switch landbase
	{
	case "w":
		west := "WPL " ystreet
		if(altchoice2 = 1)
		{
			east := "CENTRE LINE " . ystreet
		}
		else
		{
			east := "WCL " ystreet
		}
		if(altchoice = 2)
		{
			north := "SPL " northxstreet
			south := "NPL " southxstreet
		}
		else if(altchoice = 3)
		{
			north := "SCL " northxstreet
			south := "NCL " southxstreet
		}
		else
		{
			north := "CENTRE LINE " northxstreet
			south := "CENTRE LINE " southxstreet
		}

	case "e":
		if(altchoice = 2)
		{
			north := "SPL " northxstreet
			south := "NPL " southxstreet
		}
		else if(altchoice = 3)
		{
			north := "SCL " northxstreet
			south := "NCL " southxstreet
		}
		else
		{
			north := "CENTRE LINE " northxstreet
			south := "CENTRE LINE " southxstreet
		}
		if(altchoice2 = 1)
		{
			west := "CENTRE LINE " . ystreet
		}
		else
		{
			west := "ECL " ystreet
		}
		east := "EPL " ystreet

	case "n":
		north := "NPL " xstreet
		if(altchoice2 = 1)
		{
			south := "CENTRE LINE " . xstreet
		}
		else
		{
			south := "NCL " . xstreet
		}
		if(altchoice = 2)
		{
			west := "EPL " westystreet
			east := "WPL " eastystreet
		}
		else if(altchoice = 3)
		{
			west := "ECL " westystreet
			east := "WCL " eastystreet
		}
		else
		{
			west := "CENTRE LINE " westystreet
			east := "CENTRE LINE " eastystreet
		}

	case "s":
		north := "SPL " xstreet
		if(altchoice2 = 1)
		{
			south := "CENTRE LINE " . xstreet
		}
		else
		{
			south := "SCL " xstreet
		}
		if(altchoice = 2)
		{
			west := "EPL " westystreet
			east := "WPL " eastystreet
		}
		else if(altchoice = 3)
		{
			west := "ECL " westystreet
			east := "WCL " eastystreet
		}
		else
		{
			west := "CENTRE LINE " westystreet
			east := "CENTRE LINE " eastystreet
		}
	}

	if (form = "RA")
	{
		setTemplateText("RANBoundary.skt",north)
		setTemplateText("RASBoundary.skt",south)
		setTemplateText("RAWBoundary.skt", west)
		setTemplateText("RAEBoundary.skt",east)
	}
	else
	{
		setTemplateText("NBoundary.skt", north) ; ie HERE, this writes the dig area
		setTemplateText("SBoundary.skt", south)
		setTemplateText("WBoundary.skt", west)
		setTemplateText("EBoundary.skt", east)
	}
}

setRCDA()
{
	global
	landbase := getlandbase() ;NSEW etc (String)
	num := getBLNum() ;is an array
	fixstreetName()
	rclimit := InputBox("Crossing limit? (CL / PL ?)")
	Switch landbase
	{
	Case "n":
		north := "NBL " num.1 " " street
		south := "S" rclimit " " street
		west := "WBL " num.1 " " street
		east := "EBL " num.2 " " street
	Case "s":
		north := "N" rclimit " " street
		south := "SBL " num.1 " " street
		west := "WBL " num.1 " " street
		east := "EBL " num.2 " " street
	Case "w":
		north := "NBL " num.1 " " street
		south := "SBL " num.2 " " street
		west := "WBL " num.1 " " street
		east := "E" rclimit " " street
	Case "e":
		north := "NBL " num.1 " " street
		south := "SBL " num.2 " " street
		west := "W" rclimit " " street
		east := "EBL " num.1 " " street
	Case "nw":
		isInterText()
		north := "SBL " num.1 " " vstreet
		south := "S" rclimit " " hstreet
		west := "EBL " num.1 " " vstreet
		east := "WCL " vstreet
	Case "h":
		north := "NPL " . street
		south := "SPL " . street
		west := "WBL " num.1 " " street
		east := "EBL " num.2 " " street
	Case "v":
		north := "NBL " num.1 " " street
		south := "SBL " num.2 " " street
		west := "WPL " street
		east := "EPL " street
	}

	IF (FORM = "RA")
	{
		setTemplateText("RANboundary.skt",north)
		setTemplateText("RAsboundary.skt",south)
		setTemplateText("RAWBoundary.skt",west)
		setTemplateText("RAEBoundary.skt",east)
	}
	else
	{
		setTemplateText("Nboundary.skt",north)
		setTemplateText("sboundary.skt",south)
		setTemplateText("WBoundary.skt",west)
		setTemplateText("EBoundary.skt",east)
	}
}

setPLDigArea()
{
	global
	landbase:=getLandbase()
	num:=getBLNum()
	fixstreetName()
	switch landbase
	{
	case "n":
		north:="NPL " num.1 " " street
		south:="NCL " street
		west:="WPL " num.1 " " street
		east:="EPL " num.1 " " street

	case "s":
		north:="SPL " num.1 " " street
		south:="SCL " street
		west:="WPL " num.1 " " street
		east:="EPL " num.1 " " street

	case "w":
		north:="NPL " num.1 " " street
		south:="SPL " num.1 " " street
		west:="WPL " num.1 " " street
		east:="WCL " street

	case "e":
		north:="NPL " num.1 " " street
		south:="SPL " num.1 " " street
		west:="ECL " street
		east:="EPL " num.1 " " street
	}

	IF (FORM = "RA")
	{
		setTemplateText("RANboundary.skt",north)
		setTemplateText("RAsboundary.skt",south)
		setTemplateText("RAWBoundary.skt",west)
		setTemplateText("RAEBoundary.skt",east)
	}
	else
	{
		setTemplateText("Nboundary.skt",north)
		setTemplateText("sboundary.skt",south)
		setTemplateText("WBoundary.skt",west)
		setTemplateText("EBoundary.skt",east)
	}
}

setStreetToStreetSketch(landbase)
{
	global
	if(stationcode="ROGYRK01") or if (stationcode = "ROGSIM01")
	{
		rclear := rogclear()
		if(rclear)
		{
			clearreason := Inputbox("Clear reason","Regular (r)`nFTTH (f)`nClear For Fibre Only(c)")
			switch clearreason
			{
				case "r": loadImage("rogclear.skt")
				case "f": loadImage("ftth.skt")
				case "c": loadImage("exclusion agreement r.skt")
			}
			return
		}
	}

	if (altchoice = 2)
	{
		loadImageNG(landbase "streettostreetpltopl.skt")
	}
	if (altchoice = 3)
	{
		loadImageNG(landbase "streettostreetcltocl.skt")
	}
	Else
	{
		loadImageNG(landbase "streettostreet.skt")
	}
}

setPL4Sketch(landbase){
	global
	if (stationcode="ROGYRK01") or if (stationcode = "ROGSIM01")
	{
		rclear := rogclear()
		if(rclear)
		{
			clearreason := Inputbox("Clear reason","Regular (r)`nFTTH (f)`nClear For Fibre Only(c)")
			switch clearreason
			{
				case "r": loadImage("rogclear.skt")
				case "f": loadImage("ftth.skt")
				case "c": loadImage("exclusion agreement r.skt")
			}
			return
		}
	}
	(num.2)?(loadImage(landbase "PL4.skt")):(loadImage(landbase "PL4SINGLE.SKT"))
}

setPLToPLSketch(landbase)
{
	global

	if (stationCode = "ROGYRK01") or if (stationcode = "ROGSIM01")
		rclear := ROGCLEAR()
	if (rclear)
	{
		local rclearreason := Inputbox("(C)lear or (F)TTH")
		if rclearreason not in c,C,f,F
		{
			MsgBox % Invalid result
			setPLToPLSketch(landbase)
		}
		if ErrorLevel
			return
		(rclearreason = "c") ? loadImage("rogclear.skt") : loadImage("rogftth.skt")
	return rclear
}
;~ if !FileExist("C:\Users\Cr\Documents\" landbase "pltopl.skt")
;~ {
;~ Msgbox, Unable to load sketch (template not created)
;~ return
;~ }
loadImage(landbase "pltopl.skt")
}

setCornerSketch(landbase)
{
	global
	(bounds = "BL") ? loadImage(landbase "cornerbl.skt") : loadImage(landbase "corner.skt")
}

setRCSketch(landbase){
	global
	StringUpper,landbase,landbase
	if !FileExist("C:\Users\Cr\Documents\" . landbase "RC.skt")
	{
		Throw, Exception("Sketch template does not exist",-1)
	}
	else
		loadImage(landbase "RC.skt")
}

setSGasDigArea()
{
	;dig area for short gas

	global
	landbase := getLandbase()
	num := getBLNum()
	if (num[2])
	{
		num := getBLNum()
	}
	fixStreetName()
	switch landbase
	{
	case "w":
		north := "5M N/NBL " . num[1] . " " . street
		south := "5M S/SBL " . num[1] . " " . street
		west := "5M W/WBL " . num[1] . " " . street
		east := "CENTRE LINE " . street

	case "e":
		north := "5M N/NBL " . num[1] . " " . street
		south := "5M S/SBL " . num[1] . " " . street
		east := "5M E/EBL " . num[1] . " " . street
		west := "CENTRE LINE " . street

	case "n":
		north := "5M N/NBL " . num[1] . " " . street
		east := "5M E/EBL " . num[1] . " " . street
		west := "5M W/WBL " . num[1] . " " . street
		south := "CENTRE LINE " . street

	case "s":
		east := "5M E/EBL " . num[1] . " " . street
		south := "5M S/SBL " . num[1] . " " . street
		west := "5M W/WBL " . num[1] . " " . street
		north := "CENTRE LINE " . street
	}

	if (form = "RA")
	{
		setTemplateText("RANBoundary.skt", north)
		setTemplateText("RASBoundary.skt", south)
		setTemplateText("RAWBoundary.skt", west)
		setTemplateText("RAEBoundary.skt", east)
	}
	else
	{
		setTemplateText("NBoundary.skt", north) ; ie HERE, this writes the dig area
		setTemplateText("SBoundary.skt", south)
		setTemplateText("WBoundary.skt", west)
		setTemplateText("EBoundary.skt", east)
	}
}

setLGasDigArea()
{
	;dig area for long gas

	global
	landbase := getLandbase()
	num := getBLNum()
	if (num[2])
	{
		num := getBLNum()
	}
	fixStreetName()
	switch landbase
	{
	case "w":
		north := "5M N/NBL " . num[1] . " " . street
		south := "5M S/SBL " . num[1] . " " . street
		west := "5M W/WBL " . num[1] . " " . street
		east := "10M E OF ECL " . street

	case "e":
		north := "5M N/NBL " . num[1] . " " . street
		south := "5M S/SBL " . num[1] . " " . street
		east := "5M E/EBL " . num[1] . " " . street
		west := "10M W OF WCL " . street

	case "n":
		north := "5M N/NBL " . num[1] . " " . street
		east := "5M E/EBL " . num[1] . " " . street
		west := "5M W/WBL " . num[1] . " " . street
		south := "10M S OF SCL " . street

	case "s":
		east := "5M E/EBL " . num[1] . " " . street
		south := "5M S/SBL " . num[1] . " " . street
		west := "5M W/WBL " . num[1] . " " . street
		north := "10M N OF NCL " . street
	}

	if (form = "RA")
	{
		setTemplateText("RANBoundary.skt", north)
		setTemplateText("RASBoundary.skt", south)
		setTemplateText("RAWBoundary.skt", west)
		setTemplateText("RAEBoundary.skt", east)
	}
	else
	{
		setTemplateText("NBoundary.skt", north) ; ie HERE, this writes the dig area
		setTemplateText("SBoundary.skt", south)
		setTemplateText("WBoundary.skt", west)
		setTemplateText("EBoundary.skt", east)
	}
}

setLGasSketch(){
	global
	hnum := num[1]
	numpts := {"s": new Point(560,1056), "n": new Point(564,589)}
	loadImageNG(landbase . "lgas.skt")
	for k,v in numpts
	{
		if (k = landbase)
		{
			drawText("nbltext1.skt", hnum,v.x,v.y)
		}
	}
}

waitSTLoad()
{
	Text:="|<>*135$14.TwIka49n64kVax8tn08MA3w8"
	while !(ok:=FindText(347-150000, 53-150000, 347+150000, 53+150000, 0, 0, Text)) ; wait for image of rotation tool in ST
		continue
}

writeRAdigarea()
{
	global
	loadImageNG("RANBoundary.skt")
	wait()
	SendInput {f2}
	SendInput, %north%{enter}
	wait()
	loadImageNG("RASBoundary.skt")
	;Sleep 500
	SendInput, {f2}
	SendInput, %south%{enter}
	;wait()
	loadImageNG("RAWBoundary.skt")
	;Sleep 500
	SendInput, {f2}
	SendInput, %west%{enter}
	;wait()
	loadImageNG("RAEBoundary.skt")
	;Sleep 500
	SendInput, {f2}
	SendInput,%east%{enter}
	;wait()
	clickSelection()
}

;SKETCHTOOL MODULES

autoinsertSketches()
{
	global
	project := []

	;COMMENT EITHER THE NEXT TWO LINES OR THE FOLLOWING 2 LINES AT A TIME - NOT BOTH

	FileSelectFile, projfile,,%A_ScriptDir%, Select project,
	units := Inputbox("Enter units")

	;projfile:="C:\Users\Cr\Desktop\archived\autohotkey\STONEHAM 50 TO 28 R.TXT"
	;units:="1m"
	loop, Read, %projfile%
	{
		project.Push(A_LoopReadLine)
	}
	totalpages := project.Length()
	Loop % project.Length()
	{
		setform()
		waitSTLoad()
		loadImage(project[A_Index])
		Sleep 500
		stproj_saveexit()
		ControlClick("OK", "ahk_exe sketchtoolapplication.exe")
		focusTeldig()
	}
	;Msgbox, Done!
	proj:=""
	addtotimesheet()
	finishemail()
	;SetTimer,checkforNewTicket, 200 ;use this for looping
}

projectSketch()
{
	;global
	t := new Ticket()
	s := new Sketch()
	focusTeldig()
	clickLocationTab()
	t:= t.GetData()
	;getTicketData(number,street,intersection,intersection2,stationCode,diginfo,ticketNumber,town,ticketdata)
	;worktype := getWorkType()
	openSketchEditor()
	; if (ticketdata.stationcode = "ROGYRK01") or if (ticketdata.stationcode = "ROGSIM01")
	; 	sketch.form := "RA"
	; Else
	; 	sketch.form := "BA"
	t.form := t.ForceAuxilliary()
	;mb(t.form)
	waitSTLoad()
	writeDigArea()
	;s.digarea := s.getDigArea()
	;mb(obj2string(s.digarea))
	;mb(s["north"])
	;s.putDigArea()
	if (digboundary)
	{
		if(digboundary = "1")
		{
			setDWToDWSketch()
			setDWtext()
		}
		if(digboundary = "2")
		{
			setBLtoBLSketch(landbase,intdir)
			setBLtext(landbase,intdir,xstreet,vstreet)
			setOffsetLabel(landbase)
		}
		if(digboundary = "3")
		{
			setRCSketch(landbase)
			setBLtext(landbase,intdir,xstreet,vstreet)
		}
		if(digboundary="4")
		{
			setPLToPLSketch(landbase)
			setPLtext(landbase)
			setOffsetLabel(landbase)
		}
		if(digboundary="5")
		{
			setPL4Sketch(landbase)
			setPL4text(landbase)
		}
		if(digboundary="6")
		{
			setStreetToStreetSketch(landbase)
			setStreettoStreetText(landbase)
		}
		if(digboundary="7")
		{
			setCornerSketch(landbase)
			setCornerText(landbase)
		}
	}
	Else
	{
		landbase := getlandbase()
		Switch landbase
		{
			Case "N": 	SWFUNC("b - north.skt", "B - north no sw.skt")
			Case "NE": 	SWFUNC("B - NE CORNER.SKT","B - NE corner no sw.skt")
			Case "E": 	SWFUNC("B - EAST.SKT","B - east no sw.skt")
			Case "SE": 	SWFUNC("B - SE CORNER.SKT","B - SE corner no sw.skt")
			Case "S": 	SWFUNC("B - SOUTH.SKT","B - South no sw.skt")
			Case "SW":	SWFUNC("B - SW CORNER.SKT","B - SW corner no sw.skt")
			Case "W":	SWFUNC("B - WEST.SKT","B - WEST NO SW.SKT")
			Case "NW": 	SWFUNC("B - NW CORNER.SKT","B - NW corner no sw.skt")
			Case "TN":	loadImage("b - t intersection n.skt")
			Case "TS":	loadImage("b - t intersection s.skt")
			Case "TW":	loadImage("b - t intersection w.skt")
			Case "TE": 	loadImage("b - T intersection e.skt")
			Case "H": 	loadImage("B - horizontal st.skt")
			Case "V": 	loadImage("B - vertical st.skt")
			Case "HSS": loadImage("B - horizontal st centre to centre.skt")
			Case "VSS": loadImage("B - vertical centre to centre.skt")
			Case "INT": loadImage("B - intersection.skt")
			Case "Custom": openimagedialog()
			Default:	MsgBox % "No valid option selected. Please load form manually!"
		}
		if landbase in N,S,E,W
		{
			setTemplateText(landbase . "street.skt", street)
		}
		if landbase in NE,NW,SE,SW,TN,TS,TW,TE
		{
			inter := isInterText()
			setCornerText(landbase)
		}
	}
}

setOffsetLabel(landbase)
{
	meas1 := setMeasurement()
	meas2 := setMeasurement()
	label := InputBox("Enter label for cable")
	StringUpper, label, label
	list:=["meas1.skt","meas2.skt","cablelabel.skt"]
	setTemplateText(landbase "meas1.skt",meas1)
	wait()
	setTemplateText(landbase "meas2.skt",meas2)
	wait()
	setTemplateText(landbase "cablelabel.skt", label)
}

getDigBoundaries()
{
	InputBox, digboundary,Boundaries?, 1 = Driveway to Driveway`n2 = BL to BL`n3 = Road Crossing `(FTTH`)`n4 = PL to PL`n5 = All PL`n6 = Street to Street`n7 = Corner`n8 = Short Gas`n9 = Long Gas,,,300
	return digboundary
}

;AUTOMATED FORM FILLER
;THIS NEEDS TO BE REFACTORED BIG TIME
sketchAutoFill()
{
	timestart := A_TickCount
	focusTeldig()
	if (locationDataCheck = false) {
		t := new Ticket()
		t.GetData()
	}
	t.form := getForm(t)
	BlockInput("SendAndMouse")
	clickdrawingtab()
  clickNewForm()
	setForm(t)
	waitSketchTool()
	Sleep,150
	BlockInput("Off")
	SetTimer,killTemplate,-5000

	; wait for SketchTool to be loaded via rotation arrow
	waitSTLoad()

	if (form = "BP")
	{
		;QUICK FILL FOR SINGLE VS PROJECT
		btickettype := Inputbox("Single or Project?")
		if btickettype in s,S,p,P
		{
			if (btickettype = "s")
			{
				totalpages := 2

				units := Inputbox("Enter units")
				primary_template := FileSelectFile(,"C:\Users\Cr\Documents\","Choose bell primary form to open")
				focusSketchtool()
				loadImage("bell primary.skt")
				wait()
				loadImage(primary_template)
				wait()
				setTemplateText("bellprimarydate.skt",getCurrentDate())
				wait()
				setTemplateText("units.skt",units)
				wait()
				setTemplateText("RPtotalpages.skt",totalpages)
				wait()
				if !currentpage
					currentpage := 1
				Controlclick("OK","ahk_exe sketchtoolapplication.exe")
				focusTeldig()
				newPagePrompt()
				pagetimeend := ((A_TickCount - timestart) / 1000)
				FileAppend, %ticketnumber% p.%currentpage% - %pagetimeend%`n, timelog.txt
				return
			}
			else if (btickettype = "p")
			{
				bellPrimStart()
				return
			}

			else
			{
				bellPrimStart()
				return
			}
		}
	}

	;getexisting := InputBox("Open existing sketch? Y/N")
	MsgBox,4,Open Existing?,Open Existing Sketch?
	focusSketchTool()

	;if (getexisting = "y")
	ifMsgBox, Yes
	{
		autofillExistingSketch()
		newPagePrompt()
		pagetimeend := ((A_TickCount - timestart) / 1000)
		FileAppend, %ticketnumber% p.%currentpage% - %pagetimeend%`n, timelog.txt
	return ;autofill existing module
}

;else if (getexisting = "n") ;this is where it gets tricky...
ifMsgBox, No
{
	writeDigArea()

	; checks for alternate or regular dig areas and writes
	;next section is essentially prebaked vs custom dig area/sketch
	if !(digboundary = "")
	{
		if(digboundary = "1")
		{
			setDWToDWSketch()
			if !(rclear)
			{
				setDWtext()
			}
		}
		if(digboundary = "2")
		{
			setBLtoBLSketch(landbase,intdir)
			if !(rclear)
			{
				setBLtext(landbase,intdir,xstreet,vstreet)
				if (!intdir)
					setOffsetLabel(landbase)
			}
		}
		if(digboundary = "3")
		{
			setRCSketch(landbase)
			setBLtext(landbase,intdir,xstreet,vstreet)
		}
		if(digboundary="4")
		{
			rclear := rogclear()
			if (rclear)
				return
			setPLToPLSketch(landbase)
			setPLtext(landbase)
			;setOffsetLabel(landbase)
		}
		if(digboundary="5")
		{
			setPL4Sketch(landbase)
			setPL4text(landbase)
		}
		if(digboundary="6")
		{
			rclear := rogclear()
			if (rclear)
				return
			setStreetToStreetSketch(landbase)
			setStreettoStreetText(landbase)
		}
		if(digboundary="7")
		{
			setCornerSketch(landbase)
			setCornerText(landbase)
		}
		if(digboundary="8")
		{
			rclear := rogclear()
			if (rclear)
				return
			setPLtoPLSketch(landbase)
			setPLtext(landbase)
		}
		if(digboundary="9")
		{
			rclear := rogclear()
			if (rclear)
				return
			setLGasSketch()
		}
	}
	else
	{
		if (stationCode = "ROGYRK01") or if (stationCode = "ROGSIM01")
		{
			rclear := rogClear()
			if(rclear)
			{
				loadImage("rogclear.skt")
				ST_SAVEEXIT()
				newPagePrompt()
				pagetimeend := ((A_TickCount - timestart) / 1000)
				FileAppend, %ticketnumber% p.%currentpage% - %pagetimeend%`n, timelog.txt
				return
			}
		}
		if (stationCode = "APTUM01")
		{
			aptclear := aptClear()
			if (aptclear) 
			{
				loadImage("aptumclear.skt")
				ST_SAVEEXIT()
				newPagePrompt()
				return
			}
		}
		landbase := getlandbase()
		Switch landbase
		{
			Case "N": 	SWFUNC("b - north.skt", "B - north no sw.skt")
			Case "NE": 	SWFUNC("B - NE CORNER.SKT","B - NE corner no sw.skt")
			Case "E": 	SWFUNC("B - EAST.SKT","B - east no sw.skt")
			Case "SE": 	SWFUNC("B - SE CORNER.SKT","B - SE corner no sw.skt")
			Case "S": 	SWFUNC("B - SOUTH.SKT","B - South no sw.skt")
			Case "SW":	SWFUNC("B - SW CORNER.SKT","B - SW corner no sw.skt")
			Case "W":	SWFUNC("B - WEST.SKT","B - WEST NO SW.SKT")
			Case "NW": 	SWFUNC("B - NW CORNER.SKT","B - NW corner no sw.skt")
			Case "TN":	loadImage("b - t intersection n.skt")
			Case "TS":	loadImage("b - t intersection s.skt")
			Case "TW":	loadImage("b - t intersection w.skt")
			Case "TE": 	loadImage("b - T intersection e.skt")
			Case "H": 	loadImage("B - horizontal st.skt")
			Case "V": 	loadImage("B - vertical st.skt")
			Case "HSS": loadImage("B - horizontal st centre to centre.skt")
			Case "VSS": loadImage("B - vertical centre to centre.skt")
			Case "INT": loadImage("B - intersection.skt")
			Case "Custom": openimagedialog()
			Default:	MsgBox % "No valid option selected. Please load form manually!"
		}
		if landbase in N,S,E,W,H,V
		{
			setTemplateText(landbase . "street.skt", street)
		}
		if landbase in NE,NW,SE,SW,TN,TS,TW,TE
		{
			inter := isInterText()
			setCornerText(landbase)
		}
	}
	WinWaitClose, ahk_exe SketchToolApplication.exe
	newPagePrompt()
	pagetimeend := ((A_TickCount - timestart) / 1000)
	FileAppend, %ticketnumber% p.%currentpage% - %pagetimeend%`n, timelog.txt
	return
}
}

;DIG AREA
;this function needs cleanup
writeDigArea() {
	global
	digboundary := getDigBoundaries() ; asks for INT representing dig boundaries
	if (digboundary = "") ;no entry
	{
		getRegDA() ; asks line by line for dig box - returns north south east west
		wait()
		if (form = "RA") ;this might not need to be here TODO: check if can do ternary below since all that needs to change is boundary.skt etc
		{
			writeRAdigarea()
			clickselection()
			return
		}
		;setTemplateText -
		focusSketchTool()
		if (form = "AP")
		{
			digarray := {(north):"Nboundaryapt.skt",(south):"sboundaryapt.skt",(west):"wboundaryapt.skt"
		,(east):"eboundaryapt.skt"}
		}
		else
		{
			digarray := {(north):"Nboundary.skt",(south):"sboundary.skt",(west):"wboundary.skt"
			,(east):"eboundary.skt"}
		}
		for k,v in digarray
		{
			setTemplateText(v,k)
		}
		digarray :=
	}
	else ;if using different boundaries
	{
		switch digboundary
		{
			;case 1 - DW to DW, case 2 - utilizing BL
		case "1":
			setDWToDWDA()
		case "2":
			setBLToBLDA()
		case "3":
			setRCDA()
		case "4":
			setPLDigArea()
		case "5":
			setPL4DigArea()
		case "6":
			setStreetToStreetDigArea()
		case "7":
			setCornerDigArea()
		case "8":
			setSGasDigArea()
		case "9":
			setLGasDigArea()
			;default case below just in case, recursion
		default:
			digboundary := ""
			writeDigArea()
		}
	}
}

;MOBILE SPECIFIC BUTTON HANDLERS/HOTKEYS

#ifwinactive ahk_exe mobile.exe

	f2::
		ticketDatatoJSON()
	return

	RShift::
	MBUTTON::
		Menu, Mobile, Show
	return

	F8::
		projectSketch()
	return

	F9::
	::SKAF::
		sketchAutoFill()
	return

	+f9::
		AFFromClearTemplate()
	return

	^n::
	::newsketch::
		setForm()
	return

	;MOBILE HOTSTRINGS

	:::wtf::
		writeTemplateFile()
	return

#IfWinActive

;MOBILE FUNCTIONS

ticketDatatoJSON(){
	ControlGet, data, list,,SysListview321,ahk_exe mobile.exe
	tl := []
	j := new JSON()
	street:="",town:=""
	for i,row in StrSplit(data,"`n")
	{
		fields := strsplit(row, "`t")

		obj :=	{ id:i
			,name:fields[2]
			,street:fields[6]
			,civic:fields[5]
			,intersection:fields[14]
		,intersection2:fields[17]}
		tl.Push(obj)
		obj:="",fields:=""
	}
	jval := j.Dump(tl,,2)
	;ScrollBox(jval,"b1","Tickets as JSON")
	FileAppend, %jval%, jsondata.txt
}

getPoleNumber(diginfo){
	if !(diginfo)
	{
		MB("No dig info obtained")
	return ""
}
substr := StrSplit(diginfo," ", OmitChars)
for i,v in substr
{
	if (RegExMatch(v,"P[0-9]+"))
	return v
}
}

AFFromClearTemplate()
{
	global
	;used to fill out clear forms from text file format %ticketnumber%.txt
	;outputs - dig area, rogclear/ftth/foonlyclear
	;inputs - ticket data, pltopl or manual entry, address 1, address 2 if applicable, nbound, sbound, ebound, wbound
	;read text file
	setForm()
	waitSTLoad()
	;if !FileExist(A_MyDocuments "\" ticketnumber ".txt")
	;{
	;	Msgbox, % "Please complete text file"
	;}

	;else
	;{

	readClearTemplate()
	addtotimesheet()
	finishemail()
	SetTimer,checkfornewticketb, 200
}

checkforNewTicket()
{
	Controlget, ticketNumbernew, line, 1, edit1, ahk_exe mobile.exe
	if(ticketnumber != ticketNumbernew)
	{
		autoinsertSketches()
		ticketNumbernew := ""
	}
}

checkforNewTicketB()
{
	Controlget, ticketNumbernew, line, 1, edit1, ahk_exe mobile.exe
	if(ticketnumber != ticketNumbernew)
	{
		AFFromClearTemplate()
		ticketNumbernew := ""
	}
}

locationDataCheck(Ticket)
{
  if (Ticket.number != "") {
    return true
	}
}

newproj()
{
	Run, projectfile.ahk
}

openSketchEditor()
{
	Send, !ls
}

readClearTemplate()
{
	global
	FileRead, templatefile, C:\Users\Cr\Documents\%ticketnumber%.txt
	linelist := StrSplit(templatefile, "`r`n")
	msgbox % linelist.22
	if linelist[1] = "y"
		autofillExistingSketch()
	else if linelist.Length() == 3 ;ie pl4 template
	{
		num1 := linelist[2]
		num2 := linelist[3]
		setPL4DigArea(num1,num2)
		loadImage("rogclear.skt")
		ST_SAVEEXIT()
	}
	else if linelist.Length() == 5 ; manual clear template
	{
		IF (FORM = "RA")
		{
			setTemplateText("RANboundary.skt",linelist[2])
			setTemplateText("RAsboundary.skt",linelist[3])
			setTemplateText("RAWBoundary.skt",linelist[4])
			setTemplateText("RAEBoundary.skt",linelist[5])
		}
		else
		{
			setTemplateText("Nboundary.skt",linelist[2])
			setTemplateText("sboundary.skt",linelist[3])
			setTemplateText("WBoundary.skt",linelist[4])
			setTemplateText("EBoundary.skt",linelist[5])
		}
		clearreason := Inputbox("Clear reason","Regular (r)`nFTTH (f)`nClear For Fibre Only(c)")
		switch clearreason
		{
			case "r": loadImage("rogclear.skt")
			case "f": loadImage("ftth.skt")
			case "c": loadImage("exclusion agreement r.skt")
		}
		ST_SAVEEXIT()
	}
	else
	{
		MsgBox, % "Template formatting error!"S
	return
}
}

resetFormVar()
{
	global form
	global locationDataObtained
	global totalpages
	global currentpage
	form := "", locationDataObtained := "", totalpages := "",currentpage := "", num := ""
	MsgBox % "Form data has been reset!"
}

getForm(Ticket)
{
	if (Ticket.form = "") 
	{
	  firstLetter := SubStr(Ticket.stationcode,1,1)
  	switch firstLetter 
  	{
		case "R":
		  return "RP"
		case "B":
		  return "BP"
		case "A":
		  return "AP"
  	}
  }
	else 
	{
		return SubStr(Ticket.form,1,1) . "A"
	}

setForm(Ticket)
{
  switch Ticket.form
	{
		case "BP":
		  text := "|<>*117$65.zj8DD44D64w8EEEF88XA90EUUUWEG2IG0V1114UY4gY13m3m9z899D24447W2EG+E4888844UYIU8EEEE88X8N0EyyyUEEsEHw"

		case "BA":
		  text := "|<>*122$71.l13lVD0MEYTEG28n2E0kV8YUY4UZ4U1F2+91891/904W4AG2Tm2GHk948EYMUY4WY0F8Fl81189581yEWWE228m6E24n8YU44C44yA4wlxw"

		case "RP":
		  text := "|<>*122$51.D33l1sTw+0MF880EWU2W91024I0YF880EWU4Xl1s22Y0WF880EIUDm91022W12F880EADM/lxw214"

	  case "RA":
		  text := "|<>*119$71.6xz7Y41wSD60N0EE88216FA4W0V0EE444WQC4120UU8894ccD241z0SEHlF8E48220UUYWI8U8E441118Yc90EE88216F8kPsUSEE41kVF000000000000000000T00000E"

	  case "AP":
		  text := "|<>*135$46.D3kSS7Vt0FW90U8s22E4411U890EE460UYNt0EM22EY411U892EE450FW90U8nks7blsQU"

	  case "AA":
		  text := "|<>*134$68.jTlt10T7XlUG0UUEE42AWMAU8E441118b3824110EEG9FHkV0Tk7Y4wIIU8E4411194d824110EEG9+G0UUEE42AWFay87Y410Q8IF00000000000000007k00002" 
	}

	if (ok:=FindText(960-150000, 597-150000, 960+150000, 597+150000, 0, 0, text))
	{
		CoordMode, Mouse
		X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
		Click, %X%, %Y%
	}
			
}

;MOBILE MODULES

getticketpicture:
	run,getticketpicture.ahk
return

writeTemplateFile()
;generates a template file that can be used with above solution
{
	global north, south, west, east
	clickLocationTab()
	getTicketData(number, street, intersection, intersection2, stationCode, diginfo, ticketNumber, town, ticketdata)
	Loop
	{
		Inputbox, useexisting, Use existing, Y or N
		if useexisting in y,Y,n,N
			break
	}
	if (useexisting = "y")
	{
		;FileSelectFile, filename,, A_MyDocuments
		FileAppend, %useexisting%, A_MyDocuments\%ticketNumber%.txt
		MsgBox % "File written to " A_MyDocuments "\" ticketNumber ".txt"
		return
	}
	Inputbox, type, Template, Select template type:`n1.PL4`n2.Manual
	if (type = "1")
	{
		InputBox,house1, House 1, Enter house 1
		InputBox,house2, House 2, Enter house 2
		FileAppend, %useexisting%`n%house1%`n%house2%,%A_MyDocuments%\%ticketNumber%.txt
		msgbox, %useexisting%`n%house1%`n%house2%
		MsgBox % "File written to " A_MyDocuments "\" ticketNumber ".txt"
		return
		;units
		;

	}
	else
	{
		getRegDA()
		FileAppend, %useexisting%`n, C:\Users\Cr\Documents\%ticketNumber%.txt
		FileAppend, %north%`n, C:\Users\Cr\Documents\%ticketNumber%.txt
		FileAppend, %south%`n, C:\Users\Cr\Documents\%ticketNumber%.txt
		FileAppend, %west%`n, C:\Users\Cr\Documents\%ticketNumber%.txt
		FileAppend, %east%, C:\Users\Cr\Documents\%ticketNumber%.txt
		MsgBox, %south%`n
		MsgBox % "File written to " A_MyDocuments "\" ticketNumber ".txt"
		return
	}
}

;GUI BUTTON Labels

DAButtonOK:
	Gui,Da: Submit
	Gui, Da: Destroy
return

DWButtonOK:
	Gui, DW: Submit
	Gui, DW: Destroy
return

PL4ButtonOK:

	Gui, PL4: Submit
	Gui, PL4: Destroy
return

2ButtonCancel:
	Gui, 2: Cancel
return

2ButtonOK:
	Gui, 2:Submit
	rogwarn := {"fibreonly":fibreonly, "ftth":ftth, "highriskfibre":highriskfibre
	,"inaccuraterecords":inaccuraterecords, "railway": railway}
	for k, v in rogwarn
	{
		if (v = 1)
			loadImage(k ".skt")
	}
	Critical, Off
return

;CLASS DEFINITIONS

class TMobileAutomation {
}

class SketchToolAutomation {
}

class Ticket 
{

	__New(number := "", street := "", intersection := "", intersection2 := "", stationCode := "", digInfo := "", ticketNumber := "", town := "", workType:= "")
	{
		this.number := number
		this.street := street
		this.intersection := intersection
		this.intersection2 := intersection2
		this.stationCode := stationCode
		this.ticketNumber := ticketNumber
		this.town := town
		this.workType := workType
	}

	GetData()
	{
		ControlGet, number, Line,1, edit2, ahk_exe Mobile.exe
		ControlGet, street, line,1, Edit6, ahk_exe Mobile.exe
		ControlGet, intersection, line,1,edit10, ahk_exe mobile.exe
		ControlGet, intersection2, line,1,edit12, ahk_exe mobile.exe
		ControlGet, stationCode, line,1, edit9, ahk_exe mobile.exe
		ControlGetText, digInfo, edit22, ahk_exe mobile.exe
		controlget, ticketNumber, line, 1, edit1, ahk_exe mobile.exe			
		controlget, town, line, 1, edit13, ahk_exe mobile.exe
		this.number := number
		this.street := street
		this.intersection := intersection
		this.intersection2 := intersection2
		this.stationCode := stationCode
		this.ticketNumber := ticketNumber
		this.town := town
		this.workType := workType
		return this
	}

	ForceAuxilliary()
	;returns string representing auxilliary for particular utility
	{
		if (this.stationCode = "ROGYRK01"){
			return "RA"
		}
		else if (this.stationCode = "ROGSIM01"){
			return "RA"
		}
		else{
			return "BA"
		}

	}
}

class Sketch 
{

	__New(landbase:=""){
	}

	;returns an integer representing digboundary
	GetDigType(){
		return this.digtype := GetDigBoundaries()
	}

	;returns a digarea object(north,south,east,west)
	getDigArea(){
		return this.digarea := getRegDA()
	}

	;writes dig area to sketch
	putDigArea(){
		setTemplateText("NBoundary.skt",this.digarea.north)
		setTemplateText("SBoundary.skt",this.digarea.south)
		setTemplateText("WBoundary.skt",this.digarea.west)
		setTemplateText("EBoundary.skt",this.digarea.east)
	}

}

class Point 
{

	__New(x,y)
	{
		this.x := x
		this.y := y
	}
}

beginHook(Options, EndKey,Matchlist){
	ih := InputHook(Options, Endkey,Matchlist)
	ih.Start()
	ih.Wait()
}

getlandbase(){
	InputBox, landbase, Load landbase,(N/NE/E/SE/S/SW/W/NW/H/V/TN/TS/TE/TW/HSS/VSS/INT/Custom?)
return landbase
}

isSidewalk(){
	InputBox, SIDEWALK, SIDEWALK? SIDEWALK?, Y/N?
return SIDEWALK
}

boreholeAutoFill()
{
	global
	setForm()
	waitSTLoad()
	openExistingPrompt()
	IfMsgBox, Yes
	{
		autofillExistingSketch()
		WinWaitClose, ahk_exe SketchToolApplication.exe
	}
	IfMsgBox, No
	{
		setBHDigArea()
		rclear := rogClear()
		if (rclear)
		{
			setRogersClear()
			rclear := ""
			ST_SAVEEXIT()
		}
		else
		{
			InputBox, landbase, landbase, Which Direction?
			if (landbase = "n")
				loadImage("bhn.skt")
			else if (landbase = "s")
				loadImage("bhs.skt")
			else if (landbase = "w")
				loadImage("bhw.skt")
			else if (landbase = "e")
				loadImage("bhe.skt")
			else if (landbase = "h")
				loadImage("bhhorizontal.skt")
			else if (landbase = "v")
				loadImage("bhvertical.skt")
			WinWaitClose,ahk_exe sketchToolApplication.exe
		}
	}
	if (currentpage < totalpages)
		boreholeAutoFill()
}

;drawing for ped radius
pedAutoFill() {
	global
	setForm()
	openExistingPrompt()
	IfMsgBox, Yes
	autofillExistingSketch()
	IfMsgBox, No
	{
		setPedDigArea()
		InputBox, landbase, Landbase, Which Direction?
		loadImage("pedrad" . landbase . ".skt")
		setTemplateText(landbase . "street.skt", street)
		WinWaitClose, ahk_exe sketchToolApplication.exe
	}
	if (currentpage < totalpages)
		pedAutoFill()
}

openExistingPrompt()
{
	MsgBox, 4132, Open Existing?, Open existing sketch?
}

;radius dig area
#IfWinActive AHK_EXE MOBILE.EXE
+F12::
::RAF::
	radiusProject(){
		InputBox, type, Type, Boreholes = b`nPoles = p`nTrees = r`nPeds = x`nTransformer = t
		Switch type
		{
			Case "b": boreholeAutoFill()
			Case "p": poleAutoFill()
			Case "r": treeAutoFill()
			Case "x": pedAutoFill()
			Case "t": transformerAutoFill()

		}
	}
#IfWinActive

transformerAutoFill()
{
	global
	setForm()
	waitSTLoad()
	if (form = "BP")
	{
		bellPrimaryPoleAutofill()
		WinWaitClose("ahk_exe Sketchtoolapplication.exe")
		if (currentpage < totalpages)
			transformerAutoFill()
	}
	else
	{
		openExistingPrompt()

		IfMsgBox, Yes
		{
			autofillExistingSketch()
			WinWaitClose("ahk_exe Sketchtoolapplication.exe")
			if (currentpage < totalpages)
				transformerAutoFill()
		}

		IfMsgBox, No
		{
			txlocation := Inputbox("Where is the tranformer situated?`n`nb = backyard`nf = front of house")
			landbase := InputBox("What side of the road is the address on?`n(N, E, S, W)")
			address := InputBox("Address number?")
			txnumber := InputBox("Transformer number?")

			if (form = "RA")
			{
				oTransformerDigArea := { "RANBoundary.skt":"5M N OF TRANSFORMER " txnumber
					,"RASBoundary.skt": "5M S OF TRANSFORMER " txnumber
					, "RAWBoundary.skt": "5M W OF TRANSFORMER " txnumber
				, "RAEboundary.skt": "5M E OF TRANSFORMER " txnumber }
			}
			else
			{
				oTransformerDigArea := { "NBoundary.skt": "5M N OF TRANSFORMER " txnumber
					, "SBoundary.skt": "5M S OF TRANSFORMER " txnumber
					, "WBoundary.skt": "5M W OF TRANSFORMER " txnumber
				, "Eboundary.skt": "5M E OF TRANSFORMER " txnumber }
			}

			For k,v in oTransformerDigArea
			{
				setTemplateText(k,v)
				if ErrorLevel
					return
			}

			MsgBox, 36, Clear?, Locate Clear?

			IfMsgbox, Yes
			{
				if (stationcode = "ROGYRK01") or if (stationcode = "ROGSIM01")
				{
					loadImage("rogclear.skt")
					ST_SAVEEXIT()
				}
				else if (stationcode = "BCGN01") or if (stationcode = "BCGN02")
				{
					loadImage("transformerradius.skt")
					setTemplateText(landbase . "transformerradiusaddress.skt",address)
					setTemplateText("transformerradiustxnumber.skt", txnumber)
					setTemplateText("transformerradiuslocateclearbell.skt", "LOCATED AREA CLEAR OF BELL")
					ST_SAVEEXIT()
				}
			}

			IfMsgBox, No
			{
				cabledir := InputBox("Which side of the transformer is the cable on?`n(N,E,S,W)")
				offset := setMeasurement()
				if (txlocation = "b")
				{
					loadImage("transformerradius.skt")
					loadImage(cabledir . "transformercable.skt")
					setTemplateText(cabledir . "transformercableoffset.skt",offset)
					setTemplateText(landbase . "transformerradiusaddress.skt",address)
					setTemplateText("transformerradiustxnumber.skt", txnumber)
					WinWaitClose, ahk_exe SketchToolApplication.exe

				}
				else
				{
					Return
				}
			}
			if (currentpage < totalpages)
				transformerAutofill()
			pagetimeend := ((A_TickCount - timestart) / 1000)
			FileAppend, %ticketnumber% p.%currentpage% - %pagetimeend%`n, timelog.txt
		}
	}
}
^F12::
	sptreeAutofill()
return

sptreeAutofill()
{
	global
	setForm()
	waitSTLoad()

	if (form = "BP")
	{
		;QUICK FILL FOR SINGLE VS PROJECT
		btickettype := Inputbox("Single or Project?")
		if btickettype in s,S,p,P
		{
			if (btickettype = "s")
			{
				totalpages := 2

				units := Inputbox("Enter units")
				primary_template := "bellprimcabconcc.skt"
				focusSketchtool()
				loadImage("bell primary.skt")
				wait()
				loadImage(primary_template)
				wait()
				setTemplateText("bellprimarydate.skt",getCurrentDate())
				wait()
				setTemplateText("units.skt",units)
				wait()
				setTemplateText("RPtotalpages.skt",totalpages)
				wait()
				if !currentpage
					currentpage := 1
				Controlclick("OK","ahk_exe sketchtoolapplication.exe")
				focusTeldig()
			}
			else if (btickettype = "p")
			{
				bellPrimaryPoleAutofill()
				ST_SAVEEXIT()
			}

			else
			{
				bellPrimaryPoleAutofill()
				ST_SAVEEXIT()
			}
		}
	}

	else
	{
		inputbox,number,Number, Enter house number
		inputbox,street,Street, Street name?

		(form = "RA") ? loadImageNG("RANBoundary.skt") : loadImageNG("NBoundary.skt")
		SendInput {f2}
		SendInput, 2M N OF STUMP %number% %street%{Enter}
		(form = "RA") ? loadImageNG("RASBoundary.skt") : loadImageNG("SBoundary.skt")
		;Sleep
		SendInput, {f2}
		Send, 2M S OF STUMP %number% %street%{enter}
		(form = "RA") ? loadImageNG("RAWBoundary.skt") : loadImageNG("WBoundary.skt")
		;Sleep
		SendInput, {f2}
		Send, 2M W OF STUMP %number% %street%{enter}
		(form = "RA") ? loadImageNG("RAEBoundary.skt") : loadImageNG("EBoundary.skt")
		; Sleep 500
		SendInput, {f2}
		Send, 2M E OF STUMP %number% %street%{enter}
		wait()
		clickSelection()
		rclear := rogClear()
		if (rclear)
		{
			setRogersClear()
			rclear := ""
			ST_SAVEEXIT()
			return
		}
		InputBox, landbase, landbase, Which Direction?
		if (form = "RP") or if (form = "RA")
		{
			loadimageNG("tree" landbase "3.skt")
		}
		else
		{
			loadImageNG("tree" landbase "2.skt")
		}
		WAIT()
		setTemplateText(landbase "streettree.skt", street)
		wait()
		setTemplateText(landbase "treenumber.skt",number)
		wait()
		setTemplateText(landbase "treetype.skt", "STUMP")
		if (form = "RP") || if (form = "RA")
		{
			setTemplateText(landbase "treemeas1.skt", "1.0m")
			wait()
			setTemplateText(landbase "treemeas2.skt", "2.7m")
			wait()
			setTemplateText(landbase "treecablelabel1.skt","FO")
			wait()
			setTemplateText(landbase "treecablelabel2.skt", "TV")
		}
		else
		{
			setTemplateText(landbase "treemeas2.skt","2.7m")
			wait()
			setTemplateText(landbase "treecablelabel2.skt","1B1C")
			WinWaitClose, AHK_EXE SKETCHTOOLAPPLICATION.EXE
			if (currentpage < totalpages)
				sptreeAutoFill()
		}
	}
}

treeAutoFill()
{
	global
	setForm()
	waitSTLoad()
	if (form = "BP")
	{
		bellPrimaryPoleAutofill()
		ST_SAVEEXIT()
	}
	else
	{
		openExistingPrompt()
		IfMsgBox, Yes
		{
			autofillExistingSketch()
		}
		IfMsgBox, No
		{
			treetype := setTreeDigArea()
			rclear := rogClear()
			if (rclear)
			{
				setRogersClear()
				rclear := ""
				ST_SAVEEXIT()
				return
			}
			InputBox, street, Street, Street?,,,,,,, %street%
			InputBox, landbase, landbase, Which Direction?
			InputBox, number,Number, Enter house number?
			InputBox, cabloc, Location, Where is cable relative to tree?`n1 = closer to road`n2 = closer to property`n3 = both sides of tree
			loadimageNG(treeSketchBuilder(landbase,cabloc))
			setTreeLabels(street, cabloc, landbase, treetype,number)
			;if (landbase = "n")
			;       loadImage("treen.skt")
			;else if (landbase = "s")
			;        loadImage("trees.skt")
			;	else if (landbase = "w")
			;           loadImage("treew.skt")
			;	else if (landbase = "e")
			;           loadImage("treee.skt")
			WinWaitClose, AHK_EXE SKETCHTOOLAPPLICATION.EXE
		}
	}
	if (currentpage < totalpages)
		treeAutoFill()
	pagetimeend := ((A_TickCount - timestart) / 1000)
	FileAppend, %ticketnumber% p.%currentpage% - %pagetimeend%`n, timelog.txt
}

setTreeLabels(street, cabloc, landbase, treetype, number := "")
{
	setTemplateText(landbase "streettree.skt", street)
	if (cabloc = 1) {
		meas1 := setMeasurement()
		label := getCableLabel()
		setTemplateText(landbase "treemeas1.skt", meas1)
		wait()
		setTemplateText(landbase "treecablelabel1.skt", label)
		wait()
		setTemplateText(landbase "treetype.skt", treetype)
		wait()
		if (number)
		{
			setTemplateText(landbase "treenumber.skt", number)
		}
	}
	else if (cabloc = 2)
	{
		meas2 := setMeasurement()
		label2 := getCablelabel()
		setTemplateText(landbase "treemeas2.skt",meas2)
		wait()
		setTemplateText(landbase "treecablelabel2.skt",label2)
		wait()
		setTemplateText(landbase "treetype.skt", treetype)
		wait()
		if (number)
		{
			setTemplateText(landbase "treenumber.skt", number)
		}
	}
	else
	{
		meas1 := setMeasurement()
		meas2 := setMeasurement()
		label := getCableLabel()
		label2 := getCableLabel()
		setTemplateText(landbase "treemeas1.skt", meas1)
		wait()
		setTemplateText(landbase "treemeas2.skt", meas2)
		wait()
		setTemplateText(landbase "treecablelabel1.skt", label)
		wait()
		setTemplateText(landbase "treecablelabel2.skt", label2)
		wait()
		setTemplateText(landbase "treetype.skt", treetype)
		wait()
		if (number)
		{
			setTemplateText(landbase "treenumber.skt", number)
		}
	}
}

getCableLabel()
{
	label := Inputbox("Enter label for cable")
	StringUpper, label, label
return label
}

treeSketchBuilder(landbase, cabloc := "")
{
return "tree" . landbase . cabloc . ".skt"
}

setPoleLandbase()
{
	global polenum
	global street, intersection
	;global landbase
	InputBox, landbase, landbase, Which Direction?
	poledict := {"polen.skt":"n", "poles.skt":"s", "polew.skt":"w", "polee.skt":"e", "polesw.skt":"sw", "polene.skt":"ne", "polese.skt":"se"}
	for k,v in poledict
	{
		if(v = landbase)
		{
			loadImage(k)
			setTemplateText(v "polenum.skt", polenum)
			setTemplateText(v "street.skt", street)
		}
	}
	;~ if (landbase = "n")
	;~ loadImage("polen.skt")
	;~ else if (landbase = "s")
	;~ {
	;~ loadImage("poles.skt")
	;~ setTemplateText("spolenum.skt", polenum)
	;~ setTemplateText("sstreet.skt", street)
	;~ }
	;~ else if (landbase = "w")
	;~ loadImage("polew.skt")
	;~ else if (landbase = "e")
	;~ loadImage("polee.skt")
	;~ else if(landbase = "sw")
	;~ loadImage("polesw.skt")
	;~ else if(landbase = "ne")
	;~ loadImage("polene.skt")
	;~ else if(landbase = "se")
	;~ loadImage("polese.skt")
	WinWaitActive, ahk_exe mobile.exe
}

poleAutoFill() ; AUTOCOMPLETE FOR POLES
{
	global
	setForm()
	polenum := getPoleNumber(diginfo)
	if (form = "bp")
	{
		bellPrimaryPoleAutofill()
		ST_SAVEEXIT()
	}
	else
	{
		openExistingPrompt()

		IfMsgBox, Yes
		{
			autofillExistingSketch()
		}

		IfMsgBox, No
		{
			setPoleDigArea(polenum)
			if (stationcode = "ROGYRK01") or if (stationcode = "ROGSIM01")
			{
				rclear := rogClear()
				if (rclear)
				{
					setRogersclear()
					rclear := ""
					ST_SAVEEXIT()
				}
				else
				{
					setPoleLandbase()
					return
				}
			}
			else
			{
				setPoleLandbase()
			}
		}
	}

	if (currentpage < totalpages)
	{
		poleAutoFill()
		pagetimeend := ((A_TickCount - timestart) / 1000)
		FileAppend, %ticketnumber% p.%currentpage% - %pagetimeend%`n, timelog.txt
		return
	}
}

autofillExistingSketch()
{
	global
	openimagedialog()
	waitCloseDialogBox()
	if(form = "BP")
	{
		units := Inputbox("Enter units")
		totalpages := Inputbox("Enter total pages")
		loadImage("bell primary.skt")
		wait()
		setTemplateText("units.skt", units)
		wait()
		setTemplateText("bellprimarydate.skt",getCurrentDate())
		wait()
		setTemplateText("RPtotalpages.skt", totalpages)
		IF currentpage =
			currentpage = 1
		IF TOTALPAGES =
			TOTALPAGES = 1
		wait()
		ControlClick("OK","ahk_exe sketchtoolapplication.exe")
		focusTeldig()
		pagetimeend := ((A_TickCount - timestart) / 1000)
		FileAppend, %ticketnumber% p.%currentpage% - %pagetimeend%`n, timelog.txt
	}
	Else
	{
		WinWaitClose,ahk_exe SketchToolApplication.exe
		;ST_SAVEEXIT()
		newPagePrompt()
		pagetimeend := ((A_TickCount - timestart) / 1000)
		FileAppend, %ticketnumber% p.%currentpage% - %pagetimeend%`n, timelog.txt
	}
}

buttonLoadTemplate(x)
{
	Gui, 2: Submit
	loadImage(x)
}

;ControlClick(control, window)
;{
;ControlClick, %control%, %window%
;}
;selects arrow tool in SketchTool
clickPointer(){
	Acc_Get("DoAction", "4.7.4.2.4.1.4.1.4.1.4.1.2",0, "ahk_exe mobile.exe")
}

wait() ;defines function to insert pauses if necessary
{
	cpuload := CPULoad()
	Loop
	{
		if (cpuload > 20)
		{
			Sleep 50
			cpuload := CPULoad()
			continue
		}
		else
		{
			break
		}
	}
	; Random, random_number, 100, 300
	; Sleep % random_number
}

waitForImage(image)
{
	Loop
	{
		ImageSearch, foundx, foundy, 0,0,A_ScreenWidth, A_ScreenHeight, % image
		if (ErrorLevel = 0)
			break
	}
}

;KEYBINDING FOR NUMPAD keys

NumpadUp::Up
NumpadDown::Down
NumpadLeft::Left
NumpadRight::Right
NumpadClear::Enter
return

waitCaret()
{
	Loop
	{
		if (A_Cursor = "IBeam" || A_CaretX <> "")
			break
	}
}

openImageDialog() ; opens image selection menu
{
	SendInput,!i
	Sleep 50
	SendInput,{DOWN 8}
	Sleep 50
	SendInput,{Enter}
}

waitDialogBox() ; wait for dialog box
{
	WINWAITACTIVE AHK_CLASS #32770 ahk_exe sketchtoolapplication.exe
}

waitCloseDialogBox()
{
	WinWaitClose, ahk_class #32770 ahk_exe sketchtoolapplication.exe
}

waitSketchTool() ; waits for sketchtool to accept input
{
	WinWaitActive ahk_exe sketchtoolapplication.exe
}

loadImage(x) ; loads given template name and ungroups on sketch
{
	openimagedialog()
	waitdialogbox()
	Sleep 300
	SendInput, %x%{enter}
	waitCloseDialogBox()
	Sleep 50
	SendInput, !i{DOWN}{ENTER}
}

loadImageNG(x) ; loads template without ungrouping
{
	openimagedialog()
	waitdialogbox()
	SendInput %x%
	Sleep 50

	Send,{enter}
	Sleep 50
	waitCloseDialogBox()
}

saveFile() ; opens save dialog
{
	SendInput !f{enter}
}

focusTeldig() ;makes teldig window active and enlarges to full size
{
	WinActivate, ahk_exe mobile.exe
}

focusSketchTool()
{
	WinActivate, ahk_exe sketchtoolapplication.exe
}

clickLocationTab()
{
	Acc_Get("DoAction", "4.1.4.1.4.1.4.1.4.11.4",1,"ahk_exe mobile.exe")
	Sleep 150
}

clickDigInfoTab()
{
	Acc_Get("DoAction","4.1.4.1.4.1.4.1.4.11.4",2,"ahk_exe mobile.exe")
	Sleep 150
}

clickdrawingtab()
{
	Acc_Get("DoAction", "4.1.4.1.4.1.4.1.4.11.4",3,"ahk_exe mobile.exe")
	Sleep 150
}

picSearchSelect(x)
{
	ImageSearch,foundx,foundy, 0, 0, A_ScreenWidth, A_ScreenHeight, %x%
	MouseMove, %foundx%, %foundy%
	Click
}

scrolltobottom() ; scrolls to bottom of page
{
	Send {down 50}
}

clickNewForm()
{
	Text:="|<>*130$8.0Dw000000000T3UE0000000000000Dzz08"
	if (ok:=FindText(924-150000, 639-150000, 924+150000, 639+150000, 0, 0, Text))
	{
		CoordMode, Mouse, Screen
		X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
		Click, %X%, %Y%
	}
	sleep, 150
}

statusPending() ; change ticket status to pending
{
	CONTROL, choose, 3, ComboBox1, ahk_exe mobile.exe
}

getTicketData(ByRef number, ByRef street, byref intersection, ByRef intersection2, ByRef stationCode, ByRef diginfo, ByRef ticketNumber, ByRef town, byRef ticketdata)
{	;pulls data from ticket on mobile
	;returns a ticket object
	global
	ControlGet, number, Line,1, edit2, ahk_exe Mobile.exe
	ControlGet, street, line,1, Edit6, ahk_exe Mobile.exe
	ControlGet, intersection, line,1,edit10, ahk_exe mobile.exe
	ControlGet, intersection2, line,1,edit12, ahk_exe mobile.exe
	ControlGet, stationCode, line,1, edit9, ahk_exe mobile.exe
	ControlGetText, digInfo, edit22, ahk_exe mobile.exe
	controlget, ticketNumber, line, 1, edit1, ahk_exe mobile.exe
	controlget, town, line, 1, edit13, ahk_exe mobile.exe
	;ticketdata := [number, street, intersection, intersection2, stationcode, diginfo, ticketnumber, town]
	ticketdata := {number : number, street : street, intersection : intersection, intersection2 : intersection2, stationCode : stationCode, digInfo: digInfo, ticketNumber : ticketNumber, town : town}
	sleep 1000
return ticketdata
}

writePageNumber() ; page number prompt will replace with auto numbering
{
	global
	if(!totalpages)
	{
		totalpages := InputBox("Insert total number of pages")
	}
	if(!currentpage)
	{
		currentpage := InputBox("Insert current page number")
	}
	currentpage := currentpage + 1
	Sleep 300
	loadImageNG("currentpage.skt")
	wait()
	SendInput, {f2}%currentpage%{enter}
	wait()
	SendInput ^q
	Sleep 300
	loadImageNG("totalpages.skt")
	SendInput, {f2}%totalpages%
	Sleep 1000
}

getRPPages()
{
	global
	if !(currentpage)
		currentpage := 1
	if !(totalpages)
		totalpages := 1
	wait()
	INPUTBOX, TOTALPAGES, PAGES, TOTAL PAGES?,,,,,,,,%TOTALPAGES%
return totalpages
}

writeRPPageNumber() {
	global
	IF currentpage =
		currentpage = 1
	IF TOTALPAGES =
		TOTALPAGES = 1
	wait()
	INPUTBOX, TOTALPAGES, PAGES, TOTAL PAGES?,,,,,,,,%TOTALPAGES%
	IF ERRORLEVEL
		RETURN
	Sleep 300
	loadImageNG("RPtotalpages.skt")
	SendInput, {f2}%totalpages%{enter}
	wait()
	SendInput ^q
	;Send {CLICK 25,111}{CLICK 1035,85, DOWN}{CLICK 1060,122,UP}%TOTALPAGES%{ENTER}^q
	Sleep 1000
}
/*readDigBoxClicks() {
	ToolTip, Click upper left corner
	KeyWait, LButton, D
	MouseGetPos, x1, y1
	ToolTip,
	Sleep 500
	Tooltip, Click bottom right corner
	KeyWait, LButton, D
	MouseGetPos, x2, y2
	Tooltip,
	coordinates := [x1, y1, x2, y2]
	return coordinates
}
*/
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

getPoint(inst1) {
	Tooltip, % inst1
	Keywait, LButton, D, L
	MouseGetPos, x1, y1
	Tooltip,
	;arccoord := [x1, y1]
	arccoord := new Point(x1,y1)
return arccoord
}

#IFWINACTIVE Tel ahk_exe SketchToolApplication.exe
c::
\::
	autoDrawCable()
return

autoDrawCable() { ;auto cable draw with 2 points
	points := getPoints("Click line origin", "Click line destination")
	SetTitleMatchMode, 2
	CoordMode, Mouse, Window
	tt = TelDig SketchTool
	WinWait, %tt%
	IfWinNotActive, %tt%,, WinActivate, %tt%

	Sleep 100

	MouseClick, L, 24, 178

	Sleep 100

	Send,^+c

	Sleep 150

	MouseClick, L, % points.1, % points.2,,, D

	Sleep 150

	MouseClick, L, % points.3, % points.4,,, U

	Sleep, 132

	Click, 2
	Send, ^q
}

|::
	twoPointSL()
return

twoPointSL()
; draw cable with 2 points but straightLineTool()
{
	points := getPoints("Click line origin","Click line destination")
	SetTitleMatchMode, 2
	CoordMode, Mouse, Window
	tt = TelDig SketchTool
	WinWait, %tt%
	IfWinNotActive, %tt%,, WinActivate, %tt%
		wait()
	MouseClick, L, 24, 178
	wait()
	Send,^+c
	wait()
	Send, {Blind}{Shift Down}
	wait()
	MouseClick, L, % points.1, % points.2,,, D
	wait()
	MouseClick, L, % points.3, % points.4,,, U
	Send, {Blind}{Shift Up}
	Click, 2
	Send, ^q
}

; draw offset line with 2 points but straightLineTool()
twoPointSLoffset()

{
	points := getPoints("Click line origin","Click line destination")
	SetTitleMatchMode, 2
	CoordMode, Mouse, Window

	tt = TelDig SketchTool
	WinWait, %tt%
	IfWinNotActive, %tt%,, WinActivate, %tt%

	wait()

	MouseClick, L, 24, 178

	wait()

	Send,^+o
	wait()
	Send, {Blind}{Shift Down}
	wait()
	MouseClick, L, % points.1, % points.2,,, D

	wait()

	MouseClick, L, % points.3, % points.4,,, U

	Send, {Blind}{Shift Up}
	Click, 2
	Send, ^q
}

r::
!+r:: ;draw rectangle
	points:="",ulx:="",uly:="",lrx:="",lry:=""
	points:=getPoints("Click upper left corner","Click lower right corner")
	ulx:=points.1,uly:=points.2,lrx:=points.3,lry:=points.4
	SetTitleMatchMode, 2
	CoordMode, Mouse, Window
	tt = TelDig SketchTool
	WinWait, %tt%
	IfWinNotActive, %tt%,, WinActivate, %tt%
		wait()
	MouseClick, L, 24, 317
	wait()
	MouseClick, L, %ulx%, %uly%,,, D
	wait()
	MouseClick, L, %lrx%, %lry%,,, U
	midx := (ulx + lrx) / 2
	midy := (uly + lry) / 2
	wait()
	Send, {Blind}{Ctrl Down}q{Ctrl Up}
	wait()
	MouseClick, L, 28,104
	wait()
	MouseClick, L, % midx, % midy,,, D
	wait()
	MouseClick, L, % midx + 10, % midy + 10,,, U
	wait()
	Send, X
return

]::
	straightLineTool()
return

straightLineTool() {
	points := getPoints("Click at first point", "Click at second point")
	;wait()
	focusSketchTool()
	clickPointer()
	;wait()
	;picSearchSelect("polyline.png")
	clickPolyline()
	;Sleep 500
	Send, {Shift Down}
	MouseClick, L,% points.1,% points.2
	MouseClick, L, % points.3,% points.4
	;wait()
	Send, {Shift Up}
	;Send, {Tab}
	;Sleep 500
	points := ""
	Send, ^q
}

!+v::
	VerticalArrowTool()
return

VerticalArrowTool()
{
	arrow1 := getPoint("Click first point for measurement")
	sleep 200
	arrow2:= getPoint("Click second point for measurement")
	wait()
	clickLineTool()
	wait()
	clickPerArrowHeadEnd()
	;DRAW ARROW
	Send, {ShiftDown}
	MouseClickDrag, L, % arrow1.x, % arrow1.y, % arrow1.x, % (arrow2.y > arrow1.y) ? (arrow1.y - 32) : (arrow1.y + 32)
	wait()
	MouseClickDrag, L, % arrow1.x, % arrow2.y, % arrow1.x, % (arrow2.y > arrow1.y) ? (arrow2.y + 32) : (arrow2.y - 32)
	wait()
	Send, {ShiftUp}
	wait()
	;DRAW ARROW END
	clickTextTool()
	;Text:="|<>*120$9.zwM30M30M30M30MU"
	;if (ok:=FindText(15-150000, 104-150000, 15+150000, 104+150000, 0, 0, Text))
	;{
	;CoordMode, Mouse
	;X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
	;Click, %X%, %Y%
	;}
	;wait()
	(arrow1.y < arrow2.y) ? tloc := arrow1.y - 80 : tloc := arrow2.y - 80
	MouseClickDrag, L, % arrow1.x - 45, % tloc, % arrow1.x + 45,% tloc + 30
	Send, {Click 2}
	clickRotate90degrees()
	Send,{F2}
	setMeasurement()
	arrow1 := "", arrow2 := ""
	Send, ^q
}

clickTextTool(){
	Acc_Get("DoAction", "4.7.4.2.4.1.4.1.4.1.4.1.1",0, "ahk_exe sketchtoolapplication.exe")
}

clickLineTool(){
	Acc_Get("DoAction", "4.7.4.2.4.1.4.1.4.1.4.1.4",0, "ahk_exe sketchtoolapplication.exe")
}

clickPerArrowHeadEnd(){
	Acc_Get("DoAction", "4.7.4.2.4.1.4.1.4.1.4.3.6",0, "ahk_exe sketchtoolapplication.exe")
}

clickArch(){
	Acc_Get("DoAction", "4.7.4.2.4.1.4.1.4.1.4.1.5",0, "ahk_exe sketchtoolapplication.exe")
}

clickPolyline(){
	Acc_Get("DoAction", "4.7.4.2.4.1.4.1.4.1.4.1.7",0, "ahk_exe sketchtoolapplication.exe")
}

clickRectangle(){
	Acc_Get("DoAction", "4.7.4.2.4.1.4.1.4.1.4.1.10",0, "ahk_exe sketchtoolapplication.exe")
}

clickBringtoBack(){
	Acc_Get("DoAction","4.6.4.2.11",0,"ahk_exe sketchtoolapplication.exe")
}

clickBringtoFront(){
	Acc_Get("DoAction","4.6.4.2.12",0,"ahk_exe sketchtoolapplication.exe")
}

clickRotate90degrees(){
	Acc_Get("DoAction","4.6.4.2.14",0,"ahk_exe sketchtoolapplication.exe")
}

::ugrp::
:::u::
	ungroupImage()
return

ungroupImage(){
	SendInput, !i
	SendInput,{Down}{Enter}
}

::grp::
:::g::
	groupImage()
return

groupImage()
{
	SendInput, !i
	SendInput, {enter}
}
return

!+h::
	HorizontalArrowTool()
return

HorizontalArrowTool()
{
	arrow1 := getPoint("Click first point for measurement")
	Sleep 200
	arrow2 := getPoint("Click second point for measurement")
	wait()
	clickLineTool()
	clickPerArrowHeadEnd()
	Send, {ShiftDown}
	MouseClickDrag, L, % arrow1.x, % arrow1.y, % (arrow2.x > arrow1.x) ? (arrow1.x - 32) : (arrow1.x + 32), % arrow1.y
	Sleep 50
	MouseClickDrag, L, % arrow2.x, % arrow1.y, % (arrow2.x > arrow1.x) ? (arrow2.x + 32):(arrow2.x - 32), % arrow1.y
	Sleep 50
	Send, {ShiftUp}
	wait()
	clickTextTool()
	wait()
	(arrow1.x < arrow2.x) ? tloc := arrow1.x - 96: tloc := arrow2.x - 96
	MouseClickDrag, L,% tloc , % arrow1.y - 16, % tloc + 80, % arrow1.y + 16
	Sleep 25
	Send, {Click 2}{F2}
	wait()
	setMeasurement()
	arrow1:="", arrow2 := ""
	Send, ^q
}

+!d::
	HorizontalArrowTool()
	VerticalArrowTool()
return

a::
_::
	drawCorner()
return

drawCorner()
{
	line1 := getPoints("Click first point of line", "Click second point of line")
	Sleep 200
	arc := getPoint("Click arc point")
	Sleep 200
	line2 := getPoint("Click last point of line")
	Sleep 200
	focusSketchTool()
	Sleep 200
	clickPolyline()
	Send, +^c
	Sleep 200
	Send, {Shift Down}
	MouseClick, L,% line1.1,% line1.2,,5
	MouseClick, L,% line1.3,% line1.4,,5
	wait()
	Send, {Shift Up}
	wait()
	clickArch()
	wait()
	Sleep 200
	MouseClickDrag, L, % line1.3,% line1.4,% arc.1,% arc.2,5
	Send, +^c
	wait()
	clickPolyline()
	wait()
	Send, +^c
	Send, {Shift Down}
	MouseClick, L, % arc.x, % arc.y,,5
	MouseClick, L, % line2.1, % line2.2,,5
	wait()
	Send, {Shift Up}
	MouseClick, L,,,2
	clickSelection()
}

#IFWINACTIVE AHK_EXE SKETCHTOOLAPPLICATION.EXE
f4::
::DBX::
	DIGBOX()
return

DIGBOX()
{
	global bellclear
	SplashImage,,b x509 y22,Located Area Tool, Press Shift-Esc to Cancel
	coord := getPoints("Click at top left corner", "Click on bottom right corner")
	wait()
	clickRectangle()
	wait()
	MouseClickDrag, L,% coord.1, % coord.2, % coord.3, % coord.4, 5
	wait()
	Send, ^q{click}^+D
	wait()
	Send ^q
	wait()
	clickBringtoBack()
	newx := (coord.3 - coord.1) / 2 + coord.1 ; puts textbox in approximate middle of rectangle
	newy := (coord.4 - coord.2) / 2 + coord.2
	wait()
	mousemove, %newx%, %newy%
	wait()
	setTextbox()
	if (stationCode = "BCGN01") and (bellclear = "1")
		SendInput, LOCATED AREA CLEAR OF BELL
	else if (stationcode = "BCGN02") and (bellclear = "1")
		SendInput, LOCATED AREA CLEAR OF BELL
	else
		SendInput, LOCATED AREA{enter}
	splashimage off
}

saveTicketNumber() ;copies ticket number
{
	Send {click 133, 175,2}^c
	Sleep 900
}

;SHIFT TOGGLE
#IfWinActive ahk_exe sketchtoolapplication.exe
*/::
	if (shiftToggle := !shiftToggle)
	{
		Send {blind}{LShift Down}
		Tooltip, SHIFT Button Down, 123,284
	}
	else
	{
		Send {blind}{LShift Up}
		Tooltip
	}
return

RemoveTooltip()
{
	Tooltip
}

#IfWinActive
::snapgr:: 
	;snap to grid toggle
	if (snaptogridtoggle := !snaptogridtoggle)
	{
		Send {click, R}{up 2}{Enter}
		wait()
		Send {click, 1314, 210}t
		Tooltip, Snap to Grid ON,499,100
		SetTimer, RemoveTooltip, -5000
	}
	else
	{
		Send {click, R}{up 2}{Enter}
		wait()
		Send {click, 1314, 210}f
		Tooltip, Snap to Grid OFF,499,100
		SetTimer, RemoveTooltip, -5000
	}
Return

; PASTES HIGH RISK FIBRE LETTER
#H::
	add_high_risk_fibre_letter()
return

add_high_risk_fibre_letter(){
	loadImageNG("highriskletter.skt")
	ControlClick, OK,ahk_exe SketchToolApplication.exe
	WinActivate, ahk_exe mobile.exe
}

; ADDS HIGH RISK FIBRE STICKER
::hiriskfibre::
	loadImageNG("high risk fibre.png")
return

isInt(var){
	if var is Integer
		return true
	else
		return false
}

#IfWinActive ahk_exe mobile.exe
^!t::
::tmsht::
	addtotimesheet()
return

getUtility(string) {

}

addtotimesheet()
{
	GLOBAL
	ErrorLevel := ""
	SetKeyDelay, 100
	SPLASHTEXTON ,,,ADDING TO LOGSHEET TEXT FILE
	clickLocationTab()
	getTicketData(number,street,intersection,intersection2,stationCode,diginfo,ticketNumber,town,ticketdata)
	today := A_DD . " " . A_MM . " " . A_yyyy

/*

	InputBox, units, Units, Enter units string (format: <num><M/C><util(R/B/A)> separated by Space)
	if (RegExMatch(units, " ")) {
		mb("multiple entries: " StrSplit(units," ").Length())
	}
	if (RegExMatch(units,"r")) {
		mb("rogers")
	}
	

	if !(instr(units," ")) {
		utilArray := units
	}

	else {
	utilArray = StrSplit(units, A_Space)
	}

	if (utilArray = ""){
		return
	}

	for i,j in utilArray {
		; check for improper string length
		if (StrLen(j) < 3) || (Strlen(j > 4)) {
			mb("Incorrect format!")
		}

		;rogers - if last character is r
		if (InStr(j,"r",,3)) {
			if (InStr(j,"m",,2)) {
				rogersmarked := SubStr(j,1,-1)
				stringupper,rogersmarked,rogersmarked
			}
			else if (Instr(j,"c",,2)) {
				rogersclear := SubStr(j,1,-1)
				stringupper,rogersclear,rogersclear
			}
			else {
				Mb("Incorrect format!")
			}
		}

		;aptum
		;if last character is b
		else if (InStr(j,"b",,3)) {

			;check for m or c - reject otherwise
			if (InStr(j,"m",,2)) {
				bellmarked := SubStr(j,1,-1)
				Stringupper,bellclear,bellclear
			}
			else if (Instr(j,"c",,2)) {
				bellClear := SubStr(j,1,-1)
				Stringupper,bellclear,bellclear
			}
			else {
				Mb("Incorrect format!")
			}
		}

		;aptum
		;if last character is a
		else if (InStr(j,"a",,3)) {
			if (InStr(j,"m",,2)) {
				aptummarked := SubStr(j,1,-1)
				Stringupper,aptummarked,aptummarked
			}
			else if (Instr(j,"c",,2)) {
				aptumclear := SubStr(j,1,-1)
				Stringupper,aptumclear,aptumclear
			}
			else {
				Mb("Incorrect format!")
			}
		}

		;all other cases
		else {
			MB("Incorrect format")
		}
	}
	MB(rogersmarked "`n" rogersClear "`n" bellmarked "`n" bellclear "`n" aptummarked "`n" aptumclear)
	*/

	Loop{
		InputBox, ROGERSMARKED, Enter Rogers Marked (1 -20 or blank)
		if ROGERSMARKED is not digit
			continue
	}
	until ROGERMARKED <= 20
	if ErrorLevel
		return

	Loop{
		InputBox, ROGERSCLEAR, Enter rogers Clear (1 - 20 or blank)
		if rc is not digit
			continue
	}
	until ROGERSCLEAR <= 20

	Loop{
		InputBox, BELLMARKED, Enter bell Marked (int)
		if BELLMARKED is not digit
			continue
	}
	until BELLMARKED <= 20

	Loop{
		InputBox, BELLCLEAR, Enter Bell clear (int)
		if BELLCLEAR is not digit
			continue
	}
	until BELLCLEAR <= 20

	if (rogersMarked)
		rogersMarked .= "M"
	if (rogersClear)
		rogersClear .= "C"
	if (bellMarked)
		bellMarked .= "M"
	if (bellClear)
		bellClear .= "C"

	InputBox, comments, Enter comments
	StringUpper, comments,comments
	FileAppend,% ticketnumber "," number " " street "," rogersMarked "," rogersClear "," bellMarked "," bellClear "," comments "`n", C:\Users\Cr\timesheet%today%.txt
	if (ErrorLevel)
		MsgBox % "There was an error writing to timesheet`nError: " A_LastError
	SplashTextOff
}

newtimesheetentry(){
	GLOBAL
	SPLASHTEXTON ,,,Adding new comment
	clickLocationTab()
	getTicketData(number,street,intersection,intersection2,stationCode,diginfo,ticketNumber,town,ticketdata)
	today := A_DD . " " . A_MM . " " . A_yyyy
	;today := "timesheet24 07 2020.txt"
	;ticketdata := getTicketData()
	;if FileExist("timesheet24 07 2020.txt")
	if FileExist("timesheet" . today . ".txt")
		ts := fileopen("timesheet" . today . ".txt", "a")
	;ts := fileopen("timesheet24 07 2020.txt", 6)
	else
		ts := FileOpen("timesheet" . today . ".txt", "a")
	;ts := fileopen("timesheet24 07 2020.txt", 5)
	InputBox, comments, Enter comments
	ts.WriteLine(",,,,,," comments)
	;ts.WriteLine(ticketdata.ticketNumber "," ticketdata.number "," ticketdata.street "," ticketdata.rogersMarked "," ticketdata.rogersClear "," ticketdata.bellMarked "," ticketdata.bellClear "," ticketdata.comments)
	if !IsObject(ts)
		msgbox, File object not created
	ts.Close()
	SplashTextOff
return
}

#ifwinactive Tel ahk_exe sketchtoolapplication.exe
^o::
::insimg::
:::L::
	; hotkey se - o for insert image
	openImageDialog()
RETURN

;returns to last used tool (generally arrow)
=::
	clickSelection()
	{
		SendInput, ^q
	}
return

#o::
::qacirc::
	; win o for qa circle
	loadImage("qacorrection.skt")
return

;HOTKEY WIN + T FOR TEXT BOX
t::
ralt::
::txbx::
	textboxplus()
return

textboxplus() {
	MouseGetPos, xpos, ypos
	InputBox, String, Enter Text
	if ErrorLevel {
		return
	}
	String := StrUpper(String)
	clickTextTool()
	newx := xpos + (StrLen(String)*10)
	mouseclickdrag, L, % xpos, % ypos, % newx, % ypos + 10,
	SendInput, %String%{enter}
	clickSelection()
}

+t::
+RAlt::
	textboxplusVertical()
return

textboxplusVertical(){
	MouseGetPos, xpos, ypos
	InputBox, String, Enter Text
	if ErrorLevel {
		return
	}
	StringUpper, String, String
	clickTextTool()
	newx := xpos + (strlen(String)*10)
	mouseclickdrag, L, % xpos, % ypos, % newx, % ypos + 10,
	clickRotate90degrees()
	SendInput, %String%{enter}
	clickSelection()
}

setTextbox() {
	MouseGetPos, xpos, ypos
	clickTextTool()
	;picSearchSelect("texttool.png")
	;Text:="|<>*120$9.zwM30M30M30M30MU"
	;if (ok:=FindText(15-150000, 104-150000, 15+150000, 104+150000, 0, 0, Text))
	;{
	;CoordMode, Mouse
	;X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
	;Click, %X%, %Y%
	;}
	;Sleep 150
	Send {click %xpos%, %ypos%, down}{click 20,20,rel,Up}
}

'::
::lbl::
	labelTool(InputBox("Enter Label"))
return

^s:: ; Ctrl S to save
::svf::
:::S::
	saveFile()
return

; HOTKEY CTRL ALT X FOR JPG SAVE
#ifwinactive Tel ahk_exe SketchToolApplication.exe
!^X::
	saveFile()
	waitDialogBox()
	Send {TAB}{DOWN 4}{ENTER} ; changes file type to save to jpeg
return
;WIN NUMPAD INSERT for ok in auxilliary, SAVES FIRST and prompts page numbers now

;NEW KEYBINDING
#IfWinActive Tel AHK_EXE Sketchtoolapplication.EXE

o::
	twoPointSLoffset()
return

+c::
	twoPointSL()
return

h::
	HorizontalArrowTool()
return

v::
	VerticalArrowTool()
return

z::
	send, {Ctrl Down}z{Ctrl Up}
return

y::
	send, {ctrl down}c{ctrl up}
return

p::
	send, {ctrl down}v{ctrl up}
return

x::Delete
return

#IfWinActive

getCurrentDate(){
	today := A_YYYY "-" A_MM "-" A_DD
return today

}

getUnits(){
	units := InputBox("Enter Units")
return units
}

isSave(){
	Msgbox,4,Save,Save Sketch?
	IfMsgBox,Yes
	saveSketch := 1
return saveSketch
}

finalizeSketch(form,units){
	global
	#IFWINACTIVE ahk_exe SketchToolApplication.exe
		if (stationcode = "BCGN01") or if (stationcode = "BCGN02")
			util := "B"
		else
			util := "R"
		saveSketch := isSave()
		units := getUnits()
		today := getCurrentDate()
		if(saveSketch){
			saveFile()
			WAITDIALOGBOX()
			IF ERRORLEVEL
				RETURN
			if (type = "p")
				Send, %street% pole %polenum% %util%
			if (type = "B")
				Send, %STREET% %BHNUM% %UTIL%
			if num.2
				Send, % street " " num.1 " to " num.2 " " util
			else
				Send, %street% %number% %util%
			WinWaitClose AHK_CLASS #32770 ahk_exe sketchtoolapplication.exe
		}
	}

bellPrimaryFinalize:
	InputBox,bellMarked, Marked units, Enter Marked Units?
	InputBox, bellClear, Clear units, Enter Cleared Units?
	loadImageNG("units.skt")
	SendInput {f2}
	SendInput, %bellMarked%%bellClear%{enter}
	SendInput, ^q
	Sleep 100
	loadImageNG("bellprimarydate.skt")
	SendInput, {f2}
	SendInput, %A_YYYY%-%A_MM%-%A_DD%{enter}
	;SendInput, 2020-09-18
return

CUAFinalize(UFORM)
{
	loadImageNG("units.skt")
	SendInput {F2}1C{Enter}
	Sleep 100
	loadImageNG(UFORM)
	SendInput, {F2}%A_YYYY%-%A_MM%-%A_DD%}{Enter}
}

getRogersUnits()
{
	Inputbox,rogersunits, Units, Enter units?
return rogersunits
}

rogersPrimaryFinalize:
	InputBox, rogersMarked, Marked units, Enter Marked Units?
(rogersMarked != "") ? loadImageNG("rogerspaint.skt") :
	InputBox, rogersClear, Clear units, Enter Cleared Units?
	loadImageNG("units.skt")
	Sleep 100
	SendInput {f2}
	SendInput, %rogersMarked%%rogersClear%{enter}
	SendInput, ^q
	Sleep 100
	loadImageNG("rogersPrimaryDate.skt")
	SendInput, {f2}
	SendInput, %A_YYYY%-%A_MM%-%A_DD%{enter}
	;SendInput, 2020-09-18

return

aptumPrimaryFinalize:
	InputBox, aptumMarked, Marked units, Enter Marked Units?
(aptumMarked != "") ? loadImageNG("aptumpaint.skt") :
	InputBox, aptumClear, Clear units, Enter Cleared Units?
	loadImageNG("units.skt")
	SendInput {f2}
	SendInput, %aptumMarked%%aptumClear%{enter}
	SendInput, ^q
	Sleep 100
	loadImageNG("rogersPrimaryDate.skt")
	SendInput, {f2}
	SendInput, %A_YYYY%-%A_MM%-%A_DD%{enter}
return

bellAuxilliaryFinalize:
	loadImageNG("bellauxilliarydate.skt")
	SendInput {f2}
	SendInput, %A_YYYY%-%A_MM%-%A_DD%{enter}
	;SendInput, 2020-09-18
return

stproj_saveexit()
{
	global
	today := getCurrentDate()
	if(currentpage)
		currentpage := currentpage + 1
	else
		currentpage = 1
	switch form
	{
	Case "BP" :
		;units := Inputbox("Enter units")
		loadImage("bell primary.skt")
		=> No duplicate line
		setTemplateText("units.skt",units)
		setTemplateText("bellprimarydate.skt",today)
		setTemplateText("totalpages.skt",totalpages)
	Case "BA" :
		loadImage("bellaux.skt")
		setTemplateText("bellauxilliarydate.skt",today)
		setTemplateText("currentpage.skt",currentpage)
		setTemplateText("totalpages.skt",totalpages)
	Case "RP" :
		;units := Inputbox("Enter units")
		loadImage("catv primary.skt")

		if(InStr(units,"m"))
		{
			loadImageNG("rogersmarked.skt")
		}
		setTemplateText("units.skt",units)
		setTemplateText("rogersprimarydate.skt",today)
		setTemplateText("TOTALPAGES.skt",TOTALPAGES)
	Case "RA" :
		loadImage("rogersaux.skt")
		setTemplateText("totalpages.skt",totalpages)
		setTemplateText("currentpage.skt",currentpage)
	Case "AP":
		loadImage("cogeco primary.skt")
		setTemplateText("units.skt",units)
		setTemplateText("rogersprimarydate.skt",today)
		setTemplateText("totalpages.skt",TOTALPAGES)
		setTemplateText("currentpage.skt",currentpage)

	Case "AA":
		loadImage("aptumaux.skt")
		setTemplateText("totalpages.skt",totalpages)
		setTemplateText("currentpage.skt",currentpage)
	}
}

::OKDONE::
^w:: ;SAVE AND EXIT CURRENT SKETCH
:::w::
Numpadenter::
	ST_SAVEEXIT()
return

ST_SAVEEXIT()
{
	global
	if (stationcode = "BCGN01")
		util := "B"
	else if (stationcode = "BCGN02")
		util := "B"
	else if (stationcode = "ROGYRK01")
		util := "R"
	else if (stationcode = "ROGSIM01")
		util := "R"
	else
		util := "APT"
	MsgBox,4,Save,Save Sketch?
	focusSketchTool()
	IfMsgBox, Yes
	{
		;saveSketch := 1
		;move to end
		saveFile()
		WAITDIALOGBOX()
		IF ERRORLEVEL
			RETURN
		if (type = "p")
			Send, %street% pole %polenum% %util%
		if num
		{
			if (num.2)
				Send, % street " " num.1 " TO " num.2 " " worktype " " util
			else
				Send, % street " " num.1 " " worktype " " util
		}
		else
			Send, %street% %number% %worktype% %util%
		WinWaitClose AHK_CLASS #32770 ahk_exe sketchtoolapplication.exe
		;move to end end
	}
	else ifmsgbox, No
		wait()
	;move to after prompts
	Switch form
	{
	Case "BP" :
		loadImage("bell primary.skt")
	Case "BA" :
		loadImage("bellaux.skt")
	Case "RP" :
		rogersunits := getRogersUnits()
		totalpages := getRPPages()
		loadImage("catv primary.skt")
		(InStr(rogersunits,"M")) ? loadImageNG("rogerspaint.skt") :
		setTemplateText("units.skt",rogersunits)
		setTemplateText("rogersPrimaryDate.skt",A_YYYY . "-" . A_MM . "-" . A_DD)
		setTemplateText("RPtotalpages.skt",totalpages)
		Sleep 100
	Case "RA" :
		loadImage("rogersaux.skt")
	Case "AP" : 
		rogersunits := getRogersUnits()
		totalpages := getRPPages()
		loadImage("cogeco primary.skt")
		if (InStr(rogersunits,"M"))
		{
			loadImageNG("rogerspaint.skt")
		}
		setTemplateText("units.skt",rogersunits)
		setTemplateText("rogersPrimaryDate.skt",A_YYYY . "-" . A_MM . "-" . A_DD)
		setTemplateText("RPtotalpages.skt",totalpages)
		Sleep 100
	Case "AA" :
		loadImage("aptumaux.skt")
		
	}
	; end
	Sleep 300
	if (form = "BP")
		gosub, bellPrimaryFinalize
	;else if (form = "RP")
	;gosub, rogersPrimaryFinalize
	else if (form = "BA")
		gosub, bellAuxilliaryFinalize
	;else if (form = "AP")
	;gosub, aptumPrimaryFinalize
	Sleep 150
	;Msgbox, 4132, Page Number, Insert page numbers?
	;ifMsgBox, Yes
	;{
	IF (FORM = "RP")
		wait()
	else if (form = "BP")
		writeRPPageNumber()
	else writePageNumber()
		;}
	;else
	wait()
	;PGNUMBER+=1
	;controlclick, OK, ahk_exe sketchtoolapplication.exe
	ControlClick("OK","ahk_exe sketchtoolapplication.exe")
	focusTeldig()
}

CUASAVEEXIT()
{
	if (stationcode="BCGN01") or if (stationcode = "BCGN02")
	{
		loadImage("bell primary.skt")
		Sleep 300
		CUAFinalize("bellprimarydate.skt")
	}
	else
	{
		loadImage("catv primary.skt")
		Sleep 300
		CUAFinalize("rogersPrimaryDate.skt")
	}
	Sleep 300
	loadImageNG("RPtotalpages.skt")
	SendInput, {f2}1{enter}
	wait()
	SendInput ^q
	ControlClick("OK","ahk_exe sketchtoolapplication.exe")
	focusTeldig()
}

STQLSAVEEXIT() {
	global
	if (stationcode = "BCGN01")
		util := "B"
	else if (stationcode = "BCGN02")
		util := "B"
	else if (stationcode = "ROGYRK01")
		util := "R"
	else if (stationcode = "ROGSIM01")
		util := "R"
	else
		util := "APT"
	MsgBox,4132,Save,Save Sketch?
	focusSketchTool()
	IfMsgBox, Yes
	{
		saveFile()
		WAITDIALOGBOX()
		IF ERRORLEVEL
			RETURN
		if (type = "p")
			Send, %street% pole %polenum% %util%
		if num
			Send, % street " " num.1 " to " num.2 " " util
		else
			Send, %street% %number% %util%
		WinWaitClose AHK_CLASS #32770 ahk_exe sketchtoolapplication.exe
	}
	else ifmsgbox, No
		wait()
	Switch form
	{
		Case "BP" : loadImage("bell primary.skt")
		Case "BA" : loadImage("bellaux.skt")
		Case "RP" : loadImage("catv primary.skt")
		Case "RA" : loadImage("rogersaux.skt")
		Case "AP" : loadImage("cogeco primary.skt")
		Case "AA" : loadImage("aptumaux.skt")
	}
	Sleep 300
	if (form = "BP")
		gosub, bellPrimaryFinalize
	else if (form = "RP")
		gosub, rogersPrimaryFinalize
	else if (form = "BA")
		gosub, bellAuxilliaryFinalize
	else if (form = "AP")
		gosub, aptumPrimaryFinalize
	Sleep 150
	;Msgbox, 4132, Page Number, Insert page numbers?
	;ifMsgBox, Yes
	;{
	IF (FORM = "RP")
		writeRPPageNumber()
	else if (form = "BP")
		writeRPPageNumber()
	else writePageNumber()
		;}
	;else
	wait()
	MsgBox, 4096, Please re-check records!!,
	;PGNUMBER+=1
	;controlclick, OK, ahk_exe sketchtoolapplication.exe
	ControlClick("OK","ahk_exe sketchtoolapplication.exe")
	focusTeldig()
}

;NUMPAD DEL FOR CANCEL IN AUXILLIARY
NUMPADDEL::
	ControlClick("Cancel","ahk_exe sketchtoolapplication.exe")
	Sleep 100
	if WinExist("AHK_CLASS #32770") {
		Send {enter}
	}
	WinActivate ahk_exe mobile.exe
return

; HOTKEY WIN + B FOR BELL PRIMARY
#IFWINACTIVE AHK_EXE SKETCHTOOLAPPLICATION.EXE
#B:: ; LOAD BELL PRIMARY SHEET
::insbp::
	loadImage("bell primary.skt")
return
;HOTKEY CTRL - ALT - B FOR BELL AUXILLIARY WITH DATE/PAGE NUMBERS

^!B:: ; LOAD BELL AUXILLIARY SHEET
::insba:: ; LOAD BELL AUXILLIARY
	loadImage("bellaux.skt")
return
;HOTKEY CTRL - ALT - R FOR ROGERS AUXILLIARY WITH DATE/PAGE NUMBERS

^!A:: ;LOAD ROGERS AUXILLIARY SHEET
::insra:: ;LOAD ROGERS AUXILLIARY SHEET
	loadImage("rogersaux.skt")
return
;HOTKEY CTRL - ALT - B FOR APTUM AUXILLIARY WITH DATE/PAGE NUMBERS

^!C::
::insaa::
	loadImage("aptumaux.skt")
return
; WIN R FOR ROGERS PRIMARY

#R:: ; LOAD ROGERS PRIMARY SHEET
::insrp:: ;LOAD ROGERS PRIMARY SHEET
	loadImage("catv primary.skt")
return

; win numpad keys for preloaded template
#numpadup:: ;INSERT NORTH TEMPLATE
::rdn:: ;INSERT NORTH TEMPLATE
	loadImage("b - north.skt")
return

; win numpad pgup NE
#numpadpgup:: ;INSERT NE TEMPLATE
::rdne:: ;INSERT NE TEMPLATE
	loadImage("b - ne corner.skt")
return

#numpadright:: ;INSERT E TEMPLATE
::rde:: ;INSERT E TEMPLATE
	loadImage("b - east.skt")
return

#numpadpgdn:: ;INSERT SE TEMPLATE
::rdse:: ; INSERT SE TEMPLATE
	loadImage("b - se corner.skt")
return

#numpaddown:: ;INSERT S TEMPLATE
::rds:: ; INSERT SOUTH TEMPLATE
	loadImage("b - south.skt")
return

#numpadend:: ;INSERT SW TEMPLATE
::rdsw:: ;INSERT SW TEMPLATE
	loadImage("b - sw corner.skt")
return

#numpadleft:: ;INSERT WEST TEMPLATE
::rdw:: ;INSERT WEST TEMPLATE
	loadImage("b - west.skt")
return

#numpadhome:: ;INSERT NW TEMPLATE
::rdnw:: ; INSERT NW TEMPLATE
	loadImage("b - nw corner.skt")
return

^!L:: ;ADD DIG BOX (OLD)
::dgbx:: ; add Dig Box to sketch
	loadImage("digbox.skt")
return

#IfWinActive

openForm(imgtext, currentform)
{
	global form
	BlockInput,SendAndMouse
	locationDataCheck(), clickdrawingtab()
	Sleep, 150
	clicknewform()
	Sleep, 150
	Text := imgtext
	if (ok:=FindText(960-150000, 597-150000, 960+150000, 597+150000, 0, 0, Text))
	{
		CoordMode, Mouse
		X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
		Click, %X%, %Y%
	}
	form := currentform
	waitSketchTool()
	Sleep, 150
	BlockInput,OFF
	SetTimer, killTemplate, -5000
}

#ifwinactive ahk_exe mobile.exe
#f1:: ;OPEN BELL PRIMARY FORM
::obp:: ;OPEN BELL PRIMARY FORM
	openForm("|<>**50$69.knskrkyTRUsq6tb4k6nNC77kq4ca0mN9lty4UZYk6HN+/9zY6qbUqS9NNC4Uaok7XF9PNkq4na0kP9iPy6laAk63BBmEknslrkkNxYS4", "BP")
return

#f2:: ;OPEN BELL AUXILLIARY FORM
::oba:: ;OPEN BELL AUXILLIARY FORM
	openForm("|<>*147$38.6497oC1V2F910wEWWEF948sY4GF24915aEXWEHTY8cY4o9aF91/3DATTyU","BA")
return

#f3:: ;OPEN ROGERS PRIMARY FORM
::orp:: ;OPEN ROGERS PRIMARY FORM
	openForm("|<>*138$50.D33l1sTsI0kWEE0W+0+8Y408WU4W91028c18wES0VG0F8Y408IUDm91025424WEE0UkxUj7rk88U","RP")
return

#f4:: ;OPEN ROGERS AUXILLIARY FORM
::ora:: ;OPEN ROGERS AUXILLIARY FORM
	openForm("|<>*135$40.QXSzj8+2N0F0Uc941822ksE4U89X1sG0zV+418222YE4U88O90F0Uj8rl3m200000000000008","RA")
return

::oap:: ; aptum primary
	openForm("|<>*114$38.wS7jXll8m+14U450UUE11EDc40EIu210452UUE4X8c4GD71vswQ0000000000008","AP")
return

::oaa:: ; aptum auxilliary
	openForm(">*135$40.QXSzj8+2N0F0Uc941822ksE4U89X1sG0zV+418222YE4U88O90F0Uj8rl3m200000000000008","AA")
return

::okSend:: ;FINISH AND EMAIL TICKET
NUMPADENTER:: ;FINISH AND EMAIL TICKET
:::m::
	finishemail()
return

finishemail()
{
	global
	focusTeldig()
	tickettimeend := (A_TickCount - timestart) / 1000
	FileAppend, %ticketnumber% total - %tickettimeend%`n, timelog.txt
	currentpage := "", totalpages := ""
	clickLocationTab()
	STATUSPENDING()
	if (form = "BP" or form = "BA")
		bellMarked := "", bellClear := ""
	else if (form = "RP" or form = "RA")
		rogersMarked := "", rogersClear := ""
	form := "", locationDataObtained := "",landbase := "",intdir := "",choice := "",rclear :="", num := "", timestart := ""
	SetControlDelay, -1
	ControlClick, Button43,,,,,NA
	WinWaitActive, ahk_class #32770
	ControlClick, Button1,,,,,NA
	WinWaitActive,Paper output to contractor
	ControlClick, Button4,,,,,NA
}

numpaddel:: ;COMPLET TICKET WITHOUT EMAILING
::oknoSend::
	finishnoemail()
return

;COMPLETE TICKET WITHOUT EMAILING
finishnoemail()
{
	global
	tickettimeend := (A_TickCount - timestart) / 1000
	FileAppend, %ticketnumber% total - %totaltimeend%`n, timelog.txt
	currentpage := "", totalpages := "", timestart := ""
	clickLocationTab()
	STATUSPENDING()
	form := ""
	locationDataObtained := ""
	landbase := ""
	intdir := ""
	choice := ""
	SetControlDelay, -1
	ControlClick, Button43,,,,,NA
	WinWaitActive, ahk_class #32770
	ControlClick, Button2,,,,,NA
}

+numpaddel::
	cancelticket()
return

;HIT CANCEL AND EXIT TICKET
cancelticket() ;HIT CANCEL AND EXIT TICKET
{
	ControlClick("Cancel", "ahk_exe mobile.exe")
	WinWaitActive, ahk_class #32770
	SendInput, {Enter}
}

#IFWINACTIVE AHK_EXE SKETCHTOOLAPPLICATION.EXE
#f5::
	;WRITE BELL CLEAR ON SKETCH
::bellclear::
	loadImage("bellclear.skt") ; puts bell clear... on drawing
return

#IFWINACTIVE AHK_EXE SKETCHTOOLAPPLICATION.EXE
#f6::
::rogclear::
	setRogersclear()
return

setRogersclear()
{
	loadImage("rogclear.skt") ;puts Rogers clear on drawing
}
return

::aptclear::
	loadImage("aptumclear.skt")
return

#IFWINACTIVE AHK_EXE SKETCHTOOLAPPLICATION.EXE
#f7::
::ftth::
	loadImage("rogftth.skt")
return ; rogers ftth

#F8::
::foonlyc::
	loadImage("exclusion agreement r.skt")
return ; exclusion agreement warning

::foonly::
	loadImage("foonly.skt")
return

; PAGE PROMPT WIN P
#IfWinActive AHK_EXE SKETCHTOOLAPPLICATION.EXE
#P::
::pgnum::
	writePageNumber()
RETURN
#IfWinActive

setTemplateText(template,text) ;what box and what position
{
	loadImageNG(template)
	Send, {F2}
	Sleep 200
	SendInput,{TEXT}%text%
	Sleep 50
	Send, {Enter}
	Sleep 200
}

getTreeType()
{
	Loop
	{
		InputBox, treetype, Type, Type?`n1 = Tree`2=Stump`n3=Flag`N4=CURB MARKING
	}
	until treetype in 1,2,3
	if (treetype = 3)
		treetype := "FLAG"
	else if (treetype = 2)
		treetype := "STUMP"
	else if (treetype = 4)
		treetype := "CURB MARKING"
	else
		treetype := "TREE"
return treetype
}

setTreeDigArea() {
	global form
	global treenum
	treetype := getTreeType()
	if (form = "RA") {
		setRARadiusDigArea(treetype,treenum)
		clickselection()
		return
	}
	InputBox, treenum, Tree Number, Write tree number

	loadImageNG("NBoundary.skt")
	SendInput {f2}
	SendInput, 5M N OF %TREETYPE% %treenum%{Enter}
	loadImageNG("SBoundary.skt")
	;Sleep
	SendInput, {f2}
	Send, 5M S OF %TREETYPE% %treenum%{enter}
	loadImageNG("WBoundary.skt")
	;Sleep
	SendInput, {f2}
	Send, 5M W OF %TREETYPE% %treenum%{enter}
	loadImageNG("EBoundary.skt")
	; Sleep 500
	SendInput, {f2}
	Send, 5M E OF %TREETYPE% %treenum%{enter}
	wait()
	clickSelection()
return treetype
}

setPoleDigArea(polenum) {
	global
	polenum := InputBox("Pole number","Enter pole number",,,,,,,,polenum)
	InputBox, radius, Radius, Enter radius in m
	if (form = "RA")
	{
		setRARadiusDigArea("POLE",polenum)
	}
	else
	{
		loadImageNG("NBoundary.skt")
		SendInput {f2}
		SendInput, %radius%M N of POLE %polenum%{Enter}
		loadImageNG("SBoundary.skt")
		;Sleep
		SendInput, {f2}
		Send, %radius%M S OF POLE %polenum%{enter}
		loadImageNG("WBoundary.skt")
		;Sleep
		SendInput, {f2}
		Send, %radius%M W OF POLE %polenum%{enter}
		loadImageNG("EBoundary.skt")
		; Sleep 500
		SendInput, {f2}
		Send, %radius%M E OF POLE %polenum%{enter}
	}
	wait()
	clickSelection()
}

setPedDigArea()
{
	global Form
	global pednum
	if (form = "RA")
	{
		setRARadiusDigArea("PED",pednum),clickSelection()
		return
	}
	Inputbox,pednum, Ped Address, Write ped number
	arrpednum := 	{"NBoundary.skt": "5M N OF PED " pednum
		, "SBoundary.skt": "5M S OF PED " pednum
		, "WBoundary.skt": "5M W OF PED " pednum
	, "Eboundary.skt": "5M E OF PED " pednum}
	For k,v in arrpednum
	{
		setTemplateText(k,v)
		if ErrorLevel
			return
	}
	clickSelection()
}

getRadiusDigArea()
{
	InputBox, desc, %type% Number, Write %type% Number
return desc
}

setRadiusDA(type)
{
	desc :=
}

setBHDigArea()
{
	global form
	InputBox, bhradius, Radius, Enter borehole radius (m)
	InputBox, bhnum, Borehole Number, Write Borehole number
	fixStreetname()
	if (form = "RA")
		boundaryArray := {"N":"RANBoundary.skt", "S":"RASBoundary.skt", "W":"RAWBoundary.skt", "E":"RAEBoundary.skt"}
	else
		boundaryArray := {"N":"NBoundary.skt", "S":"SBoundary.skt", "W":"WBoundary.skt", "E":"EBoundary.skt"}
	for k,v in boundaryArray {
		loadImageNG(v)
		wait()
		SendInput,{F2}
		Send, %bhradius%M %k% OF BOREHOLE %BHNUM% %STREET%
	}
	wait()
	clickSelection()
}

setRAPoledigarea() {
	global
	loadImageNG("RANBoundary.skt")
	wait()
	SendInput {f2}
	SendInput, 5m N of pole %polenum%{Enter}
	wait()
	loadImageNG("RASBoundary.skt")
	;Sleep 500
	SendInput, {f2}
	Send, 5m S of pole %polenum%{enter}
	;wait()
	loadImageNG("RAWBoundary.skt")
	;Sleep 500
	SendInput, {f2}
	Send, 5m W of pole %polenum%{enter}
	;wait()
	loadImageNG("RAEBoundary.skt")
	;Sleep 500
	SendInput, {f2}
	Send, 5m E of pole %polenum%{enter}
	;wait()
	clickSelection()
}

;sets tree dig area for Rogers auxilliary
setRAtreedigarea() {
	InputBox, treenum, Tree Number, Write tree number
	loadImageNG("RANBoundary.skt")
	wait()
	SendInput {f2}
	SendInput, 5m N OF TREE %TREENUM%{Enter}
	wait()
	loadImageNG("RASBoundary.skt")
	;Sleep 500
	SendInput, {f2}
	Send, 5m S OF TREE %TREENUM%{enter}
	;wait()
	loadImageNG("RAWBoundary.skt")
	;Sleep 500
	SendInput, {f2}
	Send, 5m W OF TREE %TREENUM%{enter}
	;wait()
	loadImageNG("RAEBoundary.skt")
	;Sleep 500
	SendInput, {f2}
	Send, 5m E OF TREE %TREENUM%{enter}
	;wait()
	clickSelection()
}

setRARadiusDigArea(type,itemno) {
	global
	boundaryArray := {"N":"RANBoundary.skt", "S":"RASBoundary.skt", "W":"RAWBoundary.skt", "E":"RAEBoundary.skt"}
	for k,v in boundaryArray {
		loadImageNG(v), wait()
		SendInput,{F2}
		Send, 5M %k% OF %type% %itemno%{Enter}
	}
	boundaryArray := ""
	wait(), clickSelection()
}

isInterSketch()
{
	global
	intdir := InputBox("Horizontal (H) or Vertical (V)?")
	loop
	{
		if(intdir="h")
			Break
		else if(intdir="v")
			Break
		else Continue
		}
return intdir
}

isInterText()
{
	global
	inter := {}
	InputBox, xstreet,,Horizontal Street? `n1 = %street%`n2 = %intersection%`n3 = %intersection2%
	if(xstreet = "1")
		xstreet := street
	else if(xstreet = "2")
		xstreet := intersection
	else if(xstreet = "3")
		xstreet := intersection2
	InputBox, vstreet,,Vertical Street? `n1 = %street%`n2 = %intersection%`n3 = %intersection2%
	if(vstreet = "1")
		vstreet := street
	else if(vstreet = "2")
		vstreet := intersection
	else if(vstreet = "3")
		vstreet := intersection2
	inter.x := xstreet, inter.y := vstreet
return inter
}

;		date ctrl d
#IFWINACTIVE AHK_EXE SKETCHTOOLAPPLICATION.EXE
^d:: ; WRITE DATE wherever mouse cursor is pointing
	MouseGetPos, xpos, ypos
	Send {click 41, 161}{click %xpos%, %ypos%}^q
return

;qa yes and no (win numpad plus/ numpad minus)
#IFWINACTIVE AHK_EXE SKETCHTOOLAPPLICATION.EXE
#numpadadd::
::QAYES::
	loadImage("qayes.skt")
return

#IFWINACTIVE AHK_EXE SKETCHTOOLAPPLICATION.EXE
#numpadsub::
::QANO::
	loadImage("qan.skt")
return

#IfWinActive ahk_exe sketchtoolapplication.exe
+BackSpace::
	changeText()
return

changeText(){
	;SendInput,{f2}{Backspace 50}
	SendInput("{F2}{Backspace 50}")
	text := Inputbox("Enter text")
	text := StrUpper(text)
	Send(text)
	Send("{Enter}")
	;MouseClick("R")
	;SendInput("{Up 2}{Enter}")
	;wait()
	;SendInput("{Tab 14}")
}

#IFWINACTIVE AHK_EXE SKETCHTOOLAPPLICATION.EXE
	;measurement tool
~[::
	measurementTool()
return

measurementTool()
{
	SendInput, {F2}
	SendInput, {BS 50} ; CLEARS BOX
	Sleep 300
	setMeasurement()
}

setMeasurement()
;returns a measurement String ending in ".m" that only requires integer input
{

	InputBox, String, Measurement, Insert Measurement ;gets measurement
	if (strlen(String) = 1)
	{
		String := "0." String " m"
		Send, %String%{enter}
	}

	else if (strlen(String) = 2)
	{
		newString := strsplit(String)
		meas1 := newString[1]
		meas2 := newString[2]
		String := meas1 "." meas2 " m"
		Send, %String%{enter}
	}
	else if (strlen(String) = 3)
	{
		newString := strsplit(String)
		newString := strsplit(String)
		meas1 := newString[1]
		meas2 := newString[2]
		meas3 := newString[3]
		String := meas1 meas2 "." meas3 " m"
		Send, %String%{enter}
	}
return String
}

#IfWinActive
::.NM::
	SendInput, %number% %street%
return

::.ST::
::zs::
	;INSERT street NAME OBTAINED FROM TELDIG DATA
	fixstreetName()
	SendInput, %street%
RETURN

::.INT::
::zx:: ;INSERT INTERSECTING street 1 AS TEXT
	fixstreetName()
	SendInput, %INTERSECTION%
RETURN

::.INTB::
::za::
	; insert intersection 2 as text
	fixstreetName()
	SendInput, %intersection2%
return

#IFWINACTIVE ahk_class #32770 ahk_exe AUTOHOTKEYU64.EXE
	;PGDN:: ;INSERT INTERSECTING street 1 AS TEXT
::.INT::
::zx::
	fixstreetName()
	SendInput, %INTERSECTION%
RETURN

;PGUP::
::.ST::
::zs:: ;INSERT street NAME OBTAINED FROM TELDIG DATA
	fixstreetName()
	SendInput, %street%
RETURN

::.INTB::
::za:: ; insert intersection 2 as text
	fixstreetName()
	SendInput, %intersection2%
return

::.NM::
	SendInput, %number%
return

#IfWinActive ahk_class #32770 ahk_exe autohotkey.exe
::.ST::
::zs:: ;INSERT street NAME OBTAINED FROM TELDIG DATA
	fixstreetName()
	SendInput, %street%
RETURN

::.INT::
::zx::
	fixstreetName()
	SendInput, %INTERSECTION%
RETURN

::.INTB::
::za:: ; insert intersection 2 as text
	fixstreetName()
	SendInput, %intersection2%
return

::.NM::
	SendInput, %number%
return

#IFWINACTIVE Tel AHK_EXE SKETCHTOOLAPPLICATION.EXE
b::
^numpadclear::
::dbldg:: ; insert building
	drawMediumBuilding()
return

drawMediumBuilding(){
	InputBox, hsnum,House Number, House number?
	loadImage("building.skt")
	setTemplateText("MBLDGTEXT.SKT",hsnum)
}

+b::
^!numpadclear::
::2dsmhse:: ; insert small house
	loadImage("sbuilding.skt")
return

; insert set of horizontal arrows with measurement
h_arrow()
{
	;clickPointer()
	MouseGetPos, xpos, ypos
	loadImage("h arrow.skt")
	MouseMove, %xpos%, %ypos%
}

::dh2a::
	h_doublearrow()
return

h_doublearrow(){
	MouseGetPos, xpos, YPOS
	loadImage("H double arrow.skt")
	mousemove, %xpos%, %ypos%
}

::dnwa::
	drawNWArrows()
return

drawNWArrows()
{
	loadImage("nwmeasurement.skt")
}

::dnea::
	drawNEArrows()
return

drawNEArrows()
{
	loadImage("nemeasurement.skt")
}

::dhdw::
	drawHorizontalDriveway()
return

drawHorizontalDriveway(){
	loadImage("hdriveway.skt")
}

::dvdw::
	drawVerticalDriveway()
return

drawVerticalDriveway(){
	loadImage("vdw.skt")
}

drawLine(type) {
	MouseGetPos, xpos, ypos
	;picSearchSelect("polyline.png")
	clickPolyline()
	Send, %type%
	MouseMove, %xpos%, %ypos%
}

drawCable() {
	MouseGetPos, xpos, ypos
	Text:="|<>*117$52.00000000000000000000000000000M0000000300000000M0000000300000000M0000000300000000M00000003Ds000000MYU0000030E000000M100000030400000080E0000000100000000C000000000000000000000000000000000000000000000000000000000000000002"
	if (ok:=FindText(26-150000, 268-150000, 26+150000, 268+150000, 0, 0, Text))
	{
		;CoordMode, Mouse
		X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
		Click, %X%, %Y%
	}
}

NUMPADDIV:: ;Thin Line
	drawLine("")
return

+NUMPADDIV:: ;ROAD LINE
	drawLine("^+R")
return

NUMPADMULT:: ;CABLE LINE
	drawLine("^+C")
return

+NUMPADMULT:: ; OFFSET LINE
	drawLine("^+O")
return

#v::
::dva::
	v_arrow()
return

v_arrow() {
	loadImage("v arrow.skt")
}

^!h::
::dhline::
	drawHorizontalCable()
return

drawHorizontalCable()
{
	loadImage("hline.skt")
}

^!v::
::dvline::
	drawVerticalCable()
return

drawVerticalCable()
{
	loadImage("vline.skt")
}

NUMPADUP::
	clickBringtoFront()
RETURN

NUMPADRIGHT::
	clickRotate90degrees()
RETURN

NUMPADDown::
	clickBringtoBack()
RETURN

NUMPADLEFT::
	clickRotate90degrees()
RETURN

;HOTKEY WIN + pgup FOR  RED TEXT BOX - QA
#PGUP::
	MouseGetPos, xpos, ypos
	Sendplay {Click, 25, 111}
	Sleep 400
	SendPlay {CLICK, 542, 676}
	mousemove, %xpos%, %ypos%
	Send {CLICK, DOWN}{CLICK 10,10,UP,REL}
	Sleep 600
	Send {CLICK 1007, 673}
return

;WIN + PGDOWN FOR RED LINE - QA
#PGDN::
	MouseGetPos, xpos, ypos
	Send {Click, 24, 183}
	Send {CLICK, 491, 675}{CLICK 1007, 673}
	mousemove, %xpos%, %ypos%
return

#S::
::bsticker::
	Bell_stickers()
return

;BELL STICKER GUI PROMPT
Bell_stickers() {
	global
	Guicontrol,1:,cable,0
	Guicontrol,1:,Conduit,0
	GuiControl,1:,bellhydro,0 ; blank the controls if reused
	GuiControl,1:,bridgealert,0
	GuiControl,1:,cableconduit,0
	GuiControl,1:,handdig,0
	guicontrol,1:,prioritycable,0
	guicontrol,1:,emptyconduit,0
	guicontrol,1:,unlocateable,0
	Gui, 1:Show, x411 y174 h383 w483, Please select all that apply ;open gui for bell stickers
return
}

ButtonCancel:
	Gui, Cancel
return

ButtonOK: ; retrieves checked boxes and loads stickers
	Gui,Submit
	bellwarn := {"cable.skt":cable, "conduit.skt":conduit, "bellhydro.skt":bellhydro, "bridgealert.skt":bridgealert, "cablesmayconduit.skt":cableconduit,"handdig.skt":handdig, "prioritycables.skt":prioritycable, "unlocateable.skt":unlocateable, "emptyconduit.skt":emptyconduit}
	for bwk, bwv in bellwarn {
		if(bwv = 1)
			loadImageNG(bwk), wait()
	}
	if(cable = 1 || conduit = 1)
		loadImageNG("paint.skt")
return

#IFWINACTIVE AHK_EXE MOBILE.EXE
^f1:: ;SELECT PENDING
	clickLocationTab()
	statusPending()
RETURN

#IFWINACTIVE AHK_EXE SKETCHTOOLAPPLICATION.EXE
	; get locate info with win f10
#f10::
	MsgBox % diginfo
return

#IfWinActive

; SketchTool GUI code
;RShift::
;MButton::
;Gui, 2:Show, x379 y149 h417 w639 Center, SketchTool Shortcuts
;Return

;SIDEWALK CHECK IN SKETCH GUI FUNCTION
SWFUNC(Y,N) {
	SIDEWALK := isSidewalk()
	(SIDEWALK) = "Y" ? loadimage(Y) : loadimage(N)
}

2GuiClose:
	Gui, 2:Cancel
return

2buttonrogersclear:
	gui, 2:submit
	loadImage("rogclear.skt")
return

2buttonrogersftth:
	gui, 2:submit
	loadImage("rogftth.skt")
return

2buttonfibreonly:
	gui, 2:submit
	loadImage("exclusion agreement r.skt")
return

2buttonbellclear:
	gui,2:submit
	loadImage("bellclear.skt")
return

2buttonlocatedareabox:
	gui,2:submit
	loadImage("digbox.skt")
return

2buttonbuilding:
	gui,2:submit
	loadImage("building.skt")
return

2buttonverticalarrows:
	gui,2:submit
	loadImage("v arrow.skt")
return

2buttonn:
	SWFUNC("B - NORTH.SKT","B - NORTH NO SW.SKT")
return
2buttonne:
	SWFUNC("b - ne corner.skt","B - NE CORNER NO SW.SKT")
return
2buttone:
	SWFUNC("b - east.skt", "B - EAST NO SW.SKT")
return
2buttonse:
	SWFUNC("b - se corner.skt", "B - SE CORNER NO SW.SKT")
return
2buttons:
	SWFUNC("b - south.skt", "B - SOUTH NO SW.SKT")
return
2buttonsw:
	SWFUNC("b - sw corner.skt", "B - SW CORNER NO SW.SKT")
return
2buttonw:
	SWFUNC("b - west.skt", "B - WEST NO SW.SKT")
return
2BUTTONNW:
	SWFUNC("B - NW CORNER.SKT", "B - NW CORNER NO SW.SKT")
RETURN
2buttonhotStringlist:
	gui, 2:submit
	showHotStrings()
return
2buttonbprim:
	buttonLoadTemplate("bell primary.skt")
return
2buttonbaux:
	buttonLoadTemplate("bellaux.skt")
return
2buttonrprim:
	buttonLoadTemplate("catv primary.skt")
return
2BUTTONSEEAUXILLIARY:
	buttonLoadTemplate("catv see auxilliary.skt")
return
2buttonraux:
	buttonLoadTemplate("rogersaux.skt")
RETURN
2buttoninsertsketch:
	gui, 2:submit
	openimagedialog()
return
2buttonsavesketch:
	gui, 2:submit
	savefile()
return
2buttondigarea:
	gui, 2:submit
	Sleep 500
	writeDigArea()
return
2BUTTONINACCURATE:
	buttonLoadTemplate("INACCURATERECORDS.SKT")
RETURN
2buttonbellstickers:
	gui, 2:submit
	Sleep 500
	bell_stickers()
return
2BUTTONSAVEANDEXIT:
	GUI, 2:SUBMIT
	Sleep 500
	ST_SAVEEXIT()
RETURN

#IFWINACTIVE AHK_EXE MOBILE.EXE
F11::
	showHotStrings()
return

showHotStrings() {
	Run, hotStringlog.txt, %A_ScriptDir%
}
#IfWinActive

#ifwinactive ahk_exe mobile.exe

NewPage:
	focusTeldig()
	setForm()
return

addtotimesheet:
	focusTeldig()
	addtotimesheet()
return

finishandemail:
	finishemail()
	WinActivate ahk_exe mobile.exe
return

finishwithoutemail:
	finishnoemail()
	WinActivate ahk_exe mobile.exe
return

#IFWINACTIVE AHK_EXE MOBILE.EXE
!^L::
::AATSAT::
	; ADD ADDRESS TO streetS AND TRIPS
	setLocationST()
return

setLocationST() 
{
	address := fixStreetName1()
	WinActivate, ahk_exe streets.exe
	waitCaret()
	;town := address.town, street := address.street, number := address.number, intersection := address.intersection
	Click 28,238
	SendInput, % address.number . " " . address.street . "," . address.town
	Send, {Enter}
	;IfWinExist, Find
	;{
	;WinClose, Find
	;MsgBox, Enter address manually
	;}
	;focusTeldig()
}

writeDirectionList(){
	ControlGet, count, List, Count, SYSLISTVIEW321, ahk_exe mobile.exe
	SplashTextOn,,,List,Preparing list for Streets and Trips
	Loop, % count {
		CONTROLGET, CURRENTADD, LIST,focused, SYSLISTVIEW321, ahk_exe mobile.exe
		TKT_ARRAY := STRSPLIT(CURRENTADD, A_TAB)
		town := TKT_ARRAY[9]
		street := TKT_ARRAY[6]
		NUMBER := TKT_ARRAY[5]
		intersection := TKT_ARRAY[14]
		town := RegExReplace(town,"AURORA.*","AURORA")
		town := RegExReplace(town,"NEWMARKET.*", "NEWMARKET")
		town := RegExReplace(town,"RICHMOND HILL.*","RICHMOND HILL")
		town := RegExReplace(town,"MARKHAM.*","MARKHAM")
		town := RegExReplace(town, "WHITCHURCH-STOUFFVILLE.*", "WHITCHURCH-STOUFFVILLE")
		street := RegExReplace(street, "LINE.*","LINE")
		;address.intersection := RegExReplace(address.intersection, "LINE.*","LINE")
		street :=RegExReplace(street," ST.*"," ST")
		street :=RegExReplace(street," RD.*"," RD")
		street :=RegExReplace(street," AVE.*"," AVE")
		;address.intersection := RegExReplace(address.intersection," AVE.*", " AVE")
		street :=RegExReplace(street,"PKWY.*","PKWY")
		street :=RegExReplace(street,"DR E.*","DR E")
		street :=RegexReplace(street,"DR W.*","DR W")
		street :=RegexReplace(street, " DR.*", " DR")
		WinActivate,ahk_exe streets.exe
		if (number)
			ControlSetText,Edit4,% number " " street ", " town,ahk_exe Streets.exe ;put street name in edit window
		else
			ControlSetText,Edit4,% street " & " intersection ", " town,AHK_EXE streets.exe
		ControlClick,Button79,ahk_exe streets.exe,,,,na
		WinWaitActive,Find ahk_exe streets.exe,,1.5 ; waits to see if find comes up
		if WinExist("Find")
			WinWaitClose,Find ahk_class #32770
		Sleep 200
		focusTeldig()
		wait()
		Send, {Down}
		wait()
	}
	SplashTextOff
}

setIntersectionST()
{
	address := fixStreetName1()
	WinActivate, ahk_exe streets.exe
	waitCaret()
	Click 28, 238
	SendInput % address.street . " & " . address.intersection . "," . address.town
	Send, {Enter}
	;IfWinExist, Find
	;{
	;WinClose, Find
	;MsgBox, Enter address manually
	;}
	;focusTeldig()
}

getLocationMobileList()
{
	CONTROLGET, LISTTEXT, LIST, focused, SYSLISTVIEW321, ahk_exe mobile.exe
	TKT_ARRAY := STRSPLIT(LISTTEXT, A_TAB)
	address := {}
	address.town := TKT_ARRAY[9]
	address.street := TKT_ARRAY[6]
	address.NUMBER := TKT_ARRAY[5]
	address.intersection := TKT_ARRAY[14]
return address
}

; regex function adapted for streets and trips data
fixstreetName1() {
	address := getLocationMobileList()
	address.street := RegExReplace(address.street,"^ |^\d+ | \(REGIONAL.*| \(COUNTY.*| \(HIGHW.*")
	address.intersection:= RegExReplace(address.intersection,"^ | \(REGIONAL.*| \(COUNTY.*| \(HIGHW.*")
	address.town:= RegExReplace(address.town,"\,.*")
return address
}

; regex function to format names from Teldig
fixstreetName()
{
	global town
	global intersection
	global intersection2
	global street
	intersection:= RegExReplace(intersection,"^ | \(REGIONAL.*| \(COUNTY.*| \(HIGHW.*")
	intersection2 := RegExReplace(intersection,"^ | \(REGIONAL.*| \(COUNTY.*| \(HIGHW.*")
	street := RegExReplace(street,"^ |^\d+ | \(REGIONAL.*| \(COUNTY.*| \(HIGHW.*|^\d+, ")
	town:= RegExReplace(town,"\,.*")
}

#IFWINACTIVE AHK_EXE MOBILE.EXE
!^I::
	setIntersectionST()
return
#IfWinActive

#v::
:::vpn::
	vpnToggle()
return

+!b::
	bellsearch()
return

bellsearch()
{
	InputBox, bcitysearch, City?, % "Enter City Name"
	if ErrorLevel
		return
	location := getIxn()
	if (location.choice = "a")
	{

		SetTitleMatchMode, 2
		CoordMode, Mouse, Window
		tt = Territory
		WinWait, %tt%
		IfWinNotActive, %tt%,, WinActivate, %tt%
			Sleep, 2000
		MouseClick, L, 1284, 500
		Sleep, 132
		tt = ahk_class WindowsForms10.Window.808.app.0.378734a
		WinWait, %tt%
		IfWinNotActive, %tt%,, WinActivate, %tt%
			Sleep, 200
		MouseClick, L, 73, 32
		tt = Zoom To Bell Address Range
		WinWait, %tt%
		IfWinNotActive, %tt%,, WinActivate, %tt%
			Sleep, 200
		Send, {Blind}%bcitysearch%
		Sleep, 1177
		MouseClick, L, 367, 131
		tt = Zoom To Bell Address Range
		WinWait, %tt%,,4,
		IfWinNotActive, %tt%,, WinActivate, %tt%
			Sleep, 250
		Send, {Blind}%street%
		Sleep, 300
		MouseClick, L, 365, 134
		tt = Zoom To Bell Address Range
		WinWait, %tt%,,4,
		IfWinNotActive, %tt%,, WinActivate, %tt%
			Sleep, 250
		Send, {Blind}%address%
		Sleep, 500
		MouseClick, L, 365, 134
	}

	else
	{
		SetTitleMatchMode, 2
		CoordMode, Mouse, Window
		tt = Territory
		WinWait, %tt%
		IfWinNotActive, %tt%,, WinActivate, %tt%
			Sleep, 2000
		MouseClick, L, 1259, 498
		Sleep, 133
		tt = ahk_class WindowsForms10.Window.808.app.0.378734a
		WinWait, %tt%
		IfWinNotActive, %tt%,, WinActivate, %tt%
			Sleep, 319
		MouseClick, L, 48, 27
		tt = Zoom To Bell Intersection
		WinWait, %tt%
		IfWinNotActive, %tt%,, WinActivate, %tt%
			Sleep, 632
		Send, {Blind}%bcitysearch%{Enter}
		tt = Zoom To Bell Intersection
		WinWait, %tt%
		IfWinNotActive, %tt%,, WinActivate, %tt%
			Sleep, 226
		Send, {Blind}%street%{Enter}
		tt = Zoom To Bell Intersection
		WinWait, %tt%
		IfWinNotActive, %tt%,, WinActivate, %tt%
			Sleep, 218
		Send, {Blind}%intersection%{enter}
		IfWinNotActive, %tt%,, WinActivate, %tt%
				/* 	WinActivate, ahk_exe lacmultiviewer.exe
				Sleep 500
			;CLICK INTERSECTION
				t1:=A_TickCount, X:=Y:=""
				Text:="|<>*100$11.000007Xz7yDwTszlw"
				if (ok:=FindText(1248-150000, 491-150000, 1248+150000, 491+150000, 0, 0, Text))
				{
						CoordMode, Mouse
						X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
						Click, %X%, %Y%
					}
				Sleep 500
			;click intersection again
				t1:=A_TickCount, X:=Y:=""
				Text:="|<>*153$41.xzU0001zz00003ry00C0Lzw0080jTs00HnoJE00YGxzU018Zzz002F/ry004WLzw00R4s"
				if (ok:=FindText(1242-150000, 484-150000, 1242+150000, 484+150000, 0, 0, Text))
				{
						CoordMode, Mouse
						X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
						Click, %X%, %Y%
					}
				WINWAITACTIVE, Zoom To Intersection
				waitCaret()
				Sendevent, %bcitysearch%{ENTER}
				waitCaret()
				Sendevent, % location.s
				Send {ENTER}
				waitCaret()
				Sendevent, % location.n
				Send {enter}
			*/
	}
}

bellsearch2() 	
{
	global street, intersection, number, town
	getTicketData(number,street,intersection,intersection2,stationCode,diginfo,ticketNumber,town,ticketdata)
	fixStreetName()
	if (number)
	{

		SetTitleMatchMode, 2
		CoordMode, Mouse, Window
		tt = Territory
		WinWait, %tt%,,5,
		IfWinNotActive, %tt%,, WinActivate, %tt%
			Sleep, 2000
		MouseClick, L, 1292, 497
		Sleep, 132
		tt = ahk_class WindowsForms10.Window.808.app.0.378734a
		WinWait, %tt%
		IfWinNotActive, %tt%,, WinActivate, %tt%
			Sleep, 530
		MouseClick, L, 73, 32
		tt = Zoom To Bell Address Range
		WinWait, %tt%
		IfWinNotActive, %tt%,, WinActivate, %tt%
			Sleep, 709
		Send, {Blind}%town%{Enter}
		Sleep, 1177
		tt = Zoom To Bell Address Range
		WinWait, %tt%,,4,
		IfWinNotActive, %tt%,, WinActivate, %tt%
			Sleep, 819
		Send, {Blind}%street%{Enter}
		Sleep, 959
		tt = Zoom To Bell Address Range
		WinWait, %tt%,,,
		IfWinNotActive, %tt%,, WinActivate, %tt%
			Sleep, 819
		Send, {Blind}%number%{Enter}
		Sleep, 959

	}
	else
	{
		SetTitleMatchMode, 2
		CoordMode, Mouse, Window
		tt = Territory
		WinWait(tt,,3)
		IfWinNotActive, %tt%,, WinActivate, %tt%
			Sleep, 2000
		MouseClick, L, 1253,500
		Sleep, 133
		tt = ahk_class WindowsForms10.Window.808.app.0.378734a
		WinWait, %tt%
		IfWinNotActive, %tt%,, WinActivate, %tt%
			Sleep, 319
		MouseClick, L, 31,37
		tt = Zoom To Bell Intersection
		WinWait, %tt%
		IfWinNotActive, %tt%,, WinActivate, %tt%
			Sleep, 632
		Send,%town%{Enter}
		tt = Zoom To Bell Intersection
		WinWait, %tt%
		IfWinNotActive, %tt%,, WinActivate, %tt%
			Sleep, 226
		Send, %street%{Enter}
		tt = Zoom To Bell Intersection
		WinWait, %tt%
		IfWinNotActive, %tt%,, WinActivate, %tt%
			Sleep, 218
		Send,%intersection%{enter}
		IfWinNotActive, %tt%,, WinActivate, %tt%
		}
}

::getahkvars::
	ListVars
return

::reloadahk::
	InputBox, isreload,Reload?, y / n
(isreload = "y") ? Reload : Return
isreload := ""
return

+!r::
	run, %comspec% /c ""pytest" "-s" "test_rOGERSLOOKUP.py"",C:\Users\Cr
return

rogersLookup()
{
	location := getIxn()
	if (location = "")
		return
	vpnstatus := isvpn()
	loop
	{
		if (vpnstatus = false)
		{
			vpnToggle()
			vpnstatus := true
		}
		else break
		}
	;WinActivate, ahk_exe chrome.exe
	WinClose, ahk_exe vpnui.exe
	fixStreetName()
	;Run,test_rOGERSLOOKUP.py "pytest" "-s"
	;Run %ComSpec% /c ""C:\My Utility.exe" "param 1" "second param" >"C:\My File.txt""
	global driver
	driver := ChromeGet()
	Text:="|<>*141$71.0000000000000000000000020001w00000070DUDz000000D0z0zz000000T3w3zz000003S7kDzz000006wTUT0y000005tztw0y00000Dnzzs1w00000TDzzU3s00000TT3z03k00000zw7y0DU00000zs7y0T000000zkDw0y000003zUzw3s000007zXvzzk00000Tzznzz000000yTz3zw000001sTw3zk0000030DU1y000000000000000000000000000000000000000000000000000001"
	if !(ok:=FindText(87-150000, 97-150000, 87+150000, 97+150000, 0, 0, Text)) ; if go 360 not open
	{
		;driver.Window.Maximize()
		driver.Get("http://10.13.218.247/go360rogersviewer/")
		;driver.Window.SetSize(1050, 704)
		driver.findElementbyId("username").SendKeys("craig.huckson") ;
		driver.findElementbyId("password").SendKeys("locates1")
		driver.findElementbyxpath("/html/body/div/form/div[3]/div[2]/div/button").click()
		;driver.findElementByCss("#loginform > div:nth-child(4) > div.col-md-2.col-sm-12.col-xs-12 > div > button").click() ; click ok on orange window
		wait()

		driver.findElementbyId("form_marqueezoom_btn").click() ;clicks marquee zoom to clear previous
		driver.findElementbyCss("#form_btn").click() ;search button
			driver.findElementbyxpath("//*[@id='tab_featureform']/div[1]/div[3]/ul/li[1]/a/span[1]").click() ; quick search tab
			if (location.choice = "a")
			{
				driver.findElementbyId("addressSearchInput").clear()
				driver.findElementbyId("addressSearchInput").SendKeys(location.n " " location.s)
				Sleep 3000
				driver.findElementByCss("title='Search Address'").click()
			}
			else
			{
				driver.findElementbyId("intersectionSearchInput1").clear()
				driver.findElementbyId("intersectionSearchInput2").clear()
				driver.findElementbyId("intersectionSearchInput1").SendKeys(location.s)
				driver.findElementbyId("intersectionSearchInput2").Sendkeys(location.n)
				Sleep 3000
			}
		}
		else
		{
			;driver.Window.SetSize(1050, 704)
			;driver.findElementbyId("form_marqueezoom_btn").click() ;clicks marquee zoom to clear previous
			driver.findElementbyCss("#form_btn").click() ;search button
			driver.findElementbyxpath("//*[@id='tab_featureform']/div[1]/div[3]/ul/li[1]/a/span[1]").click() ; quick search tab
			if (location.choice = "a")
			{
				driver.findElementbyId("addressSearchInput").clear()
				driver.findElementbyId("addressSearchInput").SendKeys(location.n " " location.s)
				Sleep 3000
				driver.findElementByCss("title='Search Address'").click()
			}
			else
			{
				driver.findElementbyId("intersectionSearchInput1").clear()
				driver.findElementbyId("intersectionSearchInput2").clear()
				driver.findElementbyId("intersectionSearchInput1").SendKeys(location.s)
				driver.findElementbyId("intersectionSearchInput2").Sendkeys(location.n)
				Sleep 3000
			}
		}
}

rogersLookup2()
{
	global street, intersection, town, number
	getTicketData(number,street,intersection,intersection2,stationCode,diginfo,ticketNumber,town,ticketdata)
	vpnstatus := isvpn()
	loop
	{
		if (vpnstatus = false)
		{
				vpnToggle()
				vpnstatus := true
		}
			else break
	}
	WinActivate, ahk_exe chrome.exe
	WinClose, ahk_exe vpnui.exe
	fixStreetName()
	global driver
	if !(driver)
	driver := ChromeGet()
	Text:="|<>*141$71.0000000000000000000000020001w00000070DUDz000000D0z0zz000000T3w3zz000003S7kDzz000006wTUT0y000005tztw0y00000Dnzzs1w00000TDzzU3s00000TT3z03k00000zw7y0DU00000zs7y0T000000zkDw0y000003zUzw3s000007zXvzzk00000Tzznzz000000yTz3zw000001sTw3zk0000030DU1y000000000000000000000000000000000000000000000000000001"
	if !(ok:=FindText(87-150000, 97-150000, 87+150000, 97+150000, 0, 0, Text)) ; if go 360 not open
	{
		driver.Get("http://10.13.218.247/go360rogersviewer/")
		driver.findElementbyId("username").SendKeys("craig.huckson") ;
		driver.findElementbyId("password").SendKeys("locates1")
		driver.findElementbyxpath("/html/body/div/form/div[3]/div[2]/div/button").click()
		wait()
		driver.findElementbyId("form_btn").click() ;search button
		driver.findElementbyxpath("//*[@id='tab_featureform']/div[1]/div[3]/ul/li[1]/a/span[1]").click() ; quick search tab
		if (number)
		{
			driver.findElementbyId("addressSearchInput").clear()
			driver.findElementbyId("addressSearchInput").SendKeys(number " " street)
			Sleep 3000
			
		}
		else
		{
			driver.findElementbyId("intersectionSearchInput1").clear()
			driver.findElementbyId("intersectionSearchInput2").clear()
			driver.findElementbyId("intersectionSearchInput1").SendKeys(street)
			driver.findElementbyId("intersectionSearchInput2").Sendkeys(intersection)
			Sleep 3000
		}
	}
	else
	{
		driver.findElementbyId("form_btn").click() ;search button
		driver.findElementbyxpath("//*[@id='tab_featureform']/div[1]/div[3]/ul/li[1]/a/span[1]").click() ; quick search tab
		if (number)
		{
			driver.findElementbyId("addressSearchInput").clear()
			driver.findElementbyId("addressSearchInput").SendKeys(number " " street)
			driver.findElementByTitle.("Search Address").click()
			Sleep 3000
		}
		else
		{
			driver.findElementbyId("intersectionSearchInput1").clear()
			driver.findElementbyId("intersectionSearchInput1").SendKeys(street)
			driver.findElementbyId("intersectionSearchInput2").clear
			driver.findElementbyId("intersectionSearchInput2").Sendkeys(intersection)
			Sleep 3000
		}
	}
}

;google maps lookup Alt Shift G
!+g::
googleLookup()
return 

googleLookup() {
	Iobj := getIxn()
	driver := ChromeGet()
	driver.Get("https://www.google.ca/maps/")
	driver.findElementbyId("searchboxinput").SendKeys(Iobj.s " &" Iobj.n)
	Send, {Enter}
	Iobj := ""
}

getIxn() {
	Inputbox, choice, Address or Intersection?, A / I
	if ErrorLevel
		return
	if (choice = "a")
	{
		InputBox, address, Enter House Number
		if ErrorLevel
			return
		InputBox, street, Enter Street Name
		if ErrorLevel
			return
		location := {"n": address, "s": street, choice: "a"}
		return location
	}
	else if (choice = "i")
	{
		InputBox, street, Enter Street 1
		if ErrorLevel
			return
		InputBox, intersection, Enter Street 2
		if ErrorLevel
			return
		location := {"s": street,"n": intersection, choice: "i"}
		return location
	}
	else
	{
		Msgbox % "Invalid selection"
		getIxn()
	}
}
;SUBROUTINES
#IFWINACTIVE AHK_EXE mobile.exe
#f10::
global stationcode
recordsLookup()
return

recordsLookup()
{
	global town
	global street
	global intersection
		;~ WinActivate, AHK_EXE mobile.exe
		;~ clickLocationTab()
		;~ getticketdata(number,street,intersection,intersection2,stationcode, diginfo, ticketNumber,town,ticketdata)
		;~ fixstreetName()
		;~ IF (stationCode = "BCGN01") or if (stationcode = "BCGN02")
			;~ bellsearch2()
		;~ IF (stationCode = "ROGYRK01") or if (stationcode = "ROGSIM01")
			;~ rogersLookup2()
		;~ IF (stationCode = "CDST01")
			;~ GOSUB, CDS_LOOKUP
	WINACTIVATE, AHK_EXE mobile.EXE
	clickLocationTab()
	getTicketData(number,street,intersection,intersection2,stationCode,diginfo,ticketNumber,town,ticketdata)
	sleep 200
	clickDigInfoTab()
	ControlGet,didata, List,, SysListView321, ahk_exe mobile.exe
	Loop, Parse, didata, `n
	{
		if instr(A_LoopField, "LATITUDE")
		{
			lat := substr(A_LoopField, 11)
		}
		if instr(A_LoopField, "LONGITUDE")
		{
			long := substr(A_LoopField, 13)
		}
	}
	;msgbox % "(" lat "," long ")"
	if (stationCode = "ROGYRK01") || if (stationCode = "ROGSIM01")

	{
		;~ vpnstatus := isvpn()
		;~ loop
		;~ {
			;~ if (vpnstatus = false)
			;~ {
				;~ vpnToggle()
				;~ vpnstatus := true
			;~ }
			;~ else break
		;~ }
		;~ WinClose, ahk_exe vpnui.exe
		if !WinExist("ahk_exe chrome.exe")
		{
			Run, C:\Program Files\Google\Chrome\Application\chrome.exe  --remote-debugging-port=9222
		}
		WinActivate, ahk_exe chrome.exe
		WinWaitActive, ahk_exe chrome.exe
		if !driver
			driver := ChromeGet()
		currenturl := driver.Url
		if (currenturl != "http://10.13.218.247/go360rogersviewer/map.jsp?m=0&isIE=-1&isTOUCH=0&lang=EN#")
		{
			driver.Get("http://10.13.218.247/go360rogersviewer/")
			driver.findElementbyId("username").SendKeys("craig.huckson")
			driver.findElementbyId("password").SendKeys("locates1")
			driver.findElementbyxpath("/html/body/div/form/div[3]/div[2]/div/button").click()
			sleep 1000
		}
		driver.findElementbyId("form_marqueezoom_btn").click() ; clicks marquee zoom to clear stuff
		if !(driver.findElementbyId("id_search_div").IsDisplayed())
			driver.findElementbyId("form_btn").click() ;search button

		driver.findElementbyxpath("//*[@id='tab_featureform']/div[1]/div[3]/ul/li[1]/a/span[1]").click()
		driver.FindElementbyId("longitudeSearchInput").clear()
		driver.findElementbyId("longitudeSearchInput").SendKeys(long)
		driver.findElementbyId("latitudeSearchInput").clear()
		driver.findElementbyId("latitudeSearchInput").SendKeys(lat)
		driver.findElementbyCss("#id_search_div > div:nth-child(1) > table > tbody > tr:nth-child(8) > td:nth-child(4) > a").click()
        driver.findElementbyCss("body > div:nth-child(7) > div.panel-header.panel-header-noborder.window-header > div.panel-tool > a.panel-tool-close").click()
	}

	else if (stationCode "BCGN01") || if (stationCode = "BCGN02")
	{
		MV := "ahk_exe lacmultiviewer.exe"
        WINACTIVATE, %MV%
		if (lat != "") 
		{
			Controlclick, WindowsForms10.BUTTON.app.0.378734a32, %MV%
			winwaitactive, Zoom to Coordinate
			sleep 50
			Controlsend, WindowsForms10.EDIT.app.0.378734a3, {bs}, %MV%
			controlsettext, WindowsForms10.EDIT.app.0.378734a3, %lat%, %MV%
			controlsettext, WindowsForms10.EDIT.app.0.378734a2, %long%, %MV%
			Controlclick, WindowsForms10.BUTTON.app.0.378734a3,%MV%
		}
		else
		{	
			fixStreetname()
			ControlClick, WindowsForms10.BUTTON.app.0.378734a27, %MV%
			sleep 1200
			Click, 18,39
			sleep 200
			WinWaitActive, Zoom To Bell
			Send, %town%
			Send, {Enter}
			sleep 300
			Send, %street%{Enter}
			sleep 300
			send, %intersection%{enter}
		}
	}

	else
	{
		MsgBox % "Utility not yet supported"
	}

}

#IfWinActive
ROGERS_LOOKUP:
;checks existence of go360 window
global intersection
global street
global number
vpnstatus := isvpn()
loop {
	if (vpnstatus = false)
	{
		vpnToggle()
		vpnstatus := true
	}
		else break
}
fixStreetName()
driver := ChromeGet()
	;driver := ComObjCreate("Selenium.EdgeDriver")
	;driver.Start()
driver.Get("http://10.13.218.247/go360rogersviewer/")
driver.findElementbyId("username").SendKeys("craig.huckson") ;
driver.findElementbyId("password").SendKeys("locates1")
driver.findElementByCss("#loginform > div:nth-child(4) > div.col-md-2.col-sm-12.col-xs-12 > div > button").click()
driver.findElementbyCss("#form_btn").click()
driver.findElementbyCss("#tab_featureform > div.tabs-header > div.tabs-wrap > ul > li.tabs-first > a > span.tabs-title").click()
driver.findElementbyId("intersectionSearchInput1").SendKeys(street)
driver.findElementbyId("intersectionSearchInput2").Sendkeys(intersection)
driver.findElementbyCss("#id_search_div > div:nth-child(1) > table > tbody > tr:nth-child(6) > td:nth-child(4) > a").click()
return

ChromeGet(IP_Port := "127.0.0.1:9222")
{
	driver := ComObjCreate("Selenium.ChromeDriver")
	driver.SetCapability("debuggerAddress", IP_Port)
	driver.Start()
	return driver
}
	;if winexist("Go360 Rogers Viewer")
		;WinActivate, "Go360 Rogers Viewer"
	;else
	;{
		;MsgBox, Please open Go360 Viewer
		;return
	;}
	;WinActivate, Go360 Rogers Viewer
	;loop {
		;ImageSearch,,,0,0,1366,768,go360search.png
		;if (errorlevel = 0) {
			;Send, {click 645, 96}
			;break
		;}
		;else
			;break
	;}
	;wait()
	;Send, {click 827, 188}
	;wait()
	;fixStreetName()
	;Send, {tab 6}
	;wait()
	;Send, %street%
	;wait()
	;Send, {tab}%intersection%
	;wait()
	;Send, {enter}
	;RETURN
BELL_LOOKUP:
	WinActivate ahk_exe lacmultiviewer.exe
	Sleep 500
	LOOP {
		imagesearch, foundx, foundy, 0,0,1368, 664, FAAR_Intersection.bmp
		IF ERRORLEVEL = 0
			break
	}
	Sleep 800
	Sendevent {click %foundx%, %foundy%}
	LOOP {
		imagesearch, foundx, foundy, 0,0,1368, 664, intersection.bmp
		IF ERRORLEVEL = 0
			break
	}
	Sendevent {click %foundx%, %foundy%}
	WINWAITACTIVE, Zoom To Intersection
	waitCaret()
	Sendevent %town%{ENTER}
	waitCaret()
	Sendevent %street%{ENTER}
	waitCaret()
	Sendevent %intersection%{enter}
	return
	CDS_LOOKUP:
	WinActivate ahk_exe MAPINFOR.EXE
	Sleep 1000
	Send !SF
	WINWAITACTIVE ahk_class #32770 ;wait for dialog box
	Send {DOWN 7}{TAB 2}{UP 2}{ENTER}
	RETURN
	;FANCY FUNCTIONS
	;would like to rewrite this using preset positions like dig area
	;F5::
	;checks to see if template has been created, exits if not
	;isErrorNoSketch(filename)
	;if !FileExist("C:\Users\Cr\Documents\" filename)
	;{
		;Msgbox, Unable to load element (template not created)
		;return
	;}

	setCornerText(landbase)
	{
		global
		setTemplateText(landbase "cornerxstreet.skt", inter.x)
		setTemplateText(landbase "cornervstreet.skt", inter.y)
		;setTemplateText(landbase "cornerhouse.skt", haddress)
	}

	setDWtext()
	{
		global
		dwtextlist := ""
		text1 := "DW " . num.1
		text2 := "DW " . num.2

		; if NOT a corner
		if(!intdir)
		{
			dwtextlist :=  {(text1):(landbase "dwtext1.skt")
						,(text2):(landbase "dwtext2.skt")
						,(street):(landbase "street.skt")}
			for k,v in dwtextlist
			{
				if !FileExist("C:\Users\Cr\Documents\" v)
				{
					Msgbox, Unable to load sketch (template not created)
					k:="",v:=""
					return
				}
			}
		}
		;if it IS a corner
		else
		{
			dwtextlist := 	{(text1):(landbase "dwtodw" intdir ".skt")
						,(xstreet):(landbase "BLTEXTHSTREET.SKT")
						,(vstreet):(landbase "BLTEXTVSTREET.SKT")}
		}

		for k,v in dwtextlist
		{
			setTemplateText(v,k)
			k:="",v:= "", intdir := ""
			;loadImageNG(v)
			;Send, {F2}%k%{Enter}
		}
	}

	;loops through text arrays to label streets and building numbers
	setBLtext(landbase,intdir:="",xstreet:="",vstreet:="")
	{
		global
		if (rclear)
			return
		if landbase in h,H,v,V 
		{
			string := InputBox("Enter building code / house number in following format:`ncode1,number1,code2,number2")
			buildingnumbers := StrSplit(string,",")
			if (buildingnumbers.Length() != 4){
				Throw, Exception("Improper input",-1)
			}
			setTemplateText(landbase . buildingnumbers[1] . "NUM.skt",buildingnumbers[2])
			setTemplateText(landbase . buildingnumbers[3] . "NUM.skt", buildingnumbers[4])
			return
		}
		
		text1 := num.1, text2 := num.2
		if(intdir != "")
		{
			textlist := {(text1):(landbase "BLTEXT" intdir ".skt"),(xstreet):(landbase "BLTEXTHSTREET.SKT"),(vstreet):(landbase "BLTEXTVSTREET.SKT")}

			;for k,v in textlist
			;{
				;if !FileExist("C:\Users\Cr\Documents\" v)
				;{
					;Msgbox, Unable to load sketch (template not created)
					;k:="",v:=""
					;return
				;}
			;}
			for k,v in textlist
			{
				loadImageNG(v)
				Send,{F2}%k%{Enter}
				intdir := ""
				textlist := ""
			}
		}

		else 
		{
			rcross := InputBox("Corner road crossing?")
			if(rcross="y")
			{
				textlist := {(text1):(landbase "rcbltext1.skt"),(vstreet):(landbase "rcblvstreet.skt")
				,(xstreet):(landbase "rcblxstreet.skt")}
				for k,v in textlist
				{
					loadImageNG(v)
					Send,{F2}%k%{Enter}
					rcross := ""
					textlist := ""
				}
			}

			else
			{
				textlist := {(text1):(landbase "BLTEXT1.SKT"),(text2):(landbase "BLTEXT2.SKT")
							,(street):(landbase "STREET.SKT")}
				;for k,v in textlist {
					;if !FileExist("C:\Users\Cr\Documents\" v)
					;{
						;Msgbox, Unable to load sketch (template not created)
						;k:="",v:=""
						;return
					;}
				;}
				for k,v in textlist
				{
					loadImageNG(v)
					Send, {F2}%k%{Enter}
					textlist := ""
				}
			}
			intdir := ""
		}
	}

	setPLtext(landbase)
	{
		global
		num1 := num.1, num2 := num.2
		if(!FileExist("C:\Users\Cr\Documents\" landbase "PLtext.skt")||!FileExist("C:\Users\Cr\Documents\" landbase "street.skt"))
		{
			Msgbox, Unable to load sketch (template not created)
			return
		}
		setTemplateText(landbase "PLtext.skt",num[1])
		setTemplateText(landbase "street.skt",street)
	}

	setStreettoStreetText(landbase)
	{
		global
		if(landbase = "n" || landbase = "s")
		{
			setTemplateText(landbase "streettostreetwy.skt",westystreet)
			setTemplateText(landbase "streettostreetey.skt",eastystreet)
			setTemplateText(landbase "streettostreetx.skt", xstreet)
		}
		else
		{
			setTemplateText(landbase "streettostreetnx.skt",northxstreet)
			setTemplateText(landbase "streettostreetsx.skt",southxstreet)
			setTemplateText(landbase "streettostreety.skt", ystreet)
		}
	}

	setPL4text(landbase)
	{
		global
		num1 := num.1, num2 := num.2
		if(rclear)
			return
		if(num2) ;if 2 addresses listed
		{
			;list :=["PL4TEXT1.skt","PL4TEXT2.skt","street.skt"]
			;for i in list
			;{
				;if !FileExist("C:\Users\Cr\Documents\" landbase i)
				;{
					;Msgbox, Unable to load sketch (template not created)
					;return
				;}
			;}
			setTemplateText(landbase "PL4TEXT1.skt",num1)
			setTemplateText(landbase "PL4TEXT2.skt",num2)
			setTemplateText(landbase "street.skt",street) ;draw 2 houses
		}
		else ;if only 1 house
		{
			if(landbase = "nw") or (landbase = "ne") or (landbase = "se") or (landbase = "sw")
			{
				inter := isInterText()
				inter.x := hstreet, inter.y := vstreet
				setTemplateText(landbase "BLTEXT.skt",num1)
				setTemplateText(landbase "BLTEXTHSTREET.skt", hstreet)
				setTemplateText(landbase "BLTEXTVSTREET.skt", vstreet)
				RETURN
			}
			if !FileExist("C:\Users\Cr\Documents\" landbase "PLTEXT.SKT")
			{
				MsgBox, Unable to load sketch (template not created)
				return
			}
			if !FileExist("C:\Users\Cr\Documents\" landbase "street.skt")
			{
				Msgbox, Unable to load sketch (template not created)
				return
			}
			setTemplateText(landbase "PLTEXT.skt",num1)
			setTemplateText(landbase "street.skt",street)
		}
	}

	getDWNum()
	{
		Inputbox,num1, N/W DW address?
		Inputbox,num2, S/E DW address?
		num := [num1,num2] ;array for driveway numbers
		return num
	}

	getBLNum()
	{
		num1 := InputBox("N/W House Address?")
		num2 := InputBox("S/E House Address?")
		num := [num1,num2] ;array for house numbers
		return num
	}

	setvtext(location,text)
	{
		global street
		loadimageNG("vlabeltext.skt")
		Click, right
		Sleep 50
		Send, {Up 2}
		Sleep 50
		Send, {Enter}
		Sleep 50
		Send, {Down 10}%location%{Enter}
		Sleep 50
		Send, {Down 7}%text%{Enter}
		Sleep 50
		Click
	}

	sethtext(location,text)
	{
		global street
		loadimageNG("hlabeltext.skt")
		Click, right
		Send, {Up 2}
		Send, {Enter}
		Send, {Down 10}%location%{Enter}
		Send, {Down 7}%text%{Enter}
		Click
	}

	setVStreet(location,text)
	{
		global street
		loadimageNG("vstreettext.skt")
		Click, right
		Send, {Up 2}
		Send, {Enter}
		Send, {Down 10}%location%{Enter}
		Send, {Down 7}%text%{Enter}
		Click
	}

	openSketchEditor:
	WinActivate, ahk_exe mobile.exe
	Send,!ls
	focusSketchtool()
	return

	F6::
	parser()
	return

	parser()
	{
		commands := {"edit sketch":func(focusTeldig),"emergency":func(emergency),"grid":func(changeGridSizeto16)}
		command := InputBox(,"Enter String")
		for cmd,func in commands{
			if (command == cmd){
				%func%()
			}
		}
		;InputBox, command, Enter String
		; switch command
		; {
		; 	Case "edit sketch" :
    ;           focusTeldig()
		; 	Send, !ls
		; 	Case "emergency" :
    ;           emergency()
    ;         Case "grid":
    ;           changeGridSizeTo16()
		; }
	}
	return

	::emerg::
	emergency()
	{
		InputBox, name, Contractor name?
		Stringupper,name,name
		setTemplateText("contractor.skt", name)
		(form = "BP") ? loadImageNG("leftonsite.skt") : loadImageNG("leftonsiter.skt")
	}

	;InputBox(message)
	;{
		;Inputbox, result,, % message
		;return result
	;}

	^NumpadHome::
	; prompts for and loads peds
	peddir := InputBox("N,E,S,W")
	if (peddir)
	{
		loadImageNG("ped" peddir ".skt")
		clickPointer()
	}
	else
	{
		loadImageNG("ped.skt")
		clickPointer()
	}
	return
	^NumpadUp::
	; prompts for and loads POLES
	poledir := InputBox("N,E,S,W")
	if (poledir)
	{
		loadImageNG("polestub" poledir ".skt")
		clickPointer()
	}
	else
	{
		loadImageNG("pole.skt")
		clickPointer()
	}
	return

	
	labelTool(text)
	{
		INPUTBOX,LABEL,,ENTER LABEL
		StringUpper, label, label
		Loop, 1
		{
			SetTitleMatchMode, 2
			CoordMode, Mouse, Window
			tt = TelDig SketchTool
			WinWait, %tt%
			IfWinNotActive, %tt%,, WinActivate, %tt%
				WAIT()
			MouseClick, L, 17, 98
			WAIT()
			MouseClick, L, 553, 148,,, D
			WAIT()
			MouseClick, L, 607, 167,,, U
			WAIT()
			Send, %LABEL%
			WAIT()
			MouseClick, L, 12, 125
			WAIT()
			MouseClick, L, 19, 320
			WAIT()
			MouseClick, L, 543, 141,,, D
			WAIT()
			MouseClick, L, 611, 169,,, U
			WAIT()
			MouseClick, L, 26, 124
			WAIT()
			MouseClick, L, 572, 155
			WAIT()
			MouseClick, L, 83, 344
			WAIT()
			MouseClick, L, 304, 63
			WAIT()
			MouseClick, L, 19, 120
			WAIT()
			MouseClick, L, 539, 135,,, D
			WAIT()
			MouseClick, L, 620, 178,,, U
			WAIT()
			MouseClick, R, 566, 151
			WAIT()
			MouseClick, L, 617, 311
			WAIT()
			MouseClick, L, 644, 161
			WAIT()
		}

	}
	;QUICK Label
	#IfWinActive ahk_exe sketchtoolapplication.exe
	::label::
	LShift & RControl::
	quickLabel()
	return

	#IfWinActive

	quickLabel()
	{
		label := InputBox("Enter label name")
        if ErrorLevel {
          return
        }
		loadImageNG(label ".skt")
	}
	+!s::
	TrayTip,,Shift + PrtScr to take screenshot,5
	run, screenshot.py,,Hide
	return

	^MButton::
	^RShift::
	if DllCall("GetCommandLine", "str") = """" A_AhkPath """ /restart """ A_ScriptFullPath """"
		MsgBox Script will be reloaded
    iniwrite, %form%, C:\Users\Cr\teldig\teldig.ini, variables, form
   iniwrite, %stationcode%, C:\Users\Cr\teldig\teldig.ini, variables, stationcode
   iniwrite, %units%, C:\Users\Cr\teldig\teldig.ini, variables, units
   iniwrite, %bellmarked%, C:\Users\Cr\teldig\teldig.ini, variables, bellmarked
   iniwrite, %bellclear%, C:\Users\Cr\teldig\teldig.ini, variables, bellclear
   iniwrite, %rogersclear%, C:\Users\Cr\teldig\teldig.ini, variables, rogersclear
   iniwrite, %rogersmarked%, C:\Users\Cr\teldig\teldig.ini, variables, rogersmarked
   iniwrite, %locationdataobtained%, C:\Users\Cr\teldig\teldig.ini, variables, locationdataobtained
   IniWrite, %street%, C:\Users\Cr\teldig\teldig.ini, variables, street
   IniWrite, %intersection%, C:\Users\Cr\teldig\teldig.ini, variables, intersection
   iniwrite, %currentpage%, C:\Users\Cr\teldig\teldig.ini, variables, currentpage
   IniWrite, %totalpages%, C:\Users\Cr\teldig\teldig.ini, variables, totalpages
	reload
	return

	#E::
	Run,https://webapp.cablecontrol.ca/owa/auth/logon.aspx?replaceCurrent=1&url=https`%3a`%2f`%2fwebapp.cablecontrol.ca`%2fowa`%2f
	;Run, openemail.py,,Maximize
	;traytip, Opening Email,,3
	return

	mobilesyncr:
	::mobilesyncr::
	amt({Type:"Mouse",Action:"Left",Actual:"",ClickCount:1,Wait:2,WindowWait:2,Comment:"Mouse Click",Match:1,OffsetX:10,OffsetY:10,Area:"TelDig Mobile - [Ticket list]",Bits:"y001U00M00C00Dzs206001U00M3z60ztY00NU06sztzDyTs07y01zzyTzzby01zU0Sm",Ones:162,Zeros:238,Threshold:132,W:20,H:20})
	amt({Type:"Mouse",Action:"Left",Actual:"Yes",ClickCount:1,Wait:2,WindowWait:2,Comment:"Mouse Click",Match:1,OffsetX:80,OffsetY:35,Area:"Connection to TelDig Mobile ahk_class #32770",Bits:"00000000000000001000E2040U1MAtN2FIEbp491F2FIEHY00000000000000000002",Ones:48,Zeros:352,Threshold:104,W:20,H:20})
	TrayTip, Sync, Sync will now begin..., 5
	return

	#IfWinActive ahk_exe SketchToolApplication.exe
    #IfWinActive Enter Text ahk_class #32770
	::lacob::
	Send, LOCATED AREA CLEAR OF BELL
	return
    #IfWinActive
    

	NumpadIns::
	ControlClick, OK,ahk_exe SketchToolApplication.exe
	WinActivate, ahk_exe mobile.exe
	return

	#IfWinActive

::deleteoldbell::
	deleteoldbell:
	traytip, Alter, Deleting Old Bell, 5
	Loop, 1
	{
		SetTitleMatchMode, 2
		CoordMode, Mouse, Window
		tt = TelDig SketchTool ahk_class WindowsForms10.Window.8.app.0.2004eee
		WinWait, %tt%
		IfWinNotActive, %tt%,, WinActivate, %tt%
			wait()
		MouseClick, R, 604, 501
		wait()
		MouseClick, L, 631, 365
		wait()
		MouseClick, L, 489, 422
		wait()
		MouseClick, L, 1130, 230,,, D
		wait()
		MouseClick, L, 1133, 407,,, U
		wait()
		MouseClick, L, 269, 91,,, D
		wait()
		MouseClick, L, 1056, 616,,, U
		wait()
		Send,{Delete}
		Send, {Blind}{6}
		wait()
		tt = TelDig SketchTool ahk_class WindowsForms10.Window.8.app.0.2004eee
		WinWait, %tt%
		IfWinNotActive, %tt%,, WinActivate, %tt%
			wait()
	}
	Traytip, Done!,,4
	return

::radigsh::
	radigsh:
	Loop, 1
	{

		SetTitleMatchMode, 2
		CoordMode, Mouse, Window

		tt = TelDig SketchTool ahk_class WindowsForms10.Window.8.app.0.2004eee
		WinWait, %tt%
		IfWinNotActive, %tt%,, WinActivate, %tt%

		Sleep, 390

		MouseClick, L, 416, 328,,, D

		Sleep, 500

		MouseClick, L, 414, 300,,, U

		Sleep, 280

		MouseClick, L, 350, 364,,, D

		Sleep, 515

		MouseClick, L, 350, 326,,, U

		Sleep, 335

		MouseClick, L, 758, 325,,, D

		Sleep, 500

		MouseClick, L, 763, 299,,, U

		Sleep, 280

		MouseClick, L, 726, 360,,, D

		Sleep, 928

		MouseClick, L, 733, 322,,, U

		Sleep, 500

	}
	return

	markJobNumberas2Clear()
	{

		Loop, 1
		{

			SetTitleMatchMode, 2
			CoordMode, Mouse, Window
		;MouseGetPos,foundx,foundy
			tt = TelDig Mobile - [Ticket list] ahk_class Afx:400000:8:10003:0:37026d
			WinWait, %tt%
			IfWinNotActive, %tt%,, WinActivate, %tt%

			wait()

		;MouseClick, R, %foundx%, %foundy%
			Send, !fnS
			wait()

			Send, {Blind}n

			wait()

			tt = Set job number ahk_class #32770
			WinWait, %tt%
			IfWinNotActive, %tt%,, WinActivate, %tt%

			wait()

			Send, {Blind}2{Enter}

			tt = TelDig Mobile - [Ticket list] ahk_class Afx:400000:8:10003:0:37026d
			WinWait, %tt%
			IfWinNotActive, %tt%,, WinActivate, %tt%

			wait()

		}

	}

	#IfWinActive ahk_exe mobile.exe
	^s::
	addressSearch()
	return

	addressSearch()
	{
	Click, 464, 121
	WinGet, hwnd, ID, A
	;msgbox % hwnd
	;accobj := Acc_Get("DoAction","4.1.4.1.4.1.4.37.4",6,"ahk_id " hwnd)
}

	;^c::
	;focus to city search
	;Acc_Get("DoAction","4.1.4.1.4.1.4.37.4",9,"ahk_exe mobile.exe")
	;return

	#IfWinActive

;^F12::
	;rogersClearFromBellSketch(){
		;Acc_Get("DoAction","4.6.4.1.4",0,"ahk_exe SketchToolApplication.exe") ;Click Image
		;Acc_Get("DoAction","4.6.4.1.4.2",0,"ahk_exe SketchToolApplication.exe") ;click Ungroup

		;click 418,329
		;wait()
		;click 134, 668
		;wait()
		;click 50,670
		;wait()
		;Send,{Shift}{End}
		;wait()
		;Send, ^c
		;nboundary := Clipboard
		;ControlGet,nboundary,Line,WindowsForms10.EDIT.app.0.2004eee1,ahk_exe SketchToolApplication.exe
		;Msgbox % nboundary
	;}
;drawing canvas
;top left - 390,106
;bottom right - 933,560

;::test::
	;clickPointer()
	;Click, 18,177
	;wait()
	;Click, 80, 125
;Click,600,106,d
;wait()
;Click600,560,u)
	;MouseClickDrag, L,600,106,600,560

	;return

	#IfWinActive ahk_exe sketchtoolapplication.exe

	^WheelDown::return
	^WheelUp::return

	$^F12::
::`:cd::
centreDrawing()
return

centreDrawing()
	{
		focusSketchtool()
		SendInput, {WheelDown 6}

	}

;Go360 FUNCTIONS

	#IfWinActive ahk_exe chrome.exe

	^b:: ;change basemap to black
	;driver := ChromeGet()
	basemap:="",g360bm:=""
	if !(driver)
	{
		driver := ChromeGet()
	}
	driver.findElementbyid("form_maplayer_btn").click()
	wait()
	basemap := driver.findElementbyId("GROUP_F_BASE1")
	g360bm := driver.findElementbyId("GROUP_F_ROGERS_GO360")
	if (g360bm.IsSelected = -1)
		g360bm.Click()
	if (basemap.IsSelected = 0)
		basemap.Click()
	;msgbox % g360bm.IsSelected
	return
	#IfWinActive

	#IfWinActive
	#IfWinActive ahk_exe SketchToolApplication.exe
	#IfWinActive ahk_class #32770

	;TEXT REPLACEMENT

	::hp::HYDRO POLE
	::sl::STREET LIGHT
	::cv::CULVERT
	::E/::EAST OF
	::N/::NORTH OF
	::W/::WEST OF
	::S/::SOUTH OF

	#IfWinActive

::OWYMAP::
	load_york_maps(YorkMaps)
	return

	load_york_maps(site)
	{
		Run, % site
	}

::OWTREL::
	Run,https://trello.com/craighuckson/boards
	return

::OWMAIL::
	Run,https://webapp.cablecontrol.ca/owa/auth/logon.aspx?
	return

::OWECOM::
	Run,https://my.ecompliance.com/
	return

::owqbit::
	Run, http://ec2.qbitmobile.com/dashboard.aspx
	return

::owtime::
	Run, https://drive.google.com/drive/folders/137VF2fn9rW8HKjrqGjNpog0pYC_OsZXp
	return

::owmmap::
	Run, https://www.google.com/maps/d/u/0/
	return

	;CABLE HOTKEYS

	#IfWinActive, ahk_exe sketchtoolapplication.exe
	~c & numpadUP::
	loadImage("vcable.skt")
	return

	~c & numpadleft::
	loadImage("hcable.skt")
	Return

	~c & numpaddown::
	loadImage("nwcable.skt")
	Return

	~c & numpadright::
	loadImage("necable.skt")
	Return

	~c & numpadhome::
	loadImage("cablearcnw.skt")
	Return

	~c & NumpadPgup::
	loadImage("cablearcne.skt")
	RETURN

	~c & NumpadPgdn::
	loadImage("cablearcse.skt")
	RETURN

	~c & NumpadEnd::
	loadImage("cablearcsw.skt")
	Return

::dx:: ;draw pedestal
	MouseGetPos, pedx, pedy
	MouseClick, L, 139, 611
	wait()
	Click,%pedx%,%pedy%
	pedx:="",pedy:=""
	clickSelection()
	return

::dp:: ;draw pole
	MouseGetPos, polex, poley
	MouseClick, L, 71, 612
	wait()
	Click,%polex%,%poley%
	polex:="",poley:=""
	clickSelection()
	return

::dt:: ;draw transformer
	MouseGetPos, txx, txy
	MouseClick, L, 33, 534
	wait()
	Click,%txx%,%txy%
	txx:="",txy:=""
	clickSelection()
	return

	^E::
	activateEditMode()
	{
		MouseClick("R")
		SendInput("{Up 7}{Enter}")
	}

	#ifwinactive

::damageremarks::
writeDamageRemarks()
{
	excavator:=inputbox("Enter excavator")
	damaged_cable:=inputbox("Cable size and type")
	work_type:=inputbox("Work type?")
	client:=inputbox("Working for?")
	damx:=inputbox("Damage x coordinate")
	damy:=inputbox("Damage y coordinate")
	locate_coord:=inputbox("Where did the locate show the cable")
	Send,%excavator% damaged a %damaged_cable% while doing %work_type% for %client%. The damage occurred at %damx% and %damy%. The locate showed Bell plant at %locate_coord%
	return
}

	insertUDrawSketch:
	if (form = "BA")
	{
		SetTitleMatchMode, 2
		CoordMode, Mouse, Window

		tt = TelDig SketchTool
		WinWait, %tt%
		IfWinNotActive, %tt%,, WinActivate, %tt%
			wait()

		MouseClick, L, 493, 179,,, D

		wait()
		MouseClick, L, 522, 523,,, U
		wait()

		MouseClick, L, 522, 523,,, D

		wait()

		MouseClick, L, 509, 544,,, U

		wait()

		MouseClick, L, 1123, 247,,, D

		wait()

		MouseClick, L, 1128, 550,,, U

		wait()

		MouseClick, L, 607, 564,,, D

		wait()

		MouseClick, L, 607, 538,,, U

		wait()

	}
	else if (form = "RP")
	{
		SetTitleMatchMode, 2
		CoordMode, Mouse, Window

		tt = TelDig SketchTool - C:\TelDigMobile\2020411699_ROG ahk_class WindowsForms10.Window.8.app.0.2004eee
		WinWait, %tt%
		IfWinNotActive, %tt%,, WinActivate, %tt%

		Sleep, 772

		MouseClick, L, 538, 178,,, D

		Sleep, 553

		MouseClick, L, 714, 534,,, U

		Sleep, 296

		MouseClick, L, 714, 534,,, D

		Sleep, 1256

		MouseClick, L, 706, 493,,, U

		Sleep, 569

		MouseClick, L, 1123, 276,,, D

		Sleep, 592

		MouseClick, L, 1123, 490,,, U

		Sleep, 655

		MouseClick, L, 734, 584,,, D

		Sleep, 1076

		MouseClick, L, 727, 501,,, U

		Sleep, 1131

		MouseClick, L, 1063, 231,,, D

		Sleep, 632

		MouseClick, L, 930, 224,,, U

		Sleep, 1000

	}
	Else
		return
	return

	amt({Type:"Mouse",Action:"Left",Actual:1,ClickCount:2,Wait:2,WindowWait:2,Comment:"Mouse Click",Match:1,OffsetX:10,OffsetY:10,Area:"TelDi ahk_class WindowsForms10.Window.8.app.0.2004eee",Bits:"00000000000001U00g00D003zw0z10zWEDlo1xz07LkDYjzvnzywzzjDzvzzzzzzzzy",Ones:193,Zeros:207,Threshold:230,W:20,H:20})
	amt({Type:"Window",Area:"Open ahk_class #32770",WindowWait:2})
	amt({Type:"InsertText",Text:"building.skt",Wait:2,WindowWait:2,SelectAll:1,Comment:"Mouse Click",Match:1,OffsetX:65,OffsetY:-5,Area:"Open ahk_class #32770",Bits:"0000000U008002000XUy94AWT28Y0W9U8WD2800000Tk00000000000000000000002",Ones:49,Zeros:351,Threshold:115,W:20,H:20})
	amt({Type:"Mouse",Action:"Left",Actual:1,ClickCount:1,Wait:2,WindowWait:2,Comment:"Mouse Click",Match:1,OffsetX:63,OffsetY:437,Area:"Open ahk_class #32770",Bits:"bzTwzMAEk30jnzjyTxzrk",Ones:81,Zeros:40,Threshold:170,W:11,H:11})
	amt({Type:"Mouse",Action:"Left",Actual:1,ClickCount:1,Wait:2,WindowWait:2,Comment:"Mouse Click",Match:1,OffsetX:757,OffsetY:574,Area:"TelDig SketchTool  ahk_class WindowsForms10.Window.8.app.0.2004eee",Bits:"0000000000zz000E0S40Al02AE02401100kE004021000E3yQ00Y00+003000000002",Ones:54,Zeros:346,Threshold:159,W:20,H:20})
	amt({Type:"Mouse"
	,Action:"Left"
	,Actual:""
	,ClickCount:1
	,Wait:2
	,WindowWait:2
	,Comment:"Mouse Click"
	,Match:1
	,OffsetX:849
	,OffsetY:109
	,Area:"TelDig ahk_class WindowsForms10.Window.8.app.0.2004eee"
	,Bits:"BYEMQA4308"
	,Ones:16
	,Zeros:40
	,Threshold:180
	,W:7
	,H:8})

::writeaddlist::
	writeAddressList()
	return

	writeAddressList()
	{
		if (InStr(FileExist("C:\Users\Cr\addlist.csv"), "A"))
		{
			FileDelete, C:\Users\Cr\addlist.csv
		}
		CONTROLGET, LISTTEXT, LIST, , SYSLISTVIEW321, ahk_exe mobile.exe
		rowlist := StrSplit(listtext, "`n")
		MsgBox % obj2String(rowlist)
		msgbox % rowlist.Count()
		FileAppend, % "ADDRESS,TOWN`n",addlist3.txt
		for k,v in rowlist
		{
			columnlist := ""
			columnlist := StrSplit(v,A_Tab)
			columnlist.6:= RegExReplace(columnlist.6,"^ |^\d+ | \(REGIONAL.*")
			columnlist.14:= RegExReplace(columnlist.14,"^ | \(REGIONAL.*")
			if (columnlist[5])
				FileAppend, % columnlist[5] . " " . columnlist[6] . ", " . columnlist[9] . "`n", C:\Users\Cr\addlist3.txt
			else
				FileAppend, % columnlist[6] . " & " . columnlist[14] . ", " . columnlist[9] . "`n", C:\Users\Cr\addlist3.txt
		}
		FileCopy, C:\Users\Cr\addlist3.txt, C:\Users\Cr\addresslistbackup.txt,1
		FileMove, C:\Users\Cr\addlist3.txt,C:\Users\Cr\addlist.csv,
		Msgbox, Done!

	}

	#IfWinActive ahk_exe SketchToolApplication.exe
	^Tab::
	accessProperties()
	{
		MouseClick("R")
		SendInput("{Up 2}{Enter}")
		wait()
	}
	#IfWinActive

::showerror::
	displayErrorLog()
	{
		Run, C:\Users\Cr\errorlog.txt
	}

::showts::
	displayTimesheet(today)
	return

	displayTimesheet(date)
	{
		;count := 0
		FileRead, TS, C:\Users\Cr\Desktop\archived\autohotkey\timesheet%date%.txt
		if !(FileExist("C:\Users\Cr\Desktop\archived\autohotkey\timesheet" . date . ".txt"))
			FileRead, TS, C:\Users\Cr\timesheet%date%.txt
		count := StrSplit(TS, "`n").Length()
		MsgBox % "Tickets = " count "`n" TS
	}

::PAPERONLYVALID::
	loadImage("paperonlyvalid.skt")
	return

::OPCLI::
	openCommandLine()
	{
		Run, powershell.exe
	}

::getdiginfo::
	getDigInfo()
	{
		focusTeldig()
		clickdiginfotab()
		ControlGet, digtext,list,,	SysListView321,ahk_exe Mobile.exe
		MsgBox % digtext
	}

	getWorkType()
	{
		focusTeldig()
		clickDigInfoTab()
		ControlGetText, worktype, Edit1, ahk_exe mobile.exe
		return worktype
	}

::ahkman::
	openAHKManual()
	{
		hh := "ahk_exe hh.exe"
		result := Inputbox("Enter search term")
		if !WinExist(hh)
		{
			Run("autohotkey.chm","C:\Program Files\AutoHotkey")
		}
		WinActivate(hh)
		Sleep 150
		Send,!s
		wait()
		Send(result)
	}

#IfWinActive ahk_exe SketchToolApplication.exe
::sktasjpeg::
f12::
	saveSKTAsJpeg()
	{
		Inputbox,string,Enter file to search for
		sleep 20
		Inputbox,filename,Enter new filename,,,,,,,,,%string%
		WinActivate,ahk_exe SketchToolApplication.exe
		send, !i
		sleep 200
		send, {down 8}{enter}
		sleep,200
		WinWaitActive,ahk_class #32770
		winget,hdialog,id,a
		sleep 200
		ControlSetText,Edit1,%string%,ahk_id %hdialog%
		ControlFocus,Button1,ahk_id %hdialog%
		ControlSend, ahk_parent,{Enter},ahk_id %hdialog%
		WinWaitActive, ahk_exe SketchToolApplication.exe
		send, !F{enter}
		WinWaitActive,ahk_class #32770
		ControlSetText,Edit1,%filename%,ahk_class #32770
		Control,Choose,4,ComboBox2,ahk_class #32770
		ControlSend,ahk_parent,{enter},ahk_class #32770
		WinWaitActive,ahk_exe sketchtoolapplication.exe
		if fileexist(A_MyDocuments . "\" . filename . ".jpeg"){
			MsgBox, File was saved
		}
		else
			MsgBox, File not saved
	}
#IfWinActive
	#m::
    ;turns off monitor with Win-m
	Sleep 1000
	SendMessage, 0x112, 0xF170, 2,, Program Manager
	return

::owcovid::
; covid tracking form
	Run, https://docs.google.com/forms/d/e/1FAIpQLScU2XCTGCNtohl9KvmqoYOWenK4MvwPDRKa-BIZ0a3eGxrEZg/viewform?vc=0&c=0&w=1&flr=0&gxids=7628
	SetTitleMatchMode, 2
	CoordMode, Mouse, Screen
	tt = COVID-19 TRACKER
	WinWait, %tt%
	IfWinNotActive, %tt%,, WinActivate, %tt%
		Sleep, 351
	Send, {Blind}{Tab}{Shift Down}{Shift Up}Huckson{vkBC}{Space}{Shift Down}c{Shift Up}raig{Tab}{Shift Down}n{Shift Up}{Tab}n{Tab}n{Tab}{Tab}
	Sleep, 1000
	Send, {Blind}{Enter}
	return

::owrogers::
;opens Go360
Run, http://10.13.218.247/go360rogersviewer/
sleep 300
send, {down}{enter}

::CLEARROGFROMBELL::
::crfb1::
	clearRogersFromBell()
	{
		global form
		reason := InputBox("(C)lear,  (F)TTH, FIBRE (O)NLY?")
		if reason not in c,C,f,F,o,O
		{
			MsgBox % "Invalid answer!"
			clearRogersFromBell()
		}
		ungroupImage()
		Sleep 250
		MouseClick, L, 604, 408
		Sleep 250
		Gosub, deleteoldbell
		Sleep 250
		SendInput, {Wheelup 8}
		Sleep 250
		if (form = "RA")
			gosub, radigsh
		Sleep 250
		if (reason = "c")
			loadImage("rogclear.skt")
		else if (reason = "f")
			loadImage("ftth.skt")
		else
			loadImage("fibreonly.skt")
		Sleep 250
		ST_SAVEEXIT()
	}

::owsnip::
	Run, snippingtool.exe
	return

	#IfWinActive ahk_exe sketchToolApplication.exe ahk_class #32770
	Tab::Down
	#IfWinActive Choose files to add to project
	Tab::Down
	#IFWINACTIVE Select project
	Tab::Down
	#IfWinActive

:::sgrid::
	changeGridSizeTo16()
  ;changes grid size to 16 pixels
	{
		accessProperties()
		Sleep 100
		Send, {Tab 5}16{enter}
	}

#IfWinActive, ahk_exe SketchToolApplication.exe
`::LButton
Esc::Delete
return

;SKETCH RECTANGLE BOUNDARIES
;UPPER LEFT - 192, 512
;LOWER RIGHT - 948, 1152
; SKETCH_WIDTH := 756
; SKETCH_HEIGHT := 640

^F3::
::lineMOVE::
     WinActivate, ahk_exe sketchtoolapplication.exe
     loadImageNG("vTEXT.SKT")
	Sleep 250
	;~ movex := 482
	;~ movey:= 798
	;~ MsgBox % "(" . movex . "," . movey ")"
	;~ SendInput, {right 476}{down 772}
    ;~ msgbox % "Done
    accessProperties()
    Send, {tab 9}
    send, 476,772{enter}
    send, {tab 5}
    send, TV{enter}
    
^F5::
insertEZDrawRP:
drawElement(FileSelectFile("C:\Users\Cr\Documents\"),189,409,757,761)
clickSelection()
return

insertEZDrawBA:
drawElement(FileSelectFile("C:\Users\Cr\Documents\"),115,496)
clickSelection()
return

drawElement(filename,x,y,w := "",h := "",rotation := "")
{
  WinActivate, ahk_exe sketchtoolapplication.exe
  loadImageNG(filename)
  sleep 400
  accessProperties()
  wait()
  ; element position
  Send, {Tab 2}
  send, %x%,%y%{enter}
  if (w != "") or if (h != ""){
    send,{Tab}
    send, %w%,%h%{enter}
  }
}

drawText(filename, String,x,y,w := "",h := "",rotation := "")
{
  winactivate, ahk_exe sketchtoolapplication.exe
  loadImageNG(filename)
	sleep 200
	ACCESSPROPERTIES()
  ;text position
  send, {Tab 9}
  send, %x%,%y%{enter}
	sleep 250
  ;text String
  send, {tab 5}
  send, %String%{enter}
}

::rectsize::
	SetKeyDelay, 25
	loadImageNG("rect.skt")
	Sleep 250
	accessProperties()
	Send, {Tab 9}
	Send, 384, 416{enter}
	Send, {Tab}384,224{enter}
	return
#IfWinActive

::optdc::
openTeldigCache()
{
	;open teldig cache
	Run, explore C:\Users\Cr\AppData\Local\TelDig Systems\SketchTool\Cache\
}

::bpc::
writeBellPrimClear()
{
	Send, bellprimclear.skt
}

utilCount()
{
CONTROLGET, TKLIST, LIST, col3,SysListView321, ahk_exe mobile.exe
if (errorlevel)
	msgbox % "There was a problem"
oUtility := StrSplit(tklist,"`n")
belllist := [], roglist := []
for i in oUtility
{
	if (oUtility[i] == "BCGN01") or if (oUtility[i] == "BCGN02")
		belllist.push(i)
	else if (oUtility[i] == "ROGYRK01") or if (oUtility[i] == "ROGSIM01")
		roglist.Push(i)
}
MsgBox % "You have " . belllist.length() . " Bell tickets and " . roglist.length() . " Rogers tickets left!"
}

sketchSearch()
{
	run, C:\Users\Cr\archived\autohotkey\sketchsearch.ahk
}

:::note::
runNotepad()
{
	Run, notepad.exe
}

::editts::
editTimesheet()
;opens timesheet for editing in Notepad
{
global today
if (fileexist("C:\Users\Cr\timesheet" today ".txt"))
	Run,  C:\Users\Cr\timesheet%today%.txt
else
	Run,  C:\Users\Cr\Desktop\archived\autohotkey\timesheet%today%.txt
}

::propfib::
insertProposedFibreLabel()
{
	loadImage("propfib.skt")
}

^f1::
;changes pole radius to 1m from 5m
sendevent, {f2}
sleep 150
send, {home}
sleep 150
send, {right}
sleep 150
send,{BackSpace}1{Enter}
return

#IfWinActive ahk_class #32770
:::rs::
;changes B.skt in save dialog to R.SKT
Send,{End}{Backspace 5}
Send, R.skt{Enter}
return
#IfWinActive

::chvar::
changeVariable(){
editedvar := Inputbox("Enter variable name")
newval := Inputbox("Enter new value for " . editedvar)
%editedvar% := newval
}

::shvar::
showVariableName(){
editedvar := Inputbox("Enter variable name")
MsgBox % %editedvar%
}
;ON THE GO HOTStringS
:::t1::
Send, %tempvar1%
return

:::t2::
Send, %tempvar2%
return

:::t3::
Send, %tempvar3%
return

:::t4::
Send, %tempvar4%
return

:::t5::
Send, %tempvar5%
return

;this is to learn how to draw with autohotkey

::gco::
CONTROLGET, LISTTEXT, LIST, , SYSLISTVIEW321, ahk_exe mobile.exe
rowlist := StrSplit(listtext, "`n")
MsgBox % obj2String(rowlist)
msgbox % rowlist.Count()
Loop,% rowlist.Count(){
	nc := getCoords()
	sleep(100)
	Send("{Down}")
}
mb(obj2String(nc))
return

getCoords(){
	;obtains coordinates
  global
	static nc := []
	focusTeldig()
	Send("{Enter}")
	sleep(300)
	clickLocationTab()
	getTicketData(number,street,intersection,intersection2,stationcode,diginfo,ticketnumber,town, ticketdata)
	fixstreetName()
	clickDigInfoTab()
	ControlGet,didata, List,, SysListView321, ahk_exe mobile.exe
	Loop, Parse, didata, `n
	{
		if instr(A_LoopField, "LATITUDE")
		{
			lat := substr(A_LoopField, 11)
		}
		if instr(A_LoopField, "LONGITUDE")
		{
			long := substr(A_LoopField, 13)
		}
	}
	if (number){
		numstring := number . " " . street . ", " . town
		;Send(numstring "{Enter}")
		sleep(100)
		nc.Push(numstring)
	}
	else 
	{
		ixnstring := street . "& " . intersection . ", " . town
		;Send(ixnstring "{Enter}")
		sleep(100)
		nc.Push(ixnstring)
	}
	Send("{Esc}")
	sleep,100
	Send("y")
	sleep(200)
	return nc
}
	;mb("latitude: " . lat . " longitude: " . long)
	;WinActivate(ahkexe("streets.exe"))
	;sleep 300
	; if (number){
	; 	Send(number . " " . street . ", " . town "{Enter}")
	; }
	; else 
	; {
	; 	Send(street . "& " . intersection . ", " . town "{Enter}")
	; }
	;Send("123z" "{Enter}")
	;sleep(400)
	;if (WinActive("Find"))
	;{
	;	Sleep(250)
	;	Control("TabRight",2,"SysTabControl321",AhkClass("#32770"))
	;	sleep(250)
		; ControlSetText("Edit1",lat,"Find")
		; sleep(250)
		; ControlSetText("Edit2",long,"Find")
		; Sleep(250)
		; ControlClick("Button1","Find")
		; sleep(250)
		; ControlClick("OK","Find")
		; sleep(200)
		; ; Send("{Tab 2}")
		; sleep(250)
		;mb()
		; Send("+{F10}")
		; sleep(260)
		; Send("n")
		; sleep(300)
		; if (number){
		; 	numstring := number . " " . street . ", " . town
		; 	;Send(numstring "{Enter}")
		; 	sleep(100)
		; 	nc.Push(numstring)
		; }
		; else 
		; {
		; 	ixnstring := street . "& " . intersection . ", " . town
		; 	;Send(ixnstring "{Enter}")
		; 	sleep(100)
		; 	nc.Push(ixnstring)
		; }
		; focusTeldig()
		; sleep(100)
		; 
		; ;Send("+{Tab 2}")
		;mb(obj2String(nc))
	
;saveSKTasJPEG() {

