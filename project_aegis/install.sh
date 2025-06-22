#!/usr/bin/env bash
set -euo pipefail

echo "=== Reactive Badge Installer ==="

echo ">> Removing old Aegis directory..."
rm -rf "${HOME}/Aegis"

echo ">> Cloning Aegis repository..."
git clone --depth 1 https://github.com/iBlameMattheww/Aegis.git "${HOME}/Aegis"

echo ">> Installing system packages..."
sudo apt-get update
sudo apt-get install -y \
  python3 \
  python3-venv \
  python3-pip \
  git \
  build-essential \
  python3-dev

echo ">> Removing old virtual environment..."
rm -rf "${HOME}/Aegis/project_aegis/venv"

echo ">> Creating Python virtual environment..."
python3 -m venv "${HOME}/Aegis/project_aegis/venv"

echo ">> Activating virtual environment and installing Python dependencies..."
# shellcheck disable=SC1090
source "${HOME}/Aegis/project_aegis/venv/bin/activate"
pip install --upgrade pip

echo ">> Uninstalling any Jetson.GPIO remnants..."
pip uninstall -y Jetson.GPIO || true

echo ">> Installing project requirements..."
pip install -r "${HOME}/Aegis/project_aegis/requirements.txt"

echo ">> Installing Raspberry Pi GPIO & NeoPixel support..."
pip install \
  RPi.GPIO \
  adafruit-blinka \
  adafruit-circuitpython-neopixel

echo ">> Writing systemd service file..."
SERVICE_PATH="/etc/systemd/system/project_aegis.service"
sudo tee "${SERVICE_PATH}" > /dev/null <<EOF
[Unit]
Description=Reactive Badge Startup
After=network.target

[Service]
WorkingDirectory=${HOME}/Aegis/project_aegis
ExecStart=${HOME}/Aegis/project_aegis/venv/bin/python3 ${HOME}/Aegis/project_aegis/main.py
Restart=always
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF

echo ">> Reloading systemd, enabling & starting service..."
sudo systemctl daemon-reload
sudo systemctl enable project_aegis.service
sudo systemctl restart project_aegis.service

echo "✅ Reactive Badge installation complete!"


