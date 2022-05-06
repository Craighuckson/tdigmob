
#Include <acc>
#Include <obj2string>

openFindDialog()
{
	Send, ^f
}

isLongFindDialog()
{
	ControlGet,islongdlg,Visible,,ComboBox1,ahk_class #32770
	if (islongdlg = 1)
		return true
}


setFindParams()
{
	;Acc_Get("Select","4.3.4.3.4",9,"ahk_exe mapinfor.exe")
	SetControlDelay,100
	Control,Choose,9,ComboBox1, ahk_class #32770
	Control,Choose,6,ComboBox3, ahk_class #32770
	ControlClick,Button4,ahk_class #32770
}

getStreetAddress()
{
	
}

finalizeAptumLookup(address)
{
	WinActivate, ahk_exe mapinfor.exe
	ControlSetText,Edit1,%address%,ahk_class #32770
	Sleep 500
	ControlSend,Button5,{Enter},ahk_class #32770
	ControlSend,Button5,{Enter},ahk_class #32770
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



