#!/bin/bash

rm -rf .repo/local_manifests
repo init -u https://github.com/AxionAOSP/android.git -b lineage-23.0 --git-lfs
rm -rf prebuilts/clang/host/linux-x86

echo "==> Syncing sources..."
if [ -f /opt/crave/resync.sh ]; then
    /opt/crave/resync.sh
else
    repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)
fi

echo "==> Cleaning old outputs and device/vendor/hardware trees..."
dirs_to_remove=(
    out/target/product/munch
    out/target/product/gapps
    out/target/product/vanilla
    device/xiaomi/munch
    device/xiaomi/sm8250-common
    kernel/xiaomi/sm8250
    vendor/xiaomi/munch
    vendor/xiaomi/munch-firmware
    vendor/xiaomi/sm8250-common
    vendor/lineage-priv/keys
    hardware/xiaomi
    vendor/xiaomi/miuicamera
)
rm -rf "${dirs_to_remove[@]}"

echo "=== Cloning device trees ==="
git clone https://github.com/Project-SenX/android_device_xiaomi_munch -b ax device/xiaomi/munch
git clone https://github.com/Project-SenX/android_device_xiaomi_sm8250-common -b cleanup device/xiaomi/sm8250-common
git clone https://github.com/Project-SenX/android_vendor_xiaomi_munch vendor/xiaomi/munch
git clone https://github.com/Project-SenX/android_vendor_xiaomi_sm8250-common vendor/xiaomi/sm8250-common
git clone https://github.com/SenseiiX/fusionX_sm8250 -b mod kernel/xiaomi/sm8250
git clone https://github.com/Project-SenX/android_hardware_xiaomi hardware/xiaomi
git clone https://codeberg.org/munch-devs/android_vendor_xiaomi_munch-firmware vendor/xiaomi/munch-firmware
git clone https://codeberg.org/munch-devs/android_vendor_xiaomi_miuicamera vendor/xiaomi/miuicamera
git clone https://github.com/Project-SenX/priv-keys -b 16 vendor/lineage-priv/keys

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
