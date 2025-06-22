#!/bin/bash

echo "[Reactive Badge Installer] Starting installation..."

# 0. Clone the GitHub repo if it doesn't already exist
if [ ! -d "$HOME/Aegis" ]; then
    echo "[0/5] Cloning Aegis repo from GitHub..."
    git clone https://github.com/iBlameMattheww/Aegis.git "$HOME/Aegis"
else
    echo "[0/5] Repo already exists. Skipping clone..."
fi

cd "$HOME/Aegis/project_aegis" || {
    echo "Error: Failed to enter project_aegis directory."
    exit 1
}

# 1. Install required packages
echo "[1/5] Updating package lists and installing dependencies..."
sudo apt update
sudo apt install -y python3-pip python3-venv git

# 2. Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "[2/5] Creating Python virtual environment..."
    python3 -m venv venv
fi

# 3. Activate and install Python dependencies
echo "[3/5] Installing Python packages..."
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# 4. Force Blinka to Raspberry Pi GPIO
echo "[4/5] Forcing Blinka to use Raspberry Pi GPIO..."
if ! grep -q "BLINKA_FORCECHIP=BCM2XXX" ~/.bashrc; then
    echo 'export BLINKA_FORCECHIP=BCM2XXX' >> ~/.bashrc
fi
export BLINKA_FORCECHIP=BCM2XXX  # For current session

# 5. Set up systemd service
echo "[5/5] Setting up project_aegis systemd service..."

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

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable project_aegis.service
sudo systemctl restart project_aegis.service

echo "[✅] Installation complete. Use 'sudo systemctl status project_aegis.service' to check the status."
