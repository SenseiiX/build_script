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


# ── Build ─────────────────────────────────────────────────────────────────────
echo "==> Cleaning old outputs..."
rm -rf out/target/product/munch out/target/product/gapps

echo "=== Starting GMS (Pico) build ==="
. build/envsetup.sh
# ── KernelSU Patch ────────────────────────────────────────────────────────────
KERNEL_DIR="kernel/xiaomi/munch"
PATCH_SCRIPT="nextpatch.sh"
if [ -f "$KERNEL_DIR/$PATCH_SCRIPT" ]; then
    echo "Found $PATCH_SCRIPT in $KERNEL_DIR. Applying KernelSU patch."
    (
        cd "$KERNEL_DIR"
        chmod +x "$PATCH_SCRIPT" && bash "$PATCH_SCRIPT"
        if [ -d "KernelSU-Next" ]; then
            if [ -d "KernelSU-Next/userspace/su" ]; then
                echo "Removing KernelSU-Next/userspace/su directory."
                rm -rf KernelSU-Next/userspace/su
            else
                echo "KernelSU-Next/userspace/su not found. Skipping removal."
            fi
        else
            echo "KernelSU-Next directory not found. Skipping KernelSU operations."
        fi
    )
else
    echo "Kernel patch script ($PATCH_SCRIPT) not found in $KERNEL_DIR. Skipping."
fi

# ── Clang Toolchain ───────────────────────────────────────────────────────────
CLANG_DIR="prebuilts/clang/host/linux-x86/clang-r574158"
if [ ! -d "$CLANG_DIR" ]; then
    echo "Clang directory not found. Downloading..."
    mkdir -p "$CLANG_DIR"
    wget -qO- "https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/508ea7dd0d8f681904d0422e98af9613aaabf180/clang-r574158.tar.gz" \
        | tar -xzf - -C "$CLANG_DIR"
    echo "Clang downloaded and extracted successfully."
else
    echo "Clang directory already exists. Skipping download."
fi
axion munch user gms pico
ax -br

mv out/target/product/munch out/target/product/gapps
echo "=== All builds completed successfully! ==="
