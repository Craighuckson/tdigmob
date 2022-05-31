#sketchtool.py

import datetime
import time
from ahk import AHK
import pyautogui as p
p.PAUSE = 0.5
ahk = AHK()
#constants
SKETCH_FOLDER = r'C:\Users\Cr\Documents'
OPENDLG = r'C:\Users\Cr\teldig\testassets\buttonopen.png'
ROTATION = 'testassets\\waitrotation.png'

def winwaitactive(wintitle: str):
    while not p.getWindowsWithTitle(wintitle)[0].isActive:
        pass

def wait_sketchtool():
    wait_image(ROTATION)

def wait_image(img:str):
    p.moveTo(p.locateCenterOnScreen(img))



def open_image_dialog():
    p.hotkey('alt','i')
    p.press('down',presses = 8)
    p.press('enter')

def load_image(filename: str, ungroup:bool =True):
    open_image_dialog()
    winwaitactive('Open')
    p.write(filename)
    p.press('enter')
    winwaitactive('TelDig SketchTool')
    if ungroup:
        p.hotkey('alt','i')
        p.press(['down','enter'])

def save_dialog():
    p.hotkey('alt','f')

# def save_image(filename):
#     r.keyboard('[alt]f')
#     r.wait(0.1)
#     r.keyboard('[enter]')
#     r.hover('saveas.png')
#     r.keyboard(f'{filename}[enter]')

def set_template_text(template,text):
    if isinstance(text,str) == True:
        text = text.upper()
    elif isinstance(text,int) == True:
        text = str(text)
    load_image(template,False)
    wait_sketchtool()
    p.press('f2')
    p.sleep(0.3)
    p.write(text)
    p.sleep(0.3)
    p.press('enter')

def get_date():
    return datetime.datetime.now().strftime('%Y-%m-%d')

if __name__ == '__main__':
    import mobile
    tdwin = p.getWindowsWithTitle('TelDig Mobile')[0]
    tdwin.activate()
    winwaitactive('TelDig Mobile')
    mobile.select_drawings_tab()
    mobile.select_new_form()
    mobile.select_cabletv()
    
    wait_image(ROTATION)
    set_template_text(SKETCH_FOLDER + '\\totalpages.skt', '1')
    set_template_text(SKETCH_FOLDER + '\\nboundary.skt','NPL 130 ADDISON HALL CIR')
    
