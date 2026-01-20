# initramfs

This directory is reserved for initramfs-related files for the installer kernel.

Note: the installer ISO’s initramfs is currently assembled in the `installer-iso` repo (it bundles BusyBox, the `truthdb-installer` binary, the offline Debian payload, and required tools). This directory may be used in the future if kernel-side initramfs content is needed.