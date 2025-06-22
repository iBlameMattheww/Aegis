#!/bin/bash
# Author: iBlameMattheww

echo "[Reactive Badge Installer] Starting installation..."

# [0/6] Remove any old installation
if [ -d "/home/pi/Aegis" ]; then
    echo "[0/6] Removing existing Aegis directory..."
    rm -rf /home/pi/Aegis
fi

# [1/6] Clone fresh code from GitHub
echo "[1/6] Cloning project from GitHub..."
git clone https://github.com/iBlameMattheww/Aegis.git /home/pi/Aegis

# [2/6] Update and install system dependencies
echo "[2/6] Installing system dependencies..."
sudo apt update && sudo apt install -y python3-pip python3-venv git

# [3/6] Set up virtual environment
echo "[3/6] Creating Python virtual environment..."
cd /home/pi/Aegis/project_aegis
python3 -m venv venv
source venv/bin/activate

# [4/6] Install required Python packages
echo "[4/6] Installing Python packages..."
pip install --upgrade pip
pip install rpi_ws281x adafruit-circuitpython-neopixel adafruit-blinka obd RPi.GPIO

# Remove Jetson.GPIO if Blinka installed it (prevents crash)
pip uninstall -y Jetson.GPIO || true

# [5/6] Create systemd service
echo "[5/6] Setting up systemd service..."
SERVICE_PATH="/etc/systemd/system/project_aegis.service"
CURRENT_USER=$(whoami)

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
User=$CURRENT_USER

[Install]
WantedBy=multi-user.target
EOF

# [6/6] Enable and start the service
echo "[6/6] Enabling and starting systemd service..."
sudo systemctl daemon-reload
sudo systemctl enable project_aegis.service
sudo systemctl start project_aegis.service

# Final step: reboot to cleanly restart everything
echo "[Reactive Badge Installer] Setup complete. Rebooting..."
sudo reboot
