//
//  BOANetworkConstants.m
//  BlotoutAnalytics
//
//  Created by Blotout on 07/08/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOANetworkConstants.h"
#import <Foundation/Foundation.h>



int const BOSDK_MAJOR_VERSION = 0;
int const BOSDK_MINOR_VERSION = 7;
int const BOSDK_PATCH_VERSION = 1;

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
NSString *BO_PII_EVENTS = @"piiEvents";
NSString *BO_PHI_EVENTS = @"phiEvents";

NSString *BO_TIME_ZONE_OFFSET = @"timeZoneOffset";
NSString *BO_USER_ID = @"userid";

NSString *BO_EVENT_MAP_ID = @"map_id";
NSString *BO_EVENT_MAP_Provider = @"map_provider";

NSString *BO_EVENT_DATA_POST_API = @"boEventDataPOSTAPI";
NSString *BO_RETENTION_EVENT_DATA_POST_API = @"boRetentionEventDataPOSTAPI";

int const BO_EVENT_SDK_START = 11130;
NSString * const BO_SDK_START= @"sdk_start";

NSString * const BO_VISIBILITY_VISIBLE= @"visibility_visible";
NSString * const BO_VISIBILITY_HIDDEN= @"visibility_hidden";
int const BO_EVENT_VISIBILITY_VISIBLE = 11131;
int const BO_EVENT_VISIBILITY_HIDDEN = 11132;


NSString * const BO_APP_VERSION= @"app_version";
NSString * const BO_EVENTS= @"events";
NSString * const BO_EVENTS_TIME= @"evt";
NSString * const BO_EVENT_DAY_OCCURENCE_COUNT= @"evdc";
NSString * const BO_EVENT_CATEGORY= @"evc";
NSString * const BO_EVENT_CATEGORY_SUBTYPE= @"evcs";
NSString * const BO_MESSAGE_ID= @"mid";
NSString * const BO_EVENT_NAME_MAPPING= @"evn";
NSString * const BO_SCREEN_NAME= @"scrn";
NSString * const BO_TST= @"tst";

NSString * const BO_CRYPTO_IVX = @"Q0BG17E2819IWZYQ";
int const BO_DEV_EVENT_MAP_ID = 21001;
NSString * const     BOA_DEBUG =                                                @"BOA-DEBUG";
int const BO_DEV_EVENT_CUSTOM_KEY= 21100;
int const BO_DEFAULT_EVENT_PUSH_TIME = 3;
NSString * const BO_SDK_REST_API_MANIFEST_PULL_PATH =                           @"v1/manifest/pull";
NSString * const BO_SDK_REST_API_EVENTS_PUSH_PATH =                         @"v1/events/publish";
NSString * const BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY =                          @"com.blotout.sdk.Analytics.Root";
NSString * const BO_ANALYTICS_USER_BIRTH_TIME_STAMP_KEY =                      @"com.blotout.sdk.Analytics.Root.UserBirthTimeStamp";
NSString * const BO_ANALYTICS_SDK_MANIFEST_LAST_TIMESTAMP_SYNC_DEFAULTS_KEY =   @"sdk_manifest_last_sync_timestamp";
NSString * const BO_ANALYTICS_ALL_DEV_CODIFIED_CUSTOM_EVENTS =                  @"com.blotout.sdk.Analytics.Dev_Custom_Event";
NSString * const BO_ANALYTICS_USER_UNIQUE_KEY =                             @"UserUniqueId";
NSString * const BO_SESSION_ID = @"session_id";
NSString * const BO_VERSION_KEY = @"BOVersionKey";
NSString * const BO_BUILD_KEYV1  = @"BOBuildKey";
NSString * const BO_BUILD_KEYV2 = @"BOBuildKeyV2";

NSString * const BO_SYSTEM = @"system";
NSString * const BO_CODIFIED = @"codified";
NSString * const BO_SCREEN = @"screen";
NSString * const BO_TYPE = @"type";
