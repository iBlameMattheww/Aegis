#!/bin/bash

echo "[Reactive Badge Installer] Starting installation..."

# Step 0: Ensure project directory exists
if [ ! -d "project_aegis" ]; then
  echo "[0/5] Cloning project repository..."
  git clone https://github.com/iBlameMattheww/Aegis.git
  cd Aegis || { echo "Failed to enter Aegis directory"; exit 1; }
else
  echo "[0/5] Pulling latest code from GitHub..."
  cd Aegis || { echo "Failed to enter Aegis directory"; exit 1; }
  if [ -d ".git" ]; then
    git pull
  else
    echo "Warning: Not a git repository. Skipping pull."
  fi
fi

# Step 1: Install system packages
echo "[1/5] Updating package lists and installing dependencies..."
sudo apt-get update
sudo apt-get install -y python3-pip python3-venv git

# Step 2: Create virtual environment
echo "[2/5] Creating virtual environment..."
cd project_aegis || { echo "project_aegis directory not found."; exit 1; }
python3 -m venv venv

# Step 3: Install Python packages
echo "[3/5] Installing required Python packages..."
source venv/bin/activate
pip install --upgrade pip
pip install \
    rpi_ws281x \
    adafruit-circuitpython-neopixel \
    adafruit-blinka \
    obd \
    RPi.GPIO

# Step 3.5: Remove Jetson.GPIO if auto-installed
pip uninstall -y Jetson.GPIO >/dev/null 2>&1 && echo "[✓] Removed Jetson.GPIO to prevent conflicts"

deactivate

# Step 4: Set up systemd service
echo "[4/5] Setting up systemd service..."
SERVICE_FILE="/etc/systemd/system/project_aegis.service"
sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Reactive Badge Startup
After=network.target

[Service]
ExecStart=/home/pi/Aegis/project_aegis/venv/bin/python3 /home/pi/Aegis/project_aegis/main.py
WorkingDirectory=/home/pi/Aegis/project_aegis
StandardOutput=inherit
StandardError=inherit
Restart=always
User=pi

[Install]
WantedBy=multi-user.target
EOF

# Step 5: Enable and start the service
echo "[5/5] Enabling and starting service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable project_aegis.service
sudo systemctl restart project_aegis.service

echo "[Reactive Badge Installer] Installation completed successfully. Rebooting..."

sudo reboot now
