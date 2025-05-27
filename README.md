# AnyTLS-Go Installer

اسکریپت نصب خودکار برای برنامه [anytls-go](https://github.com/anytls/anytls-go). این اسکریپت:

- آخرین نسخه anytls-go را از GitHub دانلود می‌کند.
- فایل را unzip کرده و به صورت systemd service راه‌اندازی می‌کند.
- از کاربر پورت و پسورد را گرفته و با آن‌ها سرویس را راه‌اندازی می‌کند.

---

## پیش‌نیازها

- سیستم عامل: Ubuntu (تست‌شده روی 20.04 و 22.04)
- اتصال اینترنت فعال
- دسترسی `sudo`

---

## نصب سریع روی VPS

1. وارد سرور شوید:
   ```bash
   ssh your_user@your_vps_ip
