;GUI FOR EVERYTHING

Gui, Add, Text, , Use existing? 
;dropdown yes no
Gui, Add, Text, , Dig Boundaries
Gui, Add, Text, vlbllandbase hidden, Landbase
Gui, Add, Text, vlblhouse1 hidden, House 1
Gui, Add, Text, vlblhouse2 hidden, House 2
;dropdown of all dig boundaries + manual 
Gui, Add, Radio, vradYes gpickfiles ym, Yes
Gui, Add, Radio, vradNo, No
Gui, Add, ComboBox, vdigboundary gshowmoreoptions, Manual|Driveway to Driveway|BL to BL|FTTH Road Crossing|PL to PL|Street to Street|Corner|Short Gas
Gui, Add, ComboBox, vlandbase hidden, N|S|E|W|NE|SE|SW|NW|H|V|INT
Gui, Add, Edit, vhouse1 hidden
Gui, Add, Edit, vhouse2 Hidden
Gui, Show
return 

pickfiles:
		FileSelectFile, chosen, , %a_mydocuments%, Choose file, *.skt
return

showmoreoptions:
GuiControl, Show, lbllandbase
GuiControl, Show, lblhouse1
GuiControl, Show, lblhouse2
GuiControl, Show, landbase
GuiControl, Show, house1
GuiControl, Show, house2
Gui, Show, AutoSize
return


