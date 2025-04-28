"""
Created on Mon Feb 10 01:52:18 2025

@author: iBlameMattheww
"""

import board
import neopixel
from config import LED_PIN, NUM_LEDS

class LEDController:
    def __init__(self):
        self.pixels = neopixel.NeoPixel(board.D18, NUM_LEDS, auto_write=False)

    def update(self, brightness):
        """Updates the LED brightness based on the calculated value"""
        color = (brightness, 0, 0)  # Red intensity based on brightness

        for i in range(NUM_LEDS):
            self.pixels[i] = color

        self.pixels.show()  # Update LEDs
