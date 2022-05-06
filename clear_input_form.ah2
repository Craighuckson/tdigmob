;clear input form gui
#SingleInstance Force

cleargui := Gui(,"Rogers Clears")
cleargui.AddText("x168 y40 w117 h21 +0x200","Ticket Number:")
cleargui.AddText("x168 y80 w117 h21 +0x200","Total Pages:")
cleargui.AddText("x168 y120 w117 h21 +0x200", "North Boundary:")
cleargui.AddText("x168 y160 w117 h21 +0x200", "South Boundary:")
cleargui.AddText("x168 y200 w117 h21 +0x200", "West Boundary:")
cleargui.AddText("x168 y240 w117 h21 +0x200", "East Boundary:")
cleargui.AddEdit("vEdtTotalPages x344 y80 w120 h21 Number")
cleargui.AddEdit("vEdtTicketNumber x344 y40 w120 h21 Number")
cleargui.AddEdit("vEditNBound x344 y120 w120 h21 Uppercase")
cleargui.AddEdit("vEditSBound x344 y160 w120 h21 Uppercase")
cleargui.AddEdit("vEditWBound x344 y200 w120 h21 Uppercase")
cleargui.AddEdit("vEditEBound x344 y240 w120 h21 Uppercase")
btnSubmit := cleargui.AddButton("x280 y352 w80 h23", "&Submit")

cleargui.Show("w620 h420")
btnSubmit.OnEvent("Click",SubmitData)
cleargui.OnEvent("Close",GuiClose)

SubmitData(*)
{
	formvals := cleargui.Submit()
	for n,v in formvals.OwnProps()
		{
			MsgBox(v)
		}
	return formvals
}

GuiClose(*)
{
	cleargui.Destroy()
}



