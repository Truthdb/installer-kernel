# installer-kernel

Builds the Linux kernel artifact used by the TruthDB installer ISO.

## What This Repo Produces

The release artifact is:

- `BOOTX64.EFI`

This is currently the built `bzImage` copied/renamed to `BOOTX64.EFI` for convenience in the ISO build pipeline.

## How It’s Built

- CI downloads Linux kernel source (`6.12`) and validates it against a pinned SHA256.
- The kernel configuration used is `truthdb-installer-kernel.config`.
- Releases build in a dedicated container image published by `installer-kernel-builder-image`.

See the workflows in `.github/workflows/` for the authoritative build steps.

## License

MIT. See LICENSE.
