rogClear()
{
  MsgBox,36,Clear?,Ticket Clear?
  ifMsgBox, Yes
  {
    rclear:=1
    return rclear
  }
}
