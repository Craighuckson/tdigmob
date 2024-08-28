;TELDIG MASTER SCRIPT;

;TODO - ADD APTUM TO TIMESHEET, UPDATE PYTHON TIMESHEET AS WELL
; TAKE HOTSTRINGS OUT OF MULTIVIEWER.AHK AND ADD TO MAIN SCRIPT
; SPLIT SCRIPT INTO MAIN WORK SCRIPT AND THEN INDIVIDUAL PROGRAMS ETC

;FIXME - rogerslookup2,
;~ /* ;AUTOEXECUTE SECTION  */

;#NoEnv
#Persistent
ListLines, On
#MenuMaskKey,VK07
#include <findtext>
#include <DebugWindow>
;#include <V1TOV1FUNC>
;#include <libcon>
#include <json>
#include <Acc>
#include *i scrollbox.ahk
#include <UIA_Interface>
#include <UIA_Browser>
#include <AHKEZ>
#include <vis2>
;#Include <AHKEZ_Debug>
#Include <EntryForm>
;#Include Canvas.ahk
#Include <printstack>
;#Include multiviewer.ahk
#Include vpn.ahk
#Include .\aptumlookup.ahk
;#Include <chrome>
BlockInput, SendAndMouse
SetControlDelay, 50
Menu, Tray, Icon, %A_ScriptDir%\tico.png

;Iniread section to preload variables between resets
inifile := % A_ScriptDir . "\teldig.ini"
iniread, form, %inifile%, variables, form, ""
;iniread, stationcode, %inifile%, variables, stationcode, ""
iniread, bellmarked, %inifile%, variables, bellmarked, ""
iniread, bellclear, %inifile%, variables, bellclear, ""
iniread, rogersclear, %inifile%, variables, rogersclear, ""
iniread, rogersmarked, %inifile%, variables, rogersmarked, ""
iniread, locationdataobtained, %inifile%, variables, locationdataobtained, 0
iniread, street, %inifile%, variables, street, ""
iniread, intersection, %inifile%, variables, intersection, ""
iniread, currentpage, %inifile%, variables, currentpage, ""
iniread, totalpages, %inifile%, variables, totalpages, "

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

SKETCH_FOLDER := "C:\Users\" . A_UserName . "\Documents\"
TIMESHEET_FOLDER := "C:\Users\" . A_UserName . "\"
AHK_FOLDER := "C:\Users\" . A_UserName . "\Autohotkey\"
LOCATE_DRAW_FOLDER := ""

;setup of GUI for Bell primary sheet
Gui, 1: Add, CheckBox, x172 y80 w100 h30 vbellhydro, Bell Hydro
Gui, 1: Add, CheckBox, x172 y110 w100 h30 vbridgealert, Bridge Alert
Gui, 1: Add, CheckBox, x172 y140 w150 h30 vcableconduit, Cables May or May Not Be in Conduit
Gui, 1: Add, CheckBox, x172 y170 w100 h30 vhanddig, Hand Dig Only
Gui, 1: Add, CheckBox, x172 y200 w100 h30 vprioritycable, Priority Cable Present
Gui, 1: Add, CheckBox, x172 y230 w100 h30 vemptyconduit, Unable to Locate Empty Ducts
Gui, 1: Add, CheckBox, x172 y260 w100 h30 vunlocateable, Unlocatable Future Use
Gui, 1: Add, Button, x82 y310 w100 h30 , OK
Gui, 1: Add, Button, x272 y310 w100 h30 , Cancel
Gui, 1: Add, CheckBox, x72 y20 w100 h30 VCABLE, Cable
Gui, 1: Add, CheckBox, x272 y20 w100 h30 VCONDUIT, Conduit

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
Menu, mobile, Add, Radius Autofill, selectRadiusProjectType
Menu, Mobile, Add, Add List to Streets and Trips,writedirectionlist
Menu, Mobile, Add, Add New Timesheet &Entry, newtimesheetentry
Menu, Mobile, Add, Add To &Timesheet, addtotimesheet
Menu, Mobile, Add, Autofill CUA,autofillCUA
Menu, Mobile, Add, Create new Project, newproj
;Mobile menu definitions
Menu, Mobile, Add, Fill From EZDraw, fillFromEZDraw
Menu, Mobile, Add, Open EZDraw, openEZDraw
Menu, Mobile, Add, Finish and &Email, finishandemail
Menu, Mobile, Add, Show Ticket Picture, showTicketPictures
Menu, Mobile, Add, Load from Project, autoinsertSketches
Menu, mobile, Add, Open Sketch E&ditor, openSketchEditor
Menu, Mobile, Add, Load Clear Python Template, loadClearPyTemplate
Menu, Mobile,Add,Rogers Clear Form, rogersClearForm
Menu, Mobile, Add, Remove From Screening, removeFromScreening
Menu, mobile, Add, Reset Form&Var, resetformVar
Menu,Mobile,Add, Grade &QA, gradeQA
Menu,Mobile,Add, Autocomplete QA, AutoQA
Menu,mobile,Add, Search for Sketch, sketchSearch
Menu,mobile,Add, Clear multiple, clearMulti
Menu,mobile,Add, Open SketchTool &Config, SketchToolConfig
Menu,mobile,Add, Screen Tickets, screenTickets
Menu, forms, Add, Bell Auxilliary, 2buttonbaux
Menu, forms, Add, Bell Primary, 2buttonbprim
Menu, forms, Add, Rogers Auxilliary, 2buttonraux
Menu, forms, Add, Rogers Primary, 2buttonrprim
Menu, forms, Add, Load Telmax Primary, loadTelmaxPrimary
Menu, forms, Add, Load Telmax Auxilliary, loadTelmaxAuxilliary
Menu, drawingtools, Add, Line from Coords, Line
Menu, drawingtools, Add, Rect from Coords, Rect
Menu, drawingtools, Add , Add Template to Docs, addTemplateToDocs
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
Menu, ST, Add, Remove Checked, removeCHECKED
Menu, ST, Add, Remove Rogers Clear, RemoveRogersClear
Menu, ST, Add, Emergency, emergency
Menu, ST, Add, Save and Exit, 2buttonsaveandexit
Menu, ST, Add, HotString list, showHotStrings

;AUTOMATIC EVENT HANDLERS
MsgBox, Hello moto
;GLOBAL HOTKEYS

+^d::
dumpElements()
return

~CapsLock::
  capstate := GetKeyState("CapsLock", "T")
  if (capstate == 1)
    Notify("CapsLock ON")
  else
    Notify("CapsLock OFF")
return

~NumLock::
  numlock_state := GetKeyState("NumLock", "T")
  if (numlock_state == 1)
    Notify("NumLock ON")
  else
    Notify("NumLock OFF")
return

;OCR
#C::
  OCR()
return
; mobile menu

;SKETCHTOOL SPECIFIC HOTKEYS/BUTTON HANDLERS
#IfWinActive ahk_exe SKETCHTOOLAPPLICATION.EXE

  #D::
  ::dgarea::
    writeDigArea()
  return

  MButton::
    Menu, ST, Show
  return

  +::NumpadAdd
  -::NumpadSub

  ^t::
    putTimestamp()
  return

  ;SKETCHTOOL HOTSTRINGS

  ::autocua::
    autofillCUA()
  return

  WheelLeft::
  >::
    UIA_Interface().ElementFromHandle(WinExist("ahk_exe sketchtoolapplication.exe")).FindFirstByName("Page right").Click()
  return

  WheelRight::
  <::
    UIA_Interface().ElementFromHandle(WinExist("ahk_exe sketchtoolapplication.exe")).FindFirstByName("Page left").Click()
  return

#IfWinActive

;SKETCHTOOL FUNCTIONS

loadTelmaxPrimary()
{
  path := "telmaxprimary.skt"
  LoadImageNg(path)
}

loadTelmaxAuxilliary()
{
  path := "telmaxaux.skt"
  LoadImageNg(path)
}

autofillCUA()
{
  global totalpages

  setform()
  waitSTLoad()
  if (stationcode = "BCGN01") or if (stationcode = "BCGN02")
    loadImage("bell cua.skt")
  else
    loadImage("cua rogers.skt")
  Sleep 200
  CUASAVEEXIT()
  MsgBox, Done!
}

Line()
; opens the image called "line.skt", opens property menu in sketchtool then changes lines coordinates to x1, y1, x2, y2
{
  Inputbox, line, Line, Enter line coordinates separated by commmas
  x1 := StrSplit(line, ",")[1]
  y1 := StrSplit(line, ",")[2]
  x2 := StrSplit(line, ",")[3]
  y2 := StrSplit(line, ",")[4]
  loadImage("line.skt")
  Sleep 200
  accessProperties()
  Sleep 200
  Send, {Tab}{Tab}{Space}
  Sleep 200
  Send, %x1%,%y1%
  Sleep 200
  Send, {Tab}{Space}
  Sleep 200
  Send, %x2%,%y2%
  Send, {Enter}
}

Rect()
; opens the image called "rect.skt", opens property menu in sketchtool then changes rect coordinates to x, y, w, h
{
  Inputbox, rect, Rect, Enter rect coordinates separated by commmas
  x := StrSplit(rect, ",")[1]
  y := StrSplit(rect, ",")[2]
  w := StrSplit(rect, ",")[3]
  h := StrSplit(rect, ",")[4]
  loadImage("rect.skt")
  Sleep 200
  accessProperties()
  Sleep 200
  Send, {Tab 9}{Space}
  Sleep 200
  Send, %x%,%y%
  Sleep 200
  Send, {Tab}{Space}
  Sleep 200
  Send, %w%,%h%
  Send, {Enter}
}

bellPrimaryPoleAutofill()
{
  global
  bell_stickers()
  WinWaitClose, Please select all that apply
}

bellPrimaryAutofill()
{
  global bellclear
  focusSketchTool()
  if (useExisting() = "y")
  {
    autofillExistingSketch()
  }
  else
  {
    bellclear := InputBox("Ticket Clear? Y / N")
    if (bellclear = "y")
    {
      ST_SAVEEXIT()
    }
    else if (bellclear = "n")
    {
      bell_stickers()
      WinWaitClose, ahk_exe SketchToolApplication.exe
    }
    else
    {
      bellPrimaryAutofill()
    }
  }
  newPagePrompt()
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
  digarea["north"] := north
  digarea["south"] := south
  digarea["west"] := west
  digarea["east"] := east
  return digarea

}

isErrorNoSketchTemplate(path)
{

  if !FileExist(SKETCH_FOLDER . path)
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

removeRogersClear()
{
  Text:="|<>*134$67.s0700000DzwS03U00007zzjU1k00003zzzk0s00001k0zw0Q00000s07z0C00000Q03vU707k00C01xs3UDy00700yS1kDzU03U0T70sDVs01k0zXkQ70Q00zzzkwC3UD00TzysC73U3U0DzwQ7XVk1k070wC1tks0s03UD70QsQ0Q01k3nUDQD0C01s0xk3y70700Q0Cs0z1k7U0C07w0TUs3U0701y07kT3k03U0z01s7zk01k0C"

  if (ok:=FindText(311-150000, 384-150000, 311+150000, 384+150000, 0, 0, Text))
  {
    CoordMode, Mouse
    X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
    Click, %X%, %Y%
  }
  sleep 200
  Send, {Delete}
}

::qatc::
  SendINput, QA TEVIN - COMPLETE
return

::qanc::
  SendInput, QA NATHANIEL - COMPLETE
return

removeCHECKED()
{
  Click,435,95
  Send, {Delete}
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

enviClear()
{
  MsgBox,36,Clear?,Ticket Clear?
  focusSketchTool()
  ifMsgBox, Yes
  {
    enviClear := 1
    return enviClear
  }
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
  ;fixstreetName()
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

  if (form = "RA" || form = "EA" || form = "TA")
  {
    setTemplateText("RANBoundary.skt", north)
    setTemplateText("RASBoundary.skt", south)
    setTemplateText("RAWBoundary.skt", west)
    setTemplateText("RAEBoundary.skt", east)
  }
  else if (form = "EP" || form = "TP")
  {
    setTemplateText("NBoundaryenvi.skt",north)
    setTemplateText("SBoundaryenvi.skt",south)
    setTemplateTExt("WBoundaryenvi.skt",west)
    setTemplateText("EBoundaryenvi.skt",east)
  }
  else
  {
    setTemplateText("NBoundary.skt", north) ; ie HERE, this writes the dig area
    setTemplateText("SBoundary.skt", south)
    setTemplateText("WBoundary.skt", west)
    setTemplateText("EBoundary.skt", east)
  }
}

; @params stationcode:str returns bool
isTicketRogers(stationcode)
{
  return (stationcode = "ROGYRK01" or stationcode = "ROGSIM01")
}

writeRogersClearReason()
{
  clearreason := Inputbox("Clear reason","Regular (r)`nFTTH (f)`nClear For Fibre Only(c)")
  switch clearreason
  {
  case "r": loadImage("rogclear.skt")
  case "f": loadImage("ftth.skt")
  case "c": loadImage("exclusion agreement r.skt")
  }
}

; @params landbase:str, intdir:str returns void
setBLtoBLSketch(landbase,intdir)
{
  global
  if (intdir)
  {
    loadImage(landbase "CLTOBL" intdir ".skt")
    return cnc := false
  }
  else
  {
    ;~ switch choice
    ;~ {
    ;~ Case "i", "i": loadImage(landbase "BLTOBLI.SKT")
    ;~ Case "o", "o": loadImage(landbase "BLTOBLO.SKT")
    ;~ Case "nw", "nw": loadImage(landbase "BLTOBLNW.SKT")
    ;~ Case "se", "se": loadImage(landbase "BLTOBLSE.SKT")
    ;~ Case "single", "SINGLE": loadImage(landbase "BLTOBLSINGLE.SKT")
    ;~ Default: return
    ;~ }
    ;~ if (CableNearCurb())
    ;~ {
    ;~ moveCableToCurb(landbase)
    ;~ }
    cnc := CableNearCurb()
    if (cnc)
      loadImage(landbase "bltobl" choice "-c.skt")
    else
      loadImage(landbase "bltobl" choice)
    return cnc
  }
}

;------------------------------------------------------------------------------------------------------------------
; FUNCTION: CableNearCurb()
;
; PURPOSE:  Asks the user if the cable is near the curb and returns a boolean value based on the user's input.
;
; RETURNS:  Returns true if the cable is near the curb, false otherwise.
;
;------------------------------------------------------------------------------------------------------------------
CableNearCurb(input := "")
{
  Loop
  {
    Inputbox, bycurb, By Curb?, Is the cable by the curb? (y/n)
  }
  Until (bycurb = "y" || bycurb = "n")
  if (bycurb = "y")
    return true
  else
    return false
}

;------------------------------------------------------------------------------------------------------------------
; FUNCTION: moveCableToCurb(landbase)
;
; PURPOSE:  Moves the cable to the curb based on the landbase parameter.
;
; PARAMETERS:
;           landbase - A string representing the landbase direction ("n", "s", "e", or "w").
;
; RETURNS:  None.
;
;------------------------------------------------------------------------------------------------------------------
;~ moveCableToCurb(landbase)
;~ {
;~ switch landbase
;~ {
;~ case "n": cableToCurbN()
;~ case "s": cableToCurbS()
;~ case "e": cableToCurbE()
;~ case "w": cableToCurbW()
;~ }
;~ }

;MACRO FUNCTIONS
cableToCurbN()
{
  Loop, 1
  {
    SetTitleMatchMode, 2
    CoordMode, Mouse, Window
    tt = TelDig SketchTool
    WinWait, %tt%
    IfWinNotActive, %tt%,, WinActivate, %tt%
      Sleep, 711
    MouseClick, L, 1136, 175,,, D
    Sleep, 383
    MouseClick, L, 1120, 321,,, U
    Sleep, 265
    MouseClick, L, 688, 324
    Sleep, 125
    MouseClick, R, 688, 324
    Sleep, 992
    MouseClick, L, 731, 527
    Sleep, 484
    MouseClick, L, 701, 182
    Sleep, 695
    MouseClick, L, 666, 362
    Sleep, 101
    Send, {delete}
    Sleep, 422
    MouseClick, L, 664, 460
    Sleep, 484
    Send, {Delete}
    Sleep, 406
    MouseClick, L, 664, 437,,, D
    Sleep, 835
    MouseClick, L, 664, 473,,, U
    Sleep, 672
    MouseClick, L, 512, 429,,, D
    Sleep, 781
    MouseClick, L, 511, 466,,, U
    Sleep, 664
    MouseClick, L, 802, 430,,, D
    Sleep, 1468
    MouseClick, L, 802, 465,,, U
    Sleep, 1000
  }
}

cableToCurbS()
;s bltobl generated macro
{
  Loop, 1
  {
    SetTitleMatchMode, 2
    CoordMode, Mouse, Window
    tt = TelDig SketchTool
    WinWait, %tt%
    IfWinNotActive, %tt%,, WinActivate, %tt%
      Sleep, 555
    MouseClick, L, 1130, 191,,, D
    Sleep, 578
    MouseClick, L, 1155, 337,,, U
    Sleep, 250
    MouseClick, L, 683, 388
    MouseClick, R, 683, 388
    Sleep, 781
    MouseClick, L, 752, 601
    Sleep, 773
    MouseClick, L, 713, 168
    Sleep, 679
    MouseClick, L, 647, 284
    Sleep, 812
    Send, {Blind}{Delete}
    Sleep, 211
    MouseClick, L, 722, 450
    Sleep, 211
    Send, {Blind}{Delete}
    Sleep, 351
    MouseClick, L, 675, 324,,, D
    Sleep, 937
    MouseClick, L, 673, 280,,, U
    Sleep, 555
    MouseClick, L, 828, 334,,, D
    Sleep, 718
    MouseClick, L, 828, 293,,, U
    Sleep, 664
    MouseClick, L, 540, 330,,, D
    Sleep, 1101
    MouseClick, L, 538, 289,,, U
    Sleep, 1000
  }
}

cableToCurbE()
{
  Loop, 1
  {
    SetTitleMatchMode, 2
    CoordMode, Mouse, Window
    tt = TelDig SketchTool
    WinWait, %tt%
    IfWinNotActive, %tt%,, WinActivate, %tt%
      Sleep, 562
    MouseClick, L, 1129, 201,,, D
    Sleep, 562
    MouseClick, L, 1144, 369,,, U
    Sleep, 273
    MouseClick, L, 740, 454
    Sleep, 351
    MouseClick, R, 740, 454
    Sleep, 625
    MouseClick, L, 785, 321
    Sleep, 211
    MouseClick, L, 982, 417
    Sleep, 211
    MouseClick, L, 759, 373
    Sleep, 585
    Send, {Blind}{Delete}
    Sleep, 289
    MouseClick, L, 792, 348
    Sleep, 312
    Send, {Blind}{Delete}
    Sleep, 578
    MouseClick, L, 665, 357,,, D
    Sleep, 781
    MouseClick, L, 626, 359,,, U
    Sleep, 633
    MouseClick, L, 670, 253,,, D
    Sleep, 781
    MouseClick, L, 633, 253,,, U
    Sleep, 547
    MouseClick, L, 671, 500,,, D
    Sleep, 1187
    MouseClick, L, 634, 500,,, U
    Sleep, 1000
  }
}

cableToCurbW()
{
  Loop, 1
  {
    SetTitleMatchMode, 2
    CoordMode, Mouse, Window
    tt = TelDig SketchTool
    WinWait, %tt%
    IfWinNotActive, %tt%,, WinActivate, %tt%
      Sleep, 640
    MouseClick, L, 1133, 199,,, D
    Sleep, 609
    MouseClick, L, 1185, 376,,, U
    Sleep, 289
    MouseClick, L, 672, 397
    Sleep, 133
    MouseClick, R, 672, 397
    Sleep, 766
    MouseClick, L, 732, 604
    Sleep, 336
    MouseClick, L, 454, 408
    Sleep, 250
    MouseClick, L, 650, 349
    Sleep, 648
    Send, {Blind}{Delete}
    Sleep, 1359
    MouseClick, L, 702, 314
    Sleep, 109
    Send, {Blind}{Delete}
    Sleep, 562
    MouseClick, L, 755, 327,,, D
    Sleep, 1023
    MouseClick, L, 794, 325,,, U
    Sleep, 539
    MouseClick, L, 747, 230,,, D
    Sleep, 781
    MouseClick, L, 783, 230,,, U
    Sleep, 578
    MouseClick, L, 752, 484,,, D
    Sleep, 679
    MouseClick, L, 792, 486,,, U
    Sleep, 297
    MouseClick, L, 692, 482,,, D
    Sleep, 633
    MouseClick, L, 737, 482,,, U
    Sleep, 461
    MouseClick, L, 687, 222,,, D
    Sleep, 1125
    MouseClick, L, 726, 224,,, U
    Sleep, 406
    MouseClick, L, 735, 365,,, D
    Sleep, 617
    MouseClick, L, 780, 351,,, U
    Sleep, 1000
  }
}

;------------------------------------------------------------------
; setCornerDigArea()
;
; Sets the corner dig area based on the landbase and boundaries entered by the user.
;------------------------------------------------------------------
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

; Generates the dig area for a driveway to driveway sketch
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
  ;fixstreetName()
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
  StringLower,signs,signs
  if (signs = "y")
  {
    signdist := InputBox("Distance from curb? ")
  }

  switch landbase
  {
  Case "n":
    if (signs = "y")
    {
      north := signdist . " N/NCL " . street
    }
    else
    {
      north := "NPL " street
    }
    south := "NCL " street
    west := "ERE DW " num.1 " " street
    east := "ERE DW " num.2 " " street

  Case "nrc":
    if (signs == "y") {
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
    if (signs == "y") {
      south := signdist . " S/SCL " . street
    }
    else {
      south := "SPL " street
    }
    west := "ERE of DW" . num1 . " " . street
    east := "ERE of DW " . num.2 . " " . street

  Case "src":
    north := "NCL " street
    if (signs == "y") {
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
    if (signs == "y")
    {
      south := signdist . " W/WCL " . street
    }
    Else
      south := "WPL " street
    west := "NRE of DW " . num.1 . " " . street
    east := "NRE of DW " . num.2 . " " . street

  Case "e":
    north := "ECL " street
    if (signs == "y")
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
  ;fixstreetName()
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
    ;fixstreetName()

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
    ;fixstreetName()
    rclimit := InputBox("Crossing limit? (CL / PL ?)")
    rclimit := StrUpper(rclimit)
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
    ;fixstreetName()
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
    if (isTicketRogers(stationcode))
    {
        rclear := rogclear()
        if(rclear)
        {
            writeRogersClearReason()
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
    Loop
    {
        choice := InputBox("1.CL to Rear PL`n2.CL to Front Pl")
    }   Until choice in 1,2

    if (FileExist(A_MyDocuments "\" landbase "pltopl" choice ".skt"))
        loadImage(landbase "pltopl" choice ".skt")
    else
        loadImage(landbase "pltopl.skt")
}

setRogersclear()

setCornerSketch(landbase)
{
    global
    (bounds = "BL") ? loadImage(landbase "cornerbl.skt") : loadImage(landbase "corner.skt")
}

setRCSketch(landbase){
    global
    StringUpper,landbase,landbase
    if !FileExist(SKETCH_FOLDER . landbase "RC.skt")
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
    ;fixStreetName()
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
    ;fixStreetName()
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

; Waits for the image of the rotation tool to appear in SketchTool.
waitSTLoad()
{
    Text:="|<>*135$14.TwIka49n64kVax8tn08MA3w8"
    ; wait for image of rotation tool in ST
    while !(ok:=FindText(347-150000, 53-150000, 347+150000, 53+150000, 0, 0, Text))
        continue
}

; Writes the dig area for a Rogers Auxilliary (RA) form. Sets the text for the north, south, east, and west boundaries of the dig area using the appropriate templates.
writeRAdigarea()
{
    global
    setTemplateText("RANBoundary.skt",north)
    setTemplateText("RASBoundary.skt",south)
    setTemplateText("RAWBoundary.skt",west)
    setTemplateText("RAEBoundary.skt",east)
}

;SKETCHTOOL MODULES

autoinsertSketches(email = "n")
{
    global
    if !(project)
        project := []

    ;COMMENT EITHER THE NEXT TWO LINES OR THE FOLLOWING 2 LINES AT A TIME - NOT BOTH
    if !(projfile)
    {
        FileSelectFile, projfile,,%AHK_Folder%, Select project,
        units := Inputbox("Enter units")
        loop, Read, %projfile%
        {
            project.Push(A_LoopReadLine)
        }
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
        ;rogersunits := ["","1C"]
        addtotimesheet()
    /*         if (email == "n")
     *             FinishNoEmail()
     *         else
     *             finishemail()
     *         SetTimer,checkforNewTicket, 200 ;use this for looping
     */
}

projectSketch()
{
    ;global
    t := new Ticket()
    s := new Sketch()
    focusTeldig()
    clickLocationTab()
    t:= t.GetDataFromOneCallInfo()
    ;getTicketData()
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
        ;auto inserts street names

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

setOffsetLabel(landbase,cnc:=0)
{
    meas1 := setMeasurement()
    meas2 := setMeasurement()
    label := InputBox("Enter label for cable")
    StringUpper, label, label
    if (cnc != 0)
        files := ["meas1-c.skt","meas2-c.skt","cablelabel-c.skt"]
    else
        files := ["meas1.skt","meas2.skt","cablelabel.skt"]
    setTemplateText(landbase files[1],meas1)
    wait()
    setTemplateText(landbase files[2],meas2)
    wait()
    setTemplateText(landbase files[3], label)
}

getDigBoundaries()
{
    InputBox, digboundary,Boundaries?, 1 = Driveway to Driveway`n2 = BL to BL`n3 = Road Crossing `(FTTH`)`n4 = PL to PL`n5 = All PL`n6 = Street to Street`n7 = Corner`n8 = Short Gas`n9 = Long Gas,,,300
    return digboundary
}

isBellPrimary(form)
{
    if (form = "BP")
    return True
Else
    return False
}

;AUTOMATED FORM FILLER
;THIS NEEDS TO BE REFACTORED BIG TIME

sketchAutoFill()
{
    ;TODO eliminate use of global variables
    /* Form filling function. Auto chooses base form to sketch on based on ticket data given.

    */
    global

    setform()
    Notify("Getting form and form data...") ;TODO change with new form initialize
    waitSTLoad()
    if (isBellPrimary(form))
    {
        ;QUICK FILL FOR SINGLE VS PROJECT
        btickettype := Inputbox("Single or Project?")
        if btickettype in s,S,p,P
        {
            if (btickettype = "s")
            {
                totalpages := 2

                units := Inputbox("Enter units")
                primary_template := FileSelectFile(,A_MyDocuments,"Choose bell primary form to open")
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
                return
            }
            else if (btickettype = "p")
            {
                bellPrimaryAutofill()
                return
            }

            else
            {
                bellPrimaryAutofill()
                return
            }
        }
    }
    focusSketchTool()

    if (useExisting() = "y")
    {
        autofillExistingSketch()
        newPagePrompt()
    return ;autofill existing module
    }

;else if (getexisting = "n") ;this is where it gets tricky...
else
{
    writeDigArea()

    ; checks for alternate or regular dig areas and writes
    ;next section is essentially prebaked vs custom dig area/sketch
    if !(digboundary = "")
    {
        if(digboundary = "1")
        {
            setDWToDWSketch()
            setDWtext()
        }

        if(digboundary = "2")
        {
            ;~ Inputbox,ezd,ezdraw,EZDraw SKetch?
            ;~ if (ezd = "y") {
            ;~ insertEZDrawRP()
            ;~ }
            cnc := setBLtoBLSketch(landbase,intdir)
            if (!intdir)
                setOffsetLabel(landbase,cnc)
            setBLtext(landbase,intdir,xstreet,vstreet)
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
        if (stationCode = "ENVIN01")
        {
            enviClear := enviClear()
            if (enviClear)
            {
                loadImage("envi clear.skt")
                st_saveexit()
                newpagePrompt()
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
            Case "LD": insertEZDrawRP()
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
    return
}
}

setCustomDigArea(digarray)
{
    setTemplateText("Nboundary.skt",digarray[1])
    setTemplateText("Sboundary.skt",digarray[2])
    setTemplateText("Wboundary.skt",digarray[3])
    setTemplateText("Eboundary.skt",digarray[4])
}

;DIG AREA
;this function needs cleanup
writeDigArea()
{
    global
    digboundary := getDigBoundaries() ; asks for INT representing dig boundaries

    if (digboundary = "") ;no entry
    {
        getRegDA() ; asks line by line for dig box - returns north south east west
        wait()
        focusSketchTool()
        if (form == "RA" || form == "AA" || form == "EA" || form == "TA")
        {
            writeRAdigarea()
            clickselection()
            return
        }
        else if (form = "AP")
        {
            digarray := {(north):"Nboundaryapt.skt",(south):"sboundaryapt.skt",(west):"wboundaryapt.skt"
            ,(east):"eboundaryapt.skt"}
        }
        else if (form = "EP" || form == "TP")
        {
            digarray := {(north):"Nboundaryenvi.skt",(south):"sboundaryenvi.skt",(west):"wboundaryenvi.skt"
            ,(east):"eboundaryenvi.skt"}
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

newWriteDigArea()
{
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
;helpers for clear form

;MOBILE SPECIFIC BUTTON HANDLERS/HOTKEYS

#IfWinActive, Ticket list

    Tab::
        sleep 100
        ControlClick, syslistview321, ahk_exe mobile.exe
    return

    #ifwinactive ahk_exe mobile.exe

    ~Alt & ~Left::
        UIA_Interface().ElementFromHandle(WinExist("ahk_exe mobile.exe")).FindFirstByName("Drawings").Click()

    >::
        Sendinput, {Right 100}
    return

    <::
        Sendinput, {Left 100}
    return

    ^j::
        send,^{Left 2}
        UIA_Interface().ElementFromHandle(WinExist("ahk_exe mobile.exe")).FindFirstByName("Job no").Click()
    return

    ; f2::
    ; ticketDatatoJSON()
    ; return

    ^f10::
        CraigRPA.writeClearTemplate()
    return

    !f10::
        CraigRPA.ClearFromTemplate()
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

    ^f9::
        gradeQA()
    return

    ^f11::
        QA.Autocomplete()
        return

    autoQA()
    {
      QA.Autocomplete()
    }

    gradeQA()
    {
      QA.GradeQA()
    }

    F10::
        MsgBox, 4, Email, Email result to contractor?
        IfMsgBox, Yes
            autoinsertSketches()
        IfMsgBox, No
            autoinsertSketches("n")
    return

#IfWinActive

;MOBILE FUNCTIONS

setJobNumberto99()
{
    Sleep, 445
    Send, {Blind}{Alt Down}f{Alt Up}n
    Sleep, 148
    tt = Set job number ahk_class #32770
    WinWait, %tt%
    IfWinNotActive, %tt%,, WinActivate, %tt%
    Sleep, 335
    Send, {Blind}99{Enter}
    tt = TelDig Mobile - [Ticket list]
    WinWait, %tt%
    IfWinNotActive, %tt%,, WinActivate, %tt%
    Sleep, 1000
}

openEZDraw()
{
    Run, % LOCATE_DRAW_FOLDER
}

rogersClearForm()
{
    craigrpa.writecleartemplate()
}

SketchToolConfig()
{
    Run, explore "C:\Users\craig\AppData\Local\TelDig Systems\TelDig.Fusion.SketchTool.Launcher"
}

addressSearch()
{
    UIA_Interface().ElementFromHandle(WinExist("ahk_exe mobile.exe")).FindFirstByName("Street").Click()
  ;~ MouseGetPos, cx, cy
  ;~ Click, %cx%, 121
}

focusLV()
{
    MouseGetPos,cx,cy
    Click,%cx%,137
}

+^f2::
    makeJSON()
return

makeJSON()
{
    temp := "C:\Users\craig\Cr\Desktop"
    j := new JSON()
    tc := ControlGet("List","Count","syslistview321","ahk_exe mobile.exe")
    ;open ticket
    Loop, %tc%
    {
        sleep 500
        send("{Enter}")
        sleep 500
        ;get data
        td := Ticket.GetDataFromOneCallInfo()
        ;mb(obj2string(td))
        sleep 500
        folder := td.ticketnumber
        FileCreateDir, C:\Users\craigaig\Tickets\%folder%
        if (errorlevel) {
            MsgBox("Couldn't create directory")
            exit
        }
        sleep 500
        jval := j.Dump(td,,4)
        FileAppend, %jval%, C:\Users\craig\Tickets\%folder%\%folder%.json
        ;exit ticket
        Send, {Esc}
        sleep 500
        Send, y
        sleep 1000
        send, {down}
        sleep 500
    }

    mb("Done")
}

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

clearMulti(){
    ;load ticket
    CraigRPA.ClearFromTemplate()
    sleep 500
    ;Mobile.SelectPending()
    Mobile.FinishWithEmail()
    sleep 2000
    SetTimer,checkforNextTicket,200
}

checkforNextTicket() {

    Controlget, ticketNumbernew, line, 1, edit1, ahk_exe mobile.exe
    if(ticketnumber != ticketNumbernew)
    {
        clearMulti()
        ticketNumbernew := ""
    }
}

locationDataCheck()
{
    global
    while locationDataObtained = ""
    {
        ;clickLocationTab()
        getTicketData()
        worktype := getWorkType()
        locationDataObtained := 1
        return locationDataObtained
    }
}

newproj()
{
    Run, % "C:\Users\craig\archived\autohotkey\projectfile.ahk"
}

openSketchEditor()
{
    Run("C:\Users\craig\Documents\LibreAutomate\Main\exe\OpenSketchEditor\OpenSketchEditor.exe")
}

readClearTemplate()
{
    global
    FileRead, templatefile, C:\Users\craigaig\Documents\%ticketnumber%.txt
    linelist := StrSplit(templatefile, "`r`n")
    msgbox % linelist
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

resetformvar()
{
    global form
    global locationDataObtained
    global totalpages
    global currentpage
	global stationcode
    form := "", locationDataObtained := "", totalpages := "",currentpage := "", num := ""
	stationcode := ""
    MsgBox % "Form data has been reset!"
}

;assigns proper form based on staiton code
setForm()
{
    ;ticketdata := getticketdata(), stationCode := ticketdata.5
    global
    focusTeldig()
    ;move this to main routine
    locationDataCheck()
    uia := UIA_Interface()
    win := uia.ElementFromHandle(WinActive("A"))
    Loop
    {
        if (stationcode == "CCS" or stationcode == "")
        {
            Loop
            {
                InputBox, stationcode, Station Code, Enter Station Code
                StringUpper, stationcode,stationcode
                switch stationcode
                {
                    Case "BCGN01": Break
                    Case "ROGYRK01": Break
                    Case "APTUM01": Break
                    Case "ENVIN01": Break
                    Case "TLMXF01": Break
                    Default: continue
                }
            }
            continue
        }
        if (stationCode == "BCGN01" and form = "") or if (stationCode == "BCGN02" and form = "") or if (stationCode == "BAGN02" and form = "")
        {
            TrayTip,Form, Opening Bell Primary Form,5
            ;openForm("|<>*117$65.zj8DD44D64w8EEEF88XA90EUUUWEG2IG0V1114UY4gY13m3m9z899D24447W2EG+E4888844UYIU8EEEE88X8N0EyyyUEEsEHw", "BP")
            ;openBellPrimary()

            win.FindFirstByName("ui-btn").click()
            win.WaitElementExistByName("SKETCH_FORM")
            d := win.FindByPath("1.3.6.6.3.1.5.1").click()
            form := "BP"
            break
        }
        else if (stationCode == "BCGN01") or if (stationCode == "BCGN02") or if (stationCode == "BAGN02")
        {
            ;openForm("|<>*122$71.l13lVD0MEYTEG28n2E0kV8YUY4UZ4U1F2+91891/904W4AG2Tm2GHk948EYMUY4WY0F8Fl81189581yEWWE228m6E24n8YU44C44yA4wlxw","BA")
            ;openBellAux()
            win.FindFirstByName("ui-btn").click()
            win.WaitElementExistByName("SKETCH_FORM")
            d := win.FindByPath("1.3.6.6.3.1.6.1").click()
            form := "BA"
            break
        }
        else if (stationCode == "ROGYRK01" and form = "") or if (stationCode == "ROGSIM01" and form = "") or if (stationCode == "ROGPEL01" and form = "")
        {
            ;openForm("|<>*122$51.D33l1sTw+0MF880EWU2W91024I0YF880EWU4Xl1s22Y0WF880EIUDm91022W12F880EADM/lxw214","RP")
            ;openCATVPrimary()
            WinActivate, ahk_exe locateaccess.exe
            uib := win.FindByPath("1.61")
            uib.click()
            d := win.WaitElementExistByNameAndType("CABLE TV","hyperlink")
            form := "RP"
            d.click()
            break
        }
        else if (stationCode == "ROGYRK01") or if (stationCode == "ROGSIM01")
        {
            ;openForm("|<>*119$71.6xz7Y41wSD60N0EE88216FA4W0V0EE444WQC4120UU8894ccD241z0SEHlF8E48220UUYWI8U8E441118Yc90EE88216F8kPsUSEE41kVF000000000000000000T00000E","RA")
            WinActivate, ahk_exe locateaccess.exe
            uib := win.FindByPath("1.61")
            uib.click()
            d := win.WaitElementExistByNameAndType("SKETCH_FORM","hyperlink")
            form := "RA"
            d.click()

            ;openCATVAux()
            break
        }
        else if (stationCode == "APTUM01" and form = "")
        {
            ;openForm("|<>*135$46.D3kSS7Vt0FW90U8s22E4411U890EE460UYNt0EM22EY411U892EE450FW90U8nks7blsQU","AP")
            WinActivate, ahk_exe locateaccess.exe
            uib := win.FindByPath("1.61")
            uib.click()
            d := win.WaitElementExistByNameAndType("COGECO","hyperlink")
            d.click()
            form := "AP"
            ;openAptumPrimary()
            break
        }
        else if(stationCode == "APTUM01")
        {
            ;openForm("|<>*134$68.jTlt10T7XlUG0UUEE42AWMAU8E441118b3824110EEG9FHkV0Tk7Y4wIIU8E4411194d824110EEG9+G0UUEE42AWFay87Y410Q8IF00000000000000007k00002","AA")
            WinActivate, ahk_exe locateaccess.exe
            uib := win.FindByPath("1.61")
            uib.click()
            d := win.WaitElementExistByNameAndType("SKETCH_FORM", "hyperlink")
            d.click()
            form := "AA"
            break
        }
        else if(stationCode == "ENVIN01" and form = "")
        {
            ;openForm("|<>*141$60.wkgD32SzkVUkYG32E48lUcYG2WE48mUgYG2mE49GwYWW2GS49GUWWW2+E45+UWWW2+E46AUVVW26E46AyUV722T42AU","EP")
            WinActivate, ahk_exe locateaccess.exe
            uib := win.FindByPath("1.61")
            uib.click()
            d := win.WaitElementExistByNameAndType("ENVI NETWORKS", "hyperlink")
            d.click()
            form := "EP"
            break
        }
        else if (stationCode == "ENVIN01")
        {
            ;openForm("|<>*119$71.6xz7Y41wSD60N0EE88216FA4W0V0EE444WQC4120UU8894ccD241z0SEHlF8E48220UUYWI8U8E441118Yc90EE88216F8kPsUSEE41kVF000000000000000000T00000E","EA")
            WinActivate, ahk_exe locateaccess.exe
            uib := win.FindByPath("1.61")
            uib.click()
            d:= win.WaitElementExistByNameAndType("SKETCH_FORM", "hyperlink")
            d.click()
            form := "EA"
            break
        }
        else if (stationcode == "TLMXF01" and form = "")
          {
            WinActivate, ahk_exe locateaccess.exe
            uib := win.FindByPath("1.61")
            uib.click()
            d := win.WaitElementExistByNameAndType("TELMAX", "hyperlink")
            d.click()
            form := "TP"
            break
          }
        else if (stationcode == "TLMXF01")
          {
            WinActivate, ahk_exe locateaccess.exe
            uib := win.FindByPath("1.61")
            uib.click()
            win.WaitElementExistByNameAndType("SKETCH_FORM", "hyperlink")
            d := win.FindFirstByNameAndType("SKETCH_FORM", "hyperlink")
            d.click()
            form := "TA"
            break
          }
        else
        {
            MsgBox % "Please select form manually and press OK to continue"
            break
        }
    }
}

HasVal(haystack,needle) {
    if !(IsObject(haystack)) || (haystack.Length() = 0)
        return 0
    for index,value in haystack
    {
        if (value = needle)
            return index
    }
return 0
}

;MOBILE MODULES

getticketpicture:
    run,getticketpicture.ahk
return

;GUI BUTTON Labels

DAButtonOK:
    Gui,Da: Submit
    Gui, Da: Destroy
return

clformButtonSubmit:
    Gui, Submit
    Gui, Destroy
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

;gui glabels

;mapinfo proviewer button handlers

#IfWinActive, ahk_exe mapinfor.exe

!^f::
aptumLookup()
return

^a::
    asBuiltLookup()
return

asBuiltLookup()
{
    ;Run, C:\Users\craigaig\teldig\beanfield.pyw
    global filechoice
    InputBox, filename,,Enter file name
    dir := "C:\Users\craigaig\As Builts\Aptum As Builts\Toronto_Mississauga"
    fileList := ""
    Loop, Files, %dir%\*%filename%*.*, R
    {
        fileList .= A_LoopFileName "|"
    }
    Gui, AB: Add, Listbox,w600 r10 vfilechoice, %fileList%
    Gui, AB: Add, Button, gChooseFile, Choose File
    Gui, AB: Show, AutoSize Center
    return

    ABGuiClose:
    Gui, Destroy
    filechoice := ""
    return

    ChooseFile:
    Gui, AB:Submit
    Run, C:\Users\craigaig\As Builts\Aptum As Builts\Toronto_Mississauga\%filechoice%
    filechoice := ""
    Gui, Destroy
    return
}

ChooseFile()
{
    Gui, Submit
    Run, C:\Users\craigaig\As Builts\Aptum As Builts\Toronto_Mississauga\%filechoice%
}

#IfWinActive

;Clear input procedure
makeTemplateFromPy()
{
    Run, rogers_clear_input.py
}

;Ctrl - F8 to run tests
^f8::
    t := new Ticket()
    t.town := "Brooklin"
    Multiviewer.Activate()
    ;    MultiViewer.BypassUpdate()
    Multiviewer.setProperTerritory(t.town)
    return

;basic testing function
Assert(a,b,params*)
{
    if (a != b)
    {
        MsgBox("Test failed - " a " != " b)
    }
    else {
        MsgBox("Test passed")
    }
}

qaautofill()
{

}

;CLASS DEFINITIONS

class LocateDrawInterOp
{
  Activate()
  {
    WinActivate, EZ Draw
    WinMaximize, EZ Draw
  }

  ;returns str - note if present takes template
  CheckForNote(template)
  {
    ;check if template contains a *
    if (InStr(template, "*"))
      {
        return StrSplit(template,",")[7]
      }
  }

  OpenTemplate(template) ;returns none
  {
    ;an automation macro to open a template in ezdraw
    this.Activate()
    SetTitleMatchMode, 2
    CoordMode, Mouse, Window

    tt = EZ Draw ahk_class TkTopLevel
    WinWait, %tt%
    IfWinNotActive, %tt%,, WinActivate, %tt%

    Sleep, 633

    MouseClick, R, 505, 322

    Sleep, 1687

    Send, {Blind}{Down}{Down}

    Sleep, 781

    Send, {Enter}

    tt = Enter BL string
    WinWait, %tt%
    IfWinNotActive, %tt%,, WinActivate, %tt%

    Sleep, 734

    Send, {Blind}{Tab}

    Sleep, 1297

    Send, %template%

    Sleep, 609

    Send, {Blind}{Enter}

    Sleep, 109

    Sleep, 1000

  }

  CloseTemplate()
  {
    this.Activate()
    SetTitleMatchMode, 2
    CoordMode, Mouse, Window

    tt = EZ Draw ahk_class TkTopLevel
    WinWait, %tt%
    IfWinNotActive, %tt%,, WinActivate, %tt%

    Sleep, 383

    Send, {Blind}w

    Sleep, 117

    tt = Erase entire image? ahk_class TkTopLevel
    WinWait, %tt%
    IfWinNotActive, %tt%,, WinActivate, %tt%

    Sleep, 351

    Send, {Blind}{Tab}{Space}

    Sleep, 179

    tt = EZ Draw ahk_class TkTopLevel
    WinWait, %tt%
    IfWinNotActive, %tt%,, WinActivate, %tt%

    Sleep, 1000

  }

  Main(template)
  ;gets template opens and saves drawing in EZ Draw as needed
  ; return
  {

    this.Activate()
    this.OpenTemplate(template)
    templateArray := StrSplit(template,",")
    street_name := templateArray[1]
    house1 := templateArray[4]
    house2 := templateArray[5]
    savefile := Format("{} {} TO {} tmx.png", street_name, house1, house2)
    clipboard := savefile
    WinWaitActive, Save
    note := this.CheckForNote(template)
    if (note == "")
      {
        Send, {Tab}{Space} ;saves image
        WinWaitActive, Saved
        Notify("paste from clipboard")
        Send, {Tab}{Space} ; close dialog
      }
    else
      {
        Send, {Tab}{Tab}{Space} ;choose no to save image
        msgbox % note ;inform about change to be made
        this.Activate()
        WinWaitActive, Save
        Notify("Please make changes to drawing and save.")
        WinWaitClose, Save ; waits until changes made and sketch saved

      }
    this.CloseTemplate() ;wipes drawing to be able to start next
    ;restore window
    WinActivate, ahk_exe locateaccess.exe
    return savefile
     ;still need to

   }

   Test()
   {
     ;temporary test runner
   }
}

fillfromEzDraw()
{
  LocateDrawInterOp.Main()
}

class MultiViewer
{
    Activate()
    {
      activateMultiviewer()
    }

    BypassUpdate()
    {
      WinWaitActive, Select datasets to update
      ControlClick, Cancel, Select datasets to update
      WinWaitActive, Datasets Have Expired
      ControlClick, Proceed, Datasets Have Expired
    }

    CheckTerritory()
    {
      ; if "GN01" in window title then return "Whitchurch-Stouffville". if "GE01" in window title then return "Brooklin"
      if (WinExist("ahk_exe lacmultiviewer.exe", "GN01"))
      {
        return "GN01"
      }
      else if (WinExist("ahk_exe lacmultiviewer.exe","GE01"))
      {
        return "GE01"
      }
      else
      {
        return "Unknown"
      }
    }

    setProperTerritory(town)
    {
      if (town = "Whitchurch-Stouffville")
        {
          if (this.CheckTerritory() != "GN01")
          {
            this.Activate()
            WinWaitActive, ahk_exe lacmultiviewer.exe
            ControlClick, T, ahk_exe lacmultiviewer.exe
            Sleep 500
            ;use uiautomation to select GN01
            uia := UIA_Interface()
            msgbox % uia
            win := uia.ElementFromHandle(WinExist("Territory"), false)
            win.WaitElementExistByName("GN01").Click(,2)
            WinWaitActive, Territory:GN01
            this.territory := "GN01"
          }

      }
      else if (town = "Brooklin")
        {
          if (this.CheckTerritory() != "GE01")
            {
              this.Activate()
              WinWaitActive, ahk_exe lacmultiviewer.exe
              ControlClick, T, ahk_exe lacmultiviewer.exe
              Sleep 500
              ;use uiautomation to select GE01
              uia := UIA_Interface()
              win := uia.ElementFromHandle(WinExist("Territory"), false)
              win.WaitElementExistByName("GE01").Click(,2)
              WinWaitActive, Territory:GE01
              this.territory := "GE01"
            }
        }
    }

    asBuiltLookup()
    ; get DSA# from user with inputbox, check for and open the pdf file in C:\Users\craigaig\As Builts\stouffville as builts that contains DSA#
    {
      InputBox, dsa, Enter DSA#, DSA#
      app := "C:\Users\craigaig\AppData\Local\SumatraPDF\SumatraPDF.exe"
      dir := "C:\Users\craig\As Builts\stouffville as builts"
      Loop, Files, %dir%\*%dsa%*.*, R
      {
          Run, open %dir%\%A_LoopFileName%
      }
    }

}

#IfWinActive ahk_exe lacmultiviewer.exe
^f::
    MultiViewer.asBuiltLookup()
    return
#IfWinActive

class Go360
{

    ZoomIn()
    {

        SetTitleMatchMode, 2
        CoordMode, Mouse, Window
        tt = Go360 Rogers Viewer 3.0.0.24 - Google Chrome ahk_class Chrome_WidgetWin_1
        WinWait, %tt%
        IfWinNotActive, %tt%,, WinActivate, %tt%
            Sleep, 1014
        MouseClick, L, 31, 186
        Sleep, 1000
    }

    ZoomOut()
    {
        SetTitleMatchMode, 2
        CoordMode, Mouse, Window
        tt = Go360 Rogers Viewer 3.0.0.24 - Google Chrome ahk_class Chrome_WidgetWin_1
        WinWait, %tt%
        IfWinNotActive, %tt%,, WinActivate, %tt%
            Sleep, 733
        MouseClick, L, 35, 310
        Sleep, 1000
    }
}

#IfWinActive, ahk_exe locateaccess.exe
:::ats::
    CraigRpa.AutomateTelmaxSketch()
    return

class CraigRPA {

    today:= A_DD . " " . A_MM . " " . A_YYYY

    __ClearTemplateExists(Ticket)
    {
        if !(FileExist(A_MyDocuments . "\" . Ticket.ticketnumber . "*.*")) {
            MsgBox("No template for this ticket")
            Mobile.Cancel()
            return false
        }
        return True
    }

    __FirstPageExists(Ticket)
    {
        ticketnumber := Ticket.ticketnumber
        ticketpage1 := A_MyDocuments "\" ticketnumber "-1.txt"
        if !(FileExist(ticketpage1)) {
            MsgBox("Couldn't find page 1 for this ticket")
            Mobile.Cancel()
            return false
        }
        return True
    }

    ClearFromTemplate(completeOnSite:=false,t:="") {

        s := new Sketch
        if (completeOnSite == false) {
            t := new Ticket
            t.GetDataFromOneCallInfo()
        }

        ;checks for existence of template
        if (this.__ClearTemplateExists(t) == false)
            return

        ;start by reading page 1
        currentsketchpage := 1
        ticketnumber := t.ticketnumber

        ;quits if page 1 for this ticket is not found
        if (this.__FirstPageExists(t) == false)
            return

        ;loops through this routine until all pages in template are read
        Loop {
            currentsketchfile := A_MyDocuments "\" ticketnumber "-" currentsketchpage ".txt"
            FileReadLine,currentpage,% currentsketchfile ,1
            FileReadLine,totalpages,% currentsketchfile,2
            FileReadLine,units,% currentsketchfile,3
            FileReadLine,clearreason, % currentsketchfile,4
            FileReadLine,north,% currentsketchfile,5
            FileReadLine,south,% currentsketchfile,6
            FileReadLine,west,% currentsketchfile,7
            FileReadLine,east,% currentsketchfile,8
            FileReadLine,saveFileName,% currentsketchfile,9

            ;init
            Notify("Creating the Form")
            t.form := t.GetFormType(t)
            ;Mobile.SelectDrawingsTab()
            sleep 250
            Mobile.SelectDrawingForm(t.form)
            sleep 500
            ;this is put in to slow down the action...
            SketchTool.WaitUntilSketchToolReady()

            ;dig area
            dbarray := {"N":north,"S":south,"W":west,"E":east}
            Notify("Creating Dig Area")
            for k,v in dbarray {
                if (t.form = "EP" || t.form = "TP")
                    s.WriteTemplateText(k . "Boundaryenvi.skt", v)
                else if (t.form = "AP")
                    s.WriteTemplateText(k . "boundaryapt.skt", v)
                else if (t.form = "RA") || (t.form = "AA") || (t.form = "EA" || t.form = "TA")
                    s.WriteTemplateText("ra" . k . "boundary.skt", v)
                else
                    s.WriteTemplateText(k . "boundary.skt", v)
                sleep 500
            }

            ;MOVED CLEAR STAMP TO HERE
            if (t.form = "RP" || t.form = "RA")
                s.LoadImage(t.GetClearStamp(clearreason),false)
            else if (t.form = "EP") || (t.form = "EA")
                s.LoadImage("envi clear.skt",false)
            else if (t.form = "AP") || (t.form = "AA")
                s.LoadImage("aptumclear.skt",false)
            else if (t.form = "TP" || t.form = "TA")
                s.LoadImage("telmaxclear.skt",false)

            ;SAVE HERE TO AVOID PROBLEMS WITH REUSE
            Notify("Saving image")
            s.SaveImage(saveFileName)

            Notify("Completing rest of form")
            ;if this is the Rogers primary sheet, the current page is NOT put on the sketch
            if (currentpage > 1)
                s.WriteTemplateText("currentpage.skt",currentpage)
            sleep 500

            ;location of total pages differs for RA and RP envi and beanfield do not have total pages on first sheet
            if (t.form = "EP" || t.form = "AP" || t.form = "TP")
                sleep 50
            else
                s.WriteTemplateText(t.form = "RA" ? "totalpages.skt" : "RPtotalpages.skt",totalpages)
            sleep 500

            ;write units only on first page
            if (currentpage = 1)
                s.WriteTemplateText("units.skt",units)

            ;date is only written on the first page
            if (t.form = "RP" || t.form = "EP" || t.form = "AP" || t.form = "TP")
                s.WriteTemplateText("rogersPrimarydate.skt",A_YYYY "-" A_MM "-" A_DD)
            sleep 500

            ;writes in additional legend details / name / id depending on which form is current
            if (t.form = "RP" || t.form = "EP")
                s.LoadImage("catv primary.skt",false)
            else if (t.form = "AP")
                s.LoadImage("aptumprimary.skt",false)
            else if (t.form = "AA")
                s.LoadImage("aptumaux.skt",false)
            else if (t.form = "TP")
                s.LoadImage("telmaxprimary.skt",false)
            else if (t.form = "TA")
                s.LoadImage("telmaxaux.skt",false)
            else
                s.LoadImage("rogersaux.skt",false)

            sleep 500
            SketchTool.SubmitAndExit()
            focusTeldig()

            ;break out if done
            if (currentpage >= totalpages) {
                break
            }
            else {
                sleep 700
                currentsketchpage ++
            }
        }

        ;MsgBox, Press Ok to write to timesheet
        SplashImage,,,,Writing to timesheet
        if (t.form = "RP" || t.form = "RA")
            t.WriteUnitsToTimesheet(units,t.form)
        else
            addtotimesheet()
        t:="",s:=""
        SplashImage,Off
    }

    GetDigArea(template) ;retuns dig area object
    {
      ;template is separated by commas, split first 5 fields into street,landbase,choice,num1,num2
      fields := StrSplit(template, ",")
      street := Format("{:U}", fields[1])
      landbase := fields[2]
      choice := fields[3]
      num1 := fields[4]
      num2 := fields[5]
      ;blatant code reuse - sorry!

      Switch landbase ;folded this next section because its huge
      {
      Case "n":
          ;default is choice i
          north := "NBL " num1 " " street
          south := "NCL " street
          west := "EBL " num1 " " street
          east := "WBL " num2 " " street
          if(choice = "o")
          {
          west := "WBL " num1 " " street
          east := "EBL " num2 " " street
          }
          if(choice = "nw"){
          west := "WBL " num1 " " street
          }
          if(choice = "se"){
          east := "EBL " num2 " " street
          }
      Case "s":
          north := "SCL " street
          south := "SBL " num1 " " street
          west := "EBL " num1 " " street
          east := "WBL " num2 " " street
          if(choice = "o")
          {
          west := "WBL " num1 " " street
          east := "EBL " num2 " " street
          }
          if(choice = "nw"){
          west := "WBL " num1 " " street
          }
          if(choice = "se"){
          east := "EBL " num2 " " street
          }
      Case "w":
          north := "SBL " num1 " " street
          south := "NBL " num2 " " street
          west := "WBL " num1 " " street
          east := "WCL " street
          if(choice = "o"){
          north := "NBL " num1 " " street
          south := "SBL " num2 " " street
          }
          if(choice = "nw"){
          north := "NBL " num1 " " street
          }
          if(choice = "se"){
          south := "SBL " num2 " "street
          }
      Case "e":
          north := "SBL " num1 " " street
          south := "NBL " num2 " " street
          west := "ECL " street
          east := "EBL " num1 " " street
          if(choice = "o"){
          north := "NBL " num1 " " street
          south := "SBL " num2 " " street
          }
          if(choice = "nw"){
          north := "NBL " num1 " " street
          }
          if(choice = "se"){
          south := "SBL " num2 " "street
          }
      }
      return {"north":north, "south":south, "west":west, "east":east}
    }

    GetTemplateString()
    {
      Inputbox, template, Enter template string
      return template
    }

    AutomateTelmaxSketch()
    {
        ; a non interactive routine that does a telmax ticket
        ;maybe best to start here then go eto locatedrawinterop?
        ;this is a non interactive routine that does a telmax ticket template := this.GetTemplateString()
        global today
        template := this.GetTemplateString()
        WinActivate, ahk_exe locateaccess.exe
        digArea := this.GetDigArea(template)
        north := digArea.north
        south := digArea.south
        west := digArea.west
        east := digArea.east
        ;MsgBox("Dig Area is " north "`n" south "`n" west "`n" east)
        data := getTicketData()
        sleep 250
        number := data.number
        street := data.street
        stationcode := data.stationcode
        ticketnumber := data.ticketnumber
        if !(ticketnumber)
          ticketnumber := Inputbox("Enter Ticket Number")
        ;write t.ticketnumber and dig area to "telmaxtemp.txt"
        FileDelete,telmaxtemp.txt
        FileAppend(ticketnumber . "`n" . north "`n" . south . "`n" . west . "`n" . east . "`n","telmaxtemp.txt")
        png := LocateDrawInterop.Main(template)
        svfile := StrSplit(png, ".")[1] . ".skt"
        notify(svfile)
        FileAppend, % png, telmaxtemp.txt
        setform()
        form := "TP"
        sleep 250
        SketchTool.WaitUntilSketchToolReady()
        sleep 250
        dbarray := {"N":north,"S":south,"W":west,"E":east}
        Notify("Creating Dig Area")
        for k,v in dbarray {
            setTemplateText(k . "boundaryenvi.skt", v)
            sleep 300
        }
        insertezdrawrp(png)
        sleep 500
        Click, 663, 209
        sleep 500
        SketchTool.SaveImage(svfile)
        sleep 500
        enviunits := "1M"
        totalpages := 1
        currentpage := 1
        loadImage("telmaxprimary.skt")
        (InStr(enviunits,"M")) ? loadImageNG("telmaxpaint.skt") :
        setTemplateText("units.skt",enviunits)
        setTemplateText("rogersPrimaryDate.skt",A_YYYY . "-" . A_MM . "-" . A_DD)
        setTemplateText("RPtotalpages.skt",currentpage . "/" . totalpages)
        SketchTool.SubmitAndExit()
        focusTeldig()
        locationDataObtained := ""
    ;timesheetentry := ticketnumber . "," . number . " " . street  . ",,,,,TELMAX 1 MARKED" . "`n"
    ;tslocation := "C:\Users\craig\timesheet" today ".txt"
    ; FileAppend, %timesheetentry%, %tslocation%

    /*
        A form filling module that asks questions then prefills the locate sheet

        Page numbers
        Units
        Dig Area
        Form specific data

        These can be obtained via questionnaire

        Initialize the proper form

        Drawing / warnings: Can be autogenerated or manually added

        Save the form

    */

      ;obtain necessary info for ticket object
    }

    SelectTab(name)
    {
      uia := UIA_Interface()
      win := uia.ElementByHandle(WinExist("A"))
      win.FindFirstByName(name).click()
    }

    WaitForImage(image)
    {
        Loop
        {
            ImageSearch(foundx,foundy,0,0,A_ScreenWidth,A_ScreenHeight,image)
            if (ErrorLevel = 0)
            {
                break
            }
            MouseMove,%foundx%,%foundy%
        }
    }

    FixStreetName(street)
    {
        return RegExReplace(street,"^ | \(REGIONAL.*| \(COUNTY.*| \(HIGHW.*|\*\**.*")
    }

    FixTownName(town)
    {
        return RegExReplace(town,"\,.*")
    }

    writeClearTemplate()
    {
        IfWinExist, ahk_exe mobile.exe
            WinActivate, ahk_exe mobile.exe
        else
            WinActivate, ahk_exe LocateAccess.exe
        t := new Ticket()
        t.GetDataFromOneCallInfo()
        cleardata := t.GetClearData()
        MsgBox % cleardata.Length()
        MsgBox % obj2string(cleardata)
        ticketnumber := t.ticketnumber
        currentpage := cleardata[1]
        ;delete file if previous runthrough still present
        FileDelete(A_MyDocuments . "\" . ticketnumber . "-" . currentpage . ".txt")
        for k,v in cleardata {
            FileAppend(v . "`n",A_MyDocuments . "\" . ticketnumber . "-" . currentpage . ".txt")
        }
        if !(FileExist(A_MyDocuments . "\" . ticketnumber . "-" . currentpage . ".txt")) {
            MsgBox("Something went wrong")
        }
        else {
            MsgBox("File saved to " . A_MyDocuments . "\" . ticketnumber . "-" . currentpage . ".txt")
        }
        MsgBox,4,Complete?, Finish now?
        IfMsgbox, Yes
        {
            completeOnSite := true
            this.ClearFromTemplate(completeOnSite,t)
            return
        }
        else
            t := ""
    }

}

QAPass()
{
    tk := new Ticket()
    tk.GetDataFromOneCallInfo()
    focusSketchTool()
    loadImageNG(A_MyDocuments . "\qayes.skt")
    QA.AddToTimesheet(tk,getLocator())
    gui,pf:submit
    gui,pf:destroy
}

QAFail()
{
    tk := new Ticket()
    tk.GetDataFromOneCallInfo()
    focusSketchTool()
    loadImageNG(A_MyDocuments . "\qan.skt")
    QA.AddToTimesheet(tk,getLocator())
    gui,pf:submit
    gui,pf:destroy
}

class QA {

    locator := ""

    Autocomplete()
    ;autocompletes the QA form
    {
        tk := new Ticket()
        locator := getLocator()
        tk.GetDataFromOneCallInfo()
        tk.form := tk.GetFormType()
        Notify(tk.Ticketnumber)
        if (tk.number == tk.street)
            tk.number := ""
        file := tk.ticketNumber . "-" . tk.number . " " .  tk.street
        Notify(file)
        QA.Start()
        focussketchtool()
        removeCHECKED()
        Notify(tk.form)
        this.AddProperCheckmark(tk)

        picSave(locator,file)
        this.LogResult(locator,tk.ticketNumber,tk.number,tk.street,"PASS")
        this.AddToTimesheet(tk,locator)
        sleep 700
        ControlClick("OK","ahk_exe sketchtoolapplication.exe")
        focusTeldig()
    }

    AddProperCheckmark(tk)
    {
        if (tk.form = "RP" || tk.form = "RA")
            loadImageNG(A_MyDocuments . "\qayes.skt")
        else if (tk.form = "AP" || tk.form = "AA")
            loadImageNG(A_MyDocuments . "\aptumqayes.skt")
        else if (tk.form = "EP")
            loadImageNG(A_MyDocuments . "\enviqayes.skt")
        else
            loadImageNG(A_MyDocuments . "\qayes.skt")
    }

    ;method that adds a line to timesheet with the following in comments section : "QA COMPLETE - {locator}"
    AddToTimesheet(ticket, locator)
    {
      today := A_DD . " " . A_MM . " " . A_YYYY
      Notify("Adding to timesheet")
      FileAppend, % ticket.ticketnumber "," ticket.number " " ticket.street ",,,,,,,QA " locator "`n", C:\Users\craig\timesheet%today%.txt
    }

    Finalize()
    {
        focusSketchTool()
        SketchTool.waitCloseDialogBox()
        Msgbox("Press OK to continue")
        ControlClick("OK","ahk_exe sketchtoolapplication.exe")
        focusTeldig()
    }

    LogResult(locator,ticketnumber, number, street,status) {
        qalogfile := "C:\Users\craig\qa\" . locator . "\" . locator . "qalog.txt"
        f := fileopen(qalogfile,"a")
        f.WriteLine(Format("{1}-{2}-{3},{4},{5} {6},{7}", A_MMMM, A_DD, A_YYYY, ticketnumber, number, street,status))
        f.Close()
    }

    showPassFailGUI()
    {
        Gui,pf: Add, Text, x198 y20 w70 h20 , Locate Result:
        Gui,pf: Add, Button,gqapass x52 y70 w100 h30 , &PASS
        Gui, pf: Add, Button,gqaerror x182 y70 w100 h30 , &ERROR
        Gui,pf: Add, Button,gqafail x312 y70 w100 h30 , &FAIL
        ; Generated using SmartGUI Creator for SciTE
        Gui,pf: Show, w470 h168,PASS/FAIL/ERROR
        WinWaitClose,PASS/FAIL/ERROR
    }

    GetResult(){
      ;use an inputbox to ask for pass ("p") or fail ("f"). return the result
      results := {"p": "PASS", "pass" : "PASS", "e": "ERROR", "error": "ERROR", "f": "FAIL", "fail": "FAIL"}
      Loop {
        Inputbox, result, "Result", "(P)ass / (E)rror / (F)ail?"
        StringLower, result, result
      }
      Until result in p,pass,f,fail,e,error
      return results[result]
    }

    GradeQA()
    {
      ;open the sketch, ask pass or fail, add the appropriate marking, save a copy, add to timesheet with locator
      t := new Ticket()
      t.GetDataFromOneCallInfo()
      t.form := t.GetFormType()
      this.Start()
      status := this.GetResult()
      if (status = "PASS") || (status = "ERROR")
      {
        this.AddProperCheckmark(t)
      }
      else if (status = "FAIL")
      {
        loadImageNG(A_MyDocuments . "\qan.skt")
      }
      locator := getLocator()
      if t.number == t.street
        t.number := ""
      this.AddToTimesheet(t,locator)
      this.LogResult(locator,t.ticketnumber,t.number,t.street,status)
      picSave(locator,t.ticketnumber . "-" . t.number . " " . t.street)
      this.Finalize()
    }

    Start()
    {
        focusTeldig()
        editSketch()
        SketchTool.WaitUntilSketchToolReady()
    }
}

screenTickets()
{
    s := new Screening()
    s.Main()
}

removeFromScreening()
{
    s := new Screening()
    s.RemoveFromScreening()
}

changeToAnalysed()
{
    uia := uia_interface()
    win := uia.ElementFromHandle()
    win.FindFirstBy("AutomationId=TicketOrigin.TicketStatusID").ControlClick()
    Send, A
    win.WaitElementExist("Value=ANALYSED")
    SendInput, {Enter}
    sleep 1000
}

saveNoEmail()
{
    uia := UIA_Interface()
     uia.ElementFromHandle().FindFirstByName("Save").click()
     uia.ElementFromHandle().WaitElementExistByNameandType("No","Button")
     uia.ElementFromHandle().FindFirstByNameandType("No","Button").click()
 }

class Screening {

  Main()
  {
    ;this.checkForMapMode()
    ;this.Setup()
    ;sleep 1500
    if !(this.stillScreening()) {
      return
    }
    ;if !(Winexist("ahk_exe mapinfor.exe"))
    ;{
    ;activateMapInfo()
    ;setFindParams()
    ;WinActivate("ahk_exe locateaccess.exe")
    ;}

    Loop,
    {
      if !(this.stillScreening())
      {
        return
      }
      this.openFirstTicket()
      this.ViewImages()
      ;choice loop (inner)
      Loop
        {
        InputBox, choice, Make a selection, 1 = Open records at address`n2 = Remove from screening`n3 = Need Sketch or Meet`n4 = Clear Ticket`n5= Quit
        switch choice
        {
            case 1:
            recordsLookup()

            case 2:
            this.RemoveFromScreening()
            break

            Case 3:
            MsgBox % "Not yet implemented"

            Case 4:
            CraigRPA.writeClearTemplate()
            break

            case 5:
            break
        }
        if (choice == 5)
            return
        }
    }
}

  RemoveFromScreening()
  {

    /*     SetTitleMatchMode, 2
     *     CoordMode, Mouse, Window
     *     tt = LocateAccess - Cable Control Systems ahk_class Chrome_WidgetWin_1
     *     WinWait, %tt%
     *     IfWinNotActive, %tt%,, WinActivate, %tt%
     *     MouseClick, L, 653, 174
     *     Sleep, 562
     *     MouseClick, L, 551, 209
     *     Sleep, 609
     *     MouseClick, L, 1088, 684
     *     Sleep, 679
     *     MouseClick, L, 860, 464
     *     Sleep, 1000
     */
        changetoAnalysed()
        saveNoEmail()

  }

  StillScreening()
  {
    Notify("Checking Screening status")
    WinActivate, ahk_exe locateaccess.exe
    screen := uia_interface().ElementFromHandle().WaitElementExistByName("filtered",0x4,2,True,5000)

    if !(screen) {
      MsgBox % "Element not found"
      return False
    }
    Notify(obj2string(screen.CurrentName))
    if (instr(screen.CurrentName, "0 filtered") == 2)
      return False
    else
      return True
  }

  OpenFirstTicket()
  {
    Notify("Opening ticket")
    Click("354,211")
    Sleep(1000)
  }

  Setup() {
    WinActivate("ahk_exe locateaccess.exe")
    uia := uia_interface()
    win := uia.ElementFromHandle()
    fil := win.FindFirstByName("Filter...").SetFocus()
    sleep 1000
    SendInput, screening
    sleep 1000
  }

  ;write a function that uses imagesearch to find the "map button in locateaccess and click it

  CheckForMapMode()
  {
    Winactivate,ahk_exe locateaccess.exe
    ;this checks for the presence of grid button and clicks it if necessary
    Text:="|<>*158$20.Tzza489V22TzzbzztV22MEUaAANzzyMEUc"

    if (ok:=FindText(1323-150000, 98-150000, 1323+150000, 98+150000, 0, 0, Text))
    {

      CoordMode, Mouse
      X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
      Click, %X%, %Y%

      sleep, 1500
      ; now click on map button

      uia := uia_interface()
      win := uia.ElementFromHandle()
      map := win.WaitElementExistByName("Map")
      map.click()
    }
    Else return
  }

  ViewImages()
  {
    uia := uia_interface()
    win := uia.GetChromiumContentElement()
    p := win.FindFirstByNameAndType("Original","text",0x4,2,True).Click()
  }

}

; !f3::
; Screening.Main()
; return
#ifwinactive, ahk_exe locateaccess.exe
^f2::
Mobile.SelectPending()
return
#IfWinActive

#IfWinActive, ahk_exe mobile.exe
^f2::
    Mobile.FinishNoEmail()
return

class Mobile
{

    SelectNewForm()
    {
        clickNewForm()
    }
    SelectDrawingsTab()
    {
        CraigRPA.SelectTab(3)
    }

    SelectLocationTab()
    {
        CraigRPA.SelectTab(1)
    }

    SelectDigInfoTab()
    {
        CraigRPA.SelectTab(2)
    }

    SelectDrawingForm(form)
    {
        uia := UIA_Interface()
        win := uia.ElementFromHandle(WinActive("A"))
        win.FindFirstByName("ui-btn").click()
        switch form {
        case "RP":
            d := win.WaitElementExistByNameAndType("CABLE TV","hyperlink")
            d.click()

        case "RA", "AA", "EA", "TA":
            d := win.WaitElementExistByNameAndType("SKETCH_FORM","hyperlink")
            d.click()

        case "AP":
            d := win.WaitElementExistByNameAndType("COGECO","hyperlink")
            d.click()

        case "EP":
            d := win.WaitElementExistByNameAndType("ENVI NETWORKS","hyperlink")
            d.click()

        case "TP":
            d := win.WaitElementExistByNameAndType("TELMAX","hyperlink")
            d.click()

        default:
            MsgBox("Please select form manually")
        }
        sleep 500
    }

    SelectPending()
    {
        ;CONTROL, choose, 3, ComboBox1, ahk_exe mobile.exe
        ; UIA := UIA_Interface()
        ; win := uia.ElementFromHandle()
        ; r := win.FindFirstBy("AutomationID=TicketOrigin.TicketStatusID").Click()
        ; sleep 500

        ; ImageSearch,foundx,foundy,0,0,1366,768,pending.png
        ; if (errorlevel == 1) {
        ;     Notify("No image found")
        ;     return false
        ; }
        ; else {
        ;
        ;    MouseMove, %foundx%, %foundy%
        ;     MouseClick,L, %foundx%,%foundy%
        ;     return true
        ; }
        WinActivate("ahk_exe locateaccess.exe")
        Run("C:\Users\craigaig\OneDrive\Documents\LibreAutomate\Main\exe\ChangeToPending\ChangeToPending.exe")

    }

    ClickOK()
    {
        MouseClick("L",1079,695)
        sleep 300
      ;UIA_Interface().ElementFromHandle(WinExist("ahk_exe mobile.exe")).FindFirstByName("OK").Click()
    }

    Cancel()
    {
        MouseClick("L",1244,702)
        sleep 300
        Send("Y")
      ;UIA_Interface().ElementFromHandle(WinExist("ahk_exe mobile.exe")).FindFirstByName("Cancel").Click()
    }

    FinishWithEmail()
    {
        this.ClickOK()
      ;UIA_Interface().ElementFromHandle(WinExist("ahk_class #32770")).FindFirstByName("Yes").Click()
      ;WinWaitActive,Paper output to contractor
      ;UIA_Interface().ElementFromHandle(WinExist("Paper output to contractor")).FindFirstByName("OK").Click()
      ;WinWaitActive("ahk_class #32770")
      ;Send("y")
      ;WinWaitActive("Paper output to contractor")
      ;Send("{Enter}")
    }

    FinishNoEmail()
    {
        this.ClickOK()
      ;UIA_Interface().ElementFromHandle(WinExist("ahk_class #32770")).FindFirstByName("No").Click()
      ;WinWaitActive("ahk_class #32770")
      ;Send("n")

    }
}

class SketchTool {
    WaitUntilSketchToolReady()
    {
        waitSketchTool()
        waitSTLoad()
    }

    WaitDialogBox()
    {
        WinWaitActive("ahk_class #32770 ahk_exe sketchtoolapplication.exe")
    }

    WaitCloseDialogBox()
    {
        WinWaitClose("ahk_class #32770 ahk_exe sketchtoolapplication.exe")
    }

    OpenImageDialog()
    {

        ;~ UIA := UIA_Interface()
        ;~ WinActivate, ahk_exe sketchtool.exe
        ;~ tdEl := UIA.ElementFromHandle(WinExist("ahk_exe sketchtoolapplication.exe"))
        ;~ tdEl.FindFirstByName("Insert image from file...").Click()
        ;~ uia := "",tdEl := ""
        SendInput("!i")
        Sleep(50)
        SendInput("{Down 8}")
        Sleep(50)
        SendInput("{Enter}")
    }

    OpenSaveDialog()
    {
        Send("!f{Enter}")
      ;~ UIA := UIA_Interface()
      ;~ stEl := UIA.ElementFromHandle(WinExist("ahk_exe sketchtoolapplication.exe"))
      ;~ stEl.FindFirstByName("File").Click()
      ;~ stEl.FindFirstByName("Export...").Click()
    }

    LoadImage(filename,ungroup := true)
    {
        this.OpenImageDialog()
        this.WaitDialogBox()
        Send(filename)
        Send("{Enter}")
        ;~ UIA := UIA_Interface()
        ;~ dlgEl := UIA.ElementFromHandle(WinExist("ahk_class #32770"))
        ;~ fneditEl := dlgEl.FindByPath(3.1).SetValue(filename)
        ;~ dlgEl.FindByPath(5).Click()
        this.WaitCloseDialogBox()
        if (ungroup = true)
        {
            send("!i{Down}{Enter}")
          ;stEl := UIA.ElementFromHandle(WinExist("ahk_exe sketchtoolapplication.exe"))
          ;imageEl := stEl.FindFirstByNameAndType("Image","MenuItem").Click()
          ;stEl.FindFirstByName("Ungroup").Click()

        }
    }

    SubmitAndExit()
    {
        ControlClick("OK","ahk_exe sketchtoolapplication.exe")
      ;UIA_Interface().ElementFromHandle(WinExist("ahk_exe sketchtoolapplication.exe")).FindFirstByName("OK").Click()
    }

    SaveImage(filename := "")
    {
        this.OpenSaveDialog()
        this.WaitDialogBox()
        if (filename != "")
        {
            send(filename)
            Send("{Enter}")
            ;dlgEl := UIA_Interface().ElementFromHandle(WinExist("ahk_class #32770"))
            ;dlgEl.FindFirstByNameAndType("File name:","Edit").SetValue(filename)
            ;dlgEl.FindFirstByNameAndType("Save","Button").Click()
            this.waitCloseDialogBox()
        }
        else
        {
            this.WaitCloseDialogBox()
        }
    }
}

class Ticket
{

    __New()
    {
        return this
    }

    HasData()
    {
        if (this.street)
            return true
        Else
            return false
    }

    GetClearStamp(clearreason)
    {
        if (clearreason = 1)
            return "rogclear.skt"
        else if (clearreason = 2)
            return "ftth.skt"
        else if (clearreason = 3)
            return "exclusion agreement r.skt"
        else if (clearreason = 4)
            return "hvclear.skt"
    }

    HandleBlankStationCode(stationcode)
    {
      if (stationcode == "CCS" or stationcode == "")
        {
            Loop
            {
                InputBox, stationcode, Station Code, Enter Station Code
                StringUpper, stationcode,stationcode
                switch stationcode
                {
                    Case "BCGN01": Break
                    Case "ROGYRK01": Break
                    Case "APTUM01": Break
                    Case "ENVIN01": Break
                    Case "TLMXF01": Break
                    Default: continue
                }
            }
        }
      return stationcode
    }

    GetDataFromOneCallInfo()
    {
        if (this.HasData() = false) {

          ladatapath := "C:\Users\craig\AppData\Local\TelDigFusion.Data\data\"
          uia := UIA_Interface()
          win := uia.ElementFromHandle(WinExist("A"))
          doc := win.FindFirstByNameAndType("LocateAccess - Cable Control Systems","Document").Value
          a := StrSplit(doc,"/")
          subdir := a.8 . "_" . a.9
          stationcode := a.9
          ladatapath .= subdir
          ;file loop needs full pattern similar to dir cmd
          Loop, Files, %ladatapath%\*.txt, R
          {
              file := A_LoopFileLongPath
          }
          if (stationcode == "ROGYRK01")
          {
              FileReadLine,number,%file%,32
              FileReadLine,street,%file%,34
              FileReadLine,intersection,%file%,35
              FileReadLine,intersection2,%file%,36
              FileReadLine,digInfo,%file%,64
              FileReadLine,ticketnumber,%file%,4
              FileReadLine,town,%file%,30

              number := StrReplace(number,"UR_NO_CIVIC_INITI::")
              street := StrReplace(street,"UR_NOM_ARTER_PRINC::")
              intersection := StrReplace(intersection,"UR_NOM_ARTER_INTER_1::")
              intersection2 := StrReplace(intersection2,"UR_NOM_ARTER_INTER_2::")
              digInfo := StrReplace(diginfo,"UR_INFO_ADDIT_TROU::")
              ticketnumber := StrReplace(ticketnumber,"UR_ID_REQUE::")
              town := StrReplace(town,"UR_NOM_TESSE_1::")
          }

          else if (stationcode == "TLMXF01")
            {
              filepath := file
              file := FileOpen(filepath,"r")
              while !file.AtEOF()
                {
                  line := file.ReadLine()

                  if (A_Index = 32)
                    number := line
                  else if (A_Index = 34)
                    street := line
                  else if (A_Index = 35)
                    intersection := line
                  else if (A_Index = 36)
                    intersection2 := line
                  else if (A_Index = 64)
                    digInfo := line
                  else if (A_Index = 4)
                    ticketnumber := line
                  else if (A_Index = 30)
                    town := line
                }
              file.Close()

              number := StrReplace(number,"UR_NO_CIVIC_INITI::")
              street := StrReplace(street,"UR_NOM_ARTER_PRINC::")
              intersection := StrReplace(intersection,"UR_NOM_ARTER_INTER_1::")
              intersection2 := StrReplace(intersection2,"UR_NOM_ARTER_INTER_2::")
              digInfo := StrReplace(diginfo,"UR_INFO_ADDIT_TROU::")
              ticketnumber := StrReplace(ticketnumber,"UR_ID_REQUE::")
              town := StrReplace(town,"UR_NOM_TESSE_1::")

            }

          else if (stationcode == "APTUM01")
          {
              FileRead,aptfile,%file%
              lines := StrSplit(aptfile,"`n")
              for lineidx, line in lines {
                  if (Instr(line,"Address")) {
                      n := RegExReplace(line,".*:.")
                  }
                  number := Trim(RegExReplace(n,",.*")," `n`r")
                  street := Trim(RegExReplace(n,".*,.")," `n`r")

                  if (Instr(line,"Intersecting Street 1")) {
                      intersection := Trim(RegExReplace(line,".*:.")," `n`r")
                  }
                  if (Instr(line,"Intersecting Street 2")) {
                      intersection2 := Trim(RegExReplace(line,".*:.")," `n`r")
                  }
                  if (Instr(line,"REQUEST #:")) {
                      ticketnumber := Trim(RegExReplace(line,".*:.")," `n`r")
                  }
                  if (Instr(line,"Region/County")) {
                      town := Trim(RegExReplace(line,".*:.")," `n`r")
                  }
              }
          }
          else if (stationcode := "ENVIN01")
            {
                FileReadLine,number,%file%,63
                FileReadLine,street,%file%,67
                FileReadLine,intersection,%file%,69
                FileReadLine,intersection2,%file%,71
                FileReadLine,digInfo,%file%,127
                FileReadLine,ticketnumber,%file%,7
                FileReadLine,town,%file%,59
                number := StrReplace(number,"UR_NO_CIVIC_INITI::")
                street := StrReplace(street,"UR_NOM_ARTER_PRINC::")
                intersection := StrReplace(intersection,"UR_NOM_ARTER_INTER_1::")
                intersection2 := StrReplace(intersection2,"UR_NOM_ARTER_INTER_2::")
                digInfo := StrReplace(diginfo,"UR_INFO_ADDIT_TROU::")
                ticketnumber := StrReplace(ticketnumber,"UR_ID_REQUE::")
                town := StrReplace(town,"UR_NOM_TESSE_1::")
            }

            else
              {
                    stationcode := win.FindFirstBy("AutomationId=TicketUtility.StationCode").Value
                    ticketnumber := win.FindFirstBy("AutomationId=Ticket.TicketNumber").Value
                    address := win.FindFirstBy("AutomationId=Ticket.Address").Value
                    RegExMatch(address, "^\d+", number)
                    ;street is everything after the first space after the last number
                    street := RegExReplace(address, ".*\d\s(.*)", "$1")
                    intersection := win.FindFirstBy("AutomationId=Ticket.Intersection1").Value
                    intersection2 := win.FindFirstBy("AutomationId=Ticket.Intersection2").Value
              }

            this.number := number
            this.street := CraigRpa.FixStreetName(street)
            this.intersection := CraigRPA.FixStreetName(intersection)
            this.intersection2 := CraigRPA.FixStreetName(intersection2)
            this.stationCode := stationCode
            this.ticketNumber := ticketNumber
            this.digInfo := digInfo
            this.town := CraigRPA.FixTownName(town)
            return this
        }
    }

    GetClearData()
    {
        static currentpage,totalpages,units,digareatype,clearreason,editnorth,editsouth,editwest,editeast,savefile
        Gui, clform:Add, Text, x22 y20 w70 h20 , Current Page:
        Gui, clform:Add, Text, x22 y50 w70 h20 , Total Pages:
        Gui, clform:Add, Text, x22 y80 w70 h20 , Units:
        Gui, clform:Add, Edit, x102 y20 w80 h20 vcurrentpage, 1
        Gui, clform:Add, Edit, x102 y50 w80 h20 vtotalpages, 1
        Gui, clform:Add, Edit, x102 y80 w80 h20 vunits, 1C
        Gui, clform:Add, Text, x22 y110 w80 h20 , Dig Area Type:
        Gui, clform:Add, Radio,checked x102 y110 w90 h20 Group vdigareatype, Manual
        Gui, clform:Add, Radio,gwatchdaradio x202 y110 w110 h20 , Private Property
        Gui, clform:Add, Text, x22 y140 w80 h20, Clear Reason:
        Gui, clform:Add, Radio,checked x102 y140 w110 h20 Group vclearreason, Regular
        Gui, clform:Add, Radio, x202 y140 w110 h20,FTTH
        Gui, clform:Add, Radio,x322 y140 w110 h20,Fibre Only
        Gui, clform:Add, Radio,x422 y140 w110 h20,Hydro Vac
        Gui, clform:Add, Text, x22 y170 w70 h30 , North:
        Gui, clform:Add, Text, x22 y210 w70 h30 , South:
        Gui, clform:Add, Text, x22 y250 w70 h30 , West:
        Gui, clform:Add, Text, x22 y290 w70 h30 , East:
        Gui, clform:Add, Edit,Uppercase x102 y170 w350 h20 veditnorth,
        Gui, clform:Add, Edit, Uppercase x102 y210 w350 h20 veditsouth,
        Gui, clform:Add, Edit, Uppercase x102 y250 w350 h20 veditwest,
        Gui, clform:Add, Edit, Uppercase x102 y290 w350 h20 vediteast,
        Gui, clform:Add, Text, x22 y330 w80 h20 , Save File Name
        Gui, clform:Add, Edit, Uppercase x102 y330 w350 h20 vsaveFile,
        Gui, clform:Add, Button, x187 y360 w100 h30 , Submit
        Gui, clform:Show,x643 y8 w600 h421, Clear Locate Form Creator
        WinWaitClose, Clear Locate Form Creator
        cleardata := [currentpage, totalpages, units, clearreason, editnorth, editsouth, editwest, editeast, saveFile]
        return cleardata

        watchDARadio:
            north := "NPL " . this.number . " " . this.street
            south := "SPL " this.number " " this.street
            west := "WPL " this.number " " this.street
            east := "EPL " this.number " " this.street
            GuiControl, clform:Text, Edit4,%north%
            GuiControl, clform:Text, Edit5,%south%
            GuiControl, clform:Text, Edit6,%west%
            GuiControl, clform:Text, Edit7,%east%
            editnorth := north
            editsouth := south
            editwest := west
            editeast := east
        return

        GuiClose:
        gui, clform: Destroy
        return

    }

    ;returns string representing auxilliary for particular utility
    ForceAuxilliary()

    {
        if (this.stationCode = "ROGYRK01")
            return "RA"
        else if (this.stationCode = "ROGSIM01")
            return "RA"
        else
            return "BA"
    }

    ;Determines which form will be used for drawing, returns Str
    GetFormType()
    {
        if !(this.stationcode)
        {
            Throw Exception("No object data",-1)
        }

        if (this.form)
        {
            if (Instr(this.stationcode,"ROG"))
                return "RA"
            if (Instr(this.stationcode,"BC"))
                return "BA"
            if (Instr(this.stationcode,"BA"))
                return "BA"
            if (Instr(this.stationcode,"APT"))
                return "AA"
            if (Instr(this.stationcode,"ENV"))
                return "EA"
            if (Instr(this.stationcode,"TLMX"))
                return "TA"
            else
                throw Exception("Can't open form - no station code",1)
        }
        else
        {
            if (InStr(this.stationcode,"ROG"))
                return "RP"

            else if (Instr(this.stationCode,"BC"))
                return "BP"

            else if(Instr(this.stationCode,"BA"))
                return "BP"

            else if(Instr(this.stationCode,"APT"))
                return "AP"

            else if (Instr(this.stationCode,"ENV"))
                return "EP"

            else if (Instr(this.stationCode,"TLMX"))
                return "TP"

            else
                throw Exception("Can't open form - no station code",1)

        }
    }

    WriteUnitsToTimesheet(units,form)
    {
        today:= A_DD . " " . A_MM . " " . A_YYYY
        SplashImage,,,,Adding Units to Timesheet
        switch form
        {
            case "RP","RA":
                timesheetEntry := this.ticketnumber "," this.number " " this.street ",," units ",,,`n"
            case "AP","AA":
                timesheetEntry := this.ticketnumber "," this.street ",,,,,APTUM " . units . "`n"
            case "EP","EA":
                timesheetEntry := this.ticketnumber "," this.street ",,,,,ENVI " . units . "`n"
            case "TP","TA":
                timesheetEntry := this.ticketnumber "," this.street ",,,,,TELMAX " . units . "`n"
        }
        timesheetLocation := "C:\Users\craig\timesheet" today ".txt"
        FileAppend, %timesheetEntry%, %timesheetLocation%
        SplashImage, Off
        if (ErrorLevel)
            msgbox, No entry added

        }
    }

;msgbox, Wrote:`n%timesheetEntry%`nto %timesheetLocation%

class Sketch extends Sketchtool
{

    __New(landbase:=""){
    }

    ;returns an integer representing digboundary
    GetDigType()
    {
    return this.digtype := GetDigBoundaries()
    }

    ;returns a digarea object(north,south,east,west)
    getDigArea(){
        return this.digarea := getRegDA()
    }

    GetForm(Ticket){
        return Ticket.GetFormType()
    }

    ;Base routine to start a new sketch form
    Initialize(Ticket)
    {
        Ticket.GetDataFromOneCallInfo()
        Mobile.SelectDrawingsTab()
        Mobile.SelectNewForm()
        Mobile.SelectDrawingForm(Ticket.GetFormType())
        SketchTool.WaitUntilSketchToolReady()
    }

    ;writes dig area to sketch
    putDigArea(form){

    /*
    accepts a dig area object(north, south, west, east)
            */
        setTemplateText(form = "RA" ? "RANBoundary.skt":"NBoundary.skt",this.digarea.north)
        setTemplateText(form = "RA" ? "RASBoundary.skt":"SBoundary.skt",this.digarea.south)
        setTemplateText(form = "RA" ? "RAWBoundary.skt":"WBoundary.skt",this.digarea.west)
        setTemplateText(form = "RA" ? "RAEBoundary.skt":"EBoundary.skt",this.digarea.east)
    }

    WriteTemplateText(template, text)
    {
        SketchTool.LoadImage(template,false)
        Send("{F2}")
        Sleep(200)
        SendInput(text)
        Sleep(50)
        Send("{Enter}")
        Sleep(200)
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

isBellClear()
{
    Loop
    {
        Inputbox,bellClear,Is Bell Clear?
        if bellClear in y,Y
            return True
        Else
            return False
    }
}

boreholeAutoFill()
{
    global

    locationDataCheck()
    setForm()
    waitSTLoad()
    if (useExisting() = "y")
    {
        autofillExistingSketch()
        WinWaitClose, ahk_exe SketchToolApplication.exe
    }
    Else
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

    locationDataCheck()
    setForm()
    if (useExisting() = "y")
        autofillExistingSketch()
    else
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

useExisting()
{
    global

    Loop
    {
        Inputbox, openExisting, Open existing sketch?
    }
    Until openExisting in y,Y,n,N
    return openExisting
}

;radius dig area
#IfWinActive AHK_EXE MOBILE.EXE
    +F12::
    ::RAF::
        selectRadiusProjectType()
    return
#IfWinActive

selectRadiusProjectType(){
    InputBox, type, Type, Boreholes = b`nPoles = p`nTrees = r`nPeds = x`nTransformer = t
    Switch type
    {
        Case "b": boreholeAutoFill()
        Case "p": poleAutoFill()
        Case "r": treeAutoFill()
        Case "x": pedAutoFill()
        Case "t": transformerAutoFill()
    Default : return

}
}

transformerAutoFill()
{
    global

    locationDataCheck()
    setForm()
    waitSTLoad()
    if (form = "BP")
    {
        bellPrimaryPoleAutofill()
        WinWaitClose("ahk_exe Sketchtoolapplication.exe")
        if (currentpage < totalpages)
            transformerAutoFill()
    }
    if (useExisting() = "y")
	{
		autofillExistingSketch()
		WinWaitClose("ahk_exe Sketchtoolapplication.exe")
		if (currentpage < totalpages)
                transformerAutoFill()
	}

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
}
^F12::
    sptreeAutofill()
return

sptreeAutofill()
{
    global

    locationDataCheck()
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

checkforTreeTemplateFile(ticketnumber)
{
    if (FileExist(A_MyDocuments . "\" . ticketnumber ".txt")){
        return True
    }
    else
        return False
}

treeSketchFromTemplate(treefile)
{
    global
    Loop {

        for key,val in {north:2, south:3, west:4, east: 5, treetype:6, street:7, landbase:8, number:9, cabloc:10, meas1:11, meas2:12, label:13, label2:14, filename:15}
        ;double deref here to initialize new variables
        {
          %key% := FileReadLine(treefile,val)
        }

        key := "", val := ""

        clickdrawingtab()
        setForm()
        waitSTLoad()

        if (cabloc = 3)
        {
            labels := [meas1,meas2,label,label2]
        }
        else
        {
            labels := [meas1,label]
        }

        rogersunits := "1M"
        tda := [["NBoundary.skt",north], ["SBoundary.skt", south], ["WBoundary.skt",west], ["EBoundary.skt", east], ["units.skt", rogersunits] ]
        for i in tda {
          setTemplateText(tda[i][1], tda[i][2])
        }
        loadImageNG(treeSketchBuilder(landbase, cabloc))
        setTreeLabels(labels,street,cabloc,landbase,treetype,number)
        SketchTool.SaveImage(filename)
        for template,text in {"units.skt":rogersunits, "totalpages.skt":1, "rogersPrimarydate.skt": A_YYYY "-" A_MM "-" A_DD}
        {
          setTemplateText(template,text)
        }
        loadImage("catv primary.skt")
        sleep 500
        SketchTool.SubmitAndExit()
        focusTeldig()
        Mobile.SelectLocationTab()
        addtotimesheet()
        sleep 500
        ;Mobile.SelectPending()
        sleep 2000
        finishemail()
        ControlGet, ticketnumbernew, line,1,edit1,ahk_exe mobile.exe
        if(ticketnumber != ticketnumbernew)
        {
            ticketnumbernew := ""
            stationcode := ""
            north := ""
            south := ""
            west := ""
            east := ""
            treetype := ""
            street := ""
            landbase := ""
            number := ""
            cabloc := ""
            meas1 :=""
            meas2 := ""
            label := ""
            label2 := ""
            filename := ""
            form := ""
            treeAutoFill()
        }
    }
}

treeGui()
{
  global ticketnumber
  tform := "-c 'Tree Entry Form'"
  taddress := "-p 'Tree Address' -in E -o Uppercase"
  tstreet := "-p Street -in E -o Uppercase"
  tlandbase := "-p Landbase -in E Uppercase"
  tnumber := "-p 'House Number' -in E"
  tposition := "-p Position -in E -cb '1=curb side,2=property side,3=both'"
  tmeas1 := "-p 'Measurement 1' -in E"
  tmeas2 := "-p 'Measurement 2' -in E"
  tlabel1 := "-p 'Label 1' -in E Uppercase"
  tlabel2 := "-p 'Label 2' -in E Uppercase"
  tsavefile := "-p 'Save filename' -in E Uppercase"
  treeform := EntryForm(tform, taddress, tstreet, tlandbase, tnumber, tposition, tmeas1, tmeas2, tlabel1, tlabel2, tsaveFile)
  return treeform
}

treeAutofill()
{
    global
    locationDataCheck()
    ;steps currently in this method (high level)

    ;1.check for data presence
    ;2.check for template presence
    ;3.Disable Complete control (Mobile)
    ;4.Check for Bell Primary if so go there and then save/exit
    ;5.chck for existing sketch to import - if yes then open sketchtool and insert sketch
    ;6.get dig area
    ;7.get treetype
    ;8.check if clear - if yes start new clear tree sketch
    ;9.get street
    ;10.get landbase
    ;11.get number
    ;12 get cable location
    ;13 get labels
    ;14.Append most things to a file
    ;15.Check cabloc - assign labels depending on single cable or double cable
    ;16. Check to see if ticket should be completed now- NO: inform that ticket saved to file and return YES: setform and wait STLOAD

    ; FileDelete,treeticketdata.tt
    ; FileAppend(ticketnumber "`n" number "`n" street,"treeticketdata.txt")
    ; MsgBox % FileRead("treeticketdata.txt")
    ;RunWait,trees.py,%A_ScriptDir%
    if (checkforTreeTemplateFile(ticketnumber))
    {
        treeSketchFromTemplate(A_MyDocuments "\" ticketnumber ".txt")
        return
    }
    Control,Disable,,Button39,ahk_exe mobile.exe
    if (form = "BP")
    {
        bellPrimaryPoleAutofill()
        ST_SAVEEXIT()
    }
    else
    {
        if (useExisting() = "y")
        {
            clickdrawingtab()
            setForm()
            waitSTload()
            autofillExistingSketch()
        }
        else
        {
            clickdrawingtab()
            ; treeDigArea := getTreeDigArea()
            ; treetype := treeDigArea["treetype"]
            ; rclear := rogClear()
            ; if (rclear)
            ; {
            ;     setform()
            ;     waitSTload()
            ;     setTreeDigArea(treeDigArea)
            ;     writeRogersClearReason()
            ;     rclear := ""
            ;     ST_SAVEEXIT()
            ;     return
            ; }
            ; InputBox, street, Street, Street?,,,,,,, %street%
            ; InputBox, landbase, landbase, Which Direction?
            ; InputBox, number,Number, Enter house number?
            ; InputBox, cabloc, Location, Where is cable relative to tree?`n1 = closer to road`n2 = closer to property`n3 = both sides of tree,,,,,,,,2
            ; labels := getTreeLabels(cabloc)
            ;write a template file (ticketnumber)trees.txt

            treeform := treeGui()
            treedata := treeform["output"]
            treen := "2M NORTH OF STUMP " . treedata[1]
            trees := "2M SOUTH OF STUMP " . treedata[1]
            treew := "2M WEST OF STUMP " . treedata[1]
            treee := "2M EAST OF STUMP " . treedata[1]
            treefile := JoinPath(A_MyDocuments,ticketnumber . ".txt")
            MsgBox % treefile
            FileAppend(ticketnumber . "`n" . treen . "`n" . trees . "`n" . treew . "`n" . treee . "`nSTUMP`n" . treedata[2] . "`n" . treedata[3] . "`n" . treedata[4] . "`n" . treedata[5] . "`n" treedata[6] . "`n" . treedata[7] . "`n" . treedata[8] . "`n" . treedata[9] . "`n" . treedata[10], treefile)
            ; FileAppend(ticketnumber "`n" treeDigArea["north"] "`n" treeDigArea["south"] "`n" treeDigArea["west"] "`n" treeDigArea["east"] "`n" treetype "`n" street "`n" landbase "`n" number "`n" cabloc "`n",treefile)
            ;make sure the labels correspond to a single cable or double cable sketch
            ; if (cabloc =3)
            ; {
            ;     FileAppend(labels[1] "`n" labels[2] "`n" labels[3] "`n" labels[4] "`n" number " " street " TREES R.SKT",treefile)
            ; }
            ; else
            ;     FileAppend(labels[1] "`n" "x`n" labels[2] "`n" "x`n" number " " street " TREES R.SKT",treefile)
            MsgBox("Ticket info saved to file")
            ticketnumber := "",landbase := "",number :="",cabloc := "",labels := "",treefile := "",treeDigArea := "",stationcode := "",intersection := "",intersection2 := ""
            resetformVar()
        }
    }
}

;returns object with measuremetns and cable labels
getTreeLabels(cabloc)
{
    if (cabloc = 3)
    {
        meas1 := setMeasurement()
        meas2 := setMeasurement()
        label := getCableLabel()
        label2 := getCableLabel()
        tlabels := [meas1,meas2,label,label2]
        return tlabels
    }
    else
    {
        meas := setMeasurement()
        label := getCableLabel()
        tlabels := [meas,label]
        return tlabels
    }
}

setTreeLabels(labels,street, cabloc, landbase, treetype, number := "")
{
    setTemplateText(landbase "streettree.skt", street)
    if (cabloc = 1) {

        setTemplateText(landbase "treemeas1.skt", labels[1])
        wait()
        setTemplateText(landbase "treecablelabel1.skt", labels[2])
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
        setTemplateText(landbase "treemeas2.skt",labels[1])
        wait()
        setTemplateText(landbase "treecablelabel2.skt",labels[2])
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
        setTemplateText(landbase "treemeas1.skt", labels[1])
        wait()
        setTemplateText(landbase "treemeas2.skt", labels[2])
        wait()
        setTemplateText(landbase "treecablelabel1.skt", labels[3])
        wait()
        setTemplateText(landbase "treecablelabel2.skt", labels[4])
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

        if (useExisting() = "y")
        {
            autofillExistingSketch()
        }

        else
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
        return
    }
}

;routine to run if using existing drawing
autofillExistingSketch()
{
    global
    openimagedialog()
    waitCloseDialogBox()
    if (form != "BP")
    {
        openimagedialog()
        waitCloseDialogBox()
        WinWaitClose,ahk_exe SketchToolApplication.exe
        newPagePrompt()
    }

    else
    {
        OpenImageDialog()
        waitCloseDialogBox()
        units := Inputbox("Enter units")
        totalpages := Inputbox("Enter total pages")
        loadImage("bell primary.skt")
        wait()
        setTemplateText("units.skt", units)
        wait()
        setTemplateText("bellprimarydate.skt",getCurrentDate())
        wait()
        setTemplateText("RPtotalpages.skt", totalpages)
        if (currentpage = "")
            currentpage := 1
        if (totalpages = "")
            totalpages := 1
        ControlClick("OK","ahk_exe sketchtoolapplication.exe")
        focusTeldig()
    }
}

buttonLoadTemplate(x)
{
    Gui, 2: Submit
    loadImage(x)
}

;selects arrow tool in SketchTool
clickPointer(){
    Acc_Get("DoAction", "4.7.4.2.4.1.4.1.4.1.4.1.2",0, "ahk_exe mobile.exe")
}

;defines function to insert pauses if necessary
wait()
{
    Random, random_number, 100, 300
    Sleep % random_number
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
    if (winexist("ahk_exe locateaccess.exe"))
        WinActivate,ahk_exe locateaccess.exe
    else
        WinActivate, ahk_exe mobile.exe
}

focusSketchTool()
{
    WinActivate, ahk_exe sketchtoolapplication.exe
}

clickLocationTab()
{
   ; Acc_Get("DoAction", "4.1.4.1.4.1.4.1.4.11.4",1,"ahk_exe mobile.exe")
   ; Sleep 150
   uia := UIA_Interface()
   win := uia.ElementFromHandle(Winactive("A"))
   nnx := win.WaitElementExistByName("NNX",,,,1)
   if (!nnx)
    d := win.FindByPath("1.3.1.1.3.2.1").click()
}

clickDigInfoTab()
{
    ;Acc_Get("DoAction","4.1.4.1.4.1.4.1.4.11.4",2,"ahk_exe mobile.exe")
    ;Sleep 150
    uia := UIA_Interface()
    win := uia.ElementFromHandle(Winactive("A"))
    gi := win.WaitElementExistByName("Grid info",,,,2)
    if (!gi)
        win.FindByPath("1.3.3.1.2.2.1").click()

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
    ;Acc_Get("DoAction","4.1.4.1.4.1.4.1.4.1.4.7.4",0,"ahk_exe mobile.exe")
    ;picSearchSelect("newform.png")
    ; MouseClick, L, 928, 645
    Text:="|<>*130$8.0Dw000000000T3UE0000000000000Dzz08"
    if (ok:=FindText(924-150000, 639-150000, 924+150000, 639+150000, 0, 0, Text))
    {
        CoordMode, Mouse, Screen
        X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
        Click, %X%, %Y%
    }
}

^F2::
statusPending()
return

statusPending() ; change ticket status to pending
{
    RunWait("C:\Users\craig\Documents\LibreAutomate\Main\exe\ChangeToPending\ChangeToPending.exe")
    return true
}

; Retrieves ticket data from a text file based on the current window handle. If the ticket number is not found in the file, prompts the user to enter the data manually.
; Returns a object containing the following keys: number, street, intersection, intersection2, stationCode, digInfo, ticketNumber, and town.
getTicketData()
{
    global
    ladatapath := "C:\Users\craig\AppData\Local\TelDigFusion.Data\data\"
    uia := UIA_Interface()
    win := uia.ElementFromHandle(WinExist("A"))
    doc := win.FindFirstByNameAndType("LocateAccess - Cable Control Systems","Document").Value
    priority := win.FindFirstBy("AutomationId=Ticket.Priority").Value
    ;Notify(priority)
    a := StrSplit(doc,"/")
      subdir := a.8 . "_" . a.9
    stationcode := a.9
    ladatapath .= subdir
    ;mb("subdir: " . subdir "`nladatapath: " ladatapath "`n")
    ;file loop needs full pattern similar to dir cmd
    Loop, Files, %ladatapath%\*.txt, R
    {
        file := A_LoopFileLongPath
    }

    ;read file, save line 32 as number, line 34 as street, line 35 as intersection, line 36 as intersection2, line 64 as digInfo, line 4 as ticketnumber, line 30 as town

    if (stationcode == "ROGYRK01")
    {
        FileReadLine,number,%file%,32
        FileReadLine,street,%file%,34
        FileReadLine,intersection,%file%,35
        FileReadLine,intersection2,%file%,36
        FileReadLine,digInfo,%file%,64
        FileReadLine,ticketnumber,%file%,4
        FileReadLine,town,%file%,30
        number := StrReplace(number,"UR_NO_CIVIC_INITI::")
        street := StrReplace(street,"UR_NOM_ARTER_PRINC::")
        intersection := StrReplace(intersection,"UR_NOM_ARTER_INTER_1::")
        intersection2 := StrReplace(intersection2,"UR_NOM_ARTER_INTER_2::")
        digInfo := StrReplace(diginfo,"UR_INFO_ADDIT_TROU::")
        ticketnumber := StrReplace(ticketnumber,"UR_ID_REQUE::")
        town := StrReplace(town,"UR_NOM_TESSE_1::")
    }

    else if (stationcode == "TLMXF01")
      {
        filepath := file
        file := FileOpen(filepath,"r")
        while !file.AtEOF()
          {
            line := file.ReadLine()

            if (A_Index = 32)
              number := line
            else if (A_Index = 34)
              street := line
            else if (A_Index = 35)
              intersection := line
            else if (A_Index = 36)
              intersection2 := line
            else if (A_Index = 64)
              digInfo := line
            else if (A_Index = 4)
              ticketnumber := line
            else if (A_Index = 30)
              town := line
          }
        file.Close()

        number := StrReplace(number,"UR_NO_CIVIC_INITI::")
        street := StrReplace(street,"UR_NOM_ARTER_PRINC::")
        intersection := StrReplace(intersection,"UR_NOM_ARTER_INTER_1::")
        intersection2 := StrReplace(intersection2,"UR_NOM_ARTER_INTER_2::")
        digInfo := StrReplace(diginfo,"UR_INFO_ADDIT_TROU::")
        ticketnumber := StrReplace(ticketnumber,"UR_ID_REQUE::")
        town := StrReplace(town,"UR_NOM_TESSE_1::")

      }

    else if (stationcode == "APTUM01")
    {
        FileRead,aptfile,%file%
        lines := StrSplit(aptfile,"`n")
        for lineidx, line in lines {
            if (Instr(line,"Address")) {
                n := RegExReplace(line,".*:.")
            }
            number := Trim(RegExReplace(n,",.*|[A-Z]")," `n`r")
            street := Trim(RegExReplace(n,".*,.")," `n`r")

            if (Instr(line,"Intersecting Street 1")) {
                intersection := Trim(RegExReplace(line,".*:.")," `n`r")
            }
            if (Instr(line,"Intersecting Street 2")) {
                intersection2 := Trim(RegExReplace(line,".*:.")," `n`r")
            }
            if (Instr(line,"REQUEST #:")) {
                ticketnumber := Trim(RegExReplace(line,".*:.")," `n`r")
            }
            if (Instr(line,"Region/County")) {
                town := Trim(RegExReplace(line,".*:.")," `n`r")
            }
        }
    }

    else if (stationcode == "ENVIN01")
    {
        FileReadLine,number,%file%,63
        FileReadLine,street,%file%,67
        FileReadLine,intersection,%file%,69
        FileReadLine,intersection2,%file%,71
        FileReadLine,digInfo,%file%,127
        FileReadLine,ticketnumber,%file%,7
        FileReadLine,town,%file%,59
        number := StrReplace(number,"UR_NO_CIVIC_INITI::")
        street := StrReplace(street,"UR_NOM_ARTER_PRINC::")
        intersection := StrReplace(intersection,"UR_NOM_ARTER_INTER_1::")
        intersection2 := StrReplace(intersection2,"UR_NOM_ARTER_INTER_2::")
        digInfo := StrReplace(diginfo,"UR_INFO_ADDIT_TROU::")
        ticketnumber := StrReplace(ticketnumber,"UR_ID_REQUE::")
        town := StrReplace(town,"UR_NOM_TESSE_1::")
    }

    ; if still cant find ticket number then call getDataManually()
    else
      {
            stationcode := win.FindFirstBy("AutomationId=TicketUtility.StationCode").Value
            ticketnumber := win.FindFirstBy("AutomationId=Ticket.TicketNumber").Value
            address := win.FindFirstBy("AutomationId=Ticket.Address").Value
            RegExMatch(address, "^\d+", number)
            ;street is everything after the first space after the last number
            street := RegExReplace(address, ".*\d\s(.*)", "$1")
            intersection := win.FindFirstBy("AutomationId=Ticket.Intersection1").Value
            intersection2 := win.FindFirstBy("AutomationId=Ticket.Intersection2").Value
      }

    if (!ticketnumber || !street)
    {
      ticketdata := getDataManually()
      return
    }

    ticketdata := {number : number, street : street, intersection : intersection, intersection2 : intersection2, stationCode : stationCode, digInfo: digInfo, ticketnumber : ticketnumber, town : town}
    return ticketdata

}

getDataManually()
{
    global
    InputBox, number, Enter number, Enter number
    InputBox, street, Enter street, Enter street
    InputBox, stationCode, Enter stationCode, Enter stationCode
    InputBox, ticketNumber, Enter ticketNumber, Enter ticketNumber
    ticketdata := {number : number, street : street, stationCode : stationCode, ticketNumber : ticketNumber}
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
    if (currentpage)
        setTemplateText("currentpage.skt",currentpage)
    if (totalpages)
        setTemplateText("totalpages.skt",totalpages)
    Sleep 1000
}

writeCurrentPage(currentpage)
{
    if currentpage is not integer
    {
        Throw "Page number must be integer"
        return
    }
    setTemplateText("currentpage.skt",currentpage)
}

writeTotalPages(totalpages)
{
    if totalpages is not integer
    {
        Throw "Page number must be integer"
        return
    }
    setTemplateText("totalpages.skt",totalpages)
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

getPoints(inst1, inst2) {
    ToolTip, % inst1
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
    coordinates := [x1, y1, x2, y2]
return coordinates
}

;returns a point object
getPoint(inst1) {
    Tooltip, % inst1
    Keywait, LButton, D, L
    MouseGetPos, x1, y1
    Tooltip,
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
    twoPointSL("c")
return

twoPointSL(type := "c")
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
    sleep 150
	if (type == "c")
		Send,^+c
	else
		Send, ^+o
    sleep 150
    Send, {Blind}{Shift Down}
    sleep 150
    MouseClick, L, % points.1, % points.2,,, D
    sleep 150
    MouseClick, L, % points.3, % points.4,,, U
    sleep 150
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
    MouseClickDrag, L, % arrow1.x, % arrow1.y, % arrow1.x, % (arrow2.y > arrow1.y) ? (arrow1.y - 36) : (arrow1.y + 36)
    wait()
    MouseClickDrag, L, % arrow1.x, % arrow2.y, % arrow1.x, % (arrow2.y > arrow1.y) ? (arrow2.y + 36) : (arrow2.y - 36)
    wait()
    Send, {ShiftUp}
    wait()
    ;DRAW ARROW END
    ;select text, draw textbox, write measurement
    clickTextTool()
    (arrow1.y < arrow2.y) ? tloc := arrow1.y - 64 : tloc := arrow2.y - 64
    ;MouseClickDrag, L, % arrow1.x - 16, % tloc, % arrow1.x + 16,% tloc + 80
    MouseClickDrag, L, % arrow1.x -40, % tloc - 16, % arrow1.x + 40, % tloc + 16
    Send, {Click 2}
    clickRotate90degrees()
    sleep 500
    Send,{F2}
    multiMeasurement()
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
    Acc_Get("DoAction","4.6.4.2.12",0,"ahk_exe sketchtoolapplication.exe")
  ;~ uia := uia_interface()
  ;~ win := uia.ElementFromHandle()
  ;~ win.FindFirstByName("Send to back").click()
}

clickBringtoFront(){
    Acc_Get("DoAction","4.6.4.2.13",0,"ahk_exe sketchtoolapplication.exe")
  ;~ uia := uia_interface()
  ;~ win := uia.ElementFromHandle()
  ;~ win.FindFirstByName("Bring to front").click()

}

clickRotate90degrees(){
    Acc_Get("DoAction","4.6.4.2.16",0,"ahk_exe sketchtoolapplication.exe")
  ;~ uia := uia_interface()
  ;~ win := uia.ElementFromHandle()
  ;~ win.FindFirstByName("Rotate 90° CW").click()
  ;~ Click 2
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

Notify(text)
{
    Progress,zh0 b y30 cwblack ctyellow,%text%
    SetTimer,NotifyOff,-3000
}

NotifyOff:
Progress,off
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
    MouseClickDrag, L, % arrow1.x, % arrow1.y, % (arrow2.x > arrow1.x) ? (arrow1.x - 36) : (arrow1.x + 36), % arrow1.y
    Sleep 50
    MouseClickDrag, L, % arrow2.x, % arrow1.y, % (arrow2.x > arrow1.x) ? (arrow2.x + 36):(arrow2.x - 36), % arrow1.y
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
    multiMeasurement()
    arrow1:="", arrow2 := ""
    Send, ^q
}

DiagonalArrowTool()
{
    arrow1 := getPoint("Click first point for measurement")
    Sleep 200
    arrow2 := getPoint("Click second point for measurement")
    Notify(arrow1)
    wait()
    clickLineTool()
    clickPerArrowHeadEnd()
    pi := 4 * ATan(1)
    angle := calculateAngle(arrow1.x, arrow1.y, arrow2.x, arrow2.y)
    ;draw arrow by clicking and dragging from the point to 36 pixels away from the point using the angle
    MouseClickDrag,L,% arrow1.x, % arrow1.y, % arrow1.x - Cos(angle * pi/180) * 36, % arrow1.y - Sin(angle * pi/180) * 36
    Sleep 50
    MouseClickDrag,L,% arrow2.x, % arrow2.y, % arrow2.x + Cos(angle * pi/180) * 36, % arrow2.y + Sin(angle * pi/180) * 36
    wait()
    clickTextTool()
    wait()
    MouseClickDrag, L,% arrow1.x - 80, % arrow1.y - 16, % arrow1.x - 16, % arrow1.y + 16
    Sleep 25
    Send, {Click 2}{F2}
    wait()
    multiMeasurement()
    arrow1:="", arrow2 := ""
    Send, ^q

}

calculateAngle(x1, y1, x2, y2)
{
    ;calculate the angle between two points accounting for all four quadrants. Return the number in degrees
    pi := 4 * ATan(1)
    if (x2 > x1 && y2 > y1)
        return atan((y2 - y1) / (x2 - x1)) * 180 / pi
    else if (x2 < x1 && y2 > y1)
        return 180 - atan((y2 - y1) / (x1 - x2)) * 180 / pi
    else if (x2 < x1 && y2 < y1)
        return 180 + atan((y1 - y2) / (x1 - x2)) * 180 / pi
    else if (x2 > x1 && y2 < y1)
        return 360 - atan((y1 - y2) / (x2 - x1)) * 180 / pi
    else if (x2 == x1 && y2 > y1)
        return 0
    else if (x2 == x1 && y2 < y1)
        return 180
    else if (x2 > x1 && y2 == y1)
        return 90
    else if (x2 < x1 && y2 == y1)
        return 270
    else
        return 0
}

showAngle()
{
    arrow1 := getPoint("Click point 1")
    sleep 200
    arrow2 := getPoint("Click point 2")
    pi := 4 * ATan(1)
    angle := calculateAngle(arrow1.x, arrow1.y, arrow2.x, arrow2.y)
    msgbox % angle

}
+!d::
    DiagonalArrowTool()
return

;~ a::
;~ _::
;~ drawCorner()
;~ return

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
    sleep 100
    Send, {Shift Up}
    sleep 100
    clickArch()
    sleep 100
    Sleep 200
    MouseClickDrag, L, % line1.3,% line1.4,% arc.x,% arc.y,5
    Send, +^c
    sleep 100
    clickPolyline()
    sleep 100
    Send, +^c
    sleep 150
    Send, {Shift Down}
    ;MouseClickDrag, L, % arc.x, % arc.y, % line2.x, % line2.y,7
    MouseClick, L, % arc.x, % arc.y,,5
    sleep 150
    MouseClick, L, % line2.x, % line2.y,,5
    sleep 150
    Send, {Shift Up}
    sleep 250
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

isInt(var){
    if var is Integer
        return true
    else
        return false
}

#IfWinActive ahk_exe locateaccess.exe
^!t::
::tmsht::
    addtotimesheet()
return

getUtility(string) {

}

addToTimesheetFromPrevious(aptumunits := "",rogersunits := "")
{
    global
    splashtexton,,,,Adding to logsheet
    FileAppend,% ticketnumber "," number " " street "," rogersunits[1] "," rogersunits[2] "," aptumunits[1] "," aptumunits[2] ",,, `n", C:\Users\craig\timesheet%today%.txt
    if ErrorLevel
        MsgBox % "Couldn't write to timesheet"
    SplashTextOff
}

addtotimesheet()
{
    GLOBAL
    ErrorLevel := ""
    SetKeyDelay, 100
    clickLocationTab()
    getTicketData()
    fixStreetName()
    today := A_DD . " " . A_MM . " " . A_yyyy

    ;check if ticket already billed
    ;FIXME
    /*     Progress,zh0 w 300 y 100,,Checking Billing`n`n
     *     Progress,25
     *     runwait,%comspec% /c "findstr /i %ticketnumber% c:\users\cr\*timesheet*.txt > output.txt",,Hide
     *     While !FileExist("output.txt")
     *         sleep 250
     *     file := fileopen("output.txt","r")
     *     Progress,50
     *     string := file.read()
     *     Progress,75
     *     if (strlen(string) > 0) {
     *         Progress,Off
     *         msgbox % "Ticket already billed - " . SubStr(string,22,10),
     *         ticketnumber := ""
     *         file.close()
     *         return
     *     }
     */
    Progress,off
    if (aptumunits || rogersunits)
    {
        addToTimesheetFromPrevious(aptumunits,rogersunits)
        TrayTip("Entry added","Ticket added to timesheet",5)
        return
    }
    Notify("Adding to timesheet")
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
        if rogersclear is not digit
            continue
    }
    until ROGERSCLEAR <= 20

    Loop{
        InputBox, APTUMMARKED, Enter Aptum Marked (int)
        if APTUMMARKED is not digit
            continue
    }
    until APTUMMARKED <= 20

    Loop{
        InputBox, APTUMCLEAR, Enter Aptum clear (int)
        if APTUMCLEAR is not digit
            continue
    }
    until APTUMCLEAR <= 20

    Loop {
      Inputbox, EnviMarked, Enter Envi Marked (int)
      if EnviMarked is not digit
          continue
    }
    until EnviMarked <= 20

    Loop {
      Inputbox, EnviClear, Enter Envi Clear (int)
      if EnviClear is not digit
          continue
    }
    until EnviClear <= 20

    Loop {
      Inputbox, TelmaxMarked, Enter Telmax Marked (int)
      if TelmaxMarked is not digit
          continue
    }
    until TelmaxMarked <= 20

    Loop {
      Inputbox, TelmaxClear, Enter Telmax Clear (int)
      if TelmaxClear is not digit
          continue
    }
    until TelmaxClear <= 20

    comments := ""
    ; if envimarked, enviclear, telmaxmarked or telmaxclear have a numeric value, add them to the comments
    if (EnviMarked)
        comments .= EnviMarked . " ENVI MARKED "
    if (EnviClear)
        comments .= EnviClear . " ENVI CLEAR "
    if (TelmaxMarked)
		TelmaxMarked .= "M"
    if (TelmaxClear)
		TelmaxClear .= "C"

    if (rogersMarked)
        rogersMarked .= "M"
    if (rogersClear)
        rogersClear .= "C"
    if (aptumMarked)
        aptumMarked .= "M"
    if (aptumClear)
        aptumClear .= "C"
    ; get comments manually if comments := ""
    if (comments == "")
        InputBox, comments, Enter Comments
    StringUpper, comments,comments
    tsline := Format("{1},{2} {3},{4},{5},{6},{7},{8},{9},{10}`n",ticketnumber,number,street,rogersMarked,rogersClear,aptumMarked,aptumClear,TelmaxMarked, TelMaxClear,comments)
    FileAppend,% tsline, C:\Users\craig\timesheet%today%.txt
    if (ErrorLevel)
        MsgBox % "There was an error writing to timesheet`nError: " A_LastError

}
newtimesheetentry(){
    GLOBAL
    SPLASHTEXTON ,,,Adding new comment
    clickLocationTab()
    getTicketData()
    today := A_DD . " " . A_MM . " " . A_yyyy ;today := "timesheet24 07 2020.txt"
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
:::L::
    ; hotkey se - o for insert image
    openImageDialog()
RETURN

;returns to last used tool (generally arrow)
=::
~s::
    clickSelection()
    {
        SendInput, ^q
    }
return

#o::
    ; win o for qa circle
    loadImage(A_MyDocuments . "\qacorrection.skt")
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
  ;clickSelection()
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

^s:: ; Ctrl S to save
:::S::
    saveFile()
return

; HOTKEY CTRL ALT X FOR JPG SAVE
#ifwinactive Tel ahk_exe SketchToolApplication.exe
!^X::
    picSave(getLocator(), getFileName())
return
#ifwinactive

getFileName(){
    InputBox, filename, Enter file name
    if ErrorLevel
        return
    return filename
}

getLocator(){
    Inputbox, locator, Enter locator, B=BRUCE`nJ=JUNE`nT=THEO
    StringLower, locator, locator
    if ErrorLevel
        return
    switch locator {
        case "b": return "BRUCE"
        case "j": return "JUNE"
        case "t": return "THEO"
        default: return
    }
}

picSave(locator, filename, type := ".jpg")
{
    ;does 3 things gets save file name , gets locator name, saves file. Split this up
    focusSketchtool()
    saveFile()
    waitDialogBox()
    sleep 1100
    savedFile := "C:\Users\craig\qa\" . locator . "\" . filename . ".jpg"
    ; check to see if a file with the same name already exists in that location
    if (FileExist(savedFile))
    {
      seed := Random(1,10)
      savedFile := Format("C:\Users\craig\qa\{1}\{2}{3}.jpg", locator, filename, seed)
      Send % savedFile
    }
    else
    {
        Send % savedFile
    }
    Send,{Enter}
}

;WIN NUMPAD INSERT for ok in auxilliary, SAVES FIRST and prompts page numbers now

;NEW KEYBINDING
#IfWinActive Tel AHK_EXE Sketchtoolapplication.EXE

o::
    twoPointSL("o")
return

+c::
    twoPointSL("c")
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
e::Delete
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
            if num2
                Send, % street " " num1 " to " num2 " " util
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
    SendInput, {F2}%A_YYYY%-%A_MM%-%A_DD%{Enter}
}

getRogersUnits()
;returns array
{
    Loop {
        Inputbox,rogersmarked, Units, Enter marked units?
    }
    Until rogersmarked > 0 && rogersmarked <= 20 || rogersmarked = ""
    Loop {
        Inputbox,rogersclear, Units, Enter clear units?
    }
    Until rogersclear > 0 && rogersclear <= 20 || rogersclear = ""
    if (rogersmarked > 0)
        rogersmarked .= "M"
    if (rogersClear > 0)
        rogersClear .= "C"
    rogersunits := [rogersmarked,ROGERSCLEAR]
return rogersunits
}

getaptumUnits()
;returns array
{
    Loop {
        Inputbox,aptummarked, Units, Enter marked units?
    }
    Until aptummarked > 0 && aptummarked <= 20 || rogersmarked = ""
    Loop {
        Inputbox,aptumclear, Units, Enter clear units?
    }
    Until aptumclear > 0 && aptumclear <= 20 || aptumclear = ""
    if (aptummarked > 0)
        aptummarked .= "M"
    if (aptumClear > 0)
        aptumClear .= "C"
    aptumunits := [aptummarked,aptumCLEAR]
return aptumunits
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
        setTemplateText("RPtotalpages.skt",currentpage . "/" . totalpages)

    Case "AA":
        loadImage("aptumaux.skt")
        setTemplateText("totalpages.skt",totalpages)
        setTemplateText("currentpage.skt",currentpage)

    Case "EP":
        loadImage("catv primary.skt")
        setTemplateText("units.skt",units)
        setTemplateText("rogersprimarydate.skt",today)
        setTemplateText("RPtotalpages.skt",currentpage . "/" . totalpages)

    Case "EA":
        loadImage("envi auxilliary.skt")
        setTemplateText("totalpages.skt",totalpages)
        setTemplateText("currentpage.skt",currentpage)
    }
}

^w:: ;SAVE AND EXIT CURRENT SKETCH
:::w::
Numpadenter::
^+Enter::
    ST_SAVEEXIT()
return

getStnCodeSuffix()
{
    global
    if (stationcode = "BCGN01")
        return "B"
    else if (stationcode = "BCGN02")
        return "B"
    else if (stationcode = "ROGYRK01")
        return "R"
    else if (stationcode = "ROGSIM01")
        return "R"
    else if (stationcode = "ENVIN01")
        return "ENVI"
    else if (stationcode = "APTUM01")
        return "APT"
    else
      return "TMAX"
  }

ST_SAVEEXIT()
{
    global
    util := getStnCodeSuffix()
    MsgBox,4,Save,Save Sketch?
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

    Case "RP":
        rogersunits := getRogersUnits()
        totalpages := getRPPages()
        loadImage("catv primary.skt")
    (InStr(rogersunits[1],"M")) ? loadImageNG("rogerspaint.skt") :
        setTemplateText("units.skt",rogersunits[1] . rogersunits[2])
        setTemplateText("rogersPrimaryDate.skt",A_YYYY . "-" . A_MM . "-" . A_DD)
        setTemplateText("RPtotalpages.skt",totalpages)
        Sleep 100

    Case "EP", "TP":
        enviunits := getRogersUnits()
        totalpages := getRPPAGes()
        loadImage("telmaxprimary.skt")
    (InStr(enviunits[1],"M")) ? loadImageNG("telmaxpaint.skt") :
        setTemplateText("units.skt",enviunits[1] . enviunits[2])
        setTemplateText("rogersPrimaryDate.skt",A_YYYY . "-" . A_MM . "-" . A_DD)
        setTemplateText("RPtotalpages.skt",currentpage . "/" . totalpages)

    Case "RA" :
        loadImage("rogersaux.skt")

    Case "AP" :
        aptumunits := getaptumUnits()
        totalpages := getRPPages()
        loadImage("cogeco primary.skt")
        if (InStr(aptumunits[1],"M"))
        {
            loadImageNG("APTUMMARKED.SKT")
        }
        setTemplateText("units.skt",aptumunits[1] . aptumunits[2])
        setTemplateText("rogersPrimaryDate.skt",A_YYYY . "-" . A_MM . "-" . A_DD)
        setTemplateText("RPtotalpages.skt",currentpage . "/" . totalpages)
        Sleep 100

    Case "AA" :
        loadImage("aptumaux.skt")

    Case "TA":
        loadImage("telmaxaux.skt")

    Case "EA":
        loadImage("envi auxilliary.skt")
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
    IF (FORM = "RP" || form = "EP" || form = "AP" || form = "TP")
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
^PgDn::
    ControlClick("Cancel","ahk_exe sketchtoolapplication.exe")
    Sleep 100
    if WinExist("AHK_CLASS #32770") {
        Send {enter}
    }
    WinActivate ahk_exe mobile.exe
return

; HOTKEY WIN + B FOR BELL PRIMARY
#IFWINACTIVE AHK_EXE SKETCHTOOLAPPLICATION.EXE
 ; LOAD BELL PRIMARY SHEET
 ::insbp::
 loadBellPrimary()
 return
loadBellPrimary(){
    loadImage("bell primary.skt")
}
;HOTKEY CTRL - ALT - B FOR BELL AUXILLIARY WITH DATE/PAGE NUMBERS

::insba::
loadBellAuxilliary()
return
; LOAD BELL AUXILLIARY SHEET
loadBellAuxilliary(){ ; LOAD BELL AUXILLIARY
    loadImage("bellaux.skt")
}
;HOTKEY CTRL - ALT - R FOR ROGERS AUXILLIARY WITH DATE/PAGE NUMBERS

^!A:: ;LOAD ROGERS AUXILLIARY SHEET
::insra::
loadRogersAuxilliary()
return

loadRogersAuxilliary(){
    loadImage("rogersaux.skt")
}
;HOTKEY CTRL - ALT - B FOR APTUM AUXILLIARY WITH DATE/PAGE NUMBERS

^!C::
::insaa::

loadAptumAuxilliary(){

    loadImage("aptumaux.skt")
}
; WIN R FOR ROGERS PRIMARY

#R:: ; LOAD ROGERS PRIMARY SHEET
::insrp:: ;LOAD ROGERS PRIMARY SHEET
    loadImage("catv primary.skt")
return

; win numpad keys for preloaded template
#numpadup::
^+Up:: ;INSERT NORTH TEMPLATE
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
    Notify("Finish and email")
    focusTeldig()
    currentpage := "", totalpages := ""
    if !(STATUSPENDING())
    {
        Notify("Unable to complete ticket")
        return
    }
    if (form = "BP" or form = "BA")
        bellMarked := "", bellClear := ""
    else if (form = "RP" or form = "RA")
        rogersMarked := "", rogersClear := ""
    form := "", locationDataObtained := "",landbase := "",intdir := "",choice := "",rclear :="", num := "", timestart := ""
    aptumunits := ""
    rogersunits := ""
	stationcode := ""
        ;if form is "TP" or "TA" then set street,number,ticketnumber,intersection,intersection2 variables to ""

        street := ""
        number := ""
        ticketnumber := ""
        intersection := ""
        intersection2 := ""

    uia := UIA_Interface()
    uia.ElementFromHandle().FindFirstByName("Save").click()
    uia.ElementFromHandle().WaitElementExistByNameandType("Yes","Button")
    uia.ElementFromHandle().FindFirstByNameAndType("Yes","Button").click()
    uia.ElementFromHandle().WaitElementExistByNameandType("OK","Button")
    uia.ElementFromHandle().FindFirstByNameAndType("OK","Button").click()
}

numpaddel:: ;COMPLET TICKET WITHOUT EMAILING
::oknoSend::
:::n::
    finishnoemail()
return

;COMPLETE TICKET WITHOUT EMAILING
finishnoemail()
{
    global
    currentpage := "", totalpages := "", timestart := ""
    if !(STATUSPENDING())
    {
        Notify("Unable to complete ticket")
        return
    }
    form := ""
    locationDataObtained := ""
    landbase := ""
    intdir := ""
    choice := ""
    rogersunits := ""
    aptumunits := ""
     ;~ SetControlDelay, -1
     ;~ ControlClick, Button43,,,,,NA
     ;~ WinWaitActive, ahk_class #32770
     ;~ ControlClick, Button2,,,,,NA
     uia := UIA_Interface()
     uia.ElementFromHandle().FindFirstByName("Save").click()
     uia.ElementFromHandle().WaitElementExistByNameandType("No","Button")
     uia.ElementFromHandle().FindFirstByNameandType("No","Button").click()
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

setTemplateText(template,text)
;what box and what position
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
        InputBox, treetype, Type, Type?`n1 = Tree`n2=Stump`n3=Flag`n4=Curb Marking`n5=Stake,,,,,,,,2
    }
    until treetype in 1,2,3,4,5
    switch treetype
    {
    case 3:
        treetype := "FLAG"
    case 2:
        treetype := "STUMP"
    case 4:
        treetype := "CURB MARKING"
    case 5:
        treetype := "STAKE"
    default:
        treetype := "TREE"
    }

    return treetype
}

getTreeDigArea()
{
    global form
    treetype:=getTreeType()
    if (form = "RA")
    {
        setRARadiusDigArea(treetype,treenum)
        clickselection()
        return
    }
    treeDigArea := {}
    treenum := InputBox("Trees","Write tree number")
    treeDigArea["north"] := "2M N OF " . treetype . " " . treenum
    treeDigArea["south"] := "2M S OF " . treetype . " " . treenum
    treeDigArea["west"] := "2M W OF " . treetype . " " . treenum
    treeDigArea["east"] := "2M E OF " . treetype . " " . treenum
    treeDigArea["treetype"] := treetype
    return treeDigArea
}

setTreeDigArea(treeDigArea)
{
    setTemplateText("NBoundary.skt",treeDigArea["north"])
    setTemplateText("SBoundary.skt",treeDigArea["south"])
    setTemplateText("WBoundary.skt",treeDigArea["west"])
    setTemplateText("EBoundary.skt",treeDigArea["east"])
    wait()
    clickSelection()
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
    ^=::
    ::QAYES::
        loadImage(A_MyDocuments . "\qayes.skt")
    return

    #IFWINACTIVE AHK_EXE SKETCHTOOLAPPLICATION.EXE
    #numpadsub::
    ^-::
    ::QANO::
        loadImage(A_MyDocuments . "\qan.skt")
    return

    #IfWinActive ahk_exe sketchtoolapplication.exe
    +BackSpace::
        changeText()
    return

    changeText(){
        ;SendInput,{f2}{Backspace 50}
        SendInput("{F2}{Backspace 60}")
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

    ~{::
        SendInput, {F2}
        SendInput, {BS 50}
        sleep 300
        multiMeasurement()
        return

    #IfWinActive

    getMultiMeasurement()
    {
        Inputbox, string, Measurement, Insert measurements separated by ","
        return string
    }

    convertMultiMeasurement(string)
    {
        offsets := StrSplit(string, ",")
        final := ""
        for idx, val in offsets
        {
            newval := convertMeasurement(val)
            if (idx != offsets.Length())
            {
                final .= newval . ", "
            }
            else {
                final .= newval
            }
        }
        return final
    }

    multiMeasurement()
    {
        setOffset(convertMultiMeasurement(getMultiMeasurement()))
    }

    measurementTool()
    {
        SendInput, {F2}
        SendInput, {BS 50} ; CLEARS BOX
        Sleep 300
        setMeasurement()
    }

    getMeasurement()
    {
        InputBox, String, Measurement, Insert Measurement
        return string
    }

    convertMeasurement(string)
    {
        if (strlen(String) = 1)
        {
            String := "0." String " m"
        }

        else if (strlen(String) = 2)
        {
            newString := strsplit(String)
            meas1 := newString[1]
            meas2 := newString[2]
            String := meas1 "." meas2 " m"
        }
        else if (strlen(String) = 3)
        {
            newString := strsplit(String)
            newString := strsplit(String)
            meas1 := newString[1]
            meas2 := newString[2]
            meas3 := newString[3]
            String := meas1 meas2 "." meas3 " m"
        }
        return String
    }

    setOffset(string)
    {
        Send, %string%{enter}
    }

    setMeasurement(in := "")
    ;returns a measurement String ending in ".m" that only requires integer input
    {
        if (!in)
        {
            InputBox, String, Measurement, Insert Measurement ;gets measurement
        }
        else
        {
            String := in
        }
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
^]::
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
    Send {Click, 25, 111}
    Sleep 400
    Send {CLICK, 542, 676}
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
SWFUNC(Y,N)
{
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

}
#IfWinActive

#ifwinactive ahk_exe mobile.exe

NewPage:
    focusTeldig()

    ()
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

#ifwinactive ahk_exe streets.exe
;streets and trips hotkeys
f2::
    Rename()
return

Rename()
{
    MouseClick, R
    Send, n
}

#IFWINACTIVE AHK_EXE MOBILE.EXE
!^L::
::AATSAT::
    ; ADD ADDRESS TO streetS AND TRIPS
    setLocationST()
return

setLocationST()
{
    sleep 250
    address := fixStreetName1()
    WinActivate, ahk_exe streets.exe
    waitCaret()
    ;town := address.town, street := address.street, number := address.number, intersection := address.intersection
    ControlClick("Edit4","ahk_exe streets.exe")
    Send, % address.number . " " . address.street . "," . address.town
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
        street :=RegExReplace(street, "LANE.*","LN")
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
    sleep 250
    address := fixStreetName1()
    WinActivate, ahk_exe streets.exe
    waitCaret()
    ControlClick("Edit4","ahk_exe streets.exe")
    Send % address.street . " & " . address.intersection . "," . address.town
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
    address.intersection := TKT_ARRAY[16]
return address
}

; regex function adapted for streets and trips data
fixstreetName1() {
    address := getLocationMobileList()
    address.street := StrReplace(address.street,",")
    address.street := RegExReplace(address.street,"^ | \(REGIONAL.*| \(COUNTY.*| \(HIGHW.*|\*\**.*")
    address.intersection:= RegExReplace(address.intersection,"^ | \(REGIONAL.*| \(COUNTY.*| \(HIGHW.*|\*\**.*")
    address.town:= RegExReplace(address.town,"\,.*")
return address
}

; regex function to format names from Teldig
fixstreetName()
{
    global
    intersection:= RegExReplace(intersection,"^ | \(REGIONAL.*| \(COUNTY.*| \(HIGHW.*|\*\**.*")
    intersection2 := RegExReplace(intersection,"^ | \(REGIONAL.*| \(COUNTY.*| \(HIGHW.*|\*\**.*")
    town:= RegExReplace(town,"\,.*")
    street := RegExReplace(street,"^ |^\d+ | \(REGIONAL.*| \(COUNTY.*| \(HIGHW.*|^\d...|\*\**.*")
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
    getTicketData()
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
    run, %comspec% /c ""pytest" "-s" "test_rOGERSLOOKUP.py"",C:\Users\craig
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
    ;fixStreetName()
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
    getTicketData()
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
    ;fixStreetName()
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
    InputBox, address, Enter an address,, , 300, 200
    if (address != "")
    {
        ; Encode the address for use in the URL
        StringReplace, encoded_address, address, %A_Space%, +, All

        ; Construct the URL for the Google Maps search
        search_url := "https://www.google.com/maps/search/?api=1&query=" . encoded_address

        ; Open the URL in the default web browser
        Run, %search_url%
    }
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
;TODO add telmax lookup
{
    global town
    global street
    global intersection
    focusTeldig()
    data := getTicketData()
    sleep 200
    c := getcoords()
    long := c[1], lat := c[2]
    if (stationCode = "ROGYRK01") || if (stationCode = "ROGSIM01")
    {
        if !WinExist("ahk_exe chrome.exe")
        {
            Run, C:\Program Files\Google\Chrome\Application\chrome.exe  --remote-debugging-port=9222
        }

        WinActivate, ahk_exe chrome.exe
        WinWaitActive, ahk_exe chrome.exe

        try
        {
          if !driver
                driver := ChromeGet()
        }

        catch
        {
          msgbox % "Couldn't get ChromeDriver instance"
          return
        }

        try
        {
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

        catch, e
        {
            msgbox % "Error: " . e.message
            return
        }
    }


    ;TODO - add beanfield lookup via patch manager
    ;mapinfo lookup
    ; else if (stationCode == "APTUM01")
    ; {
    ;     if (!WinExist("ahk_exe mapinfor.exe"))
    ;     {
    ;         MsgBox % "Please open MapInfo"
    ;         return
    ;     }

    ;     if (data.number == "")
    ;     {
    ;         msgbox % data.street
    ;         msgbox % data.intersection
    ;         address := data.street . "&&" . data.intersection
    ;     }
    ;     else
    ;         address := data.number . " " . data.street
    ;     aptumLookup(address)
    ; }

    else if (stationCode == "APTUM01")
      {
        ;check to make sure google earth opens
        if !WinExist("ahk_exe googleearth.exe")
        {
            Run, C:\Program Files\Google\Google Earth Pro\client\googleearth.exe
            WinWaitActive, ahk_exe googleearth.exe
            sleep 1000
            WinActivate, ahk_exe googleearth.exe
        }
        else
        {
            WinActivate, ahk_exe googleearth.exe
        }

        uia := UIA_Interface()
        win := uia.ElementFromHandle("A")

        if (data.number == "")
          {
              address := data.street . " & " . data.intersection
          }
          else
              address := data.number . " " . data.street


          editSearch := win.FindByPath("2.1.2.3.1.2.1.1.1")
          editSearch.SetFocus()
          editSearch.Click()
          Send, {BS 100}
          sleep(200)
          send(address)
          sleep(200)
          send("{enter}")
      }


    else if (stationCode == "BCGN01") || (stationCode = "BCGN02")
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

    else if (stationcode = "TLMXF01") || (stationCode = "CCS")
      {
        Notify("Not implemented yet")
        ;open lac multiviewer if not already open (ahk_exe lacmultiviewer.exe)
        activateMultiViewer()

      }

}

activateMultiViewer()
{
    if !WinExist("ahk_exe lacmultiviewer.exe")
    {
        Run, C:\Program Files (x86)\NMT\LAC MultiViewer\LACMultiViewer.exe
        WinWaitActive, ahk_exe lacmultiviewer.exe
        sleep 1000
        WinActivate, ahk_exe lacmultiviewer.exe
    }
    else
    {
        WinActivate, ahk_exe lacmultiviewer.exe
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
;fixStreetName()
driver := ChromeGet()
;driver := ComObjCreate("Selenium.EdgeDriver")
;driver.Start()npm install selenium-webdriver

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
    setTemplateText(landbase "cornerystreet.skt", inter.y)
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
            if !FileExist("C:\Users\" . A_UserName . "\Documents\" v)
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
    if(!FileExist("C:\Users\craig\Documents\" landbase "PLtext.skt")||!FileExist("C:\Users\craig\Documents\" landbase "street.skt"))
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
        ;if !FileExist("C:\Users\craig\Documents\" landbase i)
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
        if !FileExist("C:\Users\craig\Documents\" landbase "PLTEXT.SKT")
        {
            MsgBox, Unable to load sketch (template not created)
            return
        }
        if !FileExist("C:\Users\craig\Documents\" landbase "street.skt")
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

F6::
parser()
return

parser()
{
    commands := {"?":"parserhelp"
                ,"edit sketch":"focusTeldig"
                ,"emergency":"emergency"
                ,"grid":"changeGridSizeto16"
                , "edit script": "editscr"
                , "repl":"repl"
                , "getmouse":"getmousepos"
                , "tkt billing": "ticketBillingLookup"
                , "qa": "gradeqa"
                , "magick": "imtest"
                , "milestokm": "runMilestoKm"
                , "pyscriptlaunch":"runPyScriptLauncher"
                , "rrc": "removeRogersClear"
                , "wt": "openTerminal"
                , "angle": "showAngle"}

    command := strlower(InputBox(,"Enter String"))
    if (command = "?") {
        helpstr := ""
        for k,v in commands {
            helpstr .= k " - " v "`n"
        }
        MsgBox % helpstr
    }
    for cmd,func in commands{
        if (command == cmd){
            %func%()
        }
    }
}
openTerminal()
{
  ;opens windows terminal
  Run, wt
}

runMilestoKm()
{
    Run, C:\Users\craig\archived\autohotkey\milestometres.ahk
}

runPyScriptLauncher()
{
    Run, C:\Users\%A_UserName%\ossu\script_launcher.py
}

ticketBillingLookup()
{
    FileDelete, C:\Users\%A_UserName%\tbl.txt
    Run, C:\Users\%A_UserName%\tbl.bat
    fileread,billing,C:\Users\%A_UserName%\tbl.txt
    msgbox % billing
}

repl()
{
    run, "C:\Users\%A_UserName%\archived\autohotkey\ahkcommandconsole.ahk"
}

    ::emerg::
emergency()
{
    InputBox, name, Contractor name?
    Stringupper,name,name
    setTemplateText("contractor.skt", name)
    (form = "BP") ? loadImageNG("leftonsite.skt") : loadImageNG("leftonsiter.skt")
}

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
iniwrite, %form%, %inifile%, variables, form
iniwrite, %stationcode%, %inifile%, variables, stationcode
iniwrite, %units%, %inifile%, variables, units
iniwrite, %bellmarked%, %inifile%, variables, bellmarked
iniwrite, %bellclear%, %inifile%, variables, bellclear
iniwrite, %rogersclear%, %inifile%, variables, rogersclear
iniwrite, %rogersmarked%, %inifile%, variables, rogersmarked
iniwrite, %locationdataobtained%, %inifile%, variables, locationdataobtained
IniWrite, %intersection%, %inifile%, variables, intersection
iniwrite, %currentpage%, %inifile%, variables, currentpage
IniWrite, %totalpages%, %inifile%, variables, totalpages
reload
return

#E::
Run,https://webapp.cablecontrol.ca/owa/auth/logon.aspx?replaceCurrent=1&url=https`%3a`%2f`%2fwebapp.cablecontrol.ca`%2fowa`%2f
;Run, openemail.py,,Maximize
;traytip, Opening Email,,3
return

#IfWinActive ahk_exe SketchToolApplication.exe


NumpadIns::
^PgUp::
ControlClick, OK,ahk_exe SketchToolApplication.exe
WinActivate, ahk_exe locateaccess.exe
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



#IfWinActive ahk_exe sketchtoolapplication.exe

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

^+f::
;uses the UIA_Browser class to find the search button and click it
uiab := new UIA_Browser("ahk_exe chrome.exe")
uiab.setfocus()
uiab.FindFirstByNameAndType("Search","button").Click()
return

    /* ^b:: ;change basemap to black
     * ;driver := ChromeGet()
     * basemap:="",g360bm:=""
     * if !(driver)
     * {
     *     driver := ChromeGet()
     * }
     * driver.findElementbyid("form_maplayer_btn").click()
     * wait()
     * basemap := driver.findElementbyId("GROUP_F_BASE1")
     * g360bm := driver.findElementbyId("GROUP_F_ROGERS_GO360")
     * if (g360bm.IsSelected = -1)
     *     g360bm.Click()
     * if (basemap.IsSelected = 0)
     *     basemap.Click()
     * ;msgbox % g360bm.IsSelected
     * return
     */

NumpadAdd::
Go360.ZoomIn()
return

NumpadSub::
Go360.ZoomOut()
return

::opsurv::
Run, "C:\Users\%A_UserName%\Documents\LibreAutomate\Main\exe\OpenSurveys\openSurveys.exe"
return

#IfWinActive

#IfWinActive
#IfWinActive ahk_exe SketchToolApplication.exe
#IfWinActive ahk_class #32770

    ;TEXT REPLACEMENT

    ::hp::HYDRO POLE
    ;::sl::STREET LIGHT
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
Notify("Opening Trello")
return

::OWMAIL::
Run,https://webapp.cablecontrol.ca/owa/auth/logon.aspx?
Notify("Opening Mail")
return

::OWECOM::
Run,https://my.ecompliance.com/
Notify("Opening ECompliance")
return

::owqbit::
Run, http://ec2.qbitmobile.com/dashboard.aspx
return

::owtime::
Progress,zh0 y30 cwblack ctyellow b,Opening timesheet...
Run, https://drive.google.com/drive/folders/137VF2fn9rW8HKjrqGjNpog0pYC_OsZXp
Sleep, 3000
Progress, off
return

::owmmap::
Notify("Opening Google MyMaps...")
Run, https://www.google.com/maps/d/u/0/
return

::owtmax::
Notify("Opening telmax egnyte server access")
Run, % "https://telmaxinc.egnyte.com"
return

;CABLE HOTKEYS

#IfWinActive, Tel ahk_exe sketchtoolapplication.exe
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

^1:: ;draw pedestal
MouseGetPos, pedx, pedy
MouseClick, L, 139, 611
wait()
Click,%pedx%,%pedy%
pedx:="",pedy:=""
clickSelection()
return

^2:: ;draw pole
drawPole()
return

drawPole()
{
    SetTitleMatchMode, 2
    CoordMode, Mouse, Window
    tt = TelDig SketchTool
    WinWait, %tt%
    IfWinNotActive, %tt%,, WinActivate, %tt%
    Sleep, 1404
    MouseGetPos, polex, poley
    MouseClick, L, 64, 636
    Sleep, 764
    MouseClick, L,%polex%,%poley%
    clickSelection()
    Sleep, 1000
}

;DRAW TRANSFORMER
^3::
MouseGetPos, txx, txy
MouseClick, L, 33, 534
wait()
Click,%txx%,%txy%
txx:="",txy:=""
clickSelection()
Return

^4::
return

^E::
activateEditMode()
{
    MouseClick("R")
    Sendinput("{Up 7}{Enter}")
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

::writeaddlist::
writeAddressList()
return

writeAddressList()
{
    if (InStr(FileExist("C:\Users\%A_UserName%\addlist.csv"), "A"))
    {
        FileDelete, C:\Users\%A_UserName%\addlist.csv
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
            FileAppend, % columnlist[5] . " " . columnlist[6] . ", " . columnlist[9] . "`n", C:\Users\%A_UserName%\addlist3.txt
        else
            FileAppend, % columnlist[6] . " & " . columnlist[14] . ", " . columnlist[9] . "`n", C:\Users\%A_UserName%\addlist3.txt
    }
    FileCopy, C:\Users\%A_UserName%\addlist3.txt, C:\Users\%A_UserName%\addresslistbackup.txt,1
    FileMove, C:\Users\%A_UserName%\addlist3.txt,C:\Users\%A_UserName%\addlist.csv,
    Msgbox, Done!

}

accessProperties()
{
    MouseClick("R")
    SendInput("{Up 2}{Enter}")
    wait()
}

#IfWinActive ahk_exe SketchToolApplication.exe
^Tab::
accessProperties()
return

#IfWinActive

::showerror::
displayErrorLog()
{
    Run, C:\Users\%A_UserName%\errorlog.txt
}

::showts::
displayTimesheet(today)
return

displayTimesheet(date)
{
    ;count := 0
    FileRead, TS, C:\Users\%A_UserName%\Desktop\archived\autohotkey\timesheet%date%.txt
    if !(FileExist("C:\Users\" A_UserName "\Desktop\archived\autohotkey\timesheet" . date . ".txt"))
        FileRead, TS, C:\Users\%A_UserName%\timesheet%date%.txt
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

::opmi::
openMapInfo()
{
    Notify("Opening MapInfo")
    Run, % "C:\Users\craig\As Builts\MAPINFO APT. JULY 06 2020\Aptum.wor"
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

::owrogers::
;opens Go360
Notify("Opening Go360")
Run, http://10.13.218.247/go360rogersviewer/
sleep 300
send, {down}{enter}
return

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
Run %ComSpec% start snippingtool
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

putTimestamp()
{
    uia := UIA_Interface()
    win := uia.ElementFromHandle()
    win.FindFirstByName("Insert current date").click()
    Click
    win.FindFirstByName("Selection").click()
}

+^d::
dumpElements()
return

`::LButton
Esc::Delete
return

;SKETCH RECTANGLE BOUNDARIES
;UPPER LEFT - 192, 512
;LOWER RIGHT - 948, 1152
; SKETCH_WIDTH := 756
; SKETCH_HEIGHT := 640

^F5::
insertEZDrawRP()
return

insertEZDrawRP(filename:=""){
    if !(filename) {
      FileSelectFile("C:\Users\craig\Documents\")
    }
    drawElement(filename,189,437,757,733)
    clickSelection()
}

insertEZDrawBA:
drawElement(FileSelectFile("C:\Users\craig\Documents\"),115,496)
clickSelection()
return

drawElement(filename,x,y,w := "",h := "",rotation := ""){
    WinActivate, ahk_exe sketchtoolapplication.exe
    loadImageNG(filename)
    sleep 400
    accessProperties()
    wait()
    ; element position
    Send, {Tab 2}
    sleep 200
    send, %x%,%y%{enter}
    if (w != "") or if (h != "")
    {
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
    Run, explore C:\Users\craig\AppData\Local\TelDig Systems\SketchTool\Cache\
}

addTemplateToDocs()
{
    ; open folder picker at c:/users/cr/appdata/local/teldig systems/sketchtool/cache
    ; copy selected file to my documents

    FileSelectFile, Template,, A_AppData\Local\Teldig Systems\Sketchtool\Cache,Select a template,*.skt
    FileCopy,%Template%,A_MyDocuments

}

::bpc::
writeBellPrimClear()
{
    Send, bellprimclear.skt
}

utilCount()
{
    CONTROLGET, TKLIST, LIST, col3,SysListView321, ahk_exe mobile.exe
    if (errorlevel) {
        msgbox % "Couldn't obtain ticket info"
        return
    }
    oUtility := StrSplit(tklist,"`n")
    belllist := [], roglist := [], beanfield :=[], envi := []
    for i in oUtility
    {
        if (oUtility[i] == "BCGN01") or if (oUtility[i] == "BCGN02")
            belllist.push(i)
        else if (oUtility[i] == "ROGYRK01") or if (oUtility[i] == "ROGSIM01")
            roglist.Push(i)
        else if (oUtility[i] == "APTUM01")
            beanfield.Push(i)
        else if (oUtility[i] == "ENVIN01")
            envi.Push(i)

    }
    MsgBox % "You have " . belllist.length() . " Bell tickets, " . roglist.length() . " Rogers tickets and " . beanfield.length() . " Beanfield tickets and " . envi.length() . " Envi tickets left"
}

sketchSearch()
{
    run, C:\Users\craig\archived\autohotkey\sketchsearch.ahk
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
    if (fileexist("C:\Users\craig\timesheet" today ".txt"))
        Run,gvim "C:\Users\craig\timesheet%today%.txt"
    else
        Run, gvim  "C:\Users\craig\Desktop\archived\autohotkey\timesheet%today%.txt"
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
changeVariable()
return

;Change variable on fly with chvar
changeVariable()
{
    editedvar := Inputbox("Enter variable to change")
    newval := Inputbox(,"Enter new value for " . editedvar . "`n" . editedvar " = " . %editedvar%)
    %editedvar% := newval
}

::shvar::
showVariableName()
{
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

;returns an output of each tickets coordinates?
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

getCoords()
{
    coords := []
    ladatapath := "C:\Users\craig\AppData\Local\TelDigFusion.Data\data\"
    uia := UIA_Interface()
    win := uia.ElementFromHandle(WinExist("A"))
    doc := win.FindFirstByNameAndType("LocateAccess - Cable Control Systems","Document").Value
    data := getTicketData()
    a := StrSplit(doc,"/")
    subdir := a.8 . "_" . a.9
    ladatapath .= subdir
    ;file loop needs full pattern similar to dir cmd
    Loop, Files, %ladatapath%\*.txt, R
    {
        file := A_LoopFileLongPath
    }
    FileReadLine,lat,%file%,66
    FileReadLine,long,%file%,67
    ;strreplace is faster than regexreplace
    coords[1] := strreplace(lat,"UR_POLY_X1::"), coords[2] := StrReplace(long,"UR_POLY_Y1::")
    return coords
}

    loadClearPyTemplate()
    {
        Suspend,On
        RunWait,% "C:\Users\craig\rogers_clear_script.py"
        Suspend,Off
    }

#IfWinActive ahk_exe cmd.exe
@::Tab
#IfWinActive

editscr()
{
    Edit
}

getmousepos(byref x := 0,byref y := 0)
{
    mousegetpos,x,y
    msgbox,% "X: " . x "`nY: " . y
}

#IfWinActive, ahk_exe LocateAccess.exe

^E::
editSketch()
return

editSketch()
{
    Text:= "|<>**50$15.Tzy01bzxk6c1Z0Mc651UcM521cKR2KcEpnybza01Tzs00U"

     if (ok:=FindText(69-150000, 49-150000, 69+150000, 49+150000, 0, 0, Text))
     {
        Text:="|<>**50$15.Tzy01bzxk6c1Z0Mc651UcM521cKR2KcEpnybza01Tzs00U"
        if (ok:=FindText(1022-150000, 48-150000, 1022+150000, 48+150000, 0, 0, Text))
        {
            CoordMode, Mouse
            X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
            Click, %X%, %Y%
        }
     }

}

Esc::
Notify("Exiting ticket...")
uia := uia_interface()
winactivate, ahk_exe locateaccess.exe
lael := uia.ElementFromHandle(WinActive("ahk_exe LocateAccess.exe"))
lael.FindFirstByNameandType("Cancel","Button").click()
return

^s::
uia := uia_interface()
result := Inputbox("Enter search term")
gridwin := uia.ElementFromHandle(WinActive("A"))
s := gridwin.FindFirstByName("Street").SetFocus()
Send, %result%
return

^f::
uia := uia_interface()
win := uia.ElementFromHandle()
win.FindFirstByName("Filter...").SetFocus()
return



dumpElements()
{
  uia := uia_interface()
  win := uia.ElementFromHandle(Winactive("A"))
  Clipboard := win.dumpall()
  msgbox, dumped
}

F9::
::SKAF::
sketchAutoFill()
return

RShift::
MBUTTON::
Menu, Mobile, Show
return

NUMPADENTER:: ;FINISH AND EMAIL TICKET
:::m::
    finishemail()
return

numpaddel:: ;COMPLET TICKET WITHOUT EMAILING
::oknoSend::
:::n::
    finishnoemail()
return

^f10::
    CraigRPA.writeClearTemplate()
return

!f10::
    CraigRPA.ClearFromTemplate()
return

>::
    nextImage()
    return

<::
    previousImage()
    return

nextImage()
{
    MouseClick, L, 1354, 419,1,5
}

previousImage()
{
    MouseClick, L, 33, 417,1,5

}

showTicketPictures()
{
    pics := []
    static Pic
    ladatapath := "C:\Users\craig\AppData\Local\TelDigFusion.Data\data\"
    uia := UIA_Interface()
    win := uia.ElementFromHandle(WinExist("A"))
    doc := win.FindFirstByNameAndType("LocateAccess - Cable Control Systems","Document").Value
    a := StrSplit(doc,"/")
    subdir := a.8 . "_" . a.9
    stationcode := a.9
    ladatapath .= subdir
     Loop, Files, %ladatapath%\*.png, R
    {
        pics.Push(LoadPicture(A_LoopFileFullPath))
    }
    Gui, tkpic: Add, Pic, w600 h-1 vPic +Border, % "HBITMAP:*" pics.1
    Gui, tkpic: Show
    Loop
    {
        ; Switch pictures!
        if (pics = "")
            break
        GuiControl,tkpic: , Pic, % "HBITMAP:*" Pics[Mod(A_Index, Pics.Length())+1]
        Sleep 3000
    }
    return
    tkpicGuiClose:
    tkpicGuiEscape:
    Gui, tkpic: Destroy
    Pic := ""
    pics := []
    return
}

 :::QAV::
        uia := UIA_Interface()
        win := uia.ElementFromHandle(WinActive("A"))
        win.FindFirstByName("COGECO",,2).click()
        return

; ADDS HIGH RISK FIBRE STICKER
::hiriskfibre::
    loadImageNG("high risk fibre.png")
return

; This code remaps the mouse wheel scrolling direction when the window with the title "LACMultiViewer.exe" is active.

#IfWinActive ahk_exe LACMultiViewer.exe
WheelDown::WheelUp
WheelUp::WheelDown
#IfWinActive

#h::  ; Win+H hotkey
; Get the text currently selected. The clipboard is used instead of
; "ControlGet Selected" because it works in a greater variety of editors
; (namely word processors).  Save the current clipboard contents to be
; restored later. Although this handles only plain text, it seems better
; than nothing:
ClipboardOld := Clipboard
Clipboard := "" ; Must start off blank for detection to work.
Send ^c
ClipWait 1
if ErrorLevel  ; ClipWait timed out.
    return
; Replace CRLF and/or LF with `n for use in a "send-raw" hotstring:
; The same is done for any other characters that might otherwise
; be a problem in raw mode:
ClipContent := StrReplace(Clipboard, "``", "````")  ; Do this replacement first to avoid interfering with the others below.
ClipContent := StrReplace(ClipContent, "`r`n", "``n")
ClipContent := StrReplace(ClipContent, "`n", "``n")
ClipContent := StrReplace(ClipContent, "`t", "``t")
ClipContent := StrReplace(ClipContent, "`;", "```;")
Clipboard := ClipboardOld  ; Restore previous contents of clipboard.
ShowInputBox(":T:`::" ClipContent)
return

ShowInputBox(DefaultValue)
{
    ; This will move the input box's caret to a more friendly position:
    SetTimer, MoveCaret, 10
    ; Show the input box, providing the default hotstring:
    InputBox, UserInput, New Hotstring,
    (
    Type your abreviation at the indicated insertion point. You can also edit the replacement text if you wish.

    Example entry: :R:btw`::by the way
    ),,,,,,,, %DefaultValue%
    if ErrorLevel  ; The user pressed Cancel.
        return

    if RegExMatch(UserInput, "O)(?P<Label>:.*?:(?P<Abbreviation>.*?))::(?P<Replacement>.*)", Hotstring)
    {
        if !Hotstring.Abbreviation
            MsgText := "You didn't provide an abbreviation"
        else if !Hotstring.Replacement
            MsgText := "You didn't provide a replacement"
        else
        {
            Hotstring(Hotstring.Label, Hotstring.Replacement)  ; Enable the hotstring now.
            FileAppend, `n%UserInput%, %A_ScriptFullPath%  ; Save the hotstring for later use.
        }
    }
    else
        MsgText := "The hotstring appears to be improperly formatted"

    if MsgText
    {
        MsgBox, 4,, %MsgText%. Would you like to try again?
        IfMsgBox, Yes
            ShowInputBox(DefaultValue)
    }
    return

    MoveCaret:
    WinWait, New Hotstring
    ; Otherwise, move the input box's insertion point to where the user will type the abbreviation.
    Send {Home}{Right 3}
    SetTimer,, Off
    return
}
