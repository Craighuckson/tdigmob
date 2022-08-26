import pyautogui
img = pyautogui.prompt('Enter image name')
pyautogui.alert('Press OK to take screenshot')
pyautogui.sleep(2)
pyautogui.screenshot(f'{img}.png')
pyautogui.alert('Screenshot saved')
pyautogui.sleep(1)
