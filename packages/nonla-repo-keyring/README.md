# nonlaOS archive keyring

This package installs the public OpenPGP key used to verify the nonlaOS APT
repository metadata.

Installed files:

- `/usr/share/keyrings/nonla-archive-keyring.gpg`
- `/usr/share/doc/nonla-repo-keyring/nonla-archive-key.asc`

The private archive signing key is never shipped in this package and must only
be stored in maintainer-controlled secret storage, such as GitHub Actions
Secrets.
