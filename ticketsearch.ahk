#include <obj2string>


tn := 20223016142
files := []
Loop, Files, C:\Users\Cr\timesheet29 07 2022.txt
{
	files.Push(A_LoopFilePath)
}
msgbox % files.length()

for idx, file in files
{
	Loop, Read, %file%
	{
		msgbox % A_LoopReadLine
		if (instr(A_LoopReadLine,tn))
			msgbox % "ticket billed"
	}
}