#!/bin/bash
# scripts/build.sh — Main build script for HealthKitPlugin
#
# Usage: ./platforms/ios/scripts/build.sh <godot_version>
# Example: ./platforms/ios/scripts/build.sh 4.6.1
#
# Produces:
#   build/output/HealthKitPlugin.gdip
#   build/output/HealthKitPlugin/bin/HealthKitPlugin.debug.xcframework/
#   build/output/HealthKitPlugin/bin/HealthKitPlugin.release.xcframework/

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/common.sh"

PLUGIN_DIR="$SCRIPT_DIR/.."
PROJECT_ROOT="$PLUGIN_DIR/../.."
BUILD_DIR="$PLUGIN_DIR/build"
OUTPUT_DIR="$BUILD_DIR/output"

if [ $# -eq 0 ]; then
    log_error "Usage: $0 <godot_version>"
    log_error "Example: $0 4.6.1"
    exit 1
fi

GODOT_VERSION="$1"

log_info "=== Building HealthKitPlugin for Godot $GODOT_VERSION ==="

# Step 1: Download Godot source
log_info "Step 1/4: Downloading Godot source..."
"$SCRIPT_DIR/download_godot.sh" "$GODOT_VERSION"

# Step 2: Generate headers
log_info "Step 2/4: Generating Godot headers..."
"$SCRIPT_DIR/generate_headers.sh"

# Step 3: Build with xcodebuild (Debug + Release)
log_info "Step 3/4: Building static libraries..."

rm -rf "$BUILD_DIR"; rm -rf ~/Library/Developer/Xcode/DerivedData/HealthKitPlugin-*
mkdir -p "$OUTPUT_DIR/HealthKitPlugin/bin"

for CONFIG in Debug Release; do
    CONFIG_LOWER=$(echo "$CONFIG" | tr '[:upper:]' '[:lower:]')
    DEVICE_ARCHIVE_PATH="$BUILD_DIR/ios-device-${CONFIG_LOWER}"
    SIMULATOR_ARCHIVE_PATH="$BUILD_DIR/ios-simulator-${CONFIG_LOWER}"

    log_info "Building $CONFIG configuration for device..."

    xcodebuild archive IPHONEOS_DEPLOYMENT_TARGET=14.0 \
        -project "$PLUGIN_DIR/HealthKitPlugin.xcodeproj" \
        -scheme HealthKitPlugin \
        SDKROOT=iphoneos -destination "generic/platform=iOS" \
        -archivePath "$DEVICE_ARCHIVE_PATH" \
        -configuration "$CONFIG" \
        ARCHS="arm64" \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        DEVELOPMENT_TEAM="" \
        | tail -20

    log_info "Building $CONFIG configuration for simulator..."

    xcodebuild archive IPHONEOS_DEPLOYMENT_TARGET=14.0 \
        -project "$PLUGIN_DIR/HealthKitPlugin.xcodeproj" \
        -scheme HealthKitPlugin \
        SDKROOT=iphonesimulator -destination "generic/platform=iOS Simulator" \
        -archivePath "$SIMULATOR_ARCHIVE_PATH" \
        -configuration "$CONFIG" \
        ARCHS="arm64 x86_64" \
        OTHER_LDFLAGS="-Wl,-weak_framework,SwiftUICore -Wl,-no_warn_duplicate_libraries" \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        DEVELOPMENT_TEAM="" \
        | tail -20

    # Locate the built .a files
    DEVICE_LIB_PATH="$DEVICE_ARCHIVE_PATH.xcarchive/Products/usr/local/lib/libHealthKitPlugin.a"
    if [ ! -f "$DEVICE_LIB_PATH" ]; then
        log_error "Built device library not found at $DEVICE_LIB_PATH"
        exit 1
    fi

    SIMULATOR_LIB_PATH="$SIMULATOR_ARCHIVE_PATH.xcarchive/Products/usr/local/lib/libHealthKitPlugin.a"
    if [ ! -f "$SIMULATOR_LIB_PATH" ]; then
        log_error "Built simulator library not found at $SIMULATOR_LIB_PATH"
        exit 1
    fi

    # Create xcframework
    XCFRAMEWORK_PATH="$OUTPUT_DIR/HealthKitPlugin/bin/HealthKitPlugin.${CONFIG_LOWER}.xcframework"
    log_info "Creating $CONFIG_LOWER xcframework..."

    xcodebuild -create-xcframework \
        -library "$DEVICE_LIB_PATH" \
        -library "$SIMULATOR_LIB_PATH" \
        -output "$XCFRAMEWORK_PATH"

    log_success "$CONFIG xcframework created."
done

# Step 4: Copy .gdip
log_info "Step 4/4: Packaging..."
cp "$PLUGIN_DIR/HealthKitPlugin.gdip" "$OUTPUT_DIR/HealthKitPlugin.gdip"

log_success "=== Build complete! ==="
log_info "Output at: $OUTPUT_DIR/"
log_info ""
log_info "To install, copy the contents of build/output/ into your Godot project's addons/healthkit_plugin/ folder:"
log_info "  cp -r $OUTPUT_DIR/* <your-godot-project>/addons/healthkit_plugin/"

# Optionally copy to demo project
DEMO_PLUGINS="$PROJECT_ROOT/platforms/godot_editor/addons/healthkit_plugin"
if [ -d "$PROJECT_ROOT/platforms/godot_editor" ]; then
    log_info "Copying to demo project..."
    rm -rf "$DEMO_PLUGINS/HealthKitPlugin" "$DEMO_PLUGINS/HealthKitPlugin.gdip"
    cp "$OUTPUT_DIR/HealthKitPlugin.gdip" "$DEMO_PLUGINS/"
    cp -r "$OUTPUT_DIR/HealthKitPlugin" "$DEMO_PLUGINS/"
    log_success "Demo project updated."
fi
