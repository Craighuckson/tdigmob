#include <findtext>

CheckForMapMode()
  {
    Winactivate,ahk_exe locateaccess.exe
    ;this checks for the presence of grid button and clicks it if necessary
    Text:="|<>*158$20.Tzza489V22TzzbzztV22MEUaAANzzyMEUc"

    if (ok:=FindText(1323-150000, 98-150000, 1323+150000, 98+150000, 0, 0, Text))

    {
      CoordMode, Mouse
      X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
      Click, %X%, %Y%

      ; now click on map button
      Text:="|<>*161$49.0k0000003y00000037k0000036w00000106010E01kD00kM00sDk0MA00S7s0++OBjjw0590YDnw02IXm5zy014G92TW00U9AWDq00E4yT1y000008000000044"
      if (ok:=FindText(1232-150000, 210-150000, 1232+150000, 210+150000, 0, 0, Text))
      {
        CoordMode, Mouse
        X:=ok.1.x, Y:=ok.1.y, Comment:=ok.1.id
          Click, %X%, %Y%
      }
    }
    Else return
  }
CheckForMapMode()
