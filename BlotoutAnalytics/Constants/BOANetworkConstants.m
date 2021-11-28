//
//  BOANetworkConstants.m
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOANetworkConstants.h"
#import <Foundation/Foundation.h>

int const BOSDK_MAJOR_VERSION = 0;
int const BOSDK_MINOR_VERSION = 9;
int const BOSDK_PATCH_VERSION = 7;

NSString *BO_GET = @"GET";
NSString *BO_POST = @"POST";
NSString *BO_PUT = @"PUT";
NSString *BO_CONTENT_TYPE = @"Content-Type";
NSString *BO_APPLICATION_JSON = @"application/json";
NSString *BO_TOKEN = @"token";
NSString *BO_ACCEPT = @"Accept";
NSString *BO_VERSION = @"version";

NSString *BO_META = @"meta";
NSString *BO_KEY = @"key";
NSString *BO_DATA = @"data";
NSString *BO_IV = @"iv";
NSString *BO_PII = @"pii";
NSString *BO_PHI = @"phi";

NSString *BO_USER_ID = @"userid";

NSString *BO_EVENT_MAP_ID = @"map_id";
NSString *BO_EVENT_MAP_PROVIDER = @"map_provider";

int const BO_EVENT_SDK_START = 11130;
NSString * const BO_SDK_START= @"sdk_start";

int const BO_EVENT_VISIBILITY_VISIBLE = 11131;
NSString * const BO_VISIBILITY_VISIBLE= @"visibility_visible";

int const BO_EVENT_VISIBILITY_HIDDEN = 11132;
NSString * const BO_VISIBILITY_HIDDEN= @"visibility_hidden";

//transaction events
NSString *BO_EVENT_TRANSACTION_NAME = @"transaction";

//item events
NSString *BO_EVENT_ITEM_NAME = @"item";

//Persona events
NSString *BO_EVENT_PERSONA_NAME = @"persona";

NSString * const BO_APP_VERSION= @"app_version";
NSString * const BO_EVENTS= @"events";
NSString * const BO_EVENTS_TIME= @"evt";
NSString * const BO_MESSAGE_ID= @"mid";
NSString * const BO_EVENT_NAME_MAPPING= @"evn";
NSString * const BO_SCREEN_NAME= @"scrn";
NSString * const BO_CRYPTO_IVX = @"Q0BG17E2819IWZYQ";
NSString * const BOA_DEBUG = @"BOA-DEBUG";
int const BO_DEFAULT_EVENT_PUSH_TIME = 3;
NSString * const BO_SDK_REST_API_MANIFEST_PULL_PATH = @"v1/manifest/pull";
NSString * const BO_SDK_REST_API_EVENTS_PUSH_PATH = @"v1/events/publish";
NSString * const BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY = @"com.blotout.sdk.Analytics.Root";
NSString * const BO_ANALYTICS_USER_BIRTH_TIME_STAMP_KEY = @"com.blotout.sdk.Analytics.Root.UserBirthTimeStamp";
NSString * const BO_ANALYTICS_ALL_DEV_CODIFIED_CUSTOM_EVENTS = @"com.blotout.sdk.Analytics.Dev_Custom_Event";
NSString * const BO_ANALYTICS_USER_UNIQUE_KEY = @"UserUniqueId";
NSString * const BO_SESSION_ID = @"session_id";
NSString * const BO_VERSION_KEY = @"BOVersionKey";
NSString * const BO_BUILD_KEYV1  = @"BOBuildKey";
NSString * const BO_BUILD_KEYV2 = @"BOBuildKeyV2";

NSString * const BO_SYSTEM = @"system";
NSString * const BO_CODIFIED = @"codified";
NSString * const BO_SCREEN = @"screen";
NSString * const BO_TYPE = @"type";

int const MANIFEST_PHI_PUBLIC_KEY = 5997;
int const MANIFEST_PII_PUBLIC_KEY = 5998;
int const MANIFEST_SYSTEM_EVENTS = 5001;

int const BO_APPLICATION_OPENED = 11001;
int const BO_APPLICATION_INSTALLED = 11002;
int const BO_APPLICATION_UPDATED = 11003;
int const BO_PUSH_NOTIFICATION_TAPPED = 11004;
int const BO_PUSH_NOTIFICATION_RECEIVED = 11005;
int const BO_REGISTER_FOR_REMOTE_NOTIFICATION = 11006;
int const BO_DEEP_LINK_OPENED = 11007;
int const BO_APPLICATION_BACKGROUNDED = 11008;
int const BO_APP_TRACKING = 11009;
int const BO_TRANSACTION_COMPLETED = 11010;
