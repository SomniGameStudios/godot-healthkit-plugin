#import "ios_native.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>

#define IS_ADMOB_DEBUG_OR_RELEASE 0

IOSNative *IOSNative::instance = NULL;

void IOSNative::_bind_methods() {
    ClassDB::bind_method(D_METHOD("request_track_permission"), &IOSNative::request_track_permission);
    ClassDB::bind_method(D_METHOD("is_admob_debug_or_release"), &IOSNative::is_admob_debug_or_release);
}

IOSNative *IOSNative::get_singleton() {
    NSLog(@"Getting IOSNative Singleton");
    return instance;
}

IOSNative::IOSNative() {
    NSLog(@"In IOSNative constructor. IS_ADMOB_DEBUG_OR_RELEASE ??? %d", IS_ADMOB_DEBUG_OR_RELEASE);
    ERR_FAIL_COND(instance != NULL);
    instance = this;
}

int IOSNative::is_admob_debug_or_release() {
    int result = false;
    NSLog(@"is_admob_debug_or_release. %d", result);
    return result;
}

void IOSNative::request_track_permission() {
    NSLog(@"request_track_permission. start");
    if (@available(iOS 14, *)) {
        NSLog(@"request_track_permission. before requestTrackingAuthorizationWithCompletionHandler");
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            switch (status) {
                case ATTrackingManagerAuthorizationStatusAuthorized:
                    // Tracking authorization dialog was shown and we are authorized
                    NSLog(@"request_track_permission. Authorized");
                    // Now that we are authorized we can get the IDFA
                    NSLog(@"request_track_permission. %@", [[ASIdentifierManager sharedManager] advertisingIdentifier]);
                    break;
                case ATTrackingManagerAuthorizationStatusDenied:
                    // Tracking authorization dialog was shown and permission is denied
                    NSLog(@"request_track_permission. Denied");
                    break;
                case ATTrackingManagerAuthorizationStatusNotDetermined:
                    // Tracking authorization dialog has not been shown
                    NSLog(@"request_track_permission. Not Determined");
                    break;
                case ATTrackingManagerAuthorizationStatusRestricted:
                    NSLog(@"request_track_permission. Restricted");
                    break;
                default:
                    NSLog(@"request_track_permission. Unknown");
                    break;
            }
        }];
    }
    else {
        NSLog(@"request_track_permission. iOS 14 or later is not available");
    }
}

IOSNative::~IOSNative() {
    if (instance == this) {
        instance = nullptr;
    }
}
