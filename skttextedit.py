#SKT text editor
#a utility to edit the text strings in Sketchtool files

#call from autohotkey using -r, -f, -o, -h
#ie skttextedit.py <file> 
import sys
import shutil
from typing import BinaryIO, TextIO
from enum import Enum

#read template file
class ClearReason(Enum):
    REGULAR = 1
    FTTH = 2
    EXCLUSION = 3
    HYDROVAC = 4

def read_template(filename : TextIO) -> dict:
    
    with open(filename,'r') as f:
        cleardata = {}
        linelist = f.read().splitlines()
    cleardata['cp'] = int(linelist[0])
    cleardata['tp'] = int(linelist[1])
    cleardata['units'] = linelist[2]
    cleardata['reason'] = int(linelist[3])
    cleardata['n'] = linelist[4]
    cleardata['s'] = linelist[5]
    cleardata['w'] = linelist[6]
    cleardata['e'] = linelist[7]
    cleardata['fn'] = linelist[8]
    
    if cleardata['cp'] <= 1:
        cleardata['form'] = 'primary'
    elif cleardata['cp'] > 1:
        cleardata['form'] = 'auxilliary'

    return cleardata

def write_to_skt_binary(file : BinaryIO,text : str,offset : int):
    with open(file,'r+b') as f:
        f.seek(offset)
        bytes = bytearray(text,'utf-16-le')
        f.write(bytes)





def main():
    if len(sys.argv) < 2:
        print('Usage: skttextedit.py <filename>')

    filename = sys.argv[1]
    
    print('Reading data')
    try:
        cleardata = read_template(filename)
    except FileNotFoundError:
        print('File does not contain proper data. Exiting...')
        sys.exit()

    print(cleardata)
    reason = cleardata['reason']
    new_file = cleardata['fn']

    if cleardata['form'] == 'primary':
        base_file = f".\\templates\\primary{reason}.skt"

        #make a copy so file not overwritten
        print('Making a file copy')
        temp_file = shutil.copy(base_file,f'C:\\Users\\Cr\\teldig\\templates\\temp.skt')
        print('Writing to binary')
        write_to_skt_binary(temp_file,str(cleardata['tp']) + ' ',441)
        write_to_skt_binary(temp_file,cleardata['units']+ '  ',720)
        write_to_skt_binary(temp_file,cleardata['n'],1001)
        write_to_skt_binary(temp_file,cleardata['s'],1452)
        write_to_skt_binary(temp_file,cleardata['w'],1951)
        write_to_skt_binary(temp_file,cleardata['e'],2478)
        write_to_skt_binary(temp_file,'CRAIG HUCKSON', 2935)
        write_to_skt_binary(temp_file,'130003',3308)
        write_to_skt_binary(temp_file,'2022-05-18',3992)
        print(f'Saving new file to C:\\Users\\Cr\\Documents\\{new_file}')

        shutil.move(temp_file,f'C:\\Users\\Cr\\Documents\\{new_file}')
        print('Done')



main()


	#test

	#chooses the base file based on reason 1=regular,2=ftth,3=fo only,4=hydrovac
    

