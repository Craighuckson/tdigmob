#include <Yunit\Yunit>
#include <Yunit\Window>





Yunit.Use(YunitWindow).test(Form, Measurements)

class Form
{
  
  tIsAnObject()
  {
    Yunit.Assert(isObject(Ticket) > 0)
  }
  ROGYRK01ShouldReturnRPWithNoForm()
  {
    Ticket.stationcode := "ROGYRK01"
    Ticket.form := ""
    Yunit.Assert(Ticket.getFormtype() = "RP")
  }
  ENVIN01ShouldReturnEPWithNoForm()
  {
    Ticket.stationcode := "ENVIN01"
    Ticket.form := ""
    Yunit.Assert(Ticket.getFormtype() = "EP")
  }
  ENVIN01ShouldNotReturnEPWithFormPresent()
  {
    Ticket.stationcode := "ENVIN01"
    Ticket.form := "EP"
    Yunit.Assert(Ticket.getFormtype() != "EP")
  }
  TLMXF01ShouldReturnTAWithForm()
  {
    Ticket.stationcode := "TLMXF01"
    Ticket.form := "TP"
    Yunit.Assert(Ticket.getFormtype() = "TA")
  }
  HasDataShouldBeFalse()
  {
    Yunit.Assert(Ticket.hasdata() = false)
  }
  ROGYRK01ShouldReturnRAWhenFormexists()
  {
    Ticket.stationcode := "ROGYRK01"
    Ticket.form := "RA"
    Yunit.Assert(Ticket.getFormtype() = "RA")
  }
}

class Measurements
{
  SingleDigitMeasurementShouldBeProperlyFormatatted()
  {
    ;msgbox % convertMeasurement("6")
    Yunit.Assert(convertMeasurement("6"), "0.6m")
  }
  DoubleDigitMeasurementShouldBeProperlyFormatatted()
  {
    Yunit.Assert(convertMeasurement("60"), "6.0m")
  }
  TripleDigitMeasurementShouldBeProperlyFormatatted()
  {
    Yunit.Assert(convertMeasurement("103"),"10.3m")
  }
}


#Include, C:\Users\Cr\teldig\teldig.ahk
