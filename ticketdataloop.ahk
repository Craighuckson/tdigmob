#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
winactivate, ahk_exe mobile.exe
Controlget, tcount, List,Count, Syslistview321, ahk_exe mobile.exe
msgbox % tcount

;Loop, Files, C:\users\cr\*, Fd
;{
;	Msgbox % A_loopfilename
;}

getTicketData()
{	;pulls data from ticket on mobile
	;returns a ticket object
	global
	ControlGet, number, Line,1, edit2, ahk_exe Mobile.exe
	ControlGet, street, line,1, Edit6, ahk_exe Mobile.exe
	ControlGet, intersection, line,1,edit10, ahk_exe mobile.exe
	ControlGet, intersection2, line,1,edit12, ahk_exe mobile.exe
	ControlGet, stationCode, line,1, edit9, ahk_exe mobile.exe
	ControlGetText, digInfo, edit22, ahk_exe mobile.exe
	controlget, ticketNumber, line, 1, edit1, ahk_exe mobile.exe
	controlget, town, line, 1, edit13, ahk_exe mobile.exe
	;ticketdata := [number, street, intersection, intersection2, stationcode, diginfo, ticketnumber, town]
	ticketdata := {number : number, street : street, intersection : intersection, intersection2 : intersection2, stationCode : stationCode, digInfo: digInfo, ticketNumber : ticketNumber, town : town}
	sleep 1000
	return ticketdata
}


Loop, 10
{
	Send,{Enter}
	sleep 1000
	td := getTicketData()
	msgbox % ticketNumber
	filecreatedir, C:\users\cr\ticketdump\%ticketnumber%
	for k,v	in td {
		fileappend, % td[k], c:\users\cr\ticketdump\%ticketnumber%\%ticketnumber%.txt
	}
	sleep 500
	send, {esc}
	sleep 1000
	send, y
	sleep 1000
	send, {down}
	sleep 1000
}
msgbox % done