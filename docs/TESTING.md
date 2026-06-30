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
- [ ] `dist/repo/dists/stable/InRelease` tồn tại sau khi chạy
  `./tools/sign-repo.sh`.
- [ ] `dist/repo/dists/stable/Release.gpg` tồn tại sau khi chạy
  `./tools/sign-repo.sh`.
- [ ] `gpgv --keyring packages/nonla-repo-keyring/src/nonla-archive-keyring.gpg
  dist/repo/dists/stable/InRelease` verify good.
- [ ] `gpgv --keyring packages/nonla-repo-keyring/src/nonla-archive-keyring.gpg
  dist/repo/dists/stable/Release.gpg dist/repo/dists/stable/Release` verify
  good.
- [ ] `nonla-repo-keyring` ship đúng
  `/usr/share/keyrings/nonla-archive-keyring.gpg`.
- [ ] APT đọc được repo local qua `file://`.
- [ ] `apt-cache policy nonla-desktop` thấy package từ repo local.

## CI ISO Checklist

- [ ] Workflow `ISO build` chạy pass trên GitHub Actions bằng
  `workflow_dispatch`.
- [ ] Secret `NONLA_ARCHIVE_PRIVATE_KEY` đã được set.
- [ ] Artifact `nonlaos-packages` có đủ package `.deb`.
- [ ] Artifact `nonlaos-apt-repo` có `Packages.gz`, `Release`, `InRelease` và
  `Release.gpg`.
- [ ] Artifact `nonlaos-iso` có `nonlaOS-0.1-alpha-amd64.iso`.
- [ ] Artifact `nonlaos-iso` có `SHA256SUMS`.
- [ ] Artifact `nonlaos-iso` có `SHA256SUMS.gpg`.
- [ ] `SHA256SUMS.gpg` verify good bằng public key nonlaOS.
- [ ] `sha256sum -c SHA256SUMS` pass.
- [ ] SourceForge upload pass nếu có đủ secrets:
  `SOURCEFORGE_USER`, `SOURCEFORGE_PROJECT`, `SOURCEFORGE_SSH_PRIVATE_KEY`.
- [ ] Nếu thiếu SourceForge secrets, workflow skip public upload nhưng vẫn pass.
- [ ] Tải ISO về và boot thử trong VM bằng UEFI.
- [ ] Live KDE desktop vào được.
- [ ] Wallpaper/theme nonla được áp dụng.
- [ ] `apt-cache policy nonla-desktop`.
- [ ] `systemctl --failed`.
- [ ] `journalctl -p 3 -b`.
