#!/bin/bash

echo "[Reactive Badge Installer] Starting installation..."

# 0. Clean existing Aegis install
echo "[0/5] Removing old Aegis directory (if exists)..."
rm -rf "$HOME/Aegis"

# Clone repo
echo "[1/5] Cloning Aegis repo..."
git clone https://github.com/iBlameMattheww/Aegis.git "$HOME/Aegis" || {
    echo "Failed to clone repo. Exiting."
    exit 1
}

cd "$HOME/Aegis/project_aegis" || {
    echo "Failed to enter project_aegis dir."
    exit 1
}

# 2. Install dependencies
echo "[2/5] Installing system packages..."
sudo apt update
sudo apt install -y python3-pip python3-venv git

# 3. Setup venv and install Python packages
echo "[3/5] Setting up Python virtual environment..."
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install rpi_ws281x adafruit-blinka

# 4. Force Blinka to use Pi GPIO
echo "[4/5] Configuring Blinka for Pi GPIO..."
if ! grep -q "BLINKA_FORCECHIP=BCM2XXX" ~/.bashrc; then
    echo 'export BLINKA_FORCECHIP=BCM2XXX' >> ~/.bashrc
fi
export BLINKA_FORCECHIP=BCM2XXX

# 5. Setup systemd service
echo "[5/5] Creating systemd service..."

SERVICE_FILE="/etc/systemd/system/project_aegis.service"
sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Reactive Badge Startup
After=network.target

[Service]
ExecStart=$HOME/Aegis/project_aegis/venv/bin/python3 $HOME/Aegis/project_aegis/main.py
WorkingDirectory=$HOME/Aegis/project_aegis
StandardOutput=inherit
StandardError=inherit
Restart=always
User=pi

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable project_aegis.service
sudo systemctl restart project_aegis.service

echo "[✅] Installation complete. Use 'sudo systemctl status project_aegis.service' to check the status."

