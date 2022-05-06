# routine to take in all info
totalpages = 0

import PySimpleGUI as sg

sg.set_options(font=(('Segoe UI',9,'normal')))
sg.theme('Default1')

def init():
    layout = ([[sg.T("Ticket Number: "),sg.Input(k='ticket_number')],
    [sg.Text('Total Pages:'), sg.I(k='total_pages')],
    [sg.T('North Boundary:'), sg.I(k='nbound')],
    [sg.T('South Boundary:'), sg.I(k='sbound')],
    [sg.T('West Boundary:'), sg.I(k='wbound')],
    [sg.T('East Boundary:'), sg.I(k='ebound')],
    [sg.T('Clear Reason:'),sg.Combo(['Regular','FTTH','Fibre Only'],default_value='Regular')],
    [sg.T('File Name:',pad=(0,20)), sg.I(k='save_name'), sg.FileSaveAs()],
    [sg.Submit(bind_return_key=True,pad=(0,20))]])

    win = sg.Window('Rogers Clears',layout, finalize=True,element_justification='center')
    return win

def clear_form(win):
    event,values = win.read()
    win.close()
    values['save_name'] = values['save_name'] + '.skt'
    return win

def write_parse_file(form,ticket_number,page_number,total_pages,units):
    
    with open(f'{ticket_number}-{page_number}.txt',mode='a') as tf:
        tf.write(f'{page_number}\n')
        tf.write(f'{total_pages}\n')
        for _ in form.values():
            tf.write(f'{_}\n')
        tf.write(units)
    sg.popup_get_text(f'File written to {ticket_number}-{page_number}.txt')

#ticket_number = pyip.inputNum("Enter ticket number:")

def main():

    ticket_number = sg.popup_get_text('Enter ticket number','Ticket Number')
    totalpages = sg.popup_get_text('Enter number of pages','Pages')

    if totalpages == "" or totalpages == None or totalpages == '0':
        sg.popup_get_text('Total pages must be number greater than 0')

    if totalpages == 1:
        units = "1C"
        page_number = 1
        form = clear_form(win)
        write_parse_file(form,ticket_number,page_number,totalpages,units)

    else:
        units = sg.popup_get_text('Enter units', 'Units')
        for page in range(totalpages):
            print('Page ',page)
            page_number = page + 1
            form = clear_form(win)
            write_parse_file(form,ticket_number,page_number,totalpages,units)

win = init()

    
