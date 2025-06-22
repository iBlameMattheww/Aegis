#!/bin/bash

echo "[Reactive Badge Installer] Starting installation..."

echo "[0/6] Cloning repo to ~/Aegis..."
INSTALL_DIR="$HOME/Aegis"
if [ ! -d "$INSTALL_DIR" ]; then
    git clone https://github.com/iBlameMattheww/Aegis.git "$INSTALL_DIR"
else
    cd "$INSTALL_DIR"
    git pull
fi

echo "[1/6] Installing system dependencies..."
sudo apt update
sudo apt install -y python3-pip python3-venv git

echo "[2/6] Setting up Python virtual environment..."
PROJECT_DIR="$INSTALL_DIR/project_aegis"
cd "$PROJECT_DIR"
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install obd RPi.GPIO adafruit-blinka

echo "[3/6] Creating systemd service..."
SERVICE_PATH="/etc/systemd/system/project_aegis.service"
sudo tee "$SERVICE_PATH" > /dev/null <<EOL
[Unit]
Description=Reactive Badge Startup
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=$PROJECT_DIR
ExecStart=$PROJECT_DIR/venv/bin/python3 $PROJECT_DIR/main.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

echo "[4/6] Reloading systemd and enabling service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable project_aegis.service

echo "[5/6] Starting project_aegis service..."
sudo systemctl restart project_aegis.service

echo "[✅] Done. View logs with: sudo journalctl -u project_aegis.service -e"
