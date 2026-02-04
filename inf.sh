#! /bin/bash

rm -rf .repo/local_manifests
repo init --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 16 -g default,-mips,-darwin,-notdefault
rm -rf prebuilts/clang/host/linux-x86

echo "==> Syncing sources..."
if [ -f /opt/crave/resync.sh ]; then
    /opt/crave/resync.sh
else
    repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)
fi


echo "==> Cleaning old outputs and device/vendor/hardware trees..."
dirs_to_remove=(
    out/target/product/rodin
    device/xiaomi/rodin
    device/mediatek/sepolicy_vndr
    device/xiaomi/rodin-kernel
    vendor/xiaomi/rodin
    vendor/mediatek/ims
    vendor/lineage-priv/keys
    hardware/xiaomi
    hardware/dolby
    hardware/mediatek
)
rm -rf "${dirs_to_remove[@]}"

echo "=== Cloning device trees ==="
git clone https://github.com/SenX-Project/android_device_xiaomi_rodin -b lineage-23.1 device/xiaomi/rodin
git clone https://github.com/SenX-Project/android_device_mediatek_sepolicy_vndr -b lineage-23.1 device/mediatek/sepolicy_vndr
git clone https://github.com/SenX-Project/android_device_xiaomi_rodin-kernel -b lineage-23.1 device/xiaomi/rodin-kernel
git clone https://gitea.com/xyzuniverse/proprietary_vendor_xiaomi_rodin -b lineage-23.0 vendor/xiaomi/rodin
git clone https://github.com/SenX-Project/android_vendor_mediatek_ims vendor/mediatek/ims
git clone https://github.com/SenX-Project/android_hardware_xiaomi -b lineage-23.0 hardware/xiaomi
git clone https://github.com/Pong-Development/hardware_dolby -b 16hardware/dolby
git clone https://github.com/SenX-Project/android_hardware_mediatek -b lineage-23.0 hardware/mediatek
git clone https://github.com/SenX-Project -b 16 vendor/lineage-priv/keys

echo "=== Starting Build ==="
. build/envsetup.sh
lunch infinity_rodin-user
m bacon -j$(nproc --all)

