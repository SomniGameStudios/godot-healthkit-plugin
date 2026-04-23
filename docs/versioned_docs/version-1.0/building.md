---
sidebar_position: 3
---

# Building from Source

Requires macOS with Xcode and Python (for scons).

```bash
# Install scons
pip install scons

# Build for Godot 4.6.2
./platforms/ios/scripts/build.sh 4.6.2
```

This will:
1. Download Godot source (for headers only)
2. Generate headers with scons
3. Build Debug + Release static libraries with xcodebuild
4. Create `.xcframework` bundles
5. Copy output to `platforms/godot_editor/addons/healthkit_plugin/`

Build output is in `platforms/ios/build/output/`.

## Troubleshooting

### `platform_config.h` not found
Run the build script with the correct Godot version. The headers must match your Godot version.

### Linker errors with `ClassDB::bind_method`
Ensure you're using the correct Debug/Release binary for your export type. The xcframework format handles this automatically.
