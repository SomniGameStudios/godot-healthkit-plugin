#include "health_kit.h"
#include "ios_native.h"
#include "core/version.h"
#include "core/config/engine.h"
#include "iosbridge_module.h"

HealthKit *health_kit;
IOSNative *ios_native;

void init_iosbridge_plugin() {
    health_kit = memnew(HealthKit);
    Engine::get_singleton()->add_singleton(Engine::Singleton("iosHealthKit", health_kit));
    ios_native = memnew(IOSNative);
    Engine::get_singleton()->add_singleton(Engine::Singleton("iosNative", ios_native));
}

void deinit_iosbridge_plugin() {
    if (health_kit) {
        memdelete(health_kit);
    }
    if (ios_native) {
        memdelete(ios_native);
    }
}
