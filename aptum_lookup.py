import uiautomation as auto
import sys


def activate_mapinfo():
    win = auto.WindowControl(SubName='MapInfo ProViewer')
    if not win.Exists(3, 1):
        auto.MessageBox("Cannot find MapInfo", "MapInfo not found")
        sys.exit()
    win.GetWindowPattern().SetWindowVisualState(1)
    return win

def open_find_dialog(win):
    auto.SendKeys('Esc')
    win.MenuItemControl(Name='Select').GetInvokePattern().Invoke()
    win.MenuItemControl(SubName='Find...').GetInvokePattern().Invoke()

def is_long_find_dialog(win):
    search_table = win.TextControl(Name="Search Table...")
    if search_table:
        return True
    else:
        return False

def set_find_params(win):
    win.ComboBoxControl(SubName='Search Table').GetValuePattern().SetValue('Roads*')
    win.ComboBoxControl(SubName='Refine Search').GetValuePattern().SetValue('Cities')

if __name__ == "__main__":
    mapinfo = activate_mapinfo()
    open_find_dialog(mapinfo)
    if is_long_find_dialog(mapinfo):
        set_find_params(mapinfo)
    
