# Testing Checklist

- [ ] Boot UEFI.
- [ ] Live desktop vào được.
- [ ] Installer mở được.
- [ ] Cài vào VM thành công.
- [ ] Reboot vào hệ đã cài.
- [ ] `apt update` / `apt upgrade`.
- [ ] `systemctl --failed`.
- [ ] `journalctl -p 3 -b`.
- [ ] Gõ tiếng Việt.
- [ ] LibreOffice mở và tạo tài liệu được.
- [ ] Firefox mở web được.
- [ ] USB.
- [ ] Audio.
- [ ] Wi-Fi.
- [ ] Suspend/resume.

## Package Checklist

- [ ] `./tools/build-packages.sh` chạy pass.
- [ ] `.deb` nằm trong `dist/packages/`.
- [ ] `lintian dist/packages/*.deb` không có error nghiêm trọng.
- [ ] Cài thử package bằng `apt install ./dist/packages/*.deb` hoặc
  `dpkg -i dist/packages/*.deb`.
