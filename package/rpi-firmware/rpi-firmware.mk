################################################################################
#
# rpi-firmware
#
################################################################################

RPI_FIRMWARE_VERSION = 889323796bb8feb99c7a96ba5e6445895cab47ce
RPI_FIRMWARE_SITE = $(call github,raspberrypi,firmware,$(RPI_FIRMWARE_VERSION))
RPI_FIRMWARE_LICENSE = BSD-3-Clause
RPI_FIRMWARE_LICENSE_FILES = boot/LICENCE.broadcom
RPI_FIRMWARE_INSTALL_IMAGES = YES

RPI_FIRMWARE_FILES = \
	$(if $(BR2_PACKAGE_RPI_FIRMWARE_BOOTCODE_BIN), bootcode.bin) \
	$(if $(BR2_PACKAGE_RPI_FIRMWARE_VARIANT_PI), start.elf fixup.dat) \
	$(if $(BR2_PACKAGE_RPI_FIRMWARE_VARIANT_PI_X), start_x.elf fixup_x.dat) \
	$(if $(BR2_PACKAGE_RPI_FIRMWARE_VARIANT_PI_CD), start_cd.elf fixup_cd.dat) \
	$(if $(BR2_PACKAGE_RPI_FIRMWARE_VARIANT_PI_DB), start_db.elf fixup_db.dat) \
	$(if $(BR2_PACKAGE_RPI_FIRMWARE_VARIANT_PI4), start4.elf fixup4.dat) \
	$(if $(BR2_PACKAGE_RPI_FIRMWARE_VARIANT_PI4_X), start4x.elf fixup4x.dat) \
	$(if $(BR2_PACKAGE_RPI_FIRMWARE_VARIANT_PI4_CD), start4cd.elf fixup4cd.dat) \
	$(if $(BR2_PACKAGE_RPI_FIRMWARE_VARIANT_PI4_DB), start4db.elf fixup4db.dat)

define RPI_FIRMWARE_INSTALL_BIN
	$(foreach f,$(RPI_FIRMWARE_FILES), \
		$(INSTALL) -D -m 0644 $(@D)/boot/$(f) $(BINARIES_DIR)/rpi-firmware/$(f)
	)
endef

RPI_FIRMWARE_CONFIG_FILE = $(call qstrip,$(BR2_PACKAGE_RPI_FIRMWARE_CONFIG_FILE))
ifneq ($(RPI_FIRMWARE_CONFIG_FILE),)
define RPI_FIRMWARE_INSTALL_CONFIG
	$(INSTALL) -D -m 0644 $(RPI_FIRMWARE_CONFIG_FILE) \
		$(BINARIES_DIR)/rpi-firmware/config.txt
endef
endif

RPI_FIRMWARE_CMDLINE_FILE = $(call qstrip,$(BR2_PACKAGE_RPI_FIRMWARE_CMDLINE_FILE))
ifneq ($(RPI_FIRMWARE_CMDLINE_FILE),)
define RPI_FIRMWARE_INSTALL_CMDLINE
	$(INSTALL) -D -m 0644 $(RPI_FIRMWARE_CMDLINE_FILE) \
		$(BINARIES_DIR)/rpi-firmware/cmdline.txt
endef
endif

ifeq ($(BR2_PACKAGE_RPI_FIRMWARE_INSTALL_DTBS),y)
define RPI_FIRMWARE_INSTALL_DTB
	$(foreach dtb,$(wildcard $(@D)/boot/*.dtb), \
		$(INSTALL) -D -m 0644 $(dtb) $(BINARIES_DIR)/rpi-firmware/$(notdir $(dtb))
	)
endef
endif

ifeq ($(BR2_PACKAGE_RPI_FIRMWARE_INSTALL_DTB_OVERLAYS),y)
define RPI_FIRMWARE_INSTALL_DTB_OVERLAYS
	$(foreach ovldtb,$(wildcard $(@D)/boot/overlays/*.dtbo), \
		$(INSTALL) -D -m 0644 $(ovldtb) $(BINARIES_DIR)/rpi-firmware/overlays/$(notdir $(ovldtb))
	)
	$(INSTALL) -D -m 0644 $(@D)/boot/overlays/overlay_map.dtb $(BINARIES_DIR)/rpi-firmware/overlays/
endef
else
# Still create the directory, so a genimage.cfg can include it independently of
# whether _INSTALL_DTB_OVERLAYS is selected or not.
define RPI_FIRMWARE_INSTALL_DTB_OVERLAYS
	$(INSTALL) -d $(BINARIES_DIR)/rpi-firmware/overlays
endef
endif

# Install prebuilt libraries if RPI_USERLAND not enabled
ifneq ($(BR2_PACKAGE_RPI_USERLAND),y)
define RPI_FIRMWARE_INSTALL_TARGET_LIB
	$(INSTALL) -D -m 0644 $(@D)/$(if BR2_ARM_EABIHF,hardfp/)opt/vc/lib/libvcos.so \
		$(TARGET_DIR)/usr/lib/libvcos.so
	$(INSTALL) -D -m 0644 $(@D)/$(if BR2_ARM_EABIHF,hardfp/)opt/vc/lib/libdebug_sym.so \
		$(TARGET_DIR)/usr/lib/libdebug_sym.so
	$(INSTALL) -D -m 0644 $(@D)/$(if BR2_ARM_EABIHF,hardfp/)opt/vc/lib/libvchiq_arm.so \
		$(TARGET_DIR)/usr/lib/libvchiq_arm.so
	$(INSTALL) -D -m 0644 $(@D)/$(if BR2_ARM_EABIHF,hardfp/)opt/vc/lib/libbcm_host.so \
		$(TARGET_DIR)/usr/lib/libbcm_host.so
	$(INSTALL) -D -m 0644 $(@D)/$(if BR2_ARM_EABIHF,hardfp/)opt/vc/lib/libelftoolchain.so \
		$(TARGET_DIR)/usr/lib/libelftoolchain.so
endef
endif

ifeq ($(BR2_PACKAGE_RPI_FIRMWARE_INSTALL_VCDBG),y)
define RPI_FIRMWARE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0700 $(@D)/$(if BR2_ARM_EABIHF,hardfp/)opt/vc/bin/vcdbg \
		$(TARGET_DIR)/usr/sbin/vcdbg
	$(INSTALL) -D -m 0644 $(@D)/$(if BR2_ARM_EABIHF,hardfp/)opt/vc/lib/libelftoolchain.so \
		$(TARGET_DIR)/usr/lib/libelftoolchain.so
	$(INSTALL) -D -m 0700 $(@D)/$(if BR2_ARM_EABIHF,hardfp/)opt/vc/bin/tvservice \
		$(TARGET_DIR)/usr/sbin/tvservice
	$(INSTALL) -D -m 0700 $(@D)/$(if BR2_ARM_EABIHF,hardfp/)opt/vc/bin/vcgencmd \
		$(TARGET_DIR)/usr/sbin/vcgencmd
	$(RPI_FIRMWARE_INSTALL_TARGET_LIB)
endef
endif # INSTALL_VCDBG

define RPI_FIRMWARE_INSTALL_IMAGES_CMDS
	$(RPI_FIRMWARE_INSTALL_BIN)
	$(RPI_FIRMWARE_INSTALL_CONFIG)
	$(RPI_FIRMWARE_INSTALL_CMDLINE)
	$(RPI_FIRMWARE_INSTALL_DTB)
	$(RPI_FIRMWARE_INSTALL_DTB_OVERLAYS)
endef

$(eval $(generic-package))
