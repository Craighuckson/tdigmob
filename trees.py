import PySimpleGUI as sg


try:
    with open('treeticketdata.txt','r') as ttd:
        treedata = ttd.readlines()
except IOError:
        print('Couldn"t read file')

ticketnumber,number,street = treedata

layout = [
    [sg.Text('Treetype: '),sg.DropDown(('TREE','STUMP','FLAG','CURB MARKING','STAKE'),default_value='STUMP',k='treetype')],
    [sg.Text('Write tree number: '),sg.Input(k='treenum')],
    [sg.Checkbox('Ticket clear?',k='rogclear',enable_events=True)],
    [sg.Text('Street: '),sg.Input(default_text=street,k='street')],
    [sg.Text('Landbase'),sg.DropDown(('N','S','W','E'),k='landbase')],
    [sg.Text('Number: '),sg.Input(k='number')],
    [sg.Text('Cable location: '), sg.Combo(('1 - CLOSER TO ROAD', '2 - CLOSER TO PROPERTY', '3 - BOTH SIDES OF TREE'),key='cabloc',default_value= '2 - CLOSER TO PROPERTY')],
		[sg.Text('Measurement 1: '),sg.Input(k='meas1')],
		[sg.Text('Measurement 2: '),sg.Input(k='meas2')],
		[sg.Text('Label 1: '), sg.Input(default_text='TV',k='label1')],
		[sg.Text('Label 2: '), sg.Input(k='label2')],
		[sg.Submit(k='submit')]
]


win = sg.Window('Tree Sketch Details',layout = layout)

# Event Loop to process "events" and get the "values" of the inputs
while True:
    event, values = win.read()
    try:
        treetype = values['treetype']
        treenum = values['treenum']
    except TypeError:
        pass
    if event == sg.WIN_CLOSED or event == 'Cancel': # if user closes window or clicks cancel
        break
    if event == 'rogclear':
        clearstr = ''
        for _ in ['N','S','W','E']:
            clearstr += f'3M {_} OF {treetype} {treenum}\n'
        with open('rclear.txt','w') as f:
            f.write(clearstr)
        win.close()

win.close()
