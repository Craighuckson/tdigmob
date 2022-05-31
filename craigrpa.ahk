;Craig rpa

#include <acc>
#Include <ahkez>
#Include <obj2string>

;CONSTANTS

MOBILEWIN := "ahk_exe mobile.exe"
STDIALOG := "ahk_class #32770 ahk_exe sketchtoolapplication.exe"

;HELPER FUNCTIONS

;Acc helper function for Mobile tabs
SelectTab(childID)
{
	Acc_Get("DoAction", "4.1.4.1.4.1.4.1.4.11.4",childID,"ahk_exe mobile.exe")
	Sleep 150
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
	}
}

FixStreetName(street)
{
	return RegExReplace(street,"^ | \(REGIONAL.*| \(COUNTY.*| \(HIGHW.*")
}

FixTownName(town)
{
	return RegExReplace(town,"\,.*")
}

;CLASS DEFINITIONS


class Mobile
{
	

	SelectDrawingsTab()
	{
		SelectTab(3)
	}

	SelectLocationTab()
	{
		SelectTab(1)
	}

	SelectDigInfoTab()
	{
		SelectTab(2)
	}
 
	SelectCableTV()
	{
		this.SelectNewForm()
		MouseClick("L",915,498)
		sleep 150
	}

	SelectAuxilliary()
	{
		this.SelectNewForm()
		MouseClick("L",953,392)
	}

	SelectCogeco()
	{
		this.SelectNewForm()
		MouseClick("L",920,409)
	}

	SelectPending()
	{
		CONTROL, choose, 3, ComboBox1, ahk_exe mobile.exe
	}


	ClickOK()
	{
		MouseClick("L",1079,695)
	}

	FinishWithEmail()
	{
		this.ClickOK()
		WinWaitActive("ahk_class #32770")
		Send("y")
		WinWaitActive("Paper output to contractor")
		Send("{Enter}")
	}

	FinishNoEmail()
	{
		this.ClickOK()
		WinWaitActive("ahk_class #32770")
		Send("n")
	}
}

class SketchTool
{

	WaitUntilSketchToolReady()
	{
		WaitForImage(A_ScriptDir . "\testassets\waitrotation.png")
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
		SendInput("!i")
		Sleep(50)
		SendInput("{Down 8}")
		Sleep(50)
		SendInput("{Enter}")
	}

	OpenSaveDialog()
	{
		Send("!f{Enter}")
	}

	LoadImage(filename,ungroup := true)
	{
		this.OpenImageDialog()
		this.WaitDialogBox()
		Send(filename)
		Send("{Enter}")
		this.WaitCloseDialogBox()
		if (ungroup = true)
		{
			send("!i{Down}{Enter}")
		}
	}

	SaveImage(filename := "")
	{
		this.OpenSaveDialog()
		this.WaitDialogBox()
		if (filename != "")
		{
			send(filename)
			Send("{Enter}")
		}
		else
		{
			this.WaitCloseDialogBox()
		}
	}

}

class Ticket
{
  GetData()
	{
		Mobile.SelectLocationTab()
		ControlGet, number, Line,1, edit2, ahk_exe Mobile.exe
		ControlGet, street, line,1, Edit6, ahk_exe Mobile.exe
		ControlGet, intersection, line,1,edit10, ahk_exe mobile.exe
		ControlGet, intersection2, line,1,edit12, ahk_exe mobile.exe
		ControlGet, stationCode, line,1, edit9, ahk_exe mobile.exe
		ControlGetText, digInfo, edit22, ahk_exe mobile.exe
		controlget, ticketNumber, line, 1, edit1, ahk_exe mobile.exe			
		controlget, town, line, 1, edit13, ahk_exe mobile.exe
		ControlGet, remarks, line, 1, Edit23, % MOBILEWIN
		this.number := number
		this.street := CraigRpa.FixStreetName(street)
		this.intersection := CraigRPA.FixStreetName(intersection)
		this.intersection2 := CraigRPA.FixStreetName(intersection2)
		this.stationCode := stationCode
		this.ticketNumber := ticketNumber
		this.digInfo := digInfo
		this.remarks := remarks
		this.town := FixTownName(town)
		this.workType := this.GetWorkType()
		return this
	}



	GetWorkType()
	{
		Mobile.SelectDigInfoTab()
		ControlGetText, worktype, Edit1, ahk_exe mobile.exe
		return worktype
	}


}

class Sketch extends SketchTool
{
	

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


WinActivate(MOBILEWIN)
sleep 200
t := new Ticket()
Mobile.SelectLocationTab()
Sleep(100)
t.GetData()
t.GetWorkType()
Mobile.SelectCogeco()
SketchTool.WaitUntilSketchToolReady()
Sketch.WriteTemplateText("nboundary.skt",t.street)
return