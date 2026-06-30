<p align="center">
  <img src="img/readme_logo.png" alt="nonlaOS logo" width="560">
</p>

# nonlaOS

[![Package build](https://github.com/NonLaProject/nonlaOS/actions/workflows/package-build.yml/badge.svg)](https://github.com/NonLaProject/nonlaOS/actions/workflows/package-build.yml)
[![ISO build](https://github.com/NonLaProject/nonlaOS/actions/workflows/build-iso.yml/badge.svg)](https://github.com/NonLaProject/nonlaOS/actions/workflows/build-iso.yml)

nonlaOS là dự án Linux desktop tiếng Việt dựa trên Debian stable/trixie, dùng KDE
Plasma, hướng tới người chuyển từ Windows sang Linux.

Repo này chứa nền móng packaging, APT repository, live-build ISO và release
pipeline. Mọi thay đổi hệ thống phải đi qua Debian package, không sửa ISO thủ
công.

## Mục tiêu 0.1 alpha

- Debian stable/trixie làm base.
- KDE Plasma làm desktop mặc định.
- Hỗ trợ tiếng Việt, font và bộ gõ phù hợp.
- Có nhận diện nonlaOS đầu tiên qua logo, wallpaper, KDE color scheme, SDDM và
  Plymouth.
- Build package, APT repo và ISO bằng script/CI có thể lặp lại.
- Release artifact có chữ ký APT repo và checksum ISO.

## Nguyên tắc

- Không phần mềm lậu, crack, keygen hoặc asset không rõ license.
- Không sửa ISO thủ công.
- Package hóa mọi thay đổi hệ thống.
- Private key không bao giờ được commit.
- Không hardcode domain public của nonlaOS trong source.

## Cấu trúc repo

```text
packages/   Debian package source
iso/        live-build config
tools/      build, repo, signing, release scripts
docs/       roadmap, testing, packaging notes
img/        asset nội bộ của nonlaOS
artwork/    artwork source sau này
```

## Package chính

- `nonla-desktop`: metapackage kéo KDE desktop stack, app cơ bản và các package
  nhận diện/cấu hình của nonlaOS.
- `nonla-branding`: logo, icon và metadata nhận diện riêng của nonlaOS, chưa
  thay thế `/etc/os-release`.
- `nonla-look`: wallpaper, KDE color scheme `Nonla`, look-and-feel skeleton,
  SDDM theme, Plymouth theme.
- `nonla-default-settings`: seed cấu hình user mới qua `/etc/skel`, bật FCITX5
  qua `/etc/environment.d`, không ghi đè user hiện có.
- `nonla-repo-keyring`: public archive key để verify APT repo nonlaOS.

## Build packages

```bash
sudo apt-get update
sudo apt-get install -y build-essential devscripts dpkg-dev debhelper lintian

./tools/build-packages.sh
```

Output:

```text
dist/packages/
```

Lint:

```bash
lintian dist/packages/*.deb
```

## Build APT repository

```bash
sudo apt install dpkg-dev apt-utils gzip

./tools/build-packages.sh
./tools/make-repo.sh
```

Output:

```text
dist/repo/
```

Test local repo chưa ký bằng `file://`:

```bash
REPO_PATH="$(pwd)/dist/repo"

echo "deb [trusted=yes] file:${REPO_PATH} stable main" | \
  sudo tee /etc/apt/sources.list.d/nonla-local.list

sudo apt update
apt-cache policy nonla-desktop
```

Ví dụ public repo khi deploy:

```text
deb [signed-by=/usr/share/keyrings/nonla-archive-keyring.gpg] https://YOUR_EXISTING_REPO_DOMAIN/path/to/repo stable main
```

Domain thật được cấu hình ở hạ tầng deploy. Domain riêng cho nonlaOS xử lý sau.

## Archive signing key

Archive key hiện tại:

```text
uid: nonlaOS Archive Signing Key
fingerprint: 6A41 9F7B EF2D D819 B80F  3ECF 9E06 44E3 BBCF FFC3
```

Public key được commit trong:

```text
packages/nonla-repo-keyring/src/nonla-archive-key.asc
packages/nonla-repo-keyring/src/nonla-archive-keyring.gpg
```

Private key local nằm trong `dist/keys/private/` và bị `.gitignore` bỏ qua.

Tạo key mới khi rotate:

```bash
GNUPGHOME="$(mktemp -d)"
chmod 700 "$GNUPGHOME"
export GNUPGHOME

gpg --batch --pinentry-mode loopback --passphrase "" \
  --quick-generate-key "nonlaOS Archive Signing Key" rsa4096 sign 3y

KEY_FPR="$(gpg --batch --with-colons --list-secret-keys \
  "nonlaOS Archive Signing Key" | awk -F: '/^fpr:/ {print $10; exit}')"

gpg --armor --export "$KEY_FPR" > packages/nonla-repo-keyring/src/nonla-archive-key.asc
gpg --export "$KEY_FPR" > packages/nonla-repo-keyring/src/nonla-archive-keyring.gpg
gpg --armor --export-secret-keys "$KEY_FPR" > dist/keys/private/nonla-archive-private-key.asc
```

Ký repo:

```bash
./tools/build-packages.sh
./tools/make-repo.sh

NONLA_ARCHIVE_PRIVATE_KEY_FILE=dist/keys/private/nonla-archive-private-key.asc \
  ./tools/sign-repo.sh
```

Verify repo:

```bash
gpgv --keyring packages/nonla-repo-keyring/src/nonla-archive-keyring.gpg \
  dist/repo/dists/stable/InRelease

gpgv --keyring packages/nonla-repo-keyring/src/nonla-archive-keyring.gpg \
  dist/repo/dists/stable/Release.gpg \
  dist/repo/dists/stable/Release
```

## GitHub Actions release secrets

Set GPG private key:

```bash
gh secret set NONLA_ARCHIVE_PRIVATE_KEY < dist/keys/private/nonla-archive-private-key.asc
```

Nếu key có passphrase:

```bash
gh secret set NONLA_ARCHIVE_KEY_PASSPHRASE
```

Set SourceForge secrets:

```bash
gh secret set SOURCEFORGE_USER
gh secret set SOURCEFORGE_PROJECT
gh secret set SOURCEFORGE_SSH_PRIVATE_KEY < path/to/sourceforge_deploy_key
```

Custom release path nếu cần:

```bash
gh secret set SOURCEFORGE_RELEASE_PATH
```

Mặc định:

```text
/home/frs/project/${SOURCEFORGE_PROJECT}/nonlaOS/0.1-alpha/
```

## Build ISO

ISO chính thức build bằng GitHub Actions workflow:

```text
.github/workflows/build-iso.yml
```

Workflow chỉ chạy thủ công qua `workflow_dispatch`:

1. Vào tab **Actions**.
2. Chọn **ISO build**.
3. Chọn **Run workflow** trên branch `main`.
4. Tải artifact `nonlaos-iso` sau khi run xong.

Artifact ISO gồm:

```text
nonlaOS-0.1-alpha-amd64.iso
SHA256SUMS
SHA256SUMS.gpg
```

Workflow kiểm tra boot metadata và BIOS boot smoke test trước khi upload:

```bash
file dist/iso/nonlaOS-0.1-alpha-amd64.iso
isoinfo -d -i dist/iso/nonlaOS-0.1-alpha-amd64.iso
xorriso -indev dist/iso/nonlaOS-0.1-alpha-amd64.iso -report_el_torito plain
./tools/verify-iso-boot.sh
```

`tools/build-iso.sh` ưu tiên tạo ISO hybrid có BIOS + UEFI bootloader bằng
`syslinux,grub-efi`. Nếu live-build trên runner không hỗ trợ nhiều bootloader,
script fallback về BIOS `syslinux` để VirtualBox/QEMU vẫn boot được.

Nếu SourceForge secrets có đủ, workflow upload các file trên lên SourceForge.
Nếu thiếu SourceForge secrets, workflow vẫn build và upload GitHub Actions
artifacts, chỉ bỏ qua public upload.

Tải từ SourceForge sau khi upload:

```text
https://sourceforge.net/projects/YOUR_SOURCEFORGE_PROJECT/files/nonlaOS/0.1-alpha/
```

Verify checksum ISO:

```bash
gpgv --keyring packages/nonla-repo-keyring/src/nonla-archive-keyring.gpg \
  SHA256SUMS.gpg \
  SHA256SUMS

sha256sum -c SHA256SUMS
```

Local vẫn có thể chạy `./tools/build-iso.sh` nếu môi trường đủ mạnh và có
`live-build`, nhưng CI là môi trường build ISO chính thức.

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
