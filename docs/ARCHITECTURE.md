# Architecture

nonlaOS được build theo hướng package-first:

- Debian stable là base.
- KDE Plasma là desktop mặc định.
- Mọi thay đổi hệ thống được đóng gói thành `.deb`.
- APT repo sẽ phân phối package nonlaOS.
- ISO sau này sẽ được build bằng live-build hoặc pipeline tương đương, không sửa
  thủ công.

## Package groups

- `nonla-desktop`: metapackage kéo desktop stack cơ bản.
- `nonla-look`: wallpaper, color scheme, SDDM, Plymouth và nhận diện ban đầu.
- `nonla-branding`: branding hệ thống sau này.
- `nonla-default-settings`: cấu hình mặc định người dùng sau này.
- `nonla-calamares-config`: cấu hình installer sau này.
- `nonla-welcome`: welcome app sau này.
- `nonla-repo-keyring`: keyring cho APT repo sau này.
