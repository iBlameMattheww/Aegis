#!/bin/bash

echo "[Reactive Badge Installer] Starting installation..."

# [1/5] Update and install dependencies
echo "[1/5] Updating package lists and installing dependencies..."
sudo apt update && sudo apt install -y python3-pip python3-venv git

# [2/5] Clone the repo into ~/project_aegis
echo "[2/5] Cloning repository into ~/project_aegis..."
cd ~
git clone https://github.com/iBlameMattheww/Aegis.git
cd Aegis/project_aegis

# [3/5] Set up virtual environment in ~/
echo "[3/5] Creating virtual environment..."
cd ~/Aegis/project_aegis
python3 -m venv venv
source venv/bin/activate


# [4/5] Install required Python packages
echo "[4/5] Installing required Python packages..."
pip install --upgrade pip
pip install rpi_ws281x adafruit-circuitpython-neopixel adafruit-blinka obd RPi.GPIO

# [5/5] Create systemd service using home directory path
echo "[5/5] Setting up systemd service..."
SERVICE_PATH="/etc/systemd/system/project_aegis.service"

sudo bash -c "cat > $SERVICE_PATH" <<EOF
[Unit]
Description=Reactive Badge Startup
After=network.target

[Service]
ExecStart=sudo /home/pi/Aegis/project_aegis/venv/bin/python3 /home/pi/Aegis/project_aegis/main.py
WorkingDirectory=/home/pi/Aegis/project_aegis
StandardOutput=inherit
StandardError=inherit
Restart=always
User=pi

[Install]
WantedBy=multi-user.target
EOF


# Finalize setup
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable project_aegis.service
sudo systemctl start project_aegis.service

echo "[Reactive Badge Installer]  Installation completed successfully!"
