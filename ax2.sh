#!/bin/bash
rm -rf .repo/local_manifests
repo init -u https://github.com/AxionAOSP/android.git -b lineage-23.2 --git-lfs

# Clone local manifest
git clone https://github.com/SenX-Project/local_manifest -b ax2 .repo/local_manifests

echo "==> Syncing sources..."
if [ -f /opt/crave/resync.sh ]; then
    /opt/crave/resync.sh
else
    repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)
fi

echo "==> Cleaning old outputs..."
dirs_to_remove=(
    out/target/product/munch
    out/target/product/gapps
    out/target/product/vanilla
)
rm -rf "${dirs_to_remove[@]}"

echo "=== Starting GMS build ==="
. build/envsetup.sh
axion munch user gms
ax -br
mv out/target/product/munch out/target/product/gapps

#echo "=== Starting Vanilla build ==="
#. build/envsetup.sh
#axion munch user va
#ax -br
#mv out/target/product/munch out/target/product/vanilla
