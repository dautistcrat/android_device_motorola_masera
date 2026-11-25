# OrangeFox / TWRP device tree for Motorola Edge 2026 (masera)

Stock baseline: `XT2609-1_MASERA_RETUS_16_W3WF36.52-40-3`
(`motorola/masera_g_sys/masera:16/W3WF36.52-40-3/c7e92-0cd13:user/release-keys`).

## Credits

- [TeamWin Recovery Project](https://github.com/TeamWin) - recovery sources
- [OrangeFox Recovery Project](https://gitlab.com/OrangeFox) - recovery sources
- [ChimpanziCloud](https://github.com/ChimpanziCloud/android_device_motorola_vienna) -
  vienna donor tree (same MT6878 family); config structure, bootctrl and
  plpath sources adapted from there

## Verified device facts (from stock images)

| Fact | Value |
| ---- | ----- |
| SoC / platform | MediaTek MT6878 (`PRODUCT_PLATFORM=mt6878`) |
| Vendor API / kernel | API 34 (Android 14), GKI 6.1 (`android14-11`) |
| System API | API 36 (Android 16) |
| Display | 1216x2640, Tianma ili97680a (panel module name) |
| Touch | FocalTech SPI (`focaltech_touch_v3_u_mmi.ko` + `touchscreen_u_mmi.ko`) |
| Dynamic partitions | system system_ext product vendor vendor_dlkm system_dlkm (no odm) |
| Filesystems | erofs (all logical), f2fs (`/data`, `/metadata`) |
| Super size | 24427626496 (from `lpdump`; confirm `partition-size:super` on device) |
| AVB | `vbmeta` + chained `vbmeta_system`; custom images boot only with verification disabled |

## Status

Untested — bring-up pending. Checklist mirrors the vienna donor tree:

- [ ] Boot to OrangeFox UI (correct colors, touch, brightness)
- [ ] ADB in recovery, `/tmp/recovery.log` clean
- [ ] `/data` decrypt with PIN/password (FBE + wrappedkey)
- [ ] Backup/restore round-trip (`boot` + `data`)
- [ ] fastbootd answers `fastboot devices`
- [ ] Sideload installer zip; recovery persists
- [ ] MTP mount on host
- [ ] Plain-TWRP build boots (decrypt best-effort on that base)

Known accepted limitation: USB-OTG flash drive (same gap as vienna).

## Build with OrangeFox manifest (primary)

```bash
git clone https://gitlab.com/OrangeFox/misc/scripts
cd scripts
sudo bash setup/android_build_env.sh
mkdir ~/fox_16.0 && cd ~/fox_16.0
git clone https://gitlab.com/OrangeFox/sync.git && cd sync
./orangefox_sync.sh --branch 16.0 --path ~/fox_16.0
# (if the script rejects 16.0: repo init -u https://gitlab.com/OrangeFox/Manifest.git -b fox_16.0 --depth=1 && repo sync)
cd ~/fox_16.0
git clone https://github.com/dautistcrat/android_device_motorola_masera.git -b fox_16.0 device/motorola/masera
source build/envsetup.sh
export FOX_VARIANT=a_16
lunch twrp_masera-bp2a-eng && mka adbd vendorbootimage
```

Artifacts: `out/target/product/masera/OrangeFox*.img` (must be ≤ 67108864 bytes)
and `OrangeFox*.zip`. Cloud builds run via `.github/workflows/OrangeFox-Compile.yml`.

## Build plain TWRP (same tree, minimal manifest)

```bash
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp -b twrp-14.1 --depth=1
repo sync
git clone https://github.com/dautistcrat/android_device_motorola_masera.git -b fox_16.0 device/motorola/masera
source build/envsetup.sh
lunch twrp_masera-eng && mka vendorbootimage
```

(`FOX_VARIANT` defaults to `a_16` in `device.mk`, so no extra exports are needed.)
Cloud builds run via `.github/workflows/TWRP-Compile.yml`.

## Flash (current slot) and restore to stock

```bash
SLOT=$(fastboot getvar current-slot 2>&1 | grep -oE 'a|b' | tail -1)
# custom recovery (verification must stay disabled while it is flashed):
fastboot flash vbmeta_$SLOT --disable-verity --disable-verification vbmeta.img
fastboot flash vbmeta_system_$SLOT --disable-verity --disable-verification vbmeta_system.img
fastboot flash vendor_boot_$SLOT OrangeFox-*-masera.img
# restore stock (re-enables verified boot):
fastboot flash vendor_boot_$SLOT vendor_boot.img
fastboot flash vbmeta_$SLOT vbmeta.img
fastboot flash vbmeta_system_$SLOT vbmeta_system.img
```

(`vbmeta.img`, `vbmeta_system.img`, `vendor_boot.img` are the stock files from the
baseline zip. Never `fastboot boot` a vendor_boot image on MediaTek; never flash
preloader/lk/modem; never downgrade the bootloader.)
