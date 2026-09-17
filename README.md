# AetherOS — Arch Linux Distribution with KDE Plasma 6

A fully functional, modern Linux distribution built on the **Arch Linux** rolling-release base, featuring the **KDE Plasma 6** desktop environment, **PipeWire** audio architecture, **SDDM** display manager, and the **Calamares** graphical system installer.

---

## Features

- **Base**: Pure Arch Linux rolling release (always updated, access to `pacman` and the AUR).
- **Desktop**: KDE Plasma 6 on Wayland (with XWayland support) for high-refresh-rate and multi-monitor displays.
- **Display Manager**: SDDM preconfigured for automatic live user login without password prompts.
- **Audio**: Full modern PipeWire stack (`pipewire`, `wireplumber`, `pipewire-pulse`).
- **Installer**: Graphical Calamares installer supporting automated partitioning (ext4, btrfs, xfs, f2fs), user creation, and UEFI/BIOS bootloader setup.
- **Hardware Support**: Out-of-the-box drivers for Intel, AMD, and Nouveau graphics, Wi-Fi firmware, and Bluetooth.
- **Build Pipelines**: Ready for automated cloud builds via **GitHub Actions** or local containerized builds via **Docker**.

---

## Project Structure

```
├── .github/workflows/
│   └── build-iso.yml          # GitHub Actions CI/CD to build & release the ISO in the cloud
├── airootfs/                  # Live filesystem overlay (files copied into the rootfs)
│   ├── etc/
│   │   ├── calamares/         # Calamares graphical installer configuration & branding
│   │   ├── os-release         # Distro identification and metadata
│   │   ├── sddm.conf.d/       # Auto-login configuration for live user
│   │   ├── skel/Desktop/      # "Install AetherOS" desktop shortcut
│   │   ├── sudoers.d/         # Passwordless sudo for the live session
│   │   └── systemd/           # Service presets (enables SDDM, NetworkManager)
│   └── usr/local/bin/
│       └── live-setup.sh      # First-boot script that provisions liveuser & permissions
├── efiboot/                   # UEFI bootloader configuration (systemd-boot)
├── syslinux/                  # Legacy BIOS bootloader configuration (syslinux)
├── packages.x86_64            # Curated package list (Plasma, drivers, apps, utils)
├── pacman.conf                # Repositories (core, extra, multilib, chaotic-aur)
├── profiledef.sh              # Archiso metadata and image build specifications
├── Dockerfile                 # Container definition for local Docker builds
├── build-docker.sh            # Helper script for Docker builds
└── build.sh                   # Helper script for native Arch Linux builds
```

---

## How to Build the ISO

### Method 1: Cloud Build via GitHub Actions (Recommended for Mac)

Because building an Arch Linux ISO requires Linux kernel namespaces, loop devices, and `squashfs` tools, building directly on macOS is best handled by GitHub Actions' native Linux runners:

1. Initialize a git repository and push to GitHub:
   ```bash
   git init
   git add .
   git commit -m "feat: initial AetherOS profile"
   git remote add origin https://github.com/<your-username>/<your-repo>.git
   git branch -M main
   git push -u origin main
   ```
2. Navigate to the **Actions** tab in your GitHub repository.
3. Select **Build AetherOS Live ISO** and click **Run workflow**.
4. Once completed (approx. 10–15 minutes), download the ready-to-boot `.iso` file from the workflow artifacts or releases!

---

### Method 2: Local Docker Build

If you have Docker Desktop running:

```bash
./build-docker.sh
```

The resulting ISO will be placed in the `./out/` directory.

---

### Method 3: Native Linux / VM Build

On any machine running Arch Linux (or an Arch VM):

```bash
sudo pacman -S archiso git
sudo ./build.sh
```

---

## Testing Your ISO

### In QEMU (Fast VM test)

```bash
qemu-system-x86_64 -enable-kvm -m 4G -smp 4 \
    -vga virtio -display default \
    -cdrom out/aetheros-*.iso \
    -boot d
```

### In VirtualBox or UTM (macOS)
1. Create a new VM (`Type: Linux`, `Version: Arch Linux (64-bit)`).
2. Allocate at least **4 GB RAM**, **2 CPUs**, and **25 GB Virtual Disk**.
3. Enable **EFI** in VM settings.
4. Mount the `.iso` file as the virtual optical drive and start the VM.

---

## Customizing Your Distro

| To Change... | Edit File... |
| :--- | :--- |
| Distro Name & Version | `profiledef.sh` and `airootfs/etc/os-release` |
| Included Packages | `packages.x86_64` |
| Default Wallpaper & Themes | Place files in `airootfs/etc/skel/.config/` |
| Installer Branding / Logo | `airootfs/etc/calamares/branding/aether/` |
| Live Session Services | `airootfs/etc/systemd/system-preset/00-aether.preset` |

---

## Writing to a USB Drive

Once your ISO is generated:
* **Linux / macOS**: `sudo dd if=aetheros.iso of=/dev/sdX bs=4M status=progress oflag=sync`
* **Windows / Cross-platform**: Use [Ventoy](https://www.ventoy.net/) (drag & drop ISO) or [Rufus](https://rufus.ie/) (DD mode).
