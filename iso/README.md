# nonlaOS ISO build

Thư mục này chứa cấu hình live-build tối thiểu cho ISO nonlaOS.

Mục tiêu hiện tại:

- Debian stable/trixie.
- Kiến trúc `amd64`.
- ISO hybrid.
- BIOS boot bằng syslinux/isolinux.
- UEFI boot bằng GRUB EFI khi live-build hỗ trợ nhiều bootloader.
- Live desktop KDE thông qua metapackage `nonla-desktop`.
- Cài package nonlaOS từ APT repo local được tạo bởi `tools/make-repo.sh`.

Build ISO chính thức chạy trên GitHub Actions. Workflow dùng runner
`ubuntu-latest`, nhưng bước live-build chạy trong container `debian:trixie`
privileged để khớp base distro mục tiêu.

```bash
./tools/build-iso.sh
```

Output:

```text
dist/iso/nonlaOS-0.1-alpha-amd64.iso
```

## Bootloader

`tools/build-iso.sh` ưu tiên cấu hình live-build với:

```text
--bootloaders syslinux,grub-efi
```

Nếu bản live-build chỉ hỗ trợ option cũ `--bootloader`, script fallback về:

```text
--bootloader syslinux
```

Fallback này đảm bảo ISO vẫn có BIOS bootloader hợp lệ cho VirtualBox/QEMU.
UEFI sẽ tiếp tục được bật khi live-build trong Debian trixie hỗ trợ nhiều
bootloader.

Các dependency quan trọng:

- `live-build`
- `xorriso`
- `genisoimage`
- `isolinux`
- `syslinux`
- `syslinux-common`
- `syslinux-utils`
- `grub-pc-bin`
- `grub-efi-amd64-bin`
- `grub-efi-ia32-bin`
- `mtools`

## Boot smoke test

Sau khi build, workflow chạy:

```bash
./tools/verify-iso-boot.sh
```

Script này kiểm tra:

- `file` nhận diện ISO.
- `isoinfo` thấy El Torito boot catalog.
- `xorriso` report boot metadata.
- QEMU BIOS smoke test không báo `Boot failed`, `No bootable device`, hoặc lỗi
  đọc CD-ROM.

Lệnh debug thủ công:

```bash
file dist/iso/nonlaOS-0.1-alpha-amd64.iso
isoinfo -d -i dist/iso/nonlaOS-0.1-alpha-amd64.iso
qemu-system-x86_64 -m 2048 -cdrom dist/iso/nonlaOS-0.1-alpha-amd64.iso -boot d -nographic
```

## Repo local

Mặc định `tools/build-iso.sh` expose `dist/repo/` qua HTTP loopback tạm thời để
APT trong chroot live-build đọc được repo local:

```bash
NONLA_LB_REPO_MODE=http ./tools/build-iso.sh
```

Có thể ép dùng `file://`:

```bash
NONLA_LB_REPO_MODE=file ./tools/build-iso.sh
```

Nếu có private archive key, script sẽ ký repo trước khi live-build chạy.
Trong live-build, repo nội bộ vẫn dùng `[trusted=yes]` vì đây là repo local
ephemeral trên runner; artifact repo phát hành bên ngoài được verify bằng
`InRelease`/`Release.gpg`.
