#beanfield.py
import os
import pyautogui as p
import glob
from pathlib import Path
import subprocess


def find_as_built():
	filename = p.prompt('Enter Filename:')
	dir = Path(r'C:\Users\Cr\As Builts\Aptum As Builts\Toronto_Mississauga')
	file_list = [file.name for file in dir.glob(f'*{filename}*.*')]
	confirmed = p.confirm('Choose file to open','Search Results',[x for x in file_list])
	subprocess.run(f'C:\\Users\\Cr\\As Builts\\Aptum As Builts\\Toronto_Mississauga\\{confirmed}', shell=True)

if __name__ == '__main__':
	find_as_built()