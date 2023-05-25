#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

class LineType
{
  __New(x,y)
  {
    this.x := x
    this.y := y
    return this
  }

  Choose()
  {
    MouseClick, left, % this.x, % this.y
  }
}



dashedLine := new LineType(82,282)
thinLine := new LineType(80, 139)

winactivate, ahk_exe sketchtoolapplication.exe

dashedLine.Choose()
thinLine.Choose()
