"""
Created on Mon Feb 10 01:52:18 2025

@author: iBlameMattheww
"""

import time
import sys
from obd_handler import OBDHandler
from brightness_calculator import BrightnessCalculator
from led_controller import LEDController
from ui_controller import UIController
from config import UPDATE_INTERVAL

def main():
    ui = UIController()

    # Simulate startup flashing
    ui.update('CONNECTING', 0)
    time.sleep(2)

    # Simulate normal operation
    while True:
        ui.update('CONNECTED', 75)  # should keep LED ON, buzzer OFF
        time.sleep(1)



if __name__ == "__main__":
    main()
