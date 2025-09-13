#! /bin/bash

rm -rf .repo/local_manifests; \
repo init -u https://github.com/RisingOS-Revived/android -b sixteen-los --git-lfs; \
rm -rf prebuilts/clang/host/linux-x86

echo "==> Syncing sources..."
/opt/crave/resync.sh; \

export BUILD_USERNAME=SenX
export BUILD_HOSTNAME=dev

echo "==> Cleaning old outputs and device/vendor/hardware trees..."
dirs_to_remove=(
    out/target/product/munch
    out/target/product/vanilla
    out/target/product/gapps
    device/xiaomi/munch
    kernel/xiaomi/munch
    vendor/xiaomi/munch
    vendor/xiaomi/munch-firmware
    hardware/xiaomi
    hardware/dolby
    vendor/xiaomi/miuicamera
    packages/resources/devicesettings
)
rm -rf "${dirs_to_remove[@]}"

echo "=== Cloning device trees ==="
git clone https://github.com/SenseiiX/android_device_xiaomi_munch -b rising-16 device/xiaomi/munch; \
git clone https://github.com/SenseiiX/android_vendor_xiaomi_munch -b 16 vendor/xiaomi/munch; \
git clone https://github.com/SenseiiX/fusionX_sm8250 -b stable-next kernel/xiaomi/munch; \
git clone https://codeberg.org/munch-devs/android_vendor_xiaomi_munch-firmware vendor/xiaomi/munch-firmware; \
git clone https://github.com/Evolution-X-Devices/hardware_xiaomi -b bka-no-dolby hardware/xiaomi; \
git clone https://github.com/munch-devs/android_hardware_dolby hardware/dolby; \
git clone https://github.com/PocoF3Releases/packages_resources_devicesettings -b aosp-16 packages/resources/devicesettings; \
git clone https://codeberg.org/munch-devs/android_vendor_xiaomi_miuicamera vendor/xiaomi/miuicamera; \

# Build Vanilla Variant
echo "=== Building VANILLA variant ==="
. build/envsetup.sh; \
riseup munch user && rise b; \

# Clear Previous Outputs
rm -rf out/target/product/vanilla out/target/product/gapps; \

# Rename Output Folder to "vanilla"
cd out/target/product && \
mv munch vanilla && \
cd ../../..; \

# Reconfigure GApps Variant
cd device/xiaomi/munch && \
rm lineage_munch.mk && \
mv gapps.txt lineage_munch.mk && \
cd ../../..; \

# Build GApps ROM
echo "=== Building GAPPS variant ==="
. build/envsetup.sh; \
riseup munch user && rise b; \

# Rename Output Folder to "Gapps"
cd out/target/product && \
mv munch gapps && \
cd ../../..; \

echo "===== All builds completed successfully! ====="
