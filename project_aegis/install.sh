#!/bin/bash

echo "[Reactive Badge Installer] Starting installation..."

echo "[0/5] Pulling latest code from GitHub..."
if [ -d "project_aegis/.git" ]; then
    git -C project_aegis pull
else
    echo "Warning: Not a git repository. Skipping pull."
fi

echo "[1/5] Updating package lists and installing dependencies..."
sudo apt update
sudo apt install -y python3-pip python3-venv git

cd project_aegis || { echo "project_aegis directory not found."; exit 1; }

echo "[2/5] Creating virtual environment..."
python3 -m venv venv
source venv/bin/activate

echo "[3/5] Installing required Python packages..."
pip install --upgrade pip
pip install rpi_ws281x adafruit-circuitpython-neopixel obd RPi.GPIO
BLINKA_FORCEBOARD=raspberrypi pip install adafruit-blinka

echo "[4/5] Setting up systemd service..."
SERVICE_FILE="/etc/systemd/system/project_aegis.service"
sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Reactive Badge Startup
After=network.target

[Service]
ExecStart=$(pwd)/venv/bin/python3 $(pwd)/main.py
WorkingDirectory=$(pwd)
StandardOutput=inherit
StandardError=inherit
Restart=always
User=pi

[Install]
WantedBy=multi-user.target
EOF

echo "[5/5] Enabling and starting service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable project_aegis.service
sudo systemctl restart project_aegis.service

echo "[Reactive Badge Installer] Installation completed successfully. Rebooting..."
sudo reboot
