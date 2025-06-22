#!/bin/bash

echo "[Reactive Badge Installer] Starting clean install..."

# 1. Remove existing Aegis software
echo "[1/5] Removing old Aegis directory if it exists..."
rm -rf "$HOME/Aegis"

# 2. Clone the GitHub repo
echo "[2/5] Cloning Aegis repo from GitHub..."
git clone https://github.com/iBlameMattheww/Aegis.git "$HOME/Aegis"

cd "$HOME/Aegis/project_aegis" || {
    echo "Error: Failed to enter project_aegis directory."
    exit 1
}

# 3. Install required system packages
echo "[3/5] Installing system packages..."
sudo apt update
sudo apt install -y python3-pip python3-venv git

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python packages
pip install --upgrade pip
pip install -r requirements.txt

# 4. Remove Jetson references from Blinka
echo "[4/5] Removing Jetson references..."
find venv/lib/python3.11/site-packages/adafruit_blinka -type f -name "*.py" -exec sed -i '/Jetson/d' {} +
find venv/lib/python3.11/site-packages -type d -name "Jetson" -exec rm -rf {} +

# 5. Set up systemd service
echo "[5/5] Setting up systemd service..."

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

echo "Reactive Badge installation complete."
echo "Use 'sudo systemctl status project_aegis.service' to check the service status."

