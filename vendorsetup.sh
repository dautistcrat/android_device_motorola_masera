# For Minimal Manifest
export ALLOW_MISSING_DEPENDENCIES=true

# IDK what this is for
export LC_ALL="C"

# Build Device Codename
export FOX_BUILD_DEVICE=masera

# Device uses virtual ab ota update
export FOX_VIRTUAL_AB_DEVICE=1

# Device uses Vendor_Boot partition for recovery ramdisk
export FOX_VENDOR_BOOT_RECOVERY=1

# Uniform lz4 ramdisk is mandatory (GKI spec): OF_USE_LZMA_COMPRESSION=1 sets
# BOARD_RAMDISK_USE_LZMA=true (bootable/recovery/orangefox.mk), a live codec
# input that is only shadowed by BOARD_RAMDISK_USE_LZ4 today. Keep it 0.
export OF_USE_LZMA_COMPRESSION=0

# Optional
export FOX_BASH_TO_SYSTEM_BIN=1

# Build all partition tools 
export OF_ENABLE_ALL_PARTITION_TOOLS=1

# don't spam the console with loop errors
export OF_LOOP_DEVICE_ERRORS_TO_LOG=1

# Called just before formatting /data; only useful for devices/ROMs that have dynamic partitions
export OF_USE_DMCTL=1

# Set this to 1 to disable automatic rebooting after openrecoveryscript finishes
export OF_DISABLE_ORS_AUTO_REBOOT=1

# ensure that /sdcard is bind-unmounted before f2fs data repair or format
export OF_UNBIND_SDCARD_F2FS=1

# avoid MTP issues after data format
export OF_BIND_MOUNT_SDCARD_ON_FORMAT=1

# Set to 1 to attempt to unmount the SD cards before rebooting
export OF_UNMOUNT_SDCARDS_BEFORE_REBOOT=1

# Set this to 1 to force the selection of f2fs when formatting data
export OF_FORCE_DATA_FORMAT_F2FS=1

# Set this to 1 to include an addon for removing factory reset protection (FRP)
export OF_ENABLE_FRP_ADDON=1

# AromaFM does not work
export FOX_DELETE_AROMAFM=1

# Set to the maintainer's name
export OF_MAINTAINER=dautistcrat

# Use this to change the default time zone
export OF_DEFAULT_TIMEZONE=EST5EDT

# Flashlight path
export OF_FL_PATH1=/tmp/of_torch/

# Quick backup list
export OF_QUICK_BACKUP_LIST="/data;/boot;"

# Default fox settings directory where config is stored
export FOX_SETTINGS_ROOT_DIRECTORY="/persist"

# Set this to 1 if your device uses aidl (as opposed to hidl) to handle boot control, particularly changing slots
export OF_USE_AIDL_BOOT_CONTROL=1

# Device specific
export OF_SCREEN_H=2640

# Device has notch in statusbar
export OF_HIDE_NOTCH=1

# Statusbar height
export OF_STATUS_H=79

# Disables the ability to place clock in the middle of the screen
export OF_CLOCK_POS=1

# Set this to 1 to replace the "Swipe up" lockscreen screen with a button
export OF_USE_LOCKSCREEN_BUTTON=1

# Round corners
export OF_STATUS_INDENT_LEFT=71
export OF_STATUS_INDENT_RIGHT=64

# Optional
export OF_FORCE_CASEFOLDING=1

# Add extra rooting support
export FOX_ENABLE_KERNELSU_SUPPORT=1
export FOX_ENABLE_KERNELSU_NEXT_SUPPORT=1
export FOX_ENABLE_SUKISU_SUPPORT=1

# Drastic Size Reduction
export FOX_DRASTIC_SIZE_REDUCTION=0
