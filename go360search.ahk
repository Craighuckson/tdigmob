#Include, <uia_browser>
#Include, <uia_interface>

#include <obj2string>

uiab := new UIA_Browser("ahk_exe chrome.exe")
uiab.setfocus()
uiab.FindFirstByNameAndType("Search","button").Click()
ExitApp
