#include <findtext>
#include <DebugWindow>
;#include <V1TOV1FUNC>
;#include <libcon>
#include <json>
#include <Acc>
#include *i scrollbox.ahk
#include <cpuload>
#include <UIA_Interface>
#include <UIA_Browser>
#include <AHKEZ>
#include C:\Users\cr\teldig\lib\vis2.ahk
#Include <AHKEZ_Debug>
#Include <EntryForm>
;#Include Canvas.ahk
#Include <printstack>
;#Include multiviewer.ahk
#Include C:\Users\Cr\teldig\vpn.ahk
#Include C:\Users\Cr\teldig\aptumlookup.ahk
#Include <chrome>

BlockInput("SendAndMouse")
SetControlDelay(50)
TraySetIcon("C:\Users\cr\teldig\tico.png")

inifile := "C:\Users\cr\teldig\teldig.ini"

form := IniRead(inifile,"variables","form","")
bellmarked := IniRead(inifile,"variables","bellmarked","")
bellclear := IniRead(inifile,"variables","bellclear","")
rogersclear := IniRead(inifile,"variables","rogersclear","")
rogersmarked := IniRead(inifile,"variables","rogersmarked","")
locationdataobtained := IniRead(inifile,"variables","locationdataobtained", 0)
street := IniRead(inifile,"variables","street","")
intersection := IniRead(inifile,"variables","intersection","")
currentpage := IniRead(inifile,"variables","currentpage","")
totalpages := IniRead(inifile,"variables","totalpages","")

tempvar1 := ""
tempvar2 := ""
tempvar3 := ""
tempvar4 := ""
tempvar5 := ""

today := A_DD . " " . A_MM . " " . A_YYYY

la_menu := Menu()
la_menu.Add("&Records Lookup", recordsLookup)
la_menu.Add("&Sketch Autofill", sketchAutofill)
la_menu.Add("Radius Autofill", selectRadiusProjectType)
la_menu.Add("Add to &Timesheet", addToTimesheet)
la_menu.Add("Autofill CUA", autofillCUA)
la_menu.Add("Create New Project",newproj)
la_menu.Add("Load From Project",autoinsertSketches)
la_menu.Add("Reset Form&Var",resetFormVar)



~CapsLock::
{
  capstate := GetKeyState("CapsLock","T")
  if (capstate)
    Notify("CapsLock ON")
  else
    Notify("CapsLock OFF")
}
