#! /bin/bash

rm -rf .repo/local_manifests
repo init -u https://github.com/Evolution-X/manifest -b bq1 --git-lfs
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
    device/xiaomi/munch
    kernel/xiaomi/munch
    vendor/xiaomi/munch
    vendor/xiaomi/munch-firmware
    vendor/evolution-priv/keys
    hardware/xiaomi
    hardware/dolby
    vendor/xiaomi/miuicamera
)
rm -rf "${dirs_to_remove[@]}"

echo "=== Cloning device trees ==="
git clone https://github.com/Project-SenX/android_device_xiaomi_munch -b evox device/xiaomi/munch
git clone https://github.com/Project-SenX/android_vendor_xiaomi_munch -b 16 vendor/xiaomi/munch
git clone https://github.com/SenseiiX/fusionX_sm8250 -b mod kernel/xiaomi/munch
git clone https://github.com/Project-SenX/android_hardware_xiaomi hardware/xiaomi
git clone https://github.com/Project-SenX/android_vendor_xiaomi_munch-firmware vendor/xiaomi/munch-firmware
git clone https://github.com/Project-SenX/android_hardware_dolby hardware/dolby
git clone https://github.com/Project-SenX/android_vendor_xiaomi_miuicamera vendor/xiaomi/miuicamera
git clone https://github.com/Project-SenX/priv-keys -b evox vendor/evolution-priv/keys

echo "=== Starting Build ==="
. build/envsetup.sh
lunch lineage_munch-bp3a-user
m evolution

