/**************************************************************************/
/*  health_kit.h                                                          */
/**************************************************************************/
/* MIT License                                                            */
/*                                                                        */
/* Copyright (c) 2026 Somni Game Studios                                  */
/*                                                                        */
/* Permission is hereby granted, free of charge, to any person obtaining  */
/* a copy of this software and associated documentation files (the        */
/* "Software"), to deal in the Software without restriction, including    */
/* without limitation the rights to use, copy, modify, merge, publish,    */
/* distribute, sublicense, and/or sell copies of the Software, and to     */
/* permit persons to whom the Software is furnished to do so, subject to  */
/* the following conditions:                                              */
/*                                                                        */
/* The above copyright notice and this permission notice shall be         */
/* included in all copies or substantial portions of the Software.        */
/*                                                                        */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
/**************************************************************************/

#ifndef HEALTH_KIT_H
#define HEALTH_KIT_H

#include "core/version.h"
#include "core/object/class_db.h"
#include <map>
#include <mutex>

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
    void open_settings();

    void refresh_health_store();
    
    void start_step_observer();
    void stop_step_observer();

    bool is_pedometer_available();
    int get_pedometer_permission_status();
    void start_pedometer_observer();
    void stop_pedometer_observer();
    int get_live_pedometer_steps();

    static HealthKit *get_singleton();

    HealthKit();
    ~HealthKit();
    
private:
    int today_steps = 0;
    int total_steps = 0;
    int live_pedometer_steps = 0;
    std::map<String, int> period_steps;
    void* health_store = nullptr;
    void* observer_query = nullptr;
    void* pedometer = nullptr;
    void* pedometer_start_time = nullptr;
    std::mutex data_mutex;
};

#endif
