#!/bin/bash

echo "[Reactive Badge Installer] Starting installation..."

echo "[0/5] Pulling latest code from GitHub..."
if [ ! -d "$HOME/Aegis" ]; then
    git clone https://github.com/iBlameMattheww/Aegis.git $HOME/Aegis
else
    cd $HOME/Aegis
    git pull
fi

echo "[1/5] Updating package lists and installing dependencies..."
sudo apt update
sudo apt install -y python3-pip python3-venv git

echo "[2/5] Setting up Python virtual environment..."
cd $HOME/Aegis/project_aegis
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install obd RPi.GPIO

echo "[3/5] Creating systemd service..."
SERVICE_FILE="/etc/systemd/system/project_aegis.service"

sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=Reactive Badge Startup
After=multi-user.target

[Service]
ExecStart=$HOME/Aegis/project_aegis/venv/bin/python3 $HOME/Aegis/project_aegis/main.py
WorkingDirectory=$HOME/Aegis/project_aegis
StandardOutput=inherit
StandardError=inherit
Restart=always
User=pi

[Install]
WantedBy=multi-user.target
EOL

echo "[4/5] Enabling service to run on boot..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable project_aegis.service

echo "[5/5] Starting service..."
sudo systemctl start project_aegis.service

echo "[✅] Installation complete. Check status with: sudo systemctl status project_aegis.service"
