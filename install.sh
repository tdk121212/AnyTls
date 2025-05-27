#!/bin/bash

set -e

# Install unzip if not installed
if ! command -v unzip &> /dev/null; then
    echo "Installing unzip..."
    sudo apt update
    sudo apt install -y unzip
fi

# Read port and password from user
read -p "Enter port (e.g. 443): " PORT
read -p "Enter password: " PASSWORD

# Variables
VERSION="0.0.8"
DOWNLOAD_URL="https://github.com/anytls/anytls-go/releases/download/v$VERSION/anytls_0.0.8_linux_amd64.zip"
INSTALL_DIR="/opt/anytls-go"
BINARY_NAME="anytls-server"
ZIP_NAME="anytls.zip"

# Create install directory
sudo mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Download and unzip
echo "Downloading anytls-go..."
curl -L "$DOWNLOAD_URL" -o "$ZIP_NAME"
unzip -o "$ZIP_NAME"
rm "$ZIP_NAME"

# Make binary executable
chmod +x $BINARY_NAME

# Create systemd service
SERVICE_FILE="/etc/systemd/system/anytls-go.service"
sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=AnyTLS-Go Server
After=network.target

[Service]
ExecStart=$INSTALL_DIR/$BINARY_NAME -l 0.0.0.0:$PORT -p $PASSWORD
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable anytls-go.service
sudo systemctl start anytls-go.service

echo "anytls-server installed and started successfully."
