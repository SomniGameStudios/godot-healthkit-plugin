#ifndef IOS_NATIVE_H
#define IOS_NATIVE_H

#include "core/version.h"
#include "core/object/class_db.h"

class IOSNative : public Object {

    GDCLASS(IOSNative, Object);

    static IOSNative *instance;
    static void _bind_methods();

public:
    void request_track_permission();
    int is_admob_debug_or_release();
    
    static IOSNative *get_singleton();

    IOSNative();
    ~IOSNative();
};

#endif
