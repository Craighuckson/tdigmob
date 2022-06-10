#functions for Teldig mobile
import pyautogui as p
from pywinauto.application import Application
from ahk import AHK
ahk = AHK()
import time
p.PAUSE = 0.5

def select_drawings_tab():
	p.click(135,101)

def select_location_tab():
    p.click(39,98)

def select_diginfo_tab():
    p.click(87,102)

def select_new_form():
    p.click(925,652)

def select_cabletv():
    p.click(915,498)

def select_auxilliary():
    p.click(953,392)

def select_cogeco():
	p.click(920,409)

def click_ok():
    p.click(1079,695)

def select_pending():
	p.hotkey('alt','q')
	p.press('p')

def save_and_email():
	click_ok()
	p.press(['y','enter'])

def save_no_email():
	click_ok()
	p.press('n')

if __name__ == '__main__':

	# test harness
	p.alert('Press ok to start')
	# mobwin = p.getWindowsWithTitle('TelDig Mobile')[0]
	app = Application(backend='uia').connect(title_re='TelDig').top_window()
	# stwin = ahk.win_get(title='TelDig Sketchtool')
	mobwin.activate()
	# select_pending()
	select_drawings_tab()
	select_new_form()
	select_cabletv()
	time.sleep(6)  # import time
	# assert ahk.image_search(r'C:\Users\Cr\teldig\testassets\auxtest.png') != None
	# print('Test passed')
	p.hotkey('alt','i')
	p.press('down', presses= 8)
	p.press('enter')
	p.sleep(3)
	p.write('Cool it worked')
