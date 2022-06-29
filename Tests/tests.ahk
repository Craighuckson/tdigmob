#Include, C:\Users\Cr\teldig\teldig.ahk
#include <Yunit\Yunit>
#include <Yunit\Window>

#t::
Yunit.Use(YunitWindow).Test(Bell)
return

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
