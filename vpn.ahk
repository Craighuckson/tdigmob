;VPN automation library

getVPNPass()
{
	VPNPASS := "7K2aVGxs"
	return VPNPaSS
}

isvpn() {
	DetectHiddenWindows, ON
	WinShow, Cisco AnyConnect Secure Mobility Client ahk_class #32770
	WinActivate, Cisco AnyConnect Secure Mobility Client ahk_class #32770, , ahk_class VPNUI
	Text:="|<>*181$35.000Tzy000zzY003zz87zbzwEzzDzlbzyST7TwQwSDz01wMzw03w3zk07sDx007szy00Dtzc00DzzE00DzyU00Dzx000Dze0023sI006U0c00Bo1E00Pc2U00rE5001iUDzzzzy00000600000B"
	if (ok:=FindText(534-150000, 350-150000, 534+150000, 350+150000, 0, 0, Text))
	{
		return true
	}
	else
		return false
}

vpnToggle()
{
	DetectHiddenWindows, ON
	WinShow, Cisco AnyConnect Secure Mobility Client ahk_class #32770
	WinActivate, Cisco AnyConnect Secure Mobility Client ahk_class #32770 ahk_exe vpnui.exe ; shows client
	;imagesearch,,,0,0,1366,768,vpnon.png ; search for checkmark
	Text:="|<>*181$35.000Tzy000zzY003zz87zbzwEzzDzlbzyST7TwQwSDz01wMzw03w3zk07sDx007szy00Dtzc00DzzE00DzyU00Dzx000Dze0023sI006U0c00Bo1E00Pc2U00rE5001iUDzzzzy00000600000B"
	(ok:=FindText(534-150000, 350-150000, 534+150000, 350+150000, 0, 0, Text)) ? vpnOff() : vpnOn() ; if image found go to turn off fxn, otherwise go to vpnon
	DetectHiddenWindows, Off
}

vpnOn() ; Logs into VPN automatically
{
	vpnpass := getVPNPass()
	SetControlDelay,-1
	;ControlClick, Connect, ahk_exe vpnui.exe,,,,na
	CONTROLCLICK("Connect", "Cisco AnyConnect Secure Mobility Client") ; connect and log in
	WinWaitactive, Cisco AnyConnect | VPN_Access_3rd_Party_Techs,,10
	if errorlevel
	{
		MsgBox Could Not Find Window
		return
	}
	waitCaret()
	sleep 500
	SendRaw, % vpnpass
	sleep 800
	Send, {enter}
	Sleep 500
	Send, {enter}
}

vpnOff() {
	WinActivate, Cisco AnyConnect Secure Mobility Client ahk_class #32770
	ControlClick("Button1","Cisco AnyConnect Secure Mobility Client") ; disconnect
	WinClose, ahk_exe vpnui.exe
}