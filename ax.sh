#!/bin/bash

TG_BOT_TOKEN="7912431988:AAE6Vj--vjE9L44frzW1ZYe-qvXE2hjDIik"
TG_BUILD_CHAT_ID="-1002629864812"
DEVICE_CODE="munch"
BUILD_TARGET="AxionOS"
ANDROID_VERSION="16"

# Change to "va" for Vanilla, "pico" for GMS
BUILD_VARIANT="pico"

export TZ="Asia/Manila"
export BUILD_USERNAME=Senseii
export BUILD_HOSTNAME=crave

# =========================================================
# DETECT BUILD TYPE
# =========================================================
if [[ "$BUILD_VARIANT" == "va" ]]; then
    BUILD_TYPE="Vanilla"
else
    BUILD_TYPE="GMS (Pico)"
    BUILD_VARIANT="pico"
fi

send_telegram_msg() {
  local chat_id="$1"
  local message="$2"

  echo -e "\n[$(date '+%Y-%m-%d %H:%M:%S')] Sending message to Telegram..."

  curl -s -X POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" \
    -d "chat_id=${chat_id}" \
    --data-urlencode "text=${message}" \
    -d "parse_mode=HTML" \
    -d "disable_web_page_preview=true" &> /dev/null
}

send_telegram_file() {
  local chat_id="$1"
  local file_path="$2"

  [ -f "$file_path" ] || {
    echo "File not found: $file_path"
    return 1
  }

  curl -s -X POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendDocument" \
    -F chat_id="${chat_id}" \
    -F document=@"${file_path}" > /dev/null
}

format_duration() {
    local T=$1
    local H=$((T/3600))
    local M=$(( (T%3600)/60 ))
    local S=$((T%60))
    printf "%02d hours, %02d minutes, %02d seconds" $H $M $S
}

start_build_process() {

    START_TIME=$(date +%s)

    local initial_msg=$'⚙️ <b>ROM Build Started!</b>\n\n• <b>ROM:</b> '"$BUILD_TARGET"$'\n• <b>Android:</b> '"$ANDROID_VERSION"$'\n• <b>Device:</b> '"$DEVICE_CODE"$'\n• <b>Type:</b> '"$BUILD_TYPE"$'\n• <b>Start Time:</b> '"$(date '+%Y-%m-%d %H:%M:%S %Z')"
    send_telegram_msg "$TG_BUILD_CHAT_ID" "$initial_msg"

    # =========================================================
    # BUILD STEPS
    # =========================================================

    # Remove local changes and init ROM repository
    rm -rf .repo/local_manifests
    repo init -u https://github.com/AxionAOSP/android.git -b lineage-23.2 --git-lfs
    git clone https://github.com/SenX-Project/local_manifest -b ax .repo/local_manifests

    echo "==> Syncing sources..."
    if [ -f /opt/crave/resync.sh ]; then
        /opt/crave/resync.sh
    else
        repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all)
    fi

    echo "==> Cleaning old outputs..."
    rm -rf out/target/product/munch \
           out/target/product/gapps \
           out/target/product/vanilla

    CLANG_DIR="prebuilts/clang/host/linux-x86/clang-r547379"
    if [ ! -d "$CLANG_DIR" ]; then
        echo "==> Clang not found. Downloading..."
        mkdir -p "$CLANG_DIR"
        wget -qO- "https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/62cdcefa89e31af2d72c366e8b5ef8db84caea62/clang-r547379.tar.gz" | tar -xzf - -C "$CLANG_DIR"
        echo "==> Clang downloaded and extracted successfully."
    else
        echo "==> Clang already exists. Skipping download."
    fi

    echo "==> Starting $BUILD_TYPE build..."
    . build/envsetup.sh
    axion munch user $BUILD_VARIANT
    ax -br

    BUILD_STATUS=$?

    if [[ $BUILD_STATUS -eq 0 ]]; then
        if [[ "$BUILD_VARIANT" == "va" ]]; then
            mv out/target/product/munch out/target/product/vanilla
            OUTPUT_DIR="out/target/product/vanilla"
        else
            mv out/target/product/munch out/target/product/gapps
            OUTPUT_DIR="out/target/product/gapps"
        fi
    fi

    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    DURATION_FORMATTED=$(format_duration $DURATION)

    if [[ $BUILD_STATUS -eq 0 ]]; then
        local status_text="✅ Success"
    else
        local status_text="❌ Faild (Exit Code: $BUILD_STATUS)"
    fi

    local final_msg=$'⚙️ <b>ROM Build Finished!</b>\n\n• <b>ROM:</b> '"$BUILD_TARGET"$'\n• <b>Android:</b> '"$ANDROID_VERSION"$'\n• <b>Device:</b> '"$DEVICE_CODE"$'\n• <b>Type:</b> '"$BUILD_TYPE"$'\n• <b>Finish Time:</b> '"$(date '+%Y-%m-%d %H:%M:%S %Z')"$'\n• <b>Duration:</b> '"$DURATION_FORMATTED"$'\n• <b>Status:</b> '"$status_text"
    send_telegram_msg "$TG_BUILD_CHAT_ID" "$final_msg"

    if [[ $BUILD_STATUS -ne 0 ]]; then
        send_telegram_file "$TG_BUILD_CHAT_ID" "out/error.log"
        return 1
    fi

    # Upload ROM on success
    send_telegram_msg "$TG_BUILD_CHAT_ID" "📤 <b>Uploading files...</b>"
    rm -rf go-up*
    wget https://raw.githubusercontent.com/Sorayukii/tools-gofile/refs/heads/private/go-up
    chmod +x go-up
    ./go-up "$OUTPUT_DIR"/*munch*.zip
}

start_build_process
