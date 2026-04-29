#!/bin/bash
rm -rf .repo/local_manifests
repo init -u https://github.com/AxionAOSP/android.git -b lineage-23.2 --git-lfs

# Clone local manifest
git clone https://github.com/Sensei-Prjkt/local_manifest -b ax .repo/local_manifests

echo "==> Syncing sources..."
if [ -f /opt/crave/resync.sh ]; then
    /opt/crave/resync.sh
else
    repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)
fi

echo "==> Cleaning old outputs..."
dirs_to_remove=(
    out/target/product/rodin
    out/target/product/gapps
)
rm -rf "${dirs_to_remove[@]}"

echo "=== Starting GMS build ==="
. build/envsetup.sh
axion rodin user pico
ax -br
mv out/target/product/rodin out/target/product/gapps
