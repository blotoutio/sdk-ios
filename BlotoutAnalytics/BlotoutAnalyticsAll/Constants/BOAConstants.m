//
//  BOAConstants.m
//  BlotoutAnalytics
//
//  Created by Pawan Singh Jat on 22/09/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOAConstants.h"


int const BOSDK_MAJOR_VERSION = 0;
int const BOSDK_MINOR_VERSION = 6;
int const BOSDK_PATCH_VERSION = 1;

int const BO_DEFAULT_EVENT_PUSH_TIME = 3;
int const BO_ANALYTICS_POST_INIT_NETWORK_DELAY = 5;


NSString * const BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY =                          @"com.blotout.sdk.Analytics.Root";
NSString * const BO_ANALYTICS_ROOT_NEW_USER_DEFAULTS_KEY =                      @"com.blotout.sdk.Analytics.Root.NewUser";
NSString * const BO_ANALYTICS_USER_BIRTH_TIME_STAMP_KEY =                      @"com.blotout.sdk.Analytics.Root.UserBirthTimeStamp";
NSString * const BO_ANALYTICS_SESSION_MODEL_DEFAULTS_KEY =                      @"com.blotout.sdk.Analytics.Sesson_Model";
NSString * const BO_ANALYTICS_LIFETIME_MODEL_DEFAULTS_KEY =                     @"com.blotout.sdk.Analytics.LifeTime_Model";
NSString * const BO_ANALYTICS_SDK_MANIFEST_LAST_DATE_SYNC_DEFAULTS_KEY =        @"sdk_manifest_last_sync_date";
NSString * const BO_ANALYTICS_SDK_MANIFEST_LAST_TIMESTAMP_SYNC_DEFAULTS_KEY =   @"sdk_manifest_last_sync_timestamp";
NSString * const BO_ANALYTICS_ALL_DEV_CODIFIED_CUSTOM_EVENTS =                  @"com.blotout.sdk.Analytics.Dev_Custom_Event";
NSString * const BO_ANALYTICS_DEV_EVENT_USER_DEFAULTS_KEY =                     @"com.blotout.sdk.Analytics.Dev_Event";
NSString * const BO_ANALYTICS_ROOT_SESSION_HISTORY_DEFAULTS_KEY =               @"com.blotout.sdk.Analytics.Root.Session_History";
NSString * const BO_ANALYTICS_FUNNEL_LAST_SYNC_TIME_DEFAULTS_KEY =              @"funnel_last_sync_time";
NSString * const BO_ANALYTICS_FUNNEL_APP_LAUNCH_PREV_DAY_DEFAULTS_KEY =         @"funnel_app_launch_prev_day";
NSString * const BO_ANALYTICS_FUNNEL_LAST_UPDATE_TIME_DEFAULTS_KEY =            @"funnel_last_update_time";
NSString * const BO_ANALYTICS_FUNNEL_USER_TRAVERSAL_COUNT_DEFAULTS_KEY =        @"funnel_user_traversal_count";
NSString * const BO_ANALYTICS_FUNNEL_USER_TRAVERSAL_PREV_DAY_DEFAULTS_KEY =     @"funnel_user_traversal_prev_day";
NSString * const BO_ANALYTICS_SEGMENT_LAST_SYNC_TIME_DEFAULTS_KEY =             @"segment_last_sync_time";
NSString * const BO_ANALYTICS_CURRENT_LOCATION_DICT =                           @"geo_ip_current_location";
NSString * const BO_ANALYTICS_ROOT_USER_DEFAULTS_PREVIOUS_DAY_APP_INFO =        @"com.blotout.sdk.Analytics.pDay.AppInfo";
NSString * const BO_SDK_ALPHA_DEV_MODE_API_DOMAIN_PATH =                        @"https://api.blotout.io/sdk";
NSString * const BO_SDK_STAGE_MODE_API_DOMAIN_PATH =                            @"https://stage-sdk.blotout.io/sdk";
NSString * const BO_SDK_PROD_MODE_API_DOMAIN_PATH =                             @"https://sdk.blotout.io/sdk";


NSString * const BO_SDK_REST_API_MANIFEST_PULL_PATH =                           @"v1/manifest/pull";
NSString * const BO_SDK_REST_API_GEO_IP_PULL_PATH =                             @"v1/geo/city";

NSString * const     BO_SDK_REST_API_SEGMENT_PULL_PATH =                        @"v1/segment/pull";
NSString * const     BO_SDK_REST_API_SEGMENT_PUSH_PATH =                        @"v1/segment/custom/feedback";
NSString * const     BO_SDK_REST_API_SEGMENT_DEFAULT_PUSH_PATH =                @"v1/segment/default/feedback";

NSString * const     BO_SDK_REST_API_FUNNEL_PULL_PATH =                         @"v1/funnel/pull";
NSString * const     BO_SDK_REST_API_FUNNEL_PUSH_PATH =                         @"v1/funnel/feedback";

NSString * const     BO_SDK_REST_API_EVENTS_PUSH_PATH =                         @"v1/events/publish";
NSString * const     BO_SDK_REST_API_RETENTION_PUSH_PATH =                      @"v1/events/retention/publish";

//------------------------------------------

NSString * const     BO_SINGLE_DAY_SESSIONS =                                   @"singleDaySessions";
NSString * const     BO_APP_INFO =                                              @"appInfo";
NSString * const     BO_BUNDLE_ID =                                             @"bundleId";
NSString * const     BO_LAST_UPDATED_TIME =                                     @"lastUpdatedTime";
NSString * const     BO_SENT_TO_SERVER =                                        @"sentToServer";
NSString * const     BO_TIME_STAMP =                                            @"timeStamp";
NSString * const     BO_VISIBLE_CLASS_NAME =                                    @"visibleClassName";
NSString * const     BO_CURRENT_VIEW =                                          @"currentView";
NSString * const     BO_DATE =                                                  @"date";
NSString * const     BO_EVENT_SUB_CODE =                                        @"eventSubCode";
NSString * const     BO_EVENT_CODE =                                            @"eventCode";
NSString * const     BO_EVENT_NAME =                                            @"eventName";
NSString * const     BO_EVENT_INFO =                                            @"eventInfo";
NSString * const     BO_AVERAGE_SESSION_DURATION =                              @"averageSessionsDuration";
NSString * const     BO_STATUS =                                                @"status";
NSString * const     BO_SESSION_DURATION =                                      @"sessionsDuration";
NSString * const     BO_TERMINATION_TIME_STAMP =                                @"terminationTimeStamp";
NSString * const     BO_LAUNCH_TIME_STAMP =                                     @"launchTimeStamp";
NSString * const     BO_START_VISIBLE_CLASS_NAME =                              @"startVisibleClassName";
NSString * const     BO_END_VISIBLE_CLASS_NAME =                                @"endVisibleClassName";
NSString * const     BO_EVENT_START_INFO =                                      @"eventStartInfo";
NSString * const     BO_EVENT_DURATION =                                        @"eventDuration";
NSString * const     BO_EVENT_START_TIME_REFERENCE =                            @"eventStartTimeReference";
NSString * const     BO_EVENT_START_TIME =                                      @"startTime";
NSString * const     BO_EVENT_END_TIME =                                        @"endTime";
NSString * const     BO_TIMED_EVENT_INFO =                                      @"timedEvenInfo";
NSString * const     BO_DAU =                                                   @"DAU";
NSString * const     BO_DAU_INFO =                                              @"dauInfo";
NSString * const     BO_DPU =                                                   @"DPU";
NSString * const     BO_DPU_INFO =                                              @"dpuInfo";
NSString * const     BO_APP_INSTALLED =                                         @"AppInstalled";
NSString * const     BO_APP_INSTALLED_INFO =                                    @"appInstalledInfo";
NSString * const     BO_IS_FIRST_LAUNCH =                                       @"isFirstLaunch";
NSString * const     BO_IS_NEW_USER =                                           @"isNewUser";
NSString * const     BO_THE_NEW_USER_INFO =                                     @"theNewUserInfo";
NSString * const     BO_NEW_USER =                                              @"NewUser";
NSString * const     BO_DAST =                                                  @"DAST";
NSString * const     BO_AVERAGE_SESSION_TIME =                                  @"averageSessionTime";
NSString * const     BO_PAYLOAD =                                               @"payload";
NSString * const     BO_DAST_INFO =                                             @"dastInfo";
NSString * const     BO_MAST_INFO =                                             @"mastInfo";
NSString * const     BO_WAST_INFO =                                             @"wastInfo";
NSString * const     BO_MAST =                                                  @"MAST";
NSString * const     BO_WAST =                                                  @"WAST";
NSString * const     BO_MAU_INFO =                                              @"mauInfo";
NSString * const     BO_WAU_INFO =                                              @"wauInfo";
NSString * const     BO_MAU =                                                   @"MAU";
NSString * const     BO_WAU =                                                   @"WAU";
NSString * const     BO_MPU =                                                   @"MPU";
NSString * const     BO_WPU =                                                   @"WPU";
NSString * const     BO_MPU_INFO =                                              @"mpuInfo";
NSString * const     BO_WPU_INFO =                                              @"wpuInfo";
//NSString * const     BO_APP_LAUNCHED =                                        @"AppLaunched"
NSString * const     BO_NAME =                                                  @"name";
NSString * const     BO_PLATFORM =                                              @"platform";
NSString * const     BO_LANGUAGE =                                              @"language";
NSString * const     BO_BUNDLE =                                                @"bundle";
NSString * const     BO_SDK_VERSION =                                           @"sdkVersion";
NSString * const     BO_OS_NAME =                                               @"osName";
NSString * const     BO_OS_VERSION =                                            @"osVersion";
NSString * const     BO_DEVICE_MFT =                                            @"deviceMft";
NSString * const     BO_DEVICE_MODEL =                                          @"deviceModel";
NSString * const     BO_VPN_STATUS =                                            @"vpnStatus";
NSString * const     BO_JBN_STATUS =                                            @"jbnStatus";
NSString * const     BO_DCOMP_STATUS =                                          @"dcompStatus";
NSString * const     BO_ACOMP_STATUS =                                          @"acompStatus";
NSString * const     BO_CURRENT_LOCATION =                                      @"currentLocation";
NSString * const     BO_APP_BECOME_ACTIVE =                                     @"AppBecomeActive";
NSString * const     BO_APP_RESIGN_ACTIVE =                                     @"AppResignActive";
NSString * const     BO_APP_MEMORY_WARNING =                                    @"AppMemoryWarning";
NSString * const     BO_APP_SIGNIFICANT_TIME_CHANGE =                           @"AppSignificantTimeChange";
NSString * const     BO_APP_BACKGROUND_REFRESH_CHANGED =                        @"BackgroundRefreshChanged";
NSString * const     BO_APP_BACKGROUND_REFRESH_AVAILABLE =                      @"BackgroundRefreshAvailable";
NSString * const     BO_STATUS_BAR_FRAME_CHANGED =                              @"StatusBarFrameChanged";
NSString * const     BO_APP_TAKEN_SCREEN_SHOT =                                 @"AppTakenScreenShot";
NSString * const     BO_NUMBER =                                                @"number";
NSString * const     BO_PROCESSOR_ID =                                          @"processorID";
NSString * const     BO_USAGE_PERCENTAGE =                                      @"usagePercentage";
NSString * const     BO_NAMES =                                                 @"names";
NSString * const     BO_PERCENTAGE =                                            @"percentage";
NSString * const     BO_ORIENTATION =                                           @"orientation";
NSString * const     BO_DEVICE_ORIENTATION =                                    @"DeviceOrientation";
NSString * const     BO_CF_UUID =                                               @"cfUUID";
NSString * const     BO_VENDOR_ID =                                             @"vendorID";
NSString * const     BO_IP_ADDRESS =                                            @"ipAddress";
NSString * const     BO_NETMASK =                                               @"netmask";
NSString * const     BO_BROADCAST_ADDRESS =                                     @"broadcastAddress";
NSString * const     BO_ROUTER_ADDRESS =                                        @"routerAddress";
NSString * const     BO_SSID =                                                  @"ssid";
NSString * const     BO_IS_CONNECTED =                                          @"isConnected";
NSString * const     BO_TOTAL_DISK_SPACE =                                      @"totalDiskSpace";
NSString * const     BO_USED_DISK_SPACE =                                       @"usedDiskSpace";
NSString * const     BO_FREE_DISK_SPACE =                                       @"freeDiskSpace";
NSString * const     BO_SPACE_UNIT =                                            @"unit";
NSString * const     BO_MEMORY_WARNING =                                        @"atMemoryWarning";
NSString * const     BO_TOTAL_RAM =                                             @"totalRAM";
NSString * const     BO_USED_MEMORY =                                           @"usedMemory";
NSString * const     BO_WIRED_MEMORY =                                          @"wiredMemory";
NSString * const     BO_ACTIVE_MEMORY =                                         @"activeMemory";
NSString * const     BO_IN_ACTIVE_MEMORY =                                      @"inActiveMemory";
NSString * const     BO_FREE_MEMORY =                                           @"freeMemory";
NSString * const     BO_PURGEABLE_MEMORY =                                      @"purgeableMemory";
NSString * const     BO_START =                                                 @"start";
NSString * const     BO_END =                                                   @"end";
NSString * const     BO_DURATION =                                              @"duration";

//exception hadling message
NSString * const     BOA_DEBUG =                                                @"BOA-DEBUG";

//User default key
NSString * const     BO_ANALYTICS_USER_UNIQUE_KEY =                             @"UserUniqueId";
