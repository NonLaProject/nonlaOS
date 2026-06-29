<p align="center">
  <img src="img/readme_logo.png" alt="nonlaOS logo" width="560">
</p>

# nonlaOS

[![Package build](https://github.com/NonLaProject/nonlaOS/actions/workflows/package-build.yml/badge.svg)](https://github.com/NonLaProject/nonlaOS/actions/workflows/package-build.yml)

nonlaOS là dự án Linux desktop tiếng Việt dựa trên Debian stable, dùng KDE
Plasma, hướng tới người chuyển từ Windows sang Linux.

Dự án ưu tiên cách làm có thể kiểm chứng và lặp lại: mọi thay đổi hệ thống được
đóng gói thành Debian package, phân phối qua APT repo, rồi mới đưa vào ISO. Repo
này là nền móng packaging/source đầu tiên của nonlaOS, chưa phải bản ISO hoàn
chỉnh cho người dùng cuối.

## Mục tiêu

MVP 0.1 tập trung vào một hệ desktop tối thiểu nhưng đúng quy trình:

- Debian stable làm base.
- KDE Plasma làm desktop mặc định.
- Hỗ trợ tiếng Việt, bộ gõ và font phù hợp.
- Cài sẵn các ứng dụng desktop cơ bản cho người mới chuyển từ Windows.
- Có nhận diện nonlaOS đầu tiên qua wallpaper, color scheme, SDDM và Plymouth.
- Có Calamares để chuẩn bị luồng cài đặt.
- Build package, repo và ISO theo hướng reproducible.

## Nguyên tắc kỹ thuật

- Không đưa phần mềm lậu, crack, keygen hoặc asset không rõ license vào repo.
- Không sửa ISO thủ công.
- Không coi theme, cấu hình hoặc branding là “file copy tay”; mọi thay đổi phải
  đi qua Debian package.
- Tối ưu cho khả năng review, rollback và update bằng APT.
- Ưu tiên Debian stable và package chính thống trước khi thêm dependency ngoài.

## Cấu trúc repo

```text
packages/
  nonla-desktop/             Metapackage cho desktop stack cơ bản
  nonla-look/                Wallpaper, KDE color scheme, SDDM, Plymouth, icon
  nonla-branding/            Branding hệ thống sau này
  nonla-default-settings/    Cấu hình mặc định người dùng sau này
  nonla-calamares-config/    Cấu hình installer sau này
  nonla-welcome/             Welcome app sau này
  nonla-repo-keyring/        Keyring cho APT repo sau này
docs/                        Roadmap, testing, packaging notes, architecture
img/                         Asset nội bộ của nonlaOS
tools/                       Script build package
iso/                         Không gian chuẩn bị cho ISO tooling sau này
artwork/                     Không gian chuẩn bị cho artwork source sau này
```

## Package hiện có

`nonla-desktop` là metapackage kéo desktop stack KDE Plasma cơ bản, gồm SDDM,
Calamares, Firefox ESR, LibreOffice, Dolphin, Konsole, Kate, Okular, Ark,
Gwenview, Noto fonts, FCITX5 Unikey và UFW.

`nonla-look` là payload nhận diện đầu tiên của nonlaOS. Package này dùng asset
nội bộ từ `img/` để ship:

- KDE wallpaper `nonlaOS Default`
- KDE color scheme `Nonla`
- Plasma look-and-feel skeleton
- SDDM theme skeleton
- Plymouth theme skeleton
- icon app `nonlaos`

Các package còn lại hiện là skeleton có chủ đích để giữ ownership packaging cho
các bước tiếp theo.

## Build packages

Trên Debian/WSL, cài dependency build:

```bash
sudo apt-get update
sudo apt-get install -y build-essential devscripts dpkg-dev debhelper lintian
```

Build toàn bộ package:

```bash
./tools/build-packages.sh
```

Output nằm trong:

```text
dist/packages/
```

Lint package:

```bash
lintian dist/packages/*.deb
```

Một số package skeleton có thể còn warning `empty-binary-package`; xem
[Packaging notes](docs/PACKAGING_NOTES.md) để biết warning nào đang được chấp
nhận tạm thời.

## Trạng thái CI

GitHub Actions hiện build toàn bộ Debian package và chạy lintian trên mỗi push
vào `main` và mỗi pull request. Branch `main` được bảo vệ bằng ruleset: thay đổi
phải đi qua pull request, CI `build` phải pass và cần review trước khi merge.

## Roadmap

- `0.1 alpha`: Debian + KDE + nonla look + tiếng Việt + Calamares + ISO
  boot/install.
- `0.5 beta`: APT repo + welcome app + docs + update hoạt động + test máy thật.
- `1.0 stable`: dùng hằng ngày ổn, license sạch, update không vỡ.
- `2.0`: Edu/Gov mode, policy, restore, bulk deploy, hardening.

Xem chi tiết tại [docs/ROADMAP.md](docs/ROADMAP.md).

## Tài liệu

- [Architecture](docs/ARCHITECTURE.md)
- [Roadmap](docs/ROADMAP.md)
- [Testing checklist](docs/TESTING.md)
- [Packaging notes](docs/PACKAGING_NOTES.md)
- [Contributing](CONTRIBUTING.md)
- [Security policy](SECURITY.md)

## License

- Source code, packaging metadata và tài liệu: `GPL-3.0-or-later`, xem
  [LICENSE](LICENSE).
- Artwork/asset nội bộ trong `img/` và payload theme: `CC-BY-SA-4.0`, xem
  [NOTICE](NOTICE) và `debian/copyright` của từng package.
