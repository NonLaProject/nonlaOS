# Packaging Notes

## Môi trường build Debian/WSL

Cài các package cần thiết:

```bash
sudo apt-get update
sudo apt-get install -y build-essential devscripts dpkg-dev debhelper lintian
```

Build toàn bộ package:

```bash
./tools/build-packages.sh
```

Output được ghi vào `dist/packages/`.

## Lintian

Lệnh kiểm tra cơ bản:

```bash
lintian dist/packages/*.deb
```

Các warning `empty-binary-package` hiện được chấp nhận cho:

- `nonla-calamares-config`
- `nonla-repo-keyring`
- `nonla-welcome`

Lý do: các package này đang là skeleton để giữ ownership packaging, chưa ship
payload thật. Khi thêm branding, cấu hình, theme, keyring hoặc welcome app thật,
các warning này phải biến mất thay vì bị ignore lâu dài.

`nonla-look` đã có payload thật đầu tiên nên không còn nằm trong nhóm warning
`empty-binary-package`.

`nonla-default-settings` đã có payload thật đầu tiên cho `/etc/skel` và
`/etc/environment.d`, nên không còn nằm trong nhóm warning
`empty-binary-package`.

`nonla-branding` đã có payload thật đầu tiên cho logo, icon và metadata nhận
diện riêng của nonlaOS, nên không còn nằm trong nhóm warning
`empty-binary-package`.

`nonla-desktop` giữ `fcitx5` và `fcitx5-unikey` trong `Depends`, nhưng đặt
`kcm-fcitx5` trong `Recommends`. Lý do: trên môi trường Debian/WSL hiện tại,
`kcm-fcitx5` không có candidate installable, nên đưa vào `Depends` sẽ làm
metapackage không cài được dù input method core vẫn có.

## Lintian overrides

`nonla-default-settings` override tag `package-contains-file-in-etc-skel` cho
các file cấu hình trong `/etc/skel`.

Lý do: package này có mục tiêu rõ ràng là seed cấu hình KDE/FCITX5 cho user mới
của distro. Cách này không ghi đè cấu hình user hiện có và tránh maintainer
script sửa home directory runtime.
