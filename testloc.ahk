;autohotkey - 2 button gui that returns the name of the button clicked



ButtonPress := "" ; initialize variable to store button press

CreateGUI()
{
    Gui, Add, Button, x10 y10 w100 h50 gTevin, Tevin ; create Tevin button
    Gui, Add, Button, x120 y10 w100 h50 gNathaniel, Nathaniel ; create Nathaniel button
    Gui, Show, w250 h70, Choose a name ; show the GUI
    WinWaitClose, Choose a name
    Return ButtonPress ; return the name of the button that was pressed
}

Tevin()
{
    global ButtonPress
    ButtonPress := "Tevin"
}

Nathaniel()
{
    global ButtonPress
    ButtonPress := "Nathaniel"
}


; example usage
Name := CreateGUI()
MsgBox, You selected %Name%


GuiClose:
ButtonPress := "Close"
Return
