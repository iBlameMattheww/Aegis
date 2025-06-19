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
        try:
            rpm, throttle, connection_status = obd.get_data()
        except Exception as e:
            print(f"[main loop] OBD error: {e}")
            rpm = 0
            throttle = 0
            connection_status = False

        brightness = BrightnessCalculator.calculate_brightness(rpm, throttle)

        leds.update(brightness)                     # Should still run even without OBD
        ui.update(connection_status, brightness)    # LED & buzzer should still work

        time.sleep(UPDATE_INTERVAL)




if __name__ == "__main__":
    main()
