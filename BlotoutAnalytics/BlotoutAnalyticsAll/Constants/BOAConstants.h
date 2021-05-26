//
//  BOAConstants.h
//  BlotoutAnalytics
//
//  Created by Blotout on 30/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


extern int const BOSDK_MAJOR_VERSION;
extern int const BOSDK_MINOR_VERSION;
extern int const BOSDK_PATCH_VERSION;

#pragma mark: Default initial delay values
extern int const BO_DEFAULT_EVENT_PUSH_TIME;
extern int const BO_ANALYTICS_POST_INIT_NETWORK_DELAY;


extern NSString * const BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY;
extern NSString * const BO_ANALYTICS_ROOT_NEW_USER_DEFAULTS_KEY;
extern NSString * const BO_ANALYTICS_USER_BIRTH_TIME_STAMP_KEY;

extern NSString * const BO_ANALYTICS_SESSION_MODEL_DEFAULTS_KEY;
extern NSString * const BO_ANALYTICS_LIFETIME_MODEL_DEFAULTS_KEY;
extern NSString * const BO_ANALYTICS_SDK_MANIFEST_LAST_DATE_SYNC_DEFAULTS_KEY;
extern NSString * const BO_ANALYTICS_SDK_MANIFEST_LAST_TIMESTAMP_SYNC_DEFAULTS_KEY;
extern NSString * const BO_ANALYTICS_ALL_DEV_CODIFIED_CUSTOM_EVENTS;
extern NSString * const BO_ANALYTICS_DEV_EVENT_USER_DEFAULTS_KEY;
extern NSString * const BO_ANALYTICS_ROOT_SESSION_HISTORY_DEFAULTS_KEY;
extern NSString * const BO_ANALYTICS_FUNNEL_LAST_SYNC_TIME_DEFAULTS_KEY;
extern NSString * const BO_ANALYTICS_FUNNEL_APP_LAUNCH_PREV_DAY_DEFAULTS_KEY;
extern NSString * const BO_ANALYTICS_FUNNEL_LAST_UPDATE_TIME_DEFAULTS_KEY;
extern NSString * const BO_ANALYTICS_FUNNEL_USER_TRAVERSAL_COUNT_DEFAULTS_KEY;
extern NSString * const BO_ANALYTICS_FUNNEL_USER_TRAVERSAL_PREV_DAY_DEFAULTS_KEY;
extern NSString * const BO_ANALYTICS_SEGMENT_LAST_SYNC_TIME_DEFAULTS_KEY;
extern NSString * const BO_ANALYTICS_CURRENT_LOCATION_DICT;
extern NSString * const BO_ANALYTICS_ROOT_USER_DEFAULTS_PREVIOUS_DAY_APP_INFO;
extern NSString * const BO_SDK_ALPHA_DEV_MODE_API_DOMAIN_PATH;
extern NSString * const BO_SDK_STAGE_MODE_API_DOMAIN_PATH;
extern NSString * const BO_SDK_PROD_MODE_API_DOMAIN_PATH;

#pragma mark: API END Points
extern NSString * const BO_SDK_REST_API_MANIFEST_PULL_PATH;
extern NSString * const BO_SDK_REST_API_GEO_IP_PULL_PATH;
extern NSString * const BO_SDK_REST_API_SEGMENT_PULL_PATH;
extern NSString * const BO_SDK_REST_API_SEGMENT_PUSH_PATH;
extern NSString * const BO_SDK_REST_API_SEGMENT_DEFAULT_PUSH_PATH;
extern NSString * const BO_SDK_REST_API_FUNNEL_PULL_PATH;
extern NSString * const BO_SDK_REST_API_FUNNEL_PUSH_PATH;
extern NSString * const BO_SDK_REST_API_EVENTS_PUSH_PATH;
extern NSString * const BO_SDK_REST_API_RETENTION_PUSH_PATH;


extern NSString * const BO_SINGLE_DAY_SESSIONS;
extern NSString * const BO_APP_INFO;
extern NSString * const BO_BUNDLE_ID;
extern NSString * const BO_LAST_UPDATED_TIME;
extern NSString * const BO_SENT_TO_SERVER;
extern NSString * const BO_TIME_STAMP;
extern NSString * const BO_VISIBLE_CLASS_NAME;
extern NSString * const BO_CURRENT_VIEW;
extern NSString * const BO_DATE;
extern NSString * const BO_EVENT_SUB_CODE;
extern NSString * const BO_EVENT_CODE;
extern NSString * const BO_EVENT_NAME;
extern NSString * const BO_EVENT_INFO;
extern NSString * const BO_AVERAGE_SESSION_DURATION;
extern NSString * const BO_STATUS;
extern NSString * const BO_SESSION_DURATION;
extern NSString * const BO_TERMINATION_TIME_STAMP;
extern NSString * const BO_LAUNCH_TIME_STAMP;
extern NSString * const BO_START_VISIBLE_CLASS_NAME;
extern NSString * const BO_END_VISIBLE_CLASS_NAME;
extern NSString * const BO_EVENT_START_INFO;
extern NSString * const BO_EVENT_DURATION;
extern NSString * const BO_EVENT_START_TIME_REFERENCE;
extern NSString * const BO_EVENT_START_TIME;
extern NSString * const BO_EVENT_END_TIME;
extern NSString * const BO_TIMED_EVENT_INFO;
extern NSString * const BO_DAU;
extern NSString * const BO_DAU_INFO;
extern NSString * const BO_DPU;
extern NSString * const BO_DPU_INFO;
extern NSString * const BO_APP_INSTALLED;

extern NSString * const BO_APP_INSTALLED_INFO;
extern NSString * const BO_IS_FIRST_LAUNCH;
extern NSString * const BO_IS_NEW_USER;
extern NSString * const BO_THE_NEW_USER_INFO;
extern NSString * const BO_NEW_USER;
extern NSString * const BO_DAST;
extern NSString * const BO_AVERAGE_SESSION_TIME;
extern NSString * const BO_PAYLOAD;
extern NSString * const BO_DAST_INFO;
extern NSString * const BO_MAST_INFO;
extern NSString * const BO_WAST_INFO;
extern NSString * const BO_MAST;
extern NSString * const BO_WAST;
extern NSString * const BO_MAU_INFO;
extern NSString * const BO_WAU_INFO;
extern NSString * const BO_MAU;
extern NSString * const BO_WAU;
extern NSString * const BO_MPU;
extern NSString * const BO_WPU;
extern NSString * const BO_MPU_INFO;
extern NSString * const BO_WPU_INFO;
extern NSString * const BO_NAME;
extern NSString * const BO_PLATFORM;
extern NSString * const BO_LANGUAGE;
extern NSString * const BO_BUNDLE;
extern NSString * const BO_SDK_VERSION;
extern NSString * const BO_OS_NAME;
extern NSString * const BO_OS_VERSION;
extern NSString * const BO_DEVICE_MFT;
extern NSString * const BO_DEVICE_MODEL;
extern NSString * const BO_VPN_STATUS;
extern NSString * const BO_JBN_STATUS;
extern NSString * const BO_DCOMP_STATUS;
extern NSString * const BO_ACOMP_STATUS;
extern NSString * const BO_CURRENT_LOCATION;
extern NSString * const BO_APP_BECOME_ACTIVE;
extern NSString * const BO_APP_RESIGN_ACTIVE;
extern NSString * const BO_APP_MEMORY_WARNING;
extern NSString * const BO_APP_SIGNIFICANT_TIME_CHANGE;
extern NSString * const BO_APP_BACKGROUND_REFRESH_CHANGED;
extern NSString * const BO_APP_BACKGROUND_REFRESH_AVAILABLE;
extern NSString * const BO_STATUS_BAR_FRAME_CHANGED;
extern NSString * const BO_APP_TAKEN_SCREEN_SHOT;
extern NSString * const BO_NUMBER;
extern NSString * const BO_PROCESSOR_ID;
extern NSString * const BO_USAGE_PERCENTAGE;
extern NSString * const BO_NAMES;
extern NSString * const BO_PERCENTAGE;
extern NSString * const BO_ORIENTATION;
extern NSString * const BO_DEVICE_ORIENTATION;
extern NSString * const BO_CF_UUID;
extern NSString * const BO_VENDOR_ID;
extern NSString * const BO_IP_ADDRESS;
extern NSString * const BO_NETMASK;
extern NSString * const BO_BROADCAST_ADDRESS;
extern NSString * const BO_ROUTER_ADDRESS;
extern NSString * const BO_SSID;
extern NSString * const BO_IS_CONNECTED;
extern NSString * const BO_TOTAL_DISK_SPACE;
extern NSString * const BO_USED_DISK_SPACE;
extern NSString * const BO_FREE_DISK_SPACE;
extern NSString * const BO_SPACE_UNIT;
extern NSString * const BO_MEMORY_WARNING;
extern NSString * const BO_TOTAL_RAM;
extern NSString * const BO_USED_MEMORY;
extern NSString * const BO_WIRED_MEMORY;
extern NSString * const BO_ACTIVE_MEMORY;
extern NSString * const BO_IN_ACTIVE_MEMORY;
extern NSString * const BO_FREE_MEMORY;
extern NSString * const BO_PURGEABLE_MEMORY;
extern NSString * const BOA_DEBUG;
extern NSString * const BO_ANALYTICS_USER_UNIQUE_KEY;
extern NSString * const BO_START;
extern NSString * const BO_END;
extern NSString * const BO_DURATION;

NS_ASSUME_NONNULL_END
