"""
Created on Mon Feb 10 01:52:18 2025

@author: iBlameMattheww
"""

import obd
import time
from config import OBD_USB_PORT, OBD_BAUD_RATE, OBD_TIMEOUT

class OBDHandler:
    def __init__(self):
        self.connection, self.connection_status = self.connect_obd()
        self.last_rpm_value = 0
        self.last_throttle_value = 0
        self.statusCounter = 0  # Counter to detect ignition off

    def connect_obd(self):
        """Establish OBD Connection via USB"""
        connection = obd.OBD(portstr=OBD_USB_PORT, baudrate=OBD_BAUD_RATE, timeout=OBD_TIMEOUT)
        if not connection.is_connected():
            return None, 'DISCONNECTED'
        return connection, 'CONNECTED'

    def reconnect(self):
        """Attempt to reconnect if the connection drops"""
        if self.connection:
            self.connection.close()
        self.connection = None
        time.sleep(1)
        self.connection, self.connection_status = self.connect_obd()

        if not self.connection:
            self.connection_status = 'DISCONNECTED'
        return self.connection_status

    def get_data(self):
        """Queries RPM and Throttle Position, handling null responses & detecting ignition off"""
        if not self.connection or not self.connection.is_connected():
            self.connection_status = self.reconnect()
            if self.connection_status == 'DISCONNECTED':
                return 0, 0, 'DISCONNECTED'

            self.connection_status = 'CONNECTING'

        rpm_cmd = obd.commands.RPM
        throttle_cmd = obd.commands.THROTTLE_POS

        rpm_resp = self.connection.query(rpm_cmd)
        throttle_resp = self.connection.query(throttle_cmd)

        # Handle null responses
        rpm_value = rpm_resp.value.magnitude if rpm_resp and rpm_resp.value else self.last_rpm_value
        throttle_value = throttle_resp.value.magnitude if throttle_resp and throttle_resp.value else self.last_throttle_value

        # Track ignition off state
        if rpm_resp.is_null():
            self.statusCounter += 1  # Increment if null response occurs
        else:
            self.statusCounter = 0  # Reset if valid RPM is read

        # Update stored values
        self.last_rpm_value, self.last_throttle_value = rpm_value, throttle_value

        # If RPM is null for 25 cycles, assume ignition is off
        if self.statusCounter >= 25:
            return 0, 0, 'IGNITION_OFF'

        return int(rpm_value), float(throttle_value), self.connection_status
