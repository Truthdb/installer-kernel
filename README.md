# installer-kernel

Builds the Linux kernel artifact used by the TruthDB installer ISO.

## What This Repo Produces

The release artifacts are:

- `BOOTX64.EFI`
- `BOOTX64.EFI.sha256`

This is currently the built `bzImage` copied/renamed to `BOOTX64.EFI` for convenience in the ISO build pipeline.

## How It’s Built

- CI downloads Linux kernel source (`6.12`) and validates it against a pinned SHA256.
- The kernel configuration used is `truthdb-installer-kernel.config`.
- Releases build in a dedicated container image published by `installer-kernel-builder-image`.

## Local Development

To build the kernel artifact locally in a container:

`./build_in_container.sh`

This will:

- Build the local builder image automatically if it is not already present
- Download the pinned Linux tarball
- Apply `truthdb-installer-kernel.config`
- Run `make olddefconfig`
- Build `bzImage`
- Write `dist/BOOTX64.EFI` and `dist/BOOTX64.EFI.sha256`

To rebuild the installer ISO using that locally built kernel:

`./build_iso_with_local_kernel.sh`

That wrapper forwards to `installer-iso/build_in_container.sh` with:

- `KERNEL_SRC=./dist/BOOTX64.EFI`
- whatever `INPUT_MODE` you set in the shell

Examples:

- local-dev ISO with local kernel: `./build_iso_with_local_kernel.sh`
- release-style ISO with local kernel: `INPUT_MODE=release ./build_iso_with_local_kernel.sh`

Useful environment variables:

- `BUILDER_IMAGE`: local Docker image tag to use for kernel builds
- `AUTO_BUILD_IMAGE`: `1` to auto-build the local builder image if missing
- `KERNEL_VERSION`: kernel version tarball to download
- `KERNEL_TARBALL_SHA256`: expected SHA256 for the kernel tarball
- `KERNEL_CONFIG`: config file to apply
- `OUTPUT_DIR`: where to write `BOOTX64.EFI` and `BOOTX64.EFI.sha256`
- `KEEP_KERNEL_SRC`: `1` to keep the unpacked `kernel-src/` tree after the build
- `INPUT_MODE`: passed through by `build_iso_with_local_kernel.sh` to the installer-iso build

See the workflows in `.github/workflows/` for the authoritative build steps.

## License

MIT. See LICENSE.
