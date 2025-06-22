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
    obd = OBDHandler()
    leds = LEDController()

    while True:
        rpm, throttle, connection_status = obd.get_data()
        brightness = BrightnessCalculator.calculate_brightness(rpm, throttle)

        leds.update(brightness)
        ui.update(connection_status, brightness)
        print(f"Status: {connection_status}, RPM: {rpm}, Throttle: {throttle}")


        time.sleep(UPDATE_INTERVAL)





if __name__ == "__main__":
    main()
