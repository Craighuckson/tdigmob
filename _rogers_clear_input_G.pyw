
import PySimpleGUI as sg

sg.set_options(font=(('Segoe UI',9,'normal')))
sg.theme('Default1')

settings = sg.UserSettings(filename = 'rogclear.ini',path='C:\\Users\\Cr\\',use_config_file=True)

sg.easy_print(settings)

layout = [
	[sg.T("Ticket Number: "),sg.Input(default_text=settings['Ticket Data']['ticket_number'],k='-TNUM-')],
[sg.T('Current page:'),sg.I(default_text=settings['Ticket Data']['current_page'],k='-CPAGE-')],
[sg.Text('Total Pages:'), sg.I(default_text=settings['Ticket Data']['total_pages'],k='-TPAGE-')],
[sg.T('North Boundary:'), sg.I(k='-NB-')],
[sg.T('South Boundary:'), sg.I(k='-SB-')],
[sg.T('West Boundary:'), sg.I(k='-WB-')],
[sg.T('East Boundary:'), sg.I(k='-EB-')],
[sg.T('Clear Reason:'),sg.Combo(['Regular','FTTH','Fibre Only'],default_value='Regular')],
[sg.T('File Name:',pad=(0,20)), sg.I(k='-SVFILE-')],
[sg.Submit(bind_return_key=True,pad=(0,20))],
]


win = sg.Window('Rogers Clears',layout, finalize=True,element_justification='center')

event, values = win.read()
settings['Ticket Data']['ticket_number'] = values['-TNUM-']
win.close()

values['-SVFILE-'] = values['-SVFILE-'] + '.skt'



sg.popup(f'You entered {values.values()}')
