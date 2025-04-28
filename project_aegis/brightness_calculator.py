"""
Created on Mon Feb 10 01:52:18 2025

@author: iBlameMattheww
"""

from config import RPM_LOW, RPM_HIGH, THROTTLE_THRESHOLD

class BrightnessCalculator:
    @staticmethod
    def calculate_brightness(rpm, throttle):
        """Determines brightness level based on RPM & Throttle Position"""
        if rpm == 0:
            return 0 
             # Engine is off
        
        if rpm < RPM_LOW or throttle < THROTTLE_THRESHOLD:
            return 0
        
        if RPM_LOW <= rpm <= RPM_HIGH:
            x = rpm / RPM_HIGH
            y = throttle / 100
            return int(255 * ((0.7 * x) + (0.3 * y)))
        
        return 255  # Max brightness
