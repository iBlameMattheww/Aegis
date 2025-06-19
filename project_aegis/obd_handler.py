"""
Created on Mon Feb 10 01:52:18 2025

@author: iBlameMattheww
"""

import obd
import time
from config import OBD_USB_PORT, OBD_BAUD_RATE, OBD_TIMEOUT

class OBDHandler:
    def __init__(self, onHardDisconnect=None):
        self.connection = None
        self.connection_status = 'DISCONNECTED'
        self.last_rpm_value = 0
        self.last_throttle_value = 0
        self.statusCounter = 0
        self.failedReconnects = 0
        self.onHardDisconnect = onHardDisconnect

        # Initial connection loop with max 5 attempts before hard disconnect
        failedAttempts = 0
        while not self.connection:
            self.connection, self.connection_status = self.connect_obd()
            if self.connection:
                break

            failedAttempts += 1
            print(f"Initial OBD connection failed (attempt {failedAttempts}). Retrying...")
            time.sleep(3)

            if failedAttempts >= 5:
                print("Triggering hard disconnect state.")
                if self.onHardDisconnect:
                    self.onHardDisconnect()
                self.connection_status = 'DISCONNECTED'
                break

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
            self.failedReconnects += 1
            if self.failedReconnects >= 5:
                print("Triggering hard disconnect due to repeated reconnect failures.")
                if self.onHardDisconnect:
                    self.onHardDisconnect()
            return False
        else:
            self.failedReconnects = 0
            return True

    def check_connection(self):
        if not self.connection or not self.connection.is_connected():
            while not self.connection or not self.connection.is_connected():
                print("OBD connection lost, attempting to reconnect...")
                self.reconnect()
                time.sleep(5)
        return True

    def get_data(self):
        """Queries RPM and Throttle Position, handling stuck RPM response & auto-reconnect"""
        self.check_connection()

        rpm_cmd = obd.commands.RPM
        throttle_cmd = obd.commands.THROTTLE_POS

        rpm_resp = self.connection.query(rpm_cmd)
        throttle_resp = self.connection.query(throttle_cmd)

        # Handle null responses
        rpm_value = rpm_resp.value.magnitude if rpm_resp and rpm_resp.value else self.last_rpm_value
        throttle_value = throttle_resp.value.magnitude if throttle_resp and throttle_resp.value else self.last_throttle_value

        # Detect ignition off via 25 repeated RPM values
        if rpm_value == self.last_rpm_value:
            self.statusCounter += 1
        else:
            self.statusCounter = 0
        self.last_rpm_value = rpm_value

        if throttle_resp and not throttle_resp.is_null():
            self.last_throttle_value = throttle_value

        if self.statusCounter >= 25:
            self.check_connection()
            self.statusCounter = 0

        return int(rpm_value), float(throttle_value), self.connection_status
