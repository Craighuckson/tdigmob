;VPN automation library
#Include, <UIA_Interface>

class VPN
{

  __New(state := "")
  ; constructor
  {
    this.state := state
  }

  Password[]
  ; returns the password for the VPN
  {
    get {
      if this.state = "rogers"
        return "T3yKBZby"
      else if this.state = "beanfield"
        return "HardyChall7nge"
      else return ""
    }
  }


  GetState()
  {

    Runwait, %ComSpec% /c ""C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe" "stats" | clip ",,Hide
    stdout := Clipboard
    if (InStr(stdout, "rogers"))
      return "rogers"
    else if (InStr(stdout, "beanfield"))
      return "beanfield"
    else
      return "disconnected"
  }

  GetSelection()
  {
    Loop
      {
        Inputbox, selection, VPN Selection, Enter "b"`,"r" or "d"
        StringLower, selection, selection
      }
      Until (selection == "b" || selection == "r" || selection == "d" || ErrorLevel > 0)
      return selection
  }

  On()
  {
  uia := UIA_Interface()
  vpnpass := this.Password
  DetectHiddenWindows,On
  WinShow,Cisco AnyConnect Secure Mobility Client ahk_class #32770
  WinActivate, Cisco AnyConnect Secure Mobility Client ahk_class #32770 ahk_exe vpnui.exe
  win := uia.ElementFromHandle(WinExist("A"))
  win.WaitElementExistByName("Ready to connect.")
  win.FindFirstByName("Open").click()
  if (this.state == "rogers")
    util := "VPN_Access_3rd_Party_Techs"
  else
    util := "Beanfield"
  win.FindFirstByName(util).click()
/*


  win3 := uia.ElementFromHandle("A")
  win3.WaitElementExistByName("Please enter your username and password.")
  win3.FindFirstByNameAndType("Password:","Edit").SetValue(vpnpass)
  win3.FindFirstByName("OK").click()
  win2 := uia.ElementFromHandle(Winexist("A"))
  win.WaitElementExistByNameAndType("Accept","Button")
  win.FindFirstByNameAndType("Accept","Button").click()
*/}

  }

  Off()
  {

  }



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

whichVPN()
{
  RunWait, whichvpn.py,,Hide
  FileRead, status, vpn_util.txt
  return status
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
  uia := UIA_Interface()
  vpnpass := getVPNPass()
  DetectHiddenWindows,On
  WinShow,Cisco AnyConnect Secure Mobility Client ahk_class #32770
  WinActivate, Cisco AnyConnect Secure Mobility Client ahk_class #32770 ahk_exe vpnui.exe
  win := uia.ElementFromHandle(WinExist("A"))
  win.WaitElementExistByName("Ready to connect.")
  ;win.FindFirstByName("Open").click()
  ;win.FindFirstByName("VPN_Access_3rd_Party_Techs").click()

  win.FindFirstByName("Connect").click()
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
