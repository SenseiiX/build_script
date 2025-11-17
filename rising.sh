#! /bin/bash

rm -rf .repo/local_manifests
repo init -u https://github.com/RisingOS-Revived/android -b sixteen --git-lfs
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
    out/target/product/vanilla
    out/target/product/gapps
    out/target/product/core
    device/xiaomi/munch
    kernel/xiaomi/munch
    vendor/xiaomi/munch
    vendor/xiaomi/munch-firmware
    vendor/lineage-priv/keys
    hardware/xiaomi
    hardware/dolby
    vendor/xiaomi/miuicamera
)
rm -rf "${dirs_to_remove[@]}"

echo "=== Cloning device trees ==="
git clone https://github.com/Project-SenX/android_device_xiaomi_munch -b rise device/xiaomi/munch
git clone https://github.com/Project-SenX/android_vendor_xiaomi_munch -b 16 vendor/xiaomi/munch
git clone https://github.com/SenseiiX/fusionX_sm8250 -b rise kernel/xiaomi/munch
git clone https://github.com/Project-SenX/android_hardware_xiaomi hardware/xiaomi
git clone https://github.com/Project-SenX/android_vendor_xiaomi_munch-firmware vendor/xiaomi/munch-firmware
git clone https://github.com/munch-devs/android_hardware_dolby hardware/dolby
git clone https://github.com/Project-SenX/android_vendor_xiaomi_miuicamera -b 16 vendor/xiaomi/miuicamera
git clone https://github.com/Project-SenX/priv-keys -b 16 vendor/lineage-priv/keys

# VANILLA
echo "=== Building VANILLA variant ==="
. build/envsetup.sh
. build/envsetup.sh
riseup munch user && \
rise b
mv out/target/product/munch out/target/product/vanilla

# GAPPS
cd device/xiaomi/munch
rm lineage_munch.mk
mv gapps.txt lineage_munch.mk
cd ../../..

echo "=== Building GAPPS variant ==="
. build/envsetup.sh
. build/envsetup.sh
riseup munch user && \
rise b
mv out/target/product/munch out/target/product/gapps

# CORE
cd device/xiaomi/munch
rm lineage_munch.mk
mv core.txt lineage_munch.mk
cd ../../..

echo "=== Building CORE variant ==="
. build/envsetup.sh
. build/envsetup.sh
riseup munch user && \
rise b
mv out/target/product/munch out/target/product/core

echo "===== All builds completed successfully! ====="
