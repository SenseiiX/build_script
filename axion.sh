#! /bin/bash

rm -rf .repo/local_manifests
repo init -u https://github.com/AxionAOSP/android.git -b lineage-23.0 --git-lfs
#rm -rf prebuilts/clang/host/linux-x86

echo "==> Syncing sources..."
/opt/crave/resync.sh

echo "==> Cleaning old outputs and device/vendor/hardware trees..."
dirs_to_remove=(
    out/target/product/munch
    out/target/product/gapps
    out/target/product/vanilla
    device/xiaomi/munch
    #kernel/xiaomi/munch
    #vendor/xiaomi/munch
    #vendor/xiaomi/munch-firmware
    #hardware/xiaomi
    #hardware/dolby
    #vendor/xiaomi/miuicamera
    #packages/resources/devicesettings
)
rm -rf "${dirs_to_remove[@]}"

echo "=== Cloning device trees ==="
git clone https://github.com/Project-SenX/android_device_xiaomi_munch -b ax device/xiaomi/munch
#git clone https://github.com/Project-SenX/android_vendor_xiaomi_munch -b 16 vendor/xiaomi/munch
git clone https://github.com/SenseiiX/fusionX_sm8250 -b wip-noksu kernel/xiaomi/munch
#git clone https://github.com/Project-SenX/android_hardware_xiaomi hardware/xiaomi
#git clone https://github.com/Project-SenX/android_vendor_xiaomi_munch-firmware vendor/xiaomi/munch-firmware
#git clone https://github.com/munch-devs/android_hardware_dolby hardware/dolby
#git clone https://github.com/PocoF3Releases/packages_resources_devicesettings -b aosp-16 packages/resources/devicesettings
#git clone https://github.com/Project-SenX/android_vendor_xiaomi_miuicamera -b vic vendor/xiaomi/miuicamera

echo "=== Starting GMS (Pico) build ==="
. build/envsetup.sh
axion munch user gms pico
ax -br
mv out/target/product/munch out/target/product/gapps

echo "=== Starting Vanilla (AOSP) build ==="
. build/envsetup.sh
axion munch user va
ax -br
mv out/target/product/munch out/target/product/vanilla


echo "=== All builds completed successfully! ==="
