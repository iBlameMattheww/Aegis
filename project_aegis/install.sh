#!/bin/bash

set -e

echo "=== Reactive Badge Installer ==="

echo ">> Removing old Aegis repo..."
rm -rf ~/Aegis

echo ">> Cloning fresh repo..."
git clone https://github.com/iBlameMattheww/Aegis.git ~/Aegis

echo ">> Installing system dependencies..."
sudo apt update
sudo apt install -y python3 python3-pip python3-venv git

echo ">> Removing old virtual environment if it exists..."
rm -rf ~/Aegis/project_aegis/venv

echo ">> Creating new virtual environment..."
python3 -m venv ~/Aegis/project_aegis/venv
source ~/Aegis/project_aegis/venv/bin/activate

echo ">> Installing required Python packages..."
pip install --upgrade pip
pip install -r ~/Aegis/project_aegis/requirements.txt

echo ">> Removing Jetson-only packages if installed..."
pip uninstall -y Jetson.GPIO rpi_ws281x adafruit-circuitpython-neopixel || true

echo ">> Installing Raspberry Pi compatible GPIO packages..."
pip install RPi.GPIO adafruit-blinka adafruit-circuitpython-neopixel

echo ">> Creating systemd service file..."
sudo tee /etc/systemd/system/project_aegis.service > /dev/null <<EOF
[Unit]
Description=Reactive Badge Startup
After=network.target

[Service]
ExecStart=/home/pi/Aegis/project_aegis/venv/bin/python3 /home/pi/Aegis/project_aegis/main.py
WorkingDirectory=/home/pi/Aegis/project_aegis
Restart=always
User=root
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF

echo ">> Reloading and enabling systemd service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable project_aegis.service
sudo systemctl restart project_aegis.service

echo "✅ Reactive Badge installed and running!"



