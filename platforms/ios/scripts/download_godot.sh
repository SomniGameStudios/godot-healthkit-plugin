#!/bin/bash
# scripts/download_godot.sh — Downloads Godot source for header generation

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/common.sh"

if [ $# -eq 0 ]; then
    log_error "Usage: $0 <godot_version>  (e.g. 4.6.2)"
    exit 1
fi

GODOT_VERSION="${1%.0}"
GODOT_FOLDER="godot-${GODOT_VERSION}-stable"
PLUGIN_DIR="$SCRIPT_DIR/.."

cd "$PLUGIN_DIR" || exit 1

# Skip if already downloaded and version matches
if [ -d "godot" ] && [ -f "godot/.version" ]; then
    INSTALLED_VER=$(cat godot/.version)
    if [ "$INSTALLED_VER" == "$GODOT_VERSION" ]; then
        log_info "Godot $GODOT_VERSION source already present. Skipping download."
        exit 0
    fi
    log_info "Godot version mismatch ($INSTALLED_VER != $GODOT_VERSION). Re-downloading..."
    rm -rf "godot"
fi

DOWNLOAD_FILE="${GODOT_FOLDER}.tar.xz"
DOWNLOAD_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/${DOWNLOAD_FILE}"

log_info "Downloading Godot ${GODOT_VERSION} from: $DOWNLOAD_URL"

if ! curl -LO "$DOWNLOAD_URL"; then
    log_error "Failed to download $DOWNLOAD_FILE"
    exit 1
fi

if [ ! -f "$DOWNLOAD_FILE" ]; then
    log_error "Download file $DOWNLOAD_FILE not found"
    exit 1
fi

log_info "Extracting..."
if ! tar -xf "$DOWNLOAD_FILE"; then
    log_error "Failed to extract $DOWNLOAD_FILE"
    rm -f "$DOWNLOAD_FILE"
    exit 1
fi

rm -f "$DOWNLOAD_FILE"

if [ ! -d "$GODOT_FOLDER" ]; then
    log_error "Extracted folder $GODOT_FOLDER not found"
    exit 1
fi

rm -rf "godot"
mv "$GODOT_FOLDER" "godot"
echo "$GODOT_VERSION" > godot/.version

log_success "Godot $GODOT_VERSION downloaded and ready in 'godot' folder"
