from ahk import AHK
from ahk.window import Window
import pprint
import PySimpleGUI as sg
import re

ahk = AHK()


# def get_ticket_data():
#     script = """
# 	ControlGet, number, Line,1, edit2, ahk_exe Mobile.exe
# 	ControlGet, street, line,1, Edit6, ahk_exe Mobile.exe
# 	ControlGet, intersection, line,1,edit10, ahk_exe mobile.exe
# 	ControlGet, intersection2, line,1,edit12, ahk_exe mobile.exe
# 	ControlGet, stationCode, line,1, edit9, ahk_exe mobile.exe
# 	ControlGetText, digInfo, edit22, ahk_exe mobile.exe
# 	controlget, ticketNumber, line, 1, edit1, ahk_exe mobile.exe
# 	controlget, town, line, 1, edit13, ahk_exe mobile.exe
# 	fileappend,%number%`n%street%`n%intersection%`n%intersection2%`n%stationCode%`n%digInfo%`n%ticketNumber%`n%town%,*
# 		"""

#     m = ahk.win_get(title="TelDig")
#     m.activate()
#     result = ahk.run_script(script)
#     results = [x for x in result.splitlines()]
#     ticket = {
#         "number": results[0],
#         "street": results[1],
#         "intersection": results[2],
#         "intersection2": results[3],
#         "station_code": results[4],
#         "dig_info": results[5],
#         "ticket_number": results[7],
#         "town": results[8],
#     }
#     return ticket

# t = get_ticket_data()
# sg.popup(f'{t["street"]} is a pretty good street, especially at #{t["number"]}')
m = ahk.win_get("TelDig Mobile")
m.activate()
script = """
Controlget,biglist,List,,SysListView321,ahk_exe mobile.exe
fileappend,%biglist%,*
exitapp
"""
result = ahk.run_script(script)
results = [x for x in result.splitlines()]
sg.popup(
    f"Do I ever love to go to %s"
    % (
        re.sub(
            "^ |^\d+ | \(REGIONAL.*| \(COUNTY.*| \(HIGHW.*",
            "",
            results[19].split("\t")[5],
        )
    )
)
