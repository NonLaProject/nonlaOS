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

## Default Settings Checklist

- [ ] Cài `nonla-look` và `nonla-default-settings`.
- [ ] Tạo user mới sau khi package đã được cài.
- [ ] Login KDE bằng user mới.
- [ ] Wallpaper nonla được áp dụng.
- [ ] Color scheme `Nonla` được áp dụng.
- [ ] Panel Plasma cơ bản xuất hiện và launcher dùng icon `nonlaos`.
- [ ] `fcitx5` chạy sau khi login.
- [ ] Gõ tiếng Việt được bằng FCITX5 Unikey.
- [ ] User đã tồn tại trước đó không bị ghi đè cấu hình.

## Branding Checklist

- [ ] Cài `nonla-branding`.
- [ ] Kiểm tra `/usr/share/nonlaos/branding/nonlaos-release`.
- [ ] Kiểm tra `/usr/share/nonlaos/branding/boot_logo.png`.
- [ ] Kiểm tra `/usr/share/nonlaos/branding/launcher_icon.png`.
- [ ] Kiểm tra `/usr/share/pixmaps/nonlaos.png`.
- [ ] Kiểm tra `/usr/share/icons/hicolor/256x256/apps/nonlaos.png`.
- [ ] Dry-run cài `nonla-desktop` và xác nhận kéo `nonla-branding`,
  `nonla-look`, `nonla-default-settings`.

## APT Repository Checklist

- [ ] `./tools/build-packages.sh` chạy pass.
- [ ] `./tools/make-repo.sh` chạy pass.
- [ ] `dist/repo/dists/stable/main/binary-amd64/Packages` tồn tại.
- [ ] `dist/repo/dists/stable/main/binary-amd64/Packages.gz` tồn tại.
- [ ] `dist/repo/dists/stable/Release` tồn tại.
- [ ] APT đọc được repo local qua `file://`.
- [ ] `apt-cache policy nonla-desktop` thấy package từ repo local.
