# Packaging Notes

## Môi trường build Debian/WSL

Cài các package cần thiết:

```bash
sudo apt-get update
sudo apt-get install -y devscripts dpkg-dev debhelper lintian
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

- `nonla-branding`
- `nonla-calamares-config`
- `nonla-default-settings`
- `nonla-repo-keyring`
- `nonla-welcome`

Lý do: các package này đang là skeleton để giữ ownership packaging, chưa ship
payload thật. Khi thêm branding, cấu hình, theme, keyring hoặc welcome app thật,
các warning này phải biến mất thay vì bị ignore lâu dài.

`nonla-look` đã có payload thật đầu tiên nên không còn nằm trong nhóm warning
`empty-binary-package`.
