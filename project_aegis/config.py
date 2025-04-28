"""
Created on Mon Feb 10 01:52:18 2025

@author: iBlameMattheww
"""


UPDATE_INTERVAL = 0.2  # Time between queries (seconds)

# OBD Connection Settings
OBD_USB_PORT = "/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0"  # Updated
OBD_BAUD_RATE = 38400  # Standard baud rate
OBD_TIMEOUT = 5  # Timeout in seconds

# LED Configuration
NUM_LEDS = 8  # Number of LEDs in the strip
LED_PIN = 18  # GPIO pin for the LED strip

# Brightness Thresholds
RPM_LOW = 1500
RPM_HIGH = 6000
THROTTLE_THRESHOLD = 40

# GPIO Pins
BUZZER_PIN = 24
LED_INDICATOR_PIN = 23