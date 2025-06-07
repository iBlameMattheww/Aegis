"""
Created on Mon Feb 10 01:52:18 2025

@author: iBlameMattheww
"""
from time import sleep
import RPi.GPIO as GPIO
from config import BUZZER_PIN, LED_INDICATOR_PIN
  

class UIController:
    def __init__(self):
        GPIO.setmode(GPIO.BCM)
        GPIO.setup(BUZZER_PIN, GPIO.OUT)
        GPIO.setup(LED_INDICATOR_PIN, GPIO.OUT)
        self.hard_disconnect_state = False

    def update(self, connection_status, brightness):
        """Manages LED and buzzer based on system state."""
        if self.hard_disconnect_state:
            # Permanent alert until system reset
            GPIO.output(BUZZER_PIN, GPIO.HIGH)
            GPIO.output(LED_INDICATOR_PIN, GPIO.HIGH)
            return

        elif connection_status == 'CONNECTING':
            for _ in range(5):
                GPIO.output(BUZZER_PIN, GPIO.HIGH)
                GPIO.output(LED_INDICATOR_PIN, GPIO.HIGH)
                sleep(0.1)
                GPIO.output(BUZZER_PIN, GPIO.LOW)
                GPIO.output(LED_INDICATOR_PIN, GPIO.LOW)
            GPIO.output(LED_INDICATOR_PIN, GPIO.LOW)

        else:
            GPIO.output(BUZZER_PIN, GPIO.LOW)
            GPIO.output(LED_INDICATOR_PIN, GPIO.HIGH if brightness > 0 else GPIO.LOW)