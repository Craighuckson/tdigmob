#Include <uia_interface>
#include <obj2string>


stillScreening()
{
	WinActivate, ahk_exe locateaccess.exe
	screen := uia_interface().ElementFromHandle().WaitElementExistByName("filtered",0x4,2,True,5000)

	if !(screen) {
		MsgBox % "Element not found"
		return 2
	}

	if (instr(screen.CurrentName, "0 filtered"))
		return False
	else
		return True
}
