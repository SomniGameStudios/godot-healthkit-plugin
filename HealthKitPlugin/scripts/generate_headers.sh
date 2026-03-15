#!/bin/bash
# scripts/generate_headers.sh — Generates Godot headers using scons (headers only, not a full build)

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/common.sh"

PLUGIN_DIR="$SCRIPT_DIR/.."

cd "$PLUGIN_DIR" || exit 1

if [ -f "godot/core/version_generated.gen.h" ]; then
    log_info "Headers already generated. Skipping."
    exit 0
fi

if [ ! -d "godot" ]; then
    log_error "Godot source folder not found. Run download_godot.sh first."
    exit 1
fi

# Suppress Python SyntaxWarnings (common with older Godot + newer Python)
export PYTHONWARNINGS="ignore::SyntaxWarning"

cd godot || exit 1

TARGETS=(
    "core/version_generated.gen.h"
    "core/disabled_classes.gen.h"
    "core/object/gdvirtual.gen.inc"
    "modules/modules_enabled.gen.h"
)

if [ -d "core/extension" ]; then
    TARGETS+=("core/extension/gdextension_interface.gen.h")
fi

log_info "Running scons to generate headers..."
scons -j "$NUM_CORES" platform=ios target=template_release "${TARGETS[@]}"

log_success "Headers generated successfully."

cd ..
