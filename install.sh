#!/bin/bash

set -e

SERVICE_NAME="anytls-go"
INSTALL_DIR="/opt/anytls-go"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"
BINARY_NAME="anytls-server"
VERSION="0.0.8"
DOWNLOAD_URL="https://github.com/anytls/anytls-go/releases/download/v$VERSION/anytls_0.0.8_linux_amd64.zip"
ZIP_NAME="anytls.zip"

# Show menu
echo "Select an option:"
echo "1) Install anytls-server"
echo "2) Uninstall anytls-server"
read -p "Enter your choice [1-2]: " CHOICE

if [[ "$CHOICE" == "2" ]]; then
    echo "Uninstalling $SERVICE_NAME..."

    if systemctl list-units --full -all | grep -Fq "$SERVICE_NAME.service"; then
        sudo systemctl stop "$SERVICE_NAME.service" || true
        sudo systemctl disable "$SERVICE_NAME.service" || true
        sudo rm -f "$SERVICE_FILE"
    fi

    if [ -d "$INSTALL_DIR" ]; then
        sudo rm -rf "$INSTALL_DIR"
    fi

    sudo systemctl daemon-reload
    echo "$SERVICE_NAME has been uninstalled."
    exit 0
elif [[ "$CHOICE" != "1" ]]; then
    echo "Invalid choice. Exiting."
    exit 1
fi

# Install unzip if not installed
if ! command -v unzip &> /dev/null; then
    echo "Installing unzip..."
    sudo apt update
    sudo apt install -y unzip
fi

# Read port and password from user
read -p "Enter port (e.g. 443): " PORT
read -p "Enter password: " PASSWORD

# Create install directory
sudo mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Download and unzip
echo "Downloading anytls-go..."
curl -L "$DOWNLOAD_URL" -o "$ZIP_NAME"
unzip -o "$ZIP_NAME"
rm "$ZIP_NAME"

# Make binary executable
chmod +x "$BINARY_NAME"

# Create systemd service
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
sudo systemctl enable "$SERVICE_NAME.service"
sudo systemctl start "$SERVICE_NAME.service"

echo "anytls-server installed and started successfully."
