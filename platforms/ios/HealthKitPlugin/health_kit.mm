#import "health_kit.h"
#include <Foundation/NSDate.h>
#include <HealthKit/HealthKit.h>
#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

HealthKit *HealthKit::instance = NULL;

void HealthKit::_bind_methods() {
    ClassDB::bind_method(D_METHOD("run_today_steps_query"), &HealthKit::run_today_steps_walked_query);
    ClassDB::bind_method(D_METHOD("run_total_steps_query"), &HealthKit::run_total_steps_walked_query);
    ClassDB::bind_method(D_METHOD("run_period_steps_query", "days"), &HealthKit::run_period_steps_query);
    ClassDB::bind_method(D_METHOD("get_today_steps"), &HealthKit::get_today_steps);
    ClassDB::bind_method(D_METHOD("get_total_steps"), &HealthKit::get_total_steps);
    ClassDB::bind_method(D_METHOD("get_period_steps_dict"), &HealthKit::get_period_steps_dict);
    
    ClassDB::bind_method(D_METHOD("request_permission"), &HealthKit::request_permission);
    ClassDB::bind_method(D_METHOD("get_permission_status"), &HealthKit::get_permission_status);
    ClassDB::bind_method(D_METHOD("is_health_data_available"), &HealthKit::is_health_data_available);
    ClassDB::bind_method(D_METHOD("open_settings"), &HealthKit::open_settings);
    ClassDB::bind_method(D_METHOD("start_step_observer"), &HealthKit::start_step_observer);
    ClassDB::bind_method(D_METHOD("stop_step_observer"), &HealthKit::stop_step_observer);

    ClassDB::bind_method(D_METHOD("is_pedometer_available"), &HealthKit::is_pedometer_available);
    ClassDB::bind_method(D_METHOD("get_pedometer_permission_status"), &HealthKit::get_pedometer_permission_status);
    ClassDB::bind_method(D_METHOD("start_pedometer_observer"), &HealthKit::start_pedometer_observer);
    ClassDB::bind_method(D_METHOD("stop_pedometer_observer"), &HealthKit::stop_pedometer_observer);
    ClassDB::bind_method(D_METHOD("get_live_pedometer_steps"), &HealthKit::get_live_pedometer_steps);

    ADD_SIGNAL(MethodInfo("permission_result", PropertyInfo(Variant::BOOL, "granted")));
    ADD_SIGNAL(MethodInfo("steps_updated", PropertyInfo(Variant::INT, "steps")));
    ADD_SIGNAL(MethodInfo("pedometer_steps_updated", PropertyInfo(Variant::INT, "steps")));
    ADD_SIGNAL(MethodInfo("pedometer_error", PropertyInfo(Variant::STRING, "reason")));

    ADD_SIGNAL(MethodInfo("today_steps_ready", PropertyInfo(Variant::INT, "steps")));
    ADD_SIGNAL(MethodInfo("total_steps_ready", PropertyInfo(Variant::INT, "steps")));
    ADD_SIGNAL(MethodInfo("period_steps_ready", PropertyInfo(Variant::DICTIONARY, "steps_dict")));
}

HealthKit *HealthKit::get_singleton() {
    NSLog(@"Getting HealthKit Singleton");
    return instance;
}

HealthKit::HealthKit() {
    NSLog(@"In HealthKit constructor");
    ERR_FAIL_COND(instance != NULL);
    instance = this;
    
    if (![HKHealthStore isHealthDataAvailable]) {
        NSLog(@"Health data is not available on this device");
        return;
    }
    
    HKHealthStore* store = [[HKHealthStore alloc] init];
    health_store = (void*)CFBridgingRetain(store);
    
    CMPedometer* ped = [[CMPedometer alloc] init];
    pedometer = (void*)CFBridgingRetain(ped);
}

int HealthKit::get_today_steps() {
    NSLog(@"In HealthKit get today walked");
    std::lock_guard<std::mutex> lock(data_mutex);
    return today_steps;
}

int HealthKit::get_total_steps() {
    NSLog(@"In HealthKit get total steps walked");
    std::lock_guard<std::mutex> lock(data_mutex);
    return total_steps;
}

void HealthKit::run_today_steps_walked_query() {
    if (!health_store) return;
    HKHealthStore* store = (__bridge HKHealthStore*)health_store;

    HKQuantityType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    NSDate *today = [NSDate date];
    
    NSDate *startOfDay = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] startOfDayForDate:[NSDate date]];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startOfDay endDate:today options:HKQueryOptionStrictStartDate];
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc]
                                initWithQuantityType:type quantitySamplePredicate:predicate
                                options:HKStatisticsOptionCumulativeSum
                                completionHandler:^(HKStatisticsQuery * _Nonnull query, HKStatistics * _Nullable result, NSError * _Nullable error) {
        
        if (error != nil) {
            NSLog(@"Error with today's steps: %@.", error);
            // Heuristic: If we get error code 11 (No data available), it often means read permission was denied 
            // but Apple is hiding it. We treat this as a negative permission result.
            if (error.code == 11) {
                instance->call_deferred("emit_signal", "permission_result", false);
            }
            
            {
                std::lock_guard<std::mutex> lock(instance->data_mutex);
                instance->today_steps = 0;
            }
            instance->call_deferred("emit_signal", "today_steps_ready", 0);
        } else {
            double steps = [[result sumQuantity] doubleValueForUnit:[HKUnit countUnit]];
            NSLog(@"Today's steps: %f", steps);
            {
                std::lock_guard<std::mutex> lock(instance->data_mutex);
                instance->today_steps = (int)steps;
            }
            instance->call_deferred("emit_signal", "today_steps_ready", (int)steps);
        }
    }];
    
    [store executeQuery:query];
}

void HealthKit::run_total_steps_walked_query() {
    if (!health_store) return;
    HKHealthStore* store = (__bridge HKHealthStore*)health_store;

    NSDate *start = [NSDate distantPast];
    NSDate *end = [NSDate date];
    
    HKQuantityType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:start endDate:end options:HKQueryOptionStrictStartDate];

    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:type quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery * _Nonnull query, HKStatistics * _Nullable result, NSError * _Nullable error) {
        
        if (error != nil) {
            NSLog(@"Error with total steps: %@. Defaulting to 0.", error);
            {
                std::lock_guard<std::mutex> lock(instance->data_mutex);
                instance->total_steps = 0;
            }
            instance->call_deferred("emit_signal", "total_steps_ready", 0);
        } else {
            double steps = [[result sumQuantity] doubleValueForUnit:[HKUnit countUnit]];
            NSLog(@"Total steps since epoch %f", steps);
            {
                std::lock_guard<std::mutex> lock(instance->data_mutex);
                instance->total_steps = (int)steps;
            }
            instance->call_deferred("emit_signal", "total_steps_ready", (int)steps);
        }
    }];
    
    [store executeQuery:query];
}

void HealthKit::run_period_steps_query(int days) {
    if (!health_store) return;
    HKHealthStore* store = (__bridge HKHealthStore*)health_store;

    HKQuantityType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];

    NSDate *startDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:-days toDate:now options:0];
    startDate = [calendar startOfDayForDate:startDate];

    NSDate *anchorDate = [calendar startOfDayForDate:now];

    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:now options:HKQueryOptionStrictStartDate];

    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;

    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc]
                                          initWithQuantityType:type
                                          quantitySamplePredicate:predicate
                                          options:HKStatisticsOptionCumulativeSum
                                          anchorDate:anchorDate
                                          intervalComponents:interval];

    query.initialResultsHandler = ^(HKStatisticsCollectionQuery * _Nonnull query, HKStatisticsCollection * _Nullable results, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error fetching steps for past %d days: %@", days, error);
            return;
        }

        Dictionary steps_data;
        {
            std::lock_guard<std::mutex> lock(instance->data_mutex);
            instance->period_steps.clear();

            [results enumerateStatisticsFromDate:startDate toDate:now withBlock:^(HKStatistics * _Nonnull statistics, BOOL * _Nonnull stop) {
                if (statistics.sumQuantity) {
                    double steps = [statistics.sumQuantity doubleValueForUnit:[HKUnit countUnit]];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyy-MM-dd"];
                    NSString *dateStr = [formatter stringFromDate:statistics.startDate];
                    instance->period_steps[dateStr.UTF8String] = (int)steps;
                }
            }];

            for (const auto& entry : instance->period_steps) {
                NSString *key = [NSString stringWithUTF8String:entry.first.utf8().get_data()];
                NSLog(@"Period steps entry: %@ -> %d", key, entry.second);
                steps_data[entry.first] = entry.second;
            }
        }
        instance->call_deferred("emit_signal", "period_steps_ready", steps_data);
    };

    [store executeQuery:query];
}

Dictionary HealthKit::get_period_steps_dict() {
    Dictionary steps_data;
    std::lock_guard<std::mutex> lock(data_mutex);
    for (const auto& entry : period_steps) {
        steps_data[entry.first] = entry.second;
    }
    return steps_data;
}

void HealthKit::request_permission() {
    if (!health_store) {
        instance->call_deferred("emit_signal", "permission_result", false);
        return;
    }
    HKHealthStore* store = (__bridge HKHealthStore*)health_store;
    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];

    NSSet<HKSampleType*> *read_types = [NSSet setWithObject:stepType];
    
    [store requestAuthorizationToShareTypes:nil readTypes:read_types completion:^(BOOL success, NSError * _Nullable error) {
        if (!success) {
            NSLog(@"Health data authorization failed: %@", error);
            instance->call_deferred("emit_signal", "permission_result", false);
            return;
        }
        NSLog(@"Health data authorization success");
        instance->call_deferred("emit_signal", "permission_result", true);
        
        instance->run_today_steps_walked_query();
        instance->run_total_steps_walked_query();
    }];
}

int HealthKit::get_permission_status() {
    if (!health_store) return 0; // Not determined
    HKHealthStore* store = (__bridge HKHealthStore*)health_store;
    HKQuantityType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    return (int)[store authorizationStatusForType:type];
}

bool HealthKit::is_health_data_available() {
    return [HKHealthStore isHealthDataAvailable];
}

void HealthKit::open_settings() {
    // Primary: Try to open the Apple Health app directly
    NSURL *healthAppUrl = [NSURL URLWithString:@"x-apple-health://"];
    if ([[UIApplication sharedApplication] canOpenURL:healthAppUrl]) {
        [[UIApplication sharedApplication] openURL:healthAppUrl options:@{} completionHandler:nil];
        return;
    } 
    
    // Fallback: Open the App's own specific Settings page
    NSURL *appSettingsUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:appSettingsUrl]) {
        [[UIApplication sharedApplication] openURL:appSettingsUrl options:@{} completionHandler:nil];
    }
}

void HealthKit::start_step_observer() {
    if (!health_store) return;
    if (observer_query) return; // Already running

    HKHealthStore* store = (__bridge HKHealthStore*)health_store;
    HKQuantityType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];

    // Enable background delivery
    [store enableBackgroundDeliveryForType:type frequency:HKUpdateFrequencyImmediate withCompletion:^(BOOL success, NSError * _Nullable error) {
        if (!success) {
            NSLog(@"Failed to enable background delivery: %@", error);
        } else {
            NSLog(@"Successfully enabled background delivery");
        }
    }];

    HKObserverQuery *query = [[HKObserverQuery alloc] initWithSampleType:type predicate:nil updateHandler:^(HKObserverQuery * _Nonnull query, HKObserverQueryCompletionHandler  _Nonnull completionHandler, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Observer query error: %@", error);
            if (completionHandler) {
                completionHandler();
            }
            return;
        }

        // When notified of an update, we should query the latest step count
        NSDate *today = [NSDate date];
        NSDate *startOfDay = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] startOfDayForDate:today];
        NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startOfDay endDate:today options:HKQueryOptionStrictStartDate];
        
        HKStatisticsQuery *statsQuery = [[HKStatisticsQuery alloc] initWithQuantityType:type quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum completionHandler:^(HKStatisticsQuery * _Nonnull statsQuery, HKStatistics * _Nullable result, NSError * _Nullable statsError) {
            if (statsError != nil) {
                NSLog(@"Error querying steps in observer: %@", statsError);
            } else {
                double steps = 0;
                if (result.sumQuantity) {
                    steps = [[result sumQuantity] doubleValueForUnit:[HKUnit countUnit]];
                }
                std::lock_guard<std::mutex> lock(instance->data_mutex);
                instance->today_steps = (int)steps;
                instance->call_deferred("emit_signal", "steps_updated", (int)steps);
            }
            if (completionHandler) {
                completionHandler();
            }
        }];
        
        [store executeQuery:statsQuery];
    }];

    observer_query = (void*)CFBridgingRetain(query);
    [store executeQuery:query];
}

void HealthKit::stop_step_observer() {
    if (!health_store || !observer_query) return;
    
    HKHealthStore* store = (__bridge HKHealthStore*)health_store;
    HKObserverQuery* query = (__bridge HKObserverQuery*)observer_query;
    
    [store stopQuery:query];
    
    HKQuantityType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    [store disableBackgroundDeliveryForType:type withCompletion:^(BOOL success, NSError * _Nullable error) {
        if (!success) {
            NSLog(@"Failed to disable background delivery: %@", error);
        }
    }];

    CFBridgingRelease(observer_query);
    observer_query = nullptr;
}

bool HealthKit::is_pedometer_available() {
    return [CMPedometer isStepCountingAvailable];
}

int HealthKit::get_pedometer_permission_status() {
    // CMAuthorizationStatus: 0=notDetermined, 1=restricted, 2=denied, 3=authorized
    return (int)[CMPedometer authorizationStatus];
}

void HealthKit::start_pedometer_observer() {
    if (!pedometer) return;
    CMPedometer* ped = (__bridge CMPedometer*)pedometer;
    
    NSDate *now = [NSDate date];
    // We start counting from right now
    [ped startPedometerUpdatesFromDate:now withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Pedometer error: %@", error);
            instance->call_deferred("emit_signal", "pedometer_error", String(error.localizedDescription.UTF8String));
            return;
        }
        
        if (pedometerData) {
            int current_steps = pedometerData.numberOfSteps.intValue;
            {
                std::lock_guard<std::mutex> lock(instance->data_mutex);
                instance->live_pedometer_steps = current_steps;
            }
            instance->call_deferred("emit_signal", "pedometer_steps_updated", current_steps);
        }
    }];
    NSLog(@"CMPedometer updates started.");
}

void HealthKit::stop_pedometer_observer() {
    if (!pedometer) return;
    CMPedometer* ped = (__bridge CMPedometer*)pedometer;
    [ped stopPedometerUpdates];
    NSLog(@"CMPedometer updates stopped.");
}

int HealthKit::get_live_pedometer_steps() {
    std::lock_guard<std::mutex> lock(data_mutex);
    return live_pedometer_steps;
}

HealthKit::~HealthKit() {
    if (observer_query) {
        CFBridgingRelease(observer_query);
        observer_query = nullptr;
    }
    if (pedometer) {
        CMPedometer* ped = (__bridge CMPedometer*)pedometer;
        [ped stopPedometerUpdates];
        CFBridgingRelease(pedometer);
        pedometer = nullptr;
    }
    if (health_store) {
        CFBridgingRelease(health_store);
        health_store = nullptr;
    }
    if (instance == this) {
        instance = nullptr;
    }
}
