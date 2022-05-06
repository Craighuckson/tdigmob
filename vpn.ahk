;VPN automation library

getVPNPass()
{
	VPNPASS := "J%sK42E4"
	return VPNPaSS
}


isVPN()
{
	RunWait, C:\Users\Cr\rogemailhelper\rogemailgen\isvpn.py,,Hide
	FileRead, status, C:\Users\Cr\vpnstatus.txt
	if (status = "True")
		return true
	else
		return false
}


vpnToggle()
{
	isvpn := isvpn()
	if (isvpn = 0) {
		vpnOn()
	}
	else if (isvpn = 1) {
		vpnOff()
	}
}

vpnOn() ; Logs into VPN automatically
{
	DetectHiddenWindows, ON
	WinShow, Cisco AnyConnect Secure Mobility Client ahk_class #32770
	WinActivate, Cisco AnyConnect Secure Mobility Client ahk_class #32770 ahk_exe vpnui.exe
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
	Winshow, Cisco AnyConnect Secure Mobility Client ahk_class #32770
	WinActivate, Cisco AnyConnect Secure Mobility Client ahk_class #32770
	ControlClick("Button1","Cisco AnyConnect Secure Mobility Client") ; disconnect
	WinClose, ahk_exe vpnui.exe
}