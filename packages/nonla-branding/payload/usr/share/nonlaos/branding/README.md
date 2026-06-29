# nonlaOS branding metadata

Thư mục này chứa logo, icon và metadata nhận diện riêng của nonlaOS.

File `nonlaos-release` có định dạng giống các trường nhận diện phổ biến của
`os-release`, nhưng hiện chỉ là metadata riêng của nonlaOS để desktop
integration, tài liệu hoặc ISO tooling đọc sau này.

Package này chưa thay thế `/etc/os-release` hoặc `/usr/lib/os-release` để tránh
conflict với package `base-files` của Debian.

Bước thay đổi branding hệ thống cấp `os-release` sẽ được xử lý riêng trong
ISO/live-build hoặc package `base-files` riêng của nonlaOS sau này.
