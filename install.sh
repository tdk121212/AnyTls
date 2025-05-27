#!/bin/bash

set -e

# بررسی و نصب unzip در صورت نیاز
if ! command -v unzip &> /dev/null; then
    echo "نصب unzip..."
    sudo apt update
    sudo apt install -y unzip
fi

# دریافت پورت و پسورد از کاربر
read -p "لطفاً پورت مورد نظر را وارد کنید (مثلاً 443): " PORT
read -s -p "لطفاً پسورد را وارد کنید: " PASSWORD
echo ""

# تعریف متغیرها
VERSION="v0.0.8"
REPO="anytls/anytls-go"
ASSET_NAME="anytls-go-linux-amd64.zip"
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$VERSION/$ASSET_NAME"
INSTALL_DIR="/opt/anytls-go"
BINARY_PATH="$INSTALL_DIR/anytls-go"

# ایجاد مسیر نصب
sudo mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# دانلود و استخراج فایل
echo "دانلود برنامه از $DOWNLOAD_URL ..."
curl -L "$DOWNLOAD_URL" -o "$ASSET_NAME"
unzip -o "$ASSET_NAME"
rm "$ASSET_NAME"
sudo chmod +x anytls-go

# ایجاد فایل سرویس systemd
SERVICE_FILE="/etc/systemd/system/anytls-go.service"
sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=AnyTLS-Go Service
After=network.target

[Service]
ExecStart=$BINARY_PATH -port $PORT -password $PASSWORD
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# فعال‌سازی و راه‌اندازی سرویس
sudo systemctl daemon-reload
sudo systemctl enable anytls-go.service
sudo systemctl start anytls-go.service

echo "نصب و راه‌اندازی anytls-go با موفقیت انجام شد."
