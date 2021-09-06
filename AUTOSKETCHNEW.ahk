DWRoutine(landbase)
{
	global
	num := getBLNum()
	num1 := num[1], num2 := num[2]
	if landbase in NE, SE, SW, NW, nw, sw, se, ne
	{
		intdir := isInterSketch()
		inter := isInterText()
	}
	rclear := rogClear()
	switch landbase
	{
	Case "n":
		WinActivate, ahk_exe sketchtoolapplication.exe
		setTemplateText("NBoundary.skt", "NPL " street)
		setTemplateText("SBoundary.skt", "NCL " street)
		setTemplateText("WBoundary.skt", "ERE DW " num.1 " " street)
		setTemplateText("EBoundary.skt", "ERE DW " num.2 " " street)

		wait()
		clickSelection()

	Case "nw":
		focusSketchtool()
		if (intdir = "h")
		{
			setTemplateText("NBoundary.skt", "NPL " xstreet)
			setTemplateText("SBoundary.skt", "NCL " xstreet)
			setTemplateText("WBoundary.skt", "ERE DW " num.1 " " xstreet)
			setTemplateText("EBoundary.skt", "WCL " vstreet)
		} else
		{
			setTemplateText("NBoundary.skt", "NRE DW " num.1 " " vstreet)
			setTemplateText("SBoundary.skt", "NCL " xstreet)
			setTemplateText("Wboundary.skt", "WPL " vstreet)
			setTemplateText("EBoundary.skt", "WCL " vstreet)
		}
		wait()
		clickSelection()

	Case "ne":
		focusSketchtool()
		if (intdir = "h")
		{
			setTemplateText("NBoundary.skt", "NPL " xstreet)
			setTemplateText("SBoundary.skt", "NCL " xstreet)
			setTemplateText("WBoundary.skt", "ERE DW " num.1 " " xstreet)
			setTemplateText("EBoundary.skt", "ECL " vstreet)
		} else
		{
			setTemplateText("NBoundary.skt", "NRE DW " num.1 " " vstreet)
			setTemplateText("SBoundary.skt", "NCL " xstreet)
			setTemplateText("Wboundary.skt", "EPL " vstreet)
			setTemplateText("EBoundary.skt", "ECL " vstreet)
		}
		wait()
		clickSelection()

	Case "s":
		WinActivate, ahk_exe sketchtoolapplication.exe
		setTemplateText("NBoundary.skt", "SCL " street)
		setTemplateText("SBoundary.skt", "SPL " street)
		setTemplateText("Wboundary.skt", "ERE of DW" . num1 . " " . street)
		setTemplateText("EBoundary.skt", "ERE of DW " . num.2 . " " . street)
		wait()
		clickSelection()

	Case "se":
		focusSketchtool()
		if (intdir = "h")
		{
			setTemplateText("NBoundary.skt", "SCL " xstreet)
			setTemplateText("SBoundary.skt", "SPL " xstreet)
			setTemplateText("WBoundary.skt", "ERE DW " num.1 " " xstreet)
			setTemplateText("EBoundary.skt", "ECL " vstreet)
		} else
		{
			setTemplateText("SBoundary.skt", "NRE DW " num.1 " " vstreet)
			setTemplateText("NBoundary.skt", "SCL " xstreet)
			setTemplateText("Wboundary.skt", "EPL " vstreet)
			setTemplateText("EBoundary.skt", "ECL " vstreet)
		}
		wait()
		clickSelection()

	Case "SW":
		focusSketchtool()
		if (intdir = "h")
		{
			setTemplateText("SBoundary.skt", "SPL " xstreet)
			setTemplateText("NBoundary.skt", "SCL " xstreet)
			setTemplateText("WBoundary.skt", "ERE DW " num.1 " " xstreet)
			setTemplateText("EBoundary.skt", "WCL " vstreet)
		}
		else
		{
			setTemplateText("NBoundary.skt", "NRE DW " num.1 " " vstreet)
			setTemplateText("SBoundary.skt", "SCL " xstreet)
			setTemplateText("Wboundary.skt", "WPL " vstreet)
			setTemplateText("EBoundary.skt", "WCL " vstreet)
		}
		wait()
		clickSelection()

	Case "w":
	WinActivate, ahk_exe sketchtoolapplication.exe
	setTemplateText("NBoundary.skt", "WCL " street)
	setTemplateText("SBoundary.skt", "WPL " street)
	setTemplateText("WBoundary.skt", "NRE of DW " . num.1 . " " . street)
	setTemplateText("EBoundary.skt"), "NRE of DW " . num.2 . " " . street)
	loadImageNG("NBoundary.skt")
	wait()
	clickSelection()

Case "e":
	WinActivate, ahk_exe sketchtoolapplication.exe
	setTemplateText("NBoundary.skt","ECL " street)
	setTemplateText("SBoundary.skt","EPL " street)
	setTemplateText("WBoundary.skt","NRE of DW " . num.1 . " " . street)
	setTemplateText("EBoundary.skt","NRE of DW " . num.2 . " " . street)
	wait()
	clickSelection()
	}

	if(rclear)
	    {
	        
		
}

autoSketchNew()
{
	landbase := getLandbase()
	digboundary := getDigBoundaries()
	switch digboundary
	{
	case "1":
		DWRoutine(landbase)

	case "2":
		BLRoutine()

	case "3":
		RCRoutine()

	case "4":
		PLRoutine()

	case "5":
		PL4Routine()

	case "6":
		streetToStreetRoutine()

	case "7":
		cornerRoutine()

	default:
		manualRoutine()

		WinWaitClose, ahk_exe SketchToolApplication.exe
		newPagePrompt()
	}
}
