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

Validated artifact: `OrangeFox-masera-hybrid4.img` (exactly 67108864 bytes). It is the only recovery artifact currently approved for flashing.

After restoring the stock `boot_a`, `init_boot_a`, and `vendor_boot_a` baseline:

| Kernel | Normal Android with hybrid4 installed | OrangeFox UI + touch | Root adb + five required modules |
| ------ | ------------------------------------- | -------------------- | -------------------------------- |
| Stock `6.1` | Passed | Passed | Passed |
| WildKernel `6.1.145-android14-Wild` | Passed | Passed | Passed |

The direct cloud builds from commits `337244a69d` and `ef3332f044` pass the structural/ELF audit but power off before OrangeFox UI or adb. A green workflow is therefore not boot proof; those direct releases remain unvalidated. The local fstab-only experiment also failed and is not a delivery candidate.

Also verified: `/data` decryption and `adb sideload`. Still unverified: backup/restore, fastbootd, MTP, installer-zip recovery persistence, and a plain-TWRP build. Known accepted limitation: USB-OTG flash drive (same gap as vienna).

## Reproduce the validated image

`hybrid4` is a composite, not a clean `mka vendorbootimage` output.

- Platform fragment: this repository's release tag `45878018134`.
- Recovery runtime: `ChimpanziCloud/android_device_motorola_vienna` release tag `42209442018`.
- Overlay masera recovery modules/firmware and stock `fstab.mt6878`/`fstab.emmc`.
- After `twrp.modules.loaded=true`, insmod `mmi_info.ko`, then `focaltech_touch_v3_u_mmi.ko`.
- Preserve vendor-boot v4/4096 and stock DTB, sign rollback/location `1/1`, require exactly 67108864 bytes.

## Build with OrangeFox manifest (primary)

```bash
git clone https://gitlab.com/OrangeFox/misc/scripts
cd scripts
sudo bash setup/android_build_env.sh
mkdir ~/fox_14.1 && cd ~/fox_14.1
git clone https://gitlab.com/OrangeFox/sync.git && cd sync
./orangefox_sync.sh --branch 14.1 --path ~/fox_14.1
# Fallback: repo init -u https://gitlab.com/OrangeFox/Manifest.git -b fox_14.1 --depth=1 && repo sync
cd ~/fox_14.1
git clone https://github.com/dautistcrat/android_device_motorola_masera.git -b fox_14.1 device/motorola/masera
source build/envsetup.sh
export FOX_VARIANT=a_14
export MASERA_MODULE_VARIANT=a_16
export ALLOW_MISSING_DEPENDENCIES=true
lunch twrp_masera-ap2a-eng
mka adbd vendorbootimage
```

Artifacts: `out/target/product/masera/OrangeFox*.img` (must be ≤ 67108864 bytes)
and `OrangeFox*.zip`. Cloud builds run via `.github/workflows/OrangeFox-Compile.yml`.

## Build plain TWRP (same tree, minimal manifest)

```bash
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp -b twrp-14.1 --depth=1
repo sync
git clone https://github.com/dautistcrat/android_device_motorola_masera.git -b fox_14.1 device/motorola/masera
source build/envsetup.sh
export FOX_VARIANT=a_14
export MASERA_MODULE_VARIANT=a_16
lunch twrp_masera-eng && mka vendorbootimage
```

(`FOX_VARIANT` defaults to `a_14` and `MASERA_MODULE_VARIANT` to `a_16`; the explicit
exports above document the required split between recovery runtime and stock modules.)
Cloud builds run via `.github/workflows/TWRP-Compile.yml`.

## Flash validated recovery and restore stock

The validated baseline uses slot `a` with the bootloader already unlocked and
`ro.boot.verifiedbootstate=orange`. Do not flash vbmeta or erase userdata/metadata.

```bash
# Install the validated local recovery:
fastboot flash vendor_boot_a OrangeFox-masera-hybrid4.img
fastboot reboot recovery

# Restore the fully stock boot chain and stock recovery:
fastboot flash boot_a boot.img
fastboot flash init_boot_a init_boot.img
fastboot flash vendor_boot_a vendor_boot.img
fastboot reboot
```

`boot.img`, `init_boot.img`, and `vendor_boot.img` are the verified files from the
`W3WF36.52-40-3` baseline. Never `fastboot boot` a vendor_boot image on MediaTek;
never flash preloader/lk/modem; never downgrade the bootloader.
