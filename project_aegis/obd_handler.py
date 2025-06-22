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
        self.connection_status = 'RECONNECTING'
        self.last_rpm_value = 0
        self.last_throttle_value = 0
        self.statusCounter = 0
        self.failedReconnects = 0
        self.onHardDisconnect = onHardDisconnect

        # Attempt initial connection up to 5 times
        for attempt in range(1, 6):
            try:
                self.connection, status = self.connect_obd()
                self.connection_status = status
                if self.connection:
                    print("OBD connection established successfully.")
                    break
            except Exception as e:
                print(f"[OBD INIT] Attempt {attempt} failed: {e}")
                time.sleep(3)

        if not self.connection:
            print("Triggering hard disconnect state.")
            self.connection_status = 'DISCONNECTED'
            if self.onHardDisconnect:
                self.onHardDisconnect()

    def connect_obd(self):
        """Establish OBD connection via USB"""
        try:
            connection = obd.OBD(portstr=OBD_USB_PORT, baudrate=OBD_BAUD_RATE, timeout=OBD_TIMEOUT)
            if connection.is_connected():
                return connection, 'CONNECTED'
        except Exception as e:
            print(f"[connect_obd] Error: {e}")
        return None, 'DISCONNECTED'

    def reconnect(self):
        """Attempt to reconnect if the connection drops"""
        self.connection_status = 'RECONNECTING'
        if self.connection:
            self.connection.close()
        self.connection = None

        try:
            self.connection, self.connection_status = self.connect_obd()
        except Exception as e:
            print(f"[reconnect] Exception during reconnect: {e}")
            self.connection_status = 'DISCONNECTED'
            self.failedReconnects += 1

        if not self.connection or not self.connection.is_connected():
            self.failedReconnects += 1
            print(f"[reconnect] Failed reconnect attempt {self.failedReconnects}")
            if self.failedReconnects >= 5 and self.onHardDisconnect:
                print("Triggering hard disconnect due to repeated reconnect failures.")
                self.connection_status = 'DISCONNECTED'
                self.onHardDisconnect()
            return False

        self.failedReconnects = 0
        print("Reconnect successful.")
        return True

    def check_connection(self):
        if not self.connection or not self.connection.is_connected():
            print("[check_connection] Connection lost. Reconnecting...")
            self.reconnect()
        return True

    def get_data(self):
        """Queries RPM and Throttle Position, handling stuck RPM & reconnects."""
        try:
            if not self.connection or not self.connection.is_connected():
                self.connection_status = 'RECONNECTING'
                self.reconnect()
                if not self.connection or not self.connection.is_connected():
                    self.connection_status = 'DISCONNECTED'
                    return 0, 0, self.connection_status
        except Exception as e:
            print(f"[get_data] Exception: {e}")
            self.connection_status = 'DISCONNECTED'
            return 0, 0, self.connection_status

        try:
            rpm_cmd = obd.commands.RPM
            throttle_cmd = obd.commands.THROTTLE_POS

            rpm_resp = self.connection.query(rpm_cmd)
            throttle_resp = self.connection.query(throttle_cmd)

            rpm_value = rpm_resp.value.magnitude if rpm_resp and rpm_resp.value else self.last_rpm_value
            throttle_value = throttle_resp.value.magnitude if throttle_resp and throttle_resp.value else self.last_throttle_value

            if rpm_value == self.last_rpm_value:
                self.statusCounter += 1
            else:
                self.statusCounter = 0
            self.last_rpm_value = rpm_value

            if throttle_resp and not throttle_resp.is_null():
                self.last_throttle_value = throttle_value

            if self.statusCounter >= 25:
                print("[get_data] Detected stuck RPM. Reconnecting...")
                self.connection_status = 'RECONNECTING'
                self.reconnect()
                self.statusCounter = 0

            self.connection_status = 'CONNECTED'
            return int(rpm_value), float(throttle_value), self.connection_status

        except Exception as e:
            print(f"[get_data] OBD query failed: {e}")
            self.connection_status = 'DISCONNECTED'
            return 0, 0, self.connection_status
