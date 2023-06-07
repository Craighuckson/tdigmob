#include <Yunit\Yunit>
#include <Yunit\Window>


+^t::
Yunit.Use(YunitWindow).Test(CableNearCurbTestSuite)

class CableNearCurbTestSuite
{
  
    
    TestCableNearCurbLoopsUntilInputIsYOrN()
    {
        ; Arrange
        input := ["a", "b", "c", "d", "y"]
        expected := true
        
        ; Act
        for i, val in input
        {
            if (i < 5)
                Inputbox := Func("MockInputbox")
            else
                Inputbox := Func("CableNearCurb")
            
            result := CableNearCurb()
            
            if (result = true)
                break
        }
        
        ; Assert
        Yunit.Assert(result = expected)
    }
    
    MockInputbox(ByRef value)
    {
        value := "a"
    }
}

class TimesheetTests
{

}

class TreeTestSuite
{
	ConstructorExists()
	{
		t := new TreeSketch
		Yunit.Assert(isObject(t) != 0)
	}
}

class Bell
{
	ShouldReturn1IfBellClearIsY()
	{
		msgbox % isBellClear()
	}
}

class Rogers
{
	ShouldPassIfStationCodeStartsWithRog()
	{
		stationcode := "ROGYRK01"
		Yunit.Assert(isTicketRogers(stationcode) = true)
	}

	ShouldBeFalseIfNotRogStationCode()
	{
		stationcode := "BCGN01"
		Yunit.Assert(isTicketRogers(stationcode) = false)
	}
}

; class TicketListOps
; {
;   Start()
;   {
;     WinActivate("ahk_exe mobile.exe")
;   }
;   ShouldGetCorrectNumberofTickets()
;   {
;     num := 99
;     Yunit.Assert(getNumberofTickets() = num)
;   }

;   ShouldReturnAList()
;   {
;     Yunit.Assert(IsObject(getListofTicketNumbers()) = true)
;   }

;   ListLengthShouldEqualNumberofTickets()
;   {
;     Yunit.Assert(getNumberofTickets() = getListofTicketNumbers().Length())
;   }

;   ; ShouldBeFalseIfDataFolderEmpty()
;   ; {
;   ;   Yunit.Assert(lookForOldTickets() = false)
;   ; }

;   ; ShouldBeFalseIfValidTicketFolderPresent()
;   ; {
;   ;   FileCreateDir("C:\Users\Cr\teldig\data\20222322655")
;   ;   Yunit.Assert(lookForOldTickets() = false)
;   ; }

;   ; ShouldBeTrueWhenOldTicketFolderPresent()
;   ; {

;   ;   Yunit.Assert(lookForOldTickets() = true)
;   ; }
; }


#Include, C:\Users\Cr\teldig\teldig.ahk
