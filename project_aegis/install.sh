#!/bin/bash

echo "[Reactive Badge Installer] Starting installation..."

# 0. Remove existing Aegis folder if it exists
if [ -d "$HOME/Aegis" ]; then
    echo "[0/6] Removing old Aegis installation..."
    rm -rf "$HOME/Aegis"
fi

# 1. Clone the GitHub repo
echo "[1/6] Cloning Aegis repo from GitHub..."
git clone https://github.com/iBlameMattheww/Aegis.git "$HOME/Aegis"

cd "$HOME/Aegis/project_aegis" || {
    echo "❌ Error: Failed to enter project_aegis directory."
    exit 1
}

# 2. Install system packages
echo "[2/6] Updating package lists and installing system dependencies..."
sudo apt update
sudo apt install -y python3-pip python3-venv git

# 3. Set up Python environment
if [ ! -d "venv" ]; then
    echo "[3/6] Creating virtual environment..."
    python3 -m venv venv
fi

echo "[3.5/6] Installing Python dependencies..."
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
pip install obd RPi.GPIO

# 4. Remove Jetson.GPIO if accidentally installed
echo "[4/6] Ensuring Jetson.GPIO is not installed..."
pip uninstall -y Jetson.GPIO || true

# 5. Force Blinka to Raspberry Pi GPIO
echo "[5/6] Forcing Blinka to use Raspberry Pi GPIO..."
if ! grep -q "BLINKA_FORCECHIP=BCM2XXX" ~/.bashrc; then
    echo 'export BLINKA_FORCECHIP=BCM2XXX' >> ~/.bashrc
fi
export BLINKA_FORCECHIP=BCM2XXX  # Current session

# 6. Setup systemd service
echo "[6/6] Setting up systemd service..."

SERVICE_FILE="/etc/systemd/system/project_aegis.service"
sudo tee $SERVICE_FILE > /dev/null <<EOF
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
Environment=BLINKA_FORCECHIP=BCM2XXX

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable project_aegis.service
sudo systemctl restart project_aegis.service

echo "[✅] Installation complete. Use 'sudo systemctl status project_aegis.service' to check the status."

