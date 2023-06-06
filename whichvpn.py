#whichvpn.py

#finds whether vpn connected to Rogers or Beanfield and outputs to text file - vpn_util.txt

import subprocess
import os


VPNPATH = (
    '"C:\\Program Files (x86)\\Cisco\\Cisco AnyConnect Secure Mobility Client\\vpncli.exe" "stats"'
)

def which_vpn():
    """Check if VPN is connected"""
    vpn_out = subprocess.run(
            VPNPATH,
            capture_output=True, text=True)
    # print(vpn_out)
    if "72.138.16" in vpn_out.stdout:
        return "rogers"
    elif "66.207.192.174" in vpn_out.stdout:
        return "beanfield"
    else:
        return "None"

if __name__ == "__main__":
  # write result to vpn_util.txt
  with open("vpn_util.txt", "w") as f:
    f.write(str(which_vpn()))
