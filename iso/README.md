# nonlaOS ISO build

Thư mục này chứa cấu hình live-build tối thiểu cho ISO nonlaOS.

Mục tiêu hiện tại:

- Debian stable/trixie.
- Kiến trúc amd64.
- ISO hybrid.
- Live desktop KDE thông qua metapackage `nonla-desktop`.
- Cài package nonlaOS từ APT repo local được tạo bởi `tools/make-repo.sh`.

Build ISO chính thức chạy trên GitHub Actions vì bước này cần nhiều tài nguyên
hơn máy local thông thường. Local chỉ cần build package và APT repo khi phát
triển packaging.

Chạy thủ công nếu môi trường đủ mạnh và đã cài `live-build`:

```bash
./tools/build-iso.sh
```

Output ISO nằm trong:

```text
dist/iso/nonlaOS-0.1-alpha-amd64.iso
```

Repo APT local hiện chưa ký GPG. Trong build ISO, repo này chỉ được dùng với
`[trusted=yes]` để cài các package nội bộ. Bước ký repo bằng `nonla-repo-keyring`
sẽ làm sau.

Mặc định `tools/build-iso.sh` expose `dist/repo/` qua HTTP loopback tạm thời để
APT trong chroot live-build đọc được repo local. Có thể ép dùng `file://` bằng:

```bash
NONLA_LB_REPO_MODE=file ./tools/build-iso.sh
```

Trên GitHub Actions, security archive của live-build đang tắt mặc định bằng
`NONLA_LB_SECURITY=false` để tránh Ubuntu runner sinh URL Debian security cũ
kiểu `trixie/updates`. Khi chuyển sang runner Debian/live-build đồng bộ hơn,
có thể bật lại:

```bash
NONLA_LB_SECURITY=true ./tools/build-iso.sh
```

Script cũng dùng `--apt-indices false` vì live-build từ Ubuntu runner hiện tìm
`Contents-amd64.gz` theo layout cũ không còn khớp Debian trixie. Điều này không
ảnh hưởng mục tiêu MVP là build ISO live có `nonla-desktop`.
