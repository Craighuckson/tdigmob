#teldig.py

import PySimpleGUI as sg
import pyautogui as pag
from ahk import AHK
from ahk.window import Window
from ahkpyinterface import *

ahk = AHK()
pag.MINIMUM_SLEEP = 0.25

class Ticket:

	def get_data():
		return get_ticket_data()

class Sketch:
	pass

class MobileAutomation:
	pass

class SketchToolAutomation:
	pass

print(Ticket.get_data())