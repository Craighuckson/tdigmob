;VPN automation library
;#Include, <UIA_Interface>

getVPNPass()
{
	VPNPASS := "T3yKBZby"
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
	; DetectHiddenWindows, ON
  ; WinShow, Cisco AnyConnect Secure Mobility Client ahk_class #32770
	; WinActivate, Cisco AnyConnect Secure Mobility Client ahk_class #32770 ahk_exe vpnui.exe
	; vpnpass := getVPNPass()
	; SetControlDelay,-1
	; ;ControlClick, Connect, ahk_exe vpnui.exe,,,,na
	; CONTROLCLICK("Connect", "Cisco AnyConnect Secure Mobility Client") ; connect and log in
	; WinWaitactive, Cisco AnyConnect | VPN_Access_3rd_Party_Techs,,10
	; if errorlevel
	; {
	; 	MsgBox Could Not Find Window
	; 	return
	; }
	; waitCaret()
	; sleep 500
	; SendRaw, % vpnpass
	; sleep 800
	; Send, {enter}
	; Sleep 500
	; Send, {enter}
  uia := UIA_Interface()
  vpnpass := getVPNPass()
  DetectHiddenWindows,On
  WinShow,Cisco AnyConnect Secure Mobility Client ahk_class #32770
  WinActivate, Cisco AnyConnect Secure Mobility Client ahk_class #32770 ahk_exe vpnui.exe
  win := uia.ElementFromHandle(WinExist("A"))
  win.WaitElementExistByName("Ready to connect.")
  win.FindFirstByName("Connect").click()
  ;WinActivate("Cisco AnyConnect | VPN_Access_3rd_Party_Techs")
  ;WinWaitActive("Cisco AnyConnect | VPN_Access_3rd_Party_Techs")
  win3 := uia.ElementFromHandle("A")
  win3.WaitElementExistByName("Please enter your username and password.")
  win3.FindFirstByNameAndType("Password:","Edit").SetValue(vpnpass)
  win3.FindFirstByName("OK").click()
  win2 := uia.ElementFromHandle(Winexist("A"))
  win.WaitElementExistByNameAndType("Accept","Button")
  win.FindFirstByNameAndType("Accept","Button").click()
}

vpnOff() {
	Winshow, Cisco AnyConnect Secure Mobility Client ahk_class #32770
	WinActivate, Cisco AnyConnect Secure Mobility Client ahk_class #32770
	;~ ControlClick("Button1","Cisco AnyConnect Secure Mobility Client") ; disconnect
	;~ WinClose, ahk_exe vpnui.exe
	uia := UIA_Interface()
	win := uia.ElementFromHandle()
	win.FindFirstByName("Disconnect").click()
	WinClose,ahk_exe vpnui.exe
}
