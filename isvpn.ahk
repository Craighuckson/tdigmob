isVPN()
{
	RunWait, C:\Users\Cr\rogemailhelper\rogemailgen\isvpn.py,,Hide
	FileRead, status, C:\Users\Cr\vpnstatus.txt
	if (status = "True")
		return true
	else
		return false
}

MsgBox, % isVPN()