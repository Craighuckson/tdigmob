#routine to take in all info
totalpages = 0

def clear_form():
    north = input('Enter north boundary:')
    south = input('Enter south boundary:')
    west = input('Enter west boundary:')
    east = input('Enter east boundary:')
    print('Enter clear reason\n1=Regular\n2=FTTH')
    clear_reason = input('3 = FO only\n:')

ticket_number = input('Enter ticket number:')

while True:
    totalpages = input('Enter number of pages:')
    if int(totalpages) > 1:
        break

if totalpages == 1:
    units = '1C'
    clear_form()
