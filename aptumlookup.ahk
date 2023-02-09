
#Include <acc>
#Include <UIA_Interface>
#Include <obj2string>

activateMapInfo()
{
	if (WinExist("ahk_exe mapinfor.exe"))
		WinActivate,ahk_exe mapinfor.exe
	else
	{
		Run,"C:\Users\Cr\As Builts\MAPINFO APT. JULY 06 2020\Aptum.wor"
		sleep 5000
		WinActivate,ahk_exe mapinfor.exe
	}
}

openFindDialog()
{
	;Send, ^f
	uia := uia_interface()
	win := uia.ElementFromHandle(WinActive("ahk_exe MAPINFOR.EXE"))
	win.FindFirstByName("Select").click()
	sleep 150
	win.FindFirstBy("Name='Find...'").Click()
}

isLongFindDialog()
{
	WinActivate, ahk_exe mapinfor.exe
	ControlGet,islongdlg,Visible,,ComboBox1,ahk_class #32770
	if (islongdlg = 1)
		return true
	else
		return false
}


setFindParams()
{
/* 	SetTitleMatchMode, 2


 * 	CoordMode, Mouse, Window
 * 
 * 	tt = Find ahk_class #32770
 * 	WinWait, %tt%
 * 	IfWinNotActive, %tt%,, WinActivate, %tt%
 * 
 * 	Sleep, 865
 * 
 * 	Send, {Blind}{Alt Down}t{Alt Up}
 * 
 * 	Sleep, 553
 * 
 * 	Send, {Blind}ro
 * 
 * 	Sleep, 538
 * 
 * 	Send, {Blind}{Tab}{Tab}
 * 
 * 	Sleep, 569
 * 
 * 	Send, {Blind}ci
 * 
 * 	Sleep, 655
 * 
 * 	Send, {Blind}{Enter}
 * 
 * 	tt = Find ahk_class #32770
 * 	WinWait, %tt%
 * 	IfWinNotActive, %tt%,, WinActivate, %tt%
 */
/*  tt = Find ahk_class #32770
 *  WinWait, %tt%
 *  IfWinNotActive, %tt%,, WinActivate, %tt%
 */
 uia := uia_interface()
 ;win := uia.ElementFromHandle(WinActive("ahk_class #32770"))
 WinWaitActive, ahk_class #32770
 win := uia.ElementFromHandle()
 win.FindFirstBy("ControlType=ComboBox AND Name='Search Table:' AND AutomationId='4'").SetFocus()
 Send,ro
 win.FindFirstBy("ControlType=ComboBox AND Name='Refine Search with Table:'").SetFocus()
 Send,ci
 sleep 500
 win.FindFirstByNameAndType("OK","Button").click()
}

getStreetAddress()
{
	
}

finalizeAptumLookup(address)
{
/* 	SetTitleMatchMode, 2
 * 	CoordMode, Mouse, Window
 * 
 * 	tt = Find ahk_class #32770
 * 	WinWait, %tt%
 * 	IfWinNotActive, %tt%,, WinActivate, %tt%
 * 
 * 	Sleep, 616
 * 
 * 	Send, %address%{Enter}
 * 
 * 	Sleep, 2815
 * 
 * 	Send, {Blind}{Enter}
 * 
 * 	tt = MapInfo ProViewer - [Aptum_Excl_UG_CCS,...,Buildin ahk_class xvt320mditask100
 * 	WinWait, %tt%
 * 	IfWinNotActive, %tt%,, WinActivate, %tt%
 */
 uia := uia_interface()
 win := uia.ElementFromHandle()
 WinWaitActive, ahk_class #32770
 win.WaitElementExistByName("STREET")
 win.FindFirstByNameAndType("STREET","Edit").SetValue(address)
 win.FindFirstByName("OK").click()
 tor := win.WaitElementExistByName("Toronto",,,,5000)
 if (!tor) {
	MsgBox % "Couldn't find address"
	return
}
 tor.click()
}


aptumLookup(address:="")
{
    if (address == "")
     InputBox, address, Address, Enter a Toronto Address
	WinActivate,ahk_exe mapinfor.exe
	openFindDialog()
	if (isLongFindDialog() = true)
	{
		setFindParams()
	}
	finalizeAptumLookup(address)
}
