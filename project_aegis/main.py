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
    def handle_disconnect():
        ui.hard_disconnect_state = True
    obd = OBDHandler(onHardDisconnect=handle_disconnect)
    leds = LEDController()
    

    
    while True:
        rpm, throttle, connection_status = obd.get_data()
        brightness = BrightnessCalculator.calculate_brightness(rpm, throttle)

        leds.update(brightness)  # Adjust LED brightness
        ui.update(connection_status, brightness)  # Update UI elements (buzzer & LED)

        print(f"UI Update | status: {connection_status}, brightness: {brightness}")
        time.sleep(UPDATE_INTERVAL)



if __name__ == "__main__":
    main()
