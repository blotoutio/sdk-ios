//
//  BOANetworkConstants.h
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

extern  NSString *BO_GET;
extern  NSString *BO_POST;
extern  NSString *BO_PUT;
extern  NSString *BO_CONTENT_TYPE;
extern  NSString *BO_APPLICATION_JSON;
extern  NSString *BO_TOKEN;
extern  NSString *BO_ACCEPT;
extern  NSString *BO_VERSION;
extern  NSString *BO_META;
extern  NSString *BO_KEY;
extern  NSString *BO_DATA;
extern  NSString *BO_IV;
extern  NSString *BO_PII;
extern  NSString *BO_PHI;
extern  NSString *BO_USER_ID;

extern int const BO_DEV_EVENT_MAP_ID;
extern  NSString *BO_EVENT_MAP_ID;
extern  NSString *BO_EVENT_MAP_PROVIDER;

extern int const BO_EVENT_SDK_START;
extern NSString * const BO_SDK_START;

extern int const BO_EVENT_VISIBILITY_VISIBLE;
extern NSString * const BO_VISIBILITY_VISIBLE;

extern int const BO_EVENT_VISIBILITY_HIDDEN;
extern NSString * const BO_VISIBILITY_HIDDEN;

extern NSString * const BO_APP_VERSION;
extern NSString * const BO_EVENTS;
extern NSString * const BO_EVENTS_TIME;
extern NSString * const BO_MESSAGE_ID;
extern NSString * const BO_EVENT_CATEGORY_SUBCODE;

extern NSString * const BO_EVENT_NAME_MAPPING;
extern NSString * const BO_SCREEN_NAME;
extern NSString * const BO_SESSION_ID;

extern int const BOSDK_MAJOR_VERSION;
extern int const BOSDK_MINOR_VERSION;
extern int const BOSDK_PATCH_VERSION;

extern NSString * const BO_CRYPTO_IVX;
extern NSString * const BOA_DEBUG;
extern int const BO_DEV_EVENT_CUSTOM_KEY;
extern int const BO_DEFAULT_EVENT_PUSH_TIME;
extern NSString * const BO_SDK_REST_API_MANIFEST_PULL_PATH;
extern NSString * const BO_SDK_REST_API_EVENTS_PUSH_PATH;
extern NSString * const BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY;
extern NSString * const BO_ANALYTICS_USER_BIRTH_TIME_STAMP_KEY;
extern NSString * const BO_ANALYTICS_ALL_DEV_CODIFIED_CUSTOM_EVENTS;
extern NSString * const BO_ANALYTICS_USER_UNIQUE_KEY;

extern NSString *const BO_VERSION_KEY;
extern NSString *const BO_BUILD_KEYV1;
extern NSString *const BO_BUILD_KEYV2;

extern NSString * const BO_SYSTEM;
extern NSString * const BO_CODIFIED;
extern NSString * const BO_SCREEN;
extern NSString * const BO_TYPE;

// Manifest keys
extern int const MANIFEST_PHI_PUBLIC_KEY;
extern int const MANIFEST_PII_PUBLIC_KEY;
extern int const MANIFEST_PUSH_SYSTEM_EVENT;

// System event codes
extern int const BO_APPLICATION_OPENED;
extern int const BO_APPLICATION_INSTALLED;
extern int const BO_APPLICATION_UPDATED;
extern int const BO_PUSH_NOTIFICATION_TAPPED;
extern int const BO_PUSH_NOTIFICATION_RECEIVED;
extern int const BO_REGISTER_FOR_REMOTE_NOTIFICATION;
extern int const BO_DEEP_LINK_OPENED;
extern int const BO_APPLICATION_BACKGROUNDED;
extern int const BO_APP_TRACKING;
extern int const BO_TRANSACTION_COMPLETED;
