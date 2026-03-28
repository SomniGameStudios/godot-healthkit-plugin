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
    
    void request_permission();
    int get_permission_status();
    bool is_health_data_available();
    
    void start_step_observer();
    void stop_step_observer();

    static HealthKit *get_singleton();

    HealthKit();
    ~HealthKit();
    
private:
    int today_steps = 0;
    int total_steps = 0;
    std::map<String, int> period_steps;
    void* health_store = nullptr;
    void* observer_query = nullptr;
};

#endif
