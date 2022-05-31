
#Include <acc>
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
	Send, ^f
}

isLongFindDialog()
{
	WinActivate, ahk_exe mapinfor.exe
	ControlGet,islongdlg,Visible,,ComboBox1,ahk_class #32770
	if (islongdlg = 1)
		return true
}


setFindParams()
{
	SetTitleMatchMode, 2
	CoordMode, Mouse, Window

	tt = Find ahk_class #32770
	WinWait, %tt%
	IfWinNotActive, %tt%,, WinActivate, %tt%

	Sleep, 865

	Send, {Blind}{Alt Down}t{Alt Up}

	Sleep, 553

	Send, {Blind}ro

	Sleep, 538

	Send, {Blind}{Tab}{Tab}

	Sleep, 569

	Send, {Blind}ci

	Sleep, 655

	Send, {Blind}{Enter}

	tt = Find ahk_class #32770
	WinWait, %tt%
	IfWinNotActive, %tt%,, WinActivate, %tt%
}

getStreetAddress()
{
	
}

finalizeAptumLookup(address)
{
	SetTitleMatchMode, 2
	CoordMode, Mouse, Window

	tt = Find ahk_class #32770
	WinWait, %tt%
	IfWinNotActive, %tt%,, WinActivate, %tt%

	Sleep, 616

	Send, %address%{Enter}

	Sleep, 2815

	Send, {Blind}{Enter}

	tt = MapInfo ProViewer - [Aptum_Excl_UG_CCS,...,Buildin ahk_class xvt320mditask100
	WinWait, %tt%
	IfWinNotActive, %tt%,, WinActivate, %tt%
}


aptumLookup()
{
	InputBox, address, Address, Enter a Toronto Address
	WinActivate,ahk_exe mapinfor.exe
	openFindDialog()
	if (isLongFindDialog() = true)
	{
		setFindParams()
	}
	finalizeAptumLookup(address)
}