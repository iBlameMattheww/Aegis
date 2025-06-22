#!/bin/bash
# Author: iBlameMattheww

echo "[Reactive Badge Installer] Starting installation..."

# [0/5] Clone or pull latest code
if [ -d "/home/pi/Aegis/.git" ]; then
    echo "[0/5] Pulling latest code from GitHub..."
    cd /home/pi/Aegis
    git pull
else
    echo "[0/5] Cloning project from GitHub..."
    sudo rm -rf /home/pi/Aegis  # Clean up just in case
    git clone https://github.com/iBlameMattheww/Aegis.git /home/pi/Aegis
fi


# [1/5] Update and install dependencies
echo "[1/5] Updating package lists and installing dependencies..."
sudo apt update && sudo apt install -y python3-pip python3-venv git

# [2/5] Set up virtual environment and activate it
echo "[2/5] Creating virtual environment..."
cd /home/pi/Aegis/project_aegis
python3 -m venv venv
source venv/bin/activate

# [3/5] Install required Python packages
# [3/5] Install required Python packages
echo "[3/5] Installing required Python packages..."
pip install --upgrade pip
export BLINKA_FORCEBOARD=raspberrypi
pip install rpi_ws281x adafruit-circuitpython-neopixel adafruit-blinka obd RPi.GPIO


# [4/5] Create systemd service
echo "[4/5] Setting up systemd service..."
SERVICE_PATH="/etc/systemd/system/project_aegis.service"

sudo bash -c "cat > $SERVICE_PATH" <<EOF
[Unit]
Description=Reactive Badge Startup
After=network.target

[Service]
ExecStart=/home/pi/Aegis/project_aegis/venv/bin/python3 /home/pi/Aegis/project_aegis/main.py
WorkingDirectory=/home/pi/Aegis/project_aegis
StandardOutput=inherit
StandardError=inherit
Restart=always
User=pi

[Install]
WantedBy=multi-user.target
EOF

# [5/5] Enable service and reboot
echo "[5/5] Enabling and starting service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable project_aegis.service
sudo systemctl start project_aegis.service

echo "[Reactive Badge Installer] Installation completed successfully. Rebooting..."
sudo reboot
