# nonla-default-settings

Package này ship cấu hình mặc định cho user mới thông qua `/etc/skel` và cấu
hình input method toàn hệ thống qua `/etc/environment.d`.

## Phạm vi

- Áp dụng wallpaper `nonla-default` cho Plasma desktop mới.
- Áp dụng color scheme `Nonla`.
- Seed panel Plasma cơ bản với launcher icon `nonlaos`.
- Bật biến môi trường FCITX5.
- Autostart `fcitx5` cho user KDE mới.
- Seed FCITX5 profile ưu tiên `unikey`.

Package không sửa home directory của user hiện có và không dùng maintainer script
để ghi đè cấu hình runtime.

## Locale và timezone

Package này không ép locale hoặc timezone hệ thống.

Locale/timezone nên được cấu hình ở installer, live-build profile hoặc tài liệu
triển khai, vì đây là lựa chọn theo vùng/người dùng và không nên bị package
settings ghi cứng bằng `postinst`.
