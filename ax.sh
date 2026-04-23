#!/bin/bash
rm -rf .repo/local_manifests
repo init -u https://github.com/AxionAOSP/android.git -b lineage-23.2 --git-lfs

# Clone local manifest
git clone https://github.com/SenX-Project/local_manifest -b ax .repo/local_manifests

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

# Check if the clang directory does NOT exist
CLANG_DIR="prebuilts/clang/host/linux-x86/clang-r547379"
if [ ! -d "$CLANG_DIR" ]; then
  echo "Clang directory not found. Cloning..."
  mkdir -p "$CLANG_DIR"
  wget -qO- "https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/62cdcefa89e31af2d72c366e8b5ef8db84caea62/clang-r547379.tar.gz" | tar -xzf - -C "$CLANG_DIR"
  
  echo "Clang has been downloaded and extracted successfully."
else
  echo "Clang directory already exists. Skipping download."
fi

#echo "=== Starting GMS build ==="
#. build/envsetup.sh
#axion munch user gms
#ax -br
#mv out/target/product/munch out/target/product/gapps

echo "=== Starting Vanilla build ==="
. build/envsetup.sh
axion munch user va
ax -br
mv out/target/product/munch out/target/product/vanilla
