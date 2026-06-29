# AGENTS.md - nonlaOS

> Luôn trả lời bằng tiếng Việt có dấu khi làm việc trong repo này.

## Mục tiêu dự án

nonlaOS là distro desktop tiếng Việt dựa trên Debian stable, dùng KDE Plasma,
hướng tới người chuyển từ Windows sang Linux.

Repo này đi theo hướng package-first:

- Không sửa ISO thủ công.
- Mọi thay đổi hệ thống phải được đóng gói thành Debian package.
- Không thêm phần mềm lậu, crack, keygen hoặc asset không rõ license.
- Không lấy asset từ mạng nếu chưa xác minh nguồn và license.
- Không mở rộng scope sang ISO/live-build nếu task chỉ yêu cầu package hoặc tài
  liệu.

## License

- Source code, packaging metadata và tài liệu dùng `GPL-3.0-or-later`.
- Artwork/asset nội bộ trong `img/` và payload theme dùng `CC-BY-SA-4.0`.
- Khi thêm file mới, cập nhật `debian/copyright`, `NOTICE` hoặc tài liệu liên
  quan nếu license/source thay đổi.

## Workflow GitHub bắt buộc

Branch `main` được bảo vệ bằng GitHub ruleset.

Không push trực tiếp lên `main`.

Quy trình đúng:

1. Tạo branch mới từ `main`.
2. Commit thay đổi theo từng logical unit.
3. Push branch lên GitHub.
4. Mở pull request vào `main`.
5. Đợi CI `Package build / build` pass.
6. Cần ít nhất 1 review trước khi merge.

Repo đã bật `delete_branch_on_merge`, nên branch của PR merged sẽ tự xóa. Nếu PR
bị đóng mà không merge, workflow `Cleanup closed PR branches` sẽ tự xóa branch
đó khi branch nằm trong cùng repo.

Ví dụ:

```bash
git switch main
git pull --ff-only
git switch -c fix/package-build

# chỉnh sửa, build, lint
git add <files>
git commit -m "fix: describe the packaging change"
git push -u origin fix/package-build
gh pr create --base main --head fix/package-build
```

## Kiểm thử packaging

Trên Debian/WSL:

```bash
sudo apt-get update
sudo apt-get install -y build-essential devscripts dpkg-dev debhelper lintian
```

Build toàn bộ package:

```bash
./tools/build-packages.sh
```

Lint:

```bash
lintian dist/packages/*.deb
```

Hiện một số package skeleton có thể còn warning `empty-binary-package`; xem
`docs/PACKAGING_NOTES.md` trước khi xử lý.

## Quy tắc sửa file

- Đọc file liên quan trước khi sửa.
- Ưu tiên patch nhỏ, đúng scope.
- Không revert thay đổi của người khác nếu không được yêu cầu rõ.
- Không commit artifact build trong `dist/`.
- Nếu thay đổi `nonla-look`, chỉ dùng asset có sẵn trong `img/` trừ khi task
  yêu cầu thêm asset và license đã rõ.

## Cấu trúc chính

- `packages/`: Debian package source.
- `packages/nonla-desktop`: metapackage desktop stack.
- `packages/nonla-look`: wallpaper, color scheme, SDDM, Plymouth, icon.
- `docs/`: roadmap, testing, packaging notes, architecture.
- `tools/build-packages.sh`: build toàn bộ package ra `dist/packages/`.
- `.github/workflows/package-build.yml`: CI build và lint package.
