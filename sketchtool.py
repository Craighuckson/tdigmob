#sketchtool.py

import datetime
import time
import pyautogui as p

#constants

OPENDLG = r'C:\Users\Cr\teldig\testassets\buttonopen.png'
ROTATION = 'rotation.png'

def winwaitactive(wintitle: str):
    while True:
        try:
            if p.getWindowsWithTitle(wintitle)[0].isActive == True:
                break
        except IndexError:
            continue

def wait_sketchtool():
    wait_image(ROTATION)

def wait_image(img):
    while True:
        try:
            if p.locateOnScreen(img):
                break
        except:
            continue



def open_image_dialog():
    p.hotkey('alt','i')
    p.press('down',presses = 8)
    p.press('enter')

def load_image(filename: str, ungroup:bool =True):
    open_image_dialog()
    winwaitactive('Open')
    p.write(filename)
    p.press('enter')
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
    p.press('f2')
    p.write(text)
    p.press('enter')

def get_date():
    return datetime.datetime.now().strftime('%Y-%m-%d')

if __name__ == '__main__':
    import mobile
    tdwin = p.getWindowsWithTitle('TelDig Mobile')[0]
    tdwin.activate()
    
