# Contributing to nonlaOS

Cảm ơn bạn muốn đóng góp cho nonlaOS.

## Nguyên tắc

- Không đưa phần mềm lậu, crack, keygen hoặc asset không rõ license vào repo.
- Không sửa ISO thủ công; mọi thay đổi hệ thống phải đi qua package.
- Giữ thay đổi nhỏ, rõ scope, dễ review.
- Build và lint package trước khi mở pull request nếu thay đổi packaging.

## Chuẩn bị môi trường

Trên Debian/WSL:

```bash
sudo apt-get update
sudo apt-get install -y devscripts dpkg-dev debhelper lintian
```

Build:

```bash
./tools/build-packages.sh
```

Lint:

```bash
lintian dist/packages/*.deb
```

## Pull request

PR nên có:

- mục tiêu thay đổi
- package hoặc tài liệu bị ảnh hưởng
- lệnh đã chạy để kiểm thử
- ghi chú license nếu thêm asset

Nếu thêm asset, hãy ghi rõ nguồn, tác giả, license và lý do asset được phép
đưa vào repo.
