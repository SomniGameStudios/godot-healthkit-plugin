#ifndef HEALTH_KIT_H
#define HEALTH_KIT_H

#include "core/version.h"
#include "core/object/class_db.h"
#include <map>

class HealthKit : public Object {

    GDCLASS(HealthKit, Object);

    static HealthKit *instance;
    static void _bind_methods();

public:
    int get_today_steps();
    int get_total_steps();
    Dictionary get_period_steps_dict();

    void run_today_steps_walked_query();
    void run_total_steps_walked_query();
    void run_period_steps_query(int days);
    
    static HealthKit *get_singleton();

    HealthKit();
    ~HealthKit();
    
private:
    int today_steps = 0;
    int total_steps = 0;
    std::map<String, int> period_steps;
    void* health_store = nullptr;
};

#endif
