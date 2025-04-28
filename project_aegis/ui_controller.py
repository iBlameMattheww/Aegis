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

    def update(self, connection_status, brightness):
        """Activates buzzer & LED indicator at high RPM"""
        if connection_status == 'DISCONNECTED':
            GPIO.output(BUZZER_PIN, GPIO.HIGH)
            GPIO.output(LED_INDICATOR_PIN, GPIO.HIGH)
            
        elif connection_status == 'CONNECTING':
            for i in range(5):
                GPIO.output(BUZZER_PIN, GPIO.HIGH)
                GPIO.output(LED_INDICATOR_PIN, GPIO.HIGH)
                sleep(0.1)
                GPIO.output(BUZZER_PIN, GPIO.LOW)
                GPIO.output(LED_INDICATOR_PIN, GPIO.LOW)
            
            GPIO.output(LED_INDICATOR_PIN, GPIO.LOW)    
    
        else:
                if brightness > 0:
                    GPIO.output(LED_INDICATOR_PIN, GPIO.HIGH)
                else:
                    GPIO.output(LED_INDICATOR_PIN, GPIO.LOW)