#change territory

import pyautogui as pag
msg = pag.prompt('Write territory?')


def change_territory(msg):
    win = pag.getWindowsWithTitle('TelDig')[0]
    win.activate()
    pag.sleep(1)
    pag.click(1268,710)
    pag.sleep(1.27)
    pag.click(1270,121)
    pag.sleep(0.26)
    pag.press('backspace')
    pag.sleep(0.51)
    pag.typewrite(msg)
    pag.sleep(1)


change_territory(msg)
