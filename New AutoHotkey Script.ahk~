#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
filelist := []
Inputbox, filestring, File, Enter search string
Loop, Files, C:\Users\Cr\Documents\*filestring*
{
	filelist .= A_LoopFileName "`n"
}
Loop, Parse, filelist, `n
{
	Msgbox, %A_LoopField%
}
