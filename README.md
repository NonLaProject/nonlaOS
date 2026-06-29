# nonlaOS

[![Package build](https://github.com/NonLaProject/nonlaOS/actions/workflows/package-build.yml/badge.svg)](https://github.com/NonLaProject/nonlaOS/actions/workflows/package-build.yml)

nonlaOS là dự án Linux desktop tiếng Việt dựa trên Debian stable, dùng KDE
Plasma, hướng tới người chuyển từ Windows sang Linux.

MVP 0.1 tập trung vào nền tảng tối thiểu:

- Debian stable làm base.
- KDE Plasma làm desktop mặc định.
- Cài đặt tiếng Việt, bộ gõ, font và ứng dụng desktop cơ bản.
- nonla look vừa đủ để nhận diện riêng.
- Calamares để cài đặt hệ thống.
- ISO boot/install được, được tạo bằng package + repo + live-build.

Nguyên tắc:

- Không đưa phần mềm lậu, crack, keygen hoặc asset không rõ license vào hệ
  thống.
- Không sửa ISO thủ công.
- Mọi thay đổi hệ thống phải được package hóa để có thể build lại và kiểm soát
  bằng APT.
- Build package, repo và ISO phải hướng tới reproducible.

## Build packages

Trên Debian/WSL, cài dependency build:

```bash
sudo apt-get update
sudo apt-get install -y devscripts dpkg-dev debhelper lintian
```

Build toàn bộ package skeleton:

```bash
./tools/build-packages.sh
```

Output nằm trong:

```text
dist/packages/
```

## nonla-look

`nonla-look` dùng các asset nội bộ từ `img/` để đóng gói payload nhận diện
đầu tiên của nonlaOS:

- wallpaper KDE
- KDE color scheme `Nonla`
- Plasma look-and-feel skeleton
- SDDM theme skeleton
- Plymouth theme skeleton
- icon app `nonlaos`

Đây là lớp nhận diện ban đầu để package hóa giao diện, chưa phải UI/theme hoàn
chỉnh.

## Tài liệu

- [Roadmap](docs/ROADMAP.md)
- [Testing checklist](docs/TESTING.md)
- [Packaging notes](docs/PACKAGING_NOTES.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Contributing](CONTRIBUTING.md)
- [Security policy](SECURITY.md)

## License

- Source code, packaging metadata và tài liệu: `GPL-3.0-or-later`, xem
  [LICENSE](LICENSE).
- Artwork/asset nội bộ trong `img/` và payload theme: `CC-BY-SA-4.0`, xem
  [NOTICE](NOTICE) và `debian/copyright` của từng package.
