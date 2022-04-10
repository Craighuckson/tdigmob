# routine to take in all info
import pyinputplus as pyip


totalpages = 0


def clear_form():
    form = {}
    form["north"] = pyip.inputStr("Enter north boundary:")
    form["south"] = pyip.inputStr("Enter south boundary:")
    form["west"] = pyip.inputStr("Enter west boundary:")
    form["east"] = pyip.inputStr("Enter east boundary:")
    form["clear_reason"] = pyip.inputMenu(
        ["regular", "ftth", "foonly"],
        numbered=True,
        prompt="Enter the reason for the clear\n",
    )
    return form

def write_parse_file(form,ticket_number,page_number,total_pages):
    
    with open(f'{ticket_number}-{page_number}.txt',mode='a') as tf:
        tf.write(f'{page_number}\n')
        tf.write(f'{total_pages}\n')
        for _ in form.values():
            tf.write(f'{_}\n')


ticket_number = pyip.inputNum("Enter ticket number:")

totalpages = pyip.inputNum("Enter number of pages:", min=1)

if totalpages == 1:
    units = "1C"
    page_number = 1
    form = clear_form()
    write_parse_file(form,ticket_number,page_number,totalpages)
