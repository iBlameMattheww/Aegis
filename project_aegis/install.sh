#!/bin/bash

echo "[Reactive Badge Installer] Starting installation..."

# Update and install dependencies
echo "[1/5] Updating package lists and installing dependencies..."
sudo apt update && sudo apt install -y python3-pip python3-venv git

# Set up python virtual environment
echo "[2/5] Creating virtual environment..."
cd ~
cd project_aegis
python3 -m venv venv
source venv/bin/activate

# Install required python packages
echo "[3/5] Installing required Python packages..."
pip install --upgrade pip
pip install rpi_ws281x adafruit-circuitpython-neopixel adafruit-blinka obd RPi.GPIO

# Create systemd service
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


# Enable and start the service
echo "[5/5] Enabling and starting the service..."
sudo systemctl daemon-reexec 
sudo systemctl enable project_aegis.service
sudo systemctl start project_aegis.service

echo "[Reactive Badge Installer] Installation completed successfully!"