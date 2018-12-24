LOCAL_PATH := $(call my-dir)

TARGET_PREBUILT_KERNEL2 := $(PLATFORM_PATH)/prebuilt/Image.gz-dtb

# Use prebuilt kernel
INTERNAL_BOOTIMAGE_ARGS := \
	$(addprefix --second ,$(INSTALLED_2NDBOOTLOADER_TARGET)) \
	--kernel $(TARGET_PREBUILT_KERNEL2)

ifneq ($(BOARD_BUILD_SYSTEM_ROOT_IMAGE),true)
INTERNAL_BOOTIMAGE_ARGS += --ramdisk $(INSTALLED_RAMDISK_TARGET)
endif

INTERNAL_BOOTIMAGE_FILES := $(filter-out --%,$(INTERNAL_BOOTIMAGE_ARGS))

INTERNAL_RECOVERYIMAGE_ARGS := \
	$(addprefix --second ,$(INSTALLED_2NDBOOTLOADER_TARGET)) \
	--kernel $(TARGET_PREBUILT_KERNEL2) \
	--ramdisk $(recovery_ramdisk)

REAL_BOARD_KERNEL_CMDLINE := $(strip $(BOARD_KERNEL_CMDLINE))
ifdef REAL_BOARD_KERNEL_CMDLINE
  INTERNAL_BOOTIMAGE_ARGS += --cmdline "$(REAL_BOARD_KERNEL_CMDLINE)"
  INTERNAL_RECOVERYIMAGE_ARGS += --cmdline "$(REAL_BOARD_KERNEL_CMDLINE)"
endif

REAL_BOARD_KERNEL_BASE := $(strip $(BOARD_KERNEL_BASE))
ifdef REAL_BOARD_KERNEL_BASE
  INTERNAL_BOOTIMAGE_ARGS += --base $(REAL_BOARD_KERNEL_BASE)
  INTERNAL_RECOVERYIMAGE_ARGS += --base $(REAL_BOARD_KERNEL_BASE)
endif

REAL_BOARD_KERNEL_PAGESIZE := $(strip $(BOARD_KERNEL_PAGESIZE))
ifdef REAL_BOARD_KERNEL_PAGESIZE
  INTERNAL_BOOTIMAGE_ARGS += --pagesize $(REAL_BOARD_KERNEL_PAGESIZE)
  INTERNAL_RECOVERYIMAGE_ARGS += --pagesize $(REAL_BOARD_KERNEL_PAGESIZE)
endif

# Overload bootimg generation: Same as the original, using prebuilt kernel
$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES)
	$(call pretty,"Target boot image: $@")
	$(hide) $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE),raw)
	@echo -e ${CL_CYN}"Made boot image: $@"${CL_RST}

# Overload recoveryimg generation: Same as the original, using prebuilt kernel
$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) \
		$(recovery_ramdisk) \
		$(recovery_kernel)
		$(call build-recoveryimage-target, $@)
	@echo -e ${CL_CYN}"----- Making recovery image ------"${CL_RST}
	$(hide) $(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)
	@echo -e ${CL_CYN}"Made recovery image: $@"${CL_RST}
