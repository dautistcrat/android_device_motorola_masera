# Set Local_path
LOCAL_PATH := $(call my-dir)

# Check if target device is codename masera
ifeq ($(TARGET_DEVICE),masera)
    include $(call all-subdir-makefiles,$(LOCAL_PATH))
endif
