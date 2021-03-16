//
//  BOANetworkConstants.m
//  BlotoutAnalytics
//
//  Created by Blotout on 07/08/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOANetworkConstants.h"
#import <Foundation/Foundation.h>

NSString *BO_GET = @"GET";
NSString *BO_POST = @"POST";
NSString *BO_PUT = @"PUT";
NSString *BO_CONTENT_TYPE = @"Content-Type";
NSString *BO_APPLICATION_JSON = @"application/json";
NSString *BO_TOKEN = @"token";
NSString *BO_ACCEPT = @"Accept";
NSString *BO_VERSION = @"version";

NSString *BO_META = @"meta";
NSString *BO_PMETA = @"pmeta";
NSString *BO_GEO = @"geo";
NSString *BO_KEY = @"key";
NSString *BO_DATA = @"data";
NSString *BO_IV = @"iv";
NSString *BO_PII = @"pii";
NSString *BO_PHI = @"phi";
NSString *BO_PII_EVENTS = @"piiEvents";
NSString *BO_PHI_EVENTS = @"phiEvents";

NSString *BO_TIME_ZONE_OFFSET = @"timeZoneOffset";
NSString *BO_USER_ID = @"userid";

int const BO_EVENT_TYPE_SESSION = 0;
int const BO_EVENT_TYPE_SESSION_WITH_TIME = 1;
int const BO_EVENT_TYPE_PII = 2;
int const BO_EVENT_TYPE_PHI = 3;
int const BO_EVENT_TYPE_START_TIMED_EVENT = 4;
int const BO_EVENT_TYPE_END_TIMED_EVENT = 5;
int const BO_EVENT_TYPE_RETENTION_EVENT = 6;

NSString *BO_EVENT_MAP_ID = @"map_id";
NSString *BO_EVENT_MAP_Provider = @"map_provider";

NSString *BO_EVENT_DATA_POST_API = @"boEventDataPOSTAPI";
NSString *BO_RETENTION_EVENT_DATA_POST_API = @"boRetentionEventDataPOSTAPI";

int const BO_EVENT_SDK_START = 11130;
NSString * const BO_SDK_START= @"sdk_start";

int const BO_EVENT_PAGE_HIDE = 11106;
NSString * const BO_PAGE_HIDE= @"pagehide";

NSString * const BO_EDGE_METADATA= @"edge_metadata";
NSString * const BO_APP_NAMESPACE= @"app_namespace";
NSString * const BO_APP_VERSION= @"app_version";
NSString * const BO_DEVICE_MANUFACTURER= @"device_manufacturer";
NSString * const BO_EVENTS= @"events";
NSString * const BO_EVENTS_TIME= @"evt";
NSString * const BO_EVENT_DAY_OCCURENCE_COUNT= @"evdc";
NSString * const BO_EVENT_CATEGORY= @"evc";
NSString * const BO_EVENT_CATEGORY_SUBTYPE= @"evcs";
NSString * const BO_MESSAGE_ID= @"mid";
NSString * const BO_EVENT_NAME_MAPPING= @"evn";
NSString * const BO_SCREEN_NAME= @"scrn";
NSString * const BO_SCREEN_TO= @"scrto";
NSString * const BO_SCREEN_FROM= @"scrfrm";
NSString * const BO_TST= @"tst";

NSString * const BO_PROPERTIES= @"properties";
NSString * const BO_CODIFIED_INFO= @"codifiedInfo";
NSString * const BO_QUANTITY= @"quantity";
NSString * const BO_OBJECT_TYPE= @"objectType";
NSString * const BO_OBJECT_RECT= @"objectRect";
NSString * const BO_OBJECT_SCREEN_RECT= @"scrRect";

NSString * const BO_VALUE= @"value";
NSString * const BO_NAVIGATION_SCREEN= @"nvg";
NSString * const BO_NAVIGATION_TIME= @"nvg_tm";
NSString * const BO_APP_NAVIGATION= @"appNavigation";
NSString * const BO_AD_IDENTIFIER= @"AdvertisingId";
NSString * const BO_AD_DO_NOT_TRACK= @"AdDoNotTrack";

NSString * const BO_CLIENT_TIMEZONE =@"client_timezone";
NSString * const BO_EVENT_START_PERIOD =@"event_start_period";
NSString * const BO_EVENT_END_PERIOD =@"event_end_period";
NSString * const BO_TOTAL_SEESION_TIME=@"total_session_time";
NSString * const BO_TOTAL_SESSION_COUNT=@"total_session_count";
NSString * const BO_APP_BIRTH =@"app_birth" ;
NSString * const BO_CUSTOM_KEY=@"custom_key";
NSString * const BO_SESSION_ID=@"session_id";


#pragma mark - Event Category
int const BO_EVENT_SYSTEM_KEY = 10001;
int const BO_EVENT_DEVELOPER_CODED_KEY = 20001;
int const BO_EVENT_FUNNEL_KEY = 30001;
int const BO_EVENT_RETENTION_KEY = 40001;
int const BO_EVENT_EXCEPTION_KEY = 50001;
int const BO_EVENT_CAMPAIGN_KEY = 60001;
int const BO_EVENT_SEGMENT_KEY = 70001;


#pragma mark - Event SYSYEM SUB EVENTS

int const BO_EVENT_APP_INSTALLED_KEY= 11001;
int const BO_EVENT_APP_UNINSTALLED_KEY= 11002;
int const BO_EVENT_APP_LAUNCHED_KEY= 11003;
int const BO_EVENT_APP_BACKGROUND_KEY= 11004;
int const BO_EVENT_APP_FOREGROUND_KEY= 11005;
int const BO_EVENT_APP_NOTIFICATION_RECEIVED_KEY= 11006;
int const BO_EVENT_APP_NOTIFICATION_VIEWED_KEY= 11007;
int const BO_EVENT_APP_NOTIFICATION_CLICKED_KEY= 11008;
int const BO_EVENT_APP_PORTRAIT_ORIENTATION_KEY= 11009;
int const BO_EVENT_APP_LANDSCAPE_ORIENTATION_KEY= 11010;
int const BO_EVENT_APP_SESSION_START_KEY= 11011;
int const BO_EVENT_APP_SESSION_END_KEY= 11012;
int const BO_EVENT_APP_CLICK_TAP_KEY= 11013;
int const BO_EVENT_APP_DOUBLE_TAP_KEY= 11014;
int const BO_EVENT_APP_VIEW_KEY= 11015;

int const BO_EVENT_APP_INSTALL_REFERRER = 11016;
int const BO_EVENT_APP_RUN_TIME_EXCEPTION = 11017;
int const BO_EVENT_APP_NAVIGATION = 11019;
int const BO_EVENT_APP_DEVICE_INFO = 11020;
int const BO_EVENT_APP_PERFORMANCE_INFO = 11021;
int const BO_EVENT_APP_DO_NOT_TRACK = 11022;
int const BO_EVENT_APP_DEEP_LINK = 11023;
int const BO_EVENT_APP_SESSION_INFO = 11024;

//Funnel Events
int const BO_FUNNEL_RECEIVED = 31001;
int const BO_FUNNEL_TRIGGERED = 31002;

//Segments
int const BO_SEGMENT_RECEIVED = 71001;
int const BO_SEGMENT_TRIGGERED = 71002;


#pragma mark - Event DEVELOPER CODED SUB EVENTS
int const BO_DEV_EVENT_MAP_ID= 21001;
int const BO_DEV_EVENT_CLICK_TAP_KEY= 21001;
int const BO_DEV_EVENT_DOUBLE_CLICK_TAP_KEY= 21002;
int const BO_DEV_EVENT_VIEW_KEY= 21003;
int const BO_DEV_EVENT_ADD_TO_CART_KEY= 21004;
int const BO_DEV_EVENT_GESTURE_KEY= 21005;
int const BO_DEV_EVENT_SWIPE_UP_KEY= 21006;
int const BO_DEV_EVENT_SWIPE_DOWN_KEY= 21007;
int const BO_DEV_EVENT_SWIPE_LEFT_KEY= 21008;
int const BO_DEV_EVENT_SWIPE_RIGHT_KEY= 21009;
int const BO_DEV_EVENT_DRAG_KEY= 21010;
int const BO_DEV_EVENT_FLICK_KEY= 21011;
int const BO_DEV_EVENT_PINCH_KEY= 21012;
int const BO_DEV_EVENT_LONG_PRESS_KEY= 21013;
int const BO_DEV_EVENT_SHAKE_KEY= 21014;
int const BO_DEV_EVENT_EDGE_PAN_GESTURE_KEY= 21015;
int const BO_DEV_EVENT_CHARGE_TRANSACTION_BUTTON_KEY= 21016;
int const BO_DEV_EVENT_CANCEL_BUTTON_KEY= 21017;
int const BO_DEV_EVENT_APPLY_COUPAN_KEY= 21018;
int const BO_DEV_EVENT_TIMED_KEY= 21019;
int const BO_DEV_EVENT_CUSTOM_KEY= 21100; // asking to change it and start from 21100

#pragma mark - Event RETENTION CODED SUB EVENTS
int const BO_RETEN_DAU_KEY= 41001;
int const BO_RETEN_WAU_KEY= 41002;
int const BO_RETEN_MAU_KEY= 41003;
int const BO_RETEN_DPU_KEY= 41004;
int const BO_RETEN_WPU_KEY= 41005;
int const BO_RETEN_MPU_KEY= 41006;
int const BO_RETEN_APP_INSTALL_KEY= 41007;
int const BO_RETEN_APP_UNINSTALL_KEY= 41008;
int const BO_RETEN_NUO_KEY=  41009;
int const BO_RETEN_DAST_KEY= 41010;
int const BO_RETEN_WAST_KEY= 41011;
int const BO_RETEN_MAST_KEY= 41012;
int const BO_RETEN_CUS_KEY1= 41013;
int const BO_RETEN_CUS_KEY2= 41014;
int const BO_RETEN_CUS_KEY3= 41015;
int const BO_RETEN_CUS_KEY4= 41016;


#pragma mark - Event CAMPAIGN SUB EVENTS
int const BO_CAMP_EVENT_RECEIVED_KEY= 61001;
int const BO_CAMP_EVENT_TRIGGERED_KEY= 61002;
int const BO_CAMP_EVENT_CONVERTED_KEY= 61003;
int const BO_CAMP_EVENT_SYSTEM_NOTIFICATION_SHOW_KEY= 61004;
int const BO_CAMP_EVENT_SYSTEM_NOTIFICATION_CLICK_KEY= 61005;
int const BO_CAMP_EVENT_ALERT_SHOW_KEY= 61006;
int const BO_CAMP_EVENT_ALERT_CLICK_KEY= 61007;
int const BO_CAMP_EVENT_EMAIL_SENT_KEY= 61008;
int const BO_CAMP_EVENT_SMS_SENT_KEY= 61009;

#pragma mark - Developer codified events
NSString * const BO_ADD_TO_CART = @"addToCart";
NSString * const BO_CHARGE_TRANSACTION = @"Transaction";
NSString * const BO_SCREEN_EDGE_PAN = @"screenEdgePan";
NSString * const BO_VIEW = @"view";
NSString * const BO_TOUCH_CLICK = @"touchClick";
NSString * const BO_DRAG = @"drag";
NSString * const BO_FLICK = @"flick";
NSString * const BO_SWIPE = @"swipe";
NSString * const BO_DOUBLE_TAP = @"doubleTap";
NSString * const BO_TWO_FINGER_TAP = @"twoFingerTap";
NSString * const BO_PINCH = @"pinch";
NSString * const BO_TOUCH_AND_HOLD = @"touchAndHold";
NSString * const BO_SHAKE = @"shake";

#pragma mark - App state events
NSString * const BO_APP_LAUNCHED = @"appLaunched";
NSString * const BO_RESIGN_ACTIVE = @"appResignActive";
NSString * const BO_APP_IN_BACKGROUND = @"appInBackground";
NSString * const BO_APP_IN_FOREGROUND = @"appInForeground";
NSString * const BO_APP_ORIENTATION_LANDSCAPE = @"appOrientationLandscape";
NSString * const BO_APP_ORIENTATION_PORTRAIT = @"appOrientationPortrait";
NSString * const BO_APP_NOTIFICATION_RECEIVED = @"appNotificationReceived";
NSString * const BO_APP_NOTIFICATION_VIEWED = @"appNotificationViewed";
NSString * const BO_APP_NOTIFICATION_CLICKED = @"appNotificationClicked";
NSString * const BO_APP_SESSION_INFO = @"appSessionInfo";

#pragma mark - Event retention events
NSString * const BO_RETEN_EVENT_NAME_DAU = @"DAU";
NSString * const BO_RETEN_EVENT_NAME_DPU = @"DPU";
NSString * const BO_RETEN_EVENT_NAME_NUO = @"NUO";
NSString * const BO_RETEN_EVENT_NAME_MAU = @"MAU";
NSString * const BO_RETEN_EVENT_NAME_WAU = @"WAU";
NSString * const BO_RETEN_EVENT_NAME_WPU = @"WPU";
NSString * const BO_RETEN_EVENT_NAME_MPU = @"MPU";
NSString * const BO_RETEN_EVENT_NAME_DAST = @"DAST";
NSString * const BO_RETEN_EVENT_NAME_WAST = @"WAST";
NSString * const BO_RETEN_EVENT_NAME_MAST = @"MAST";

NSString * const BO_EVENT_AD_INFO = @"AdInfo";

#pragma mark - Device Event Name
NSString * const BO_EVENT_MULTITASKING_ENABLED = @"multitaskingEnabled";
NSString * const BO_EVENT_PROXIMITY_SENSOR_ENABLED = @"proximitySensorEnabled";
NSString * const BO_EVENT_DEBUGGER_ATTACHED = @"debuggerAttached";
NSString * const BO_EVENT_PLUGGEDIN = @"pluggedIn";
NSString * const BO_EVENT_JAIL_BROKEN = @"jailBroken";
NSString * const BO_EVENT_NUMBER_OF_ACTIVE_PROCESSORS = @"numberOfActiveProcessors";
NSString * const BO_EVENT_PROCESSORS_USAGE = @"processorsUsage";
NSString * const BO_EVENT_ACCESSORIES_ATTACHED = @"accessoriesAttached";
NSString * const BO_EVENT_HEADPHONE_ATTACHED = @"headphoneAttached";
NSString * const BO_EVENT_NUMBER_OF_ATTACHED_ACCESSORIES = @"numberOfAttachedAccessories";
NSString * const BO_EVENT_NAME_OF_ATTACHED_ACCESSORIES = @"nameOfAttachedAccessories";
NSString * const BO_EVENT_BATTERY_LEVEL = @"batteryLevel";
NSString * const BO_EVENT_IS_CHARGING = @"isCharging";
NSString * const BO_EVENT_FULLY_CHARGED = @"fullyCharged";

#pragma mark - Storage Events
NSString * const BO_EVENT_MEMORY_INFO = @"MemoryInfo";
NSString * const BO_EVENT_STORAGE_INFO = @"StorageInfo";
NSString * const BO_EVENT_UNIT = @"unit";
NSString * const BO_EVENT_TOTAL_DISK_SPACE = @"totalDiskSpace";
NSString * const BO_EVENT_USED_DISK_SPACE = @"usedDiskSpace";
NSString * const BO_EVENT_FREE_DISK_SPACE = @"freeDiskSpace";
NSString * const BO_EVENT_TOTAL_RAM = @"totalRAM";
NSString * const BO_EVENT_USED_MEMORY = @"usedMemory";
NSString * const BO_EVENT_WIRED_MEMORY = @"wiredMemory";
NSString * const BO_EVENT_ACTIVE_MEMORY = @"activeMemory";
NSString * const BO_EVENT_INACTIVE_MEMORY = @"inActiveMemory";
NSString * const BO_EVENT_FREE_MEMORY = @"freeMemory";
NSString * const BO_EVENT_PURGEABLE_MEMORY = @"purgeableMemory";
NSString * const BO_EVENT_AT_MEMORY_WARNING = @"atMemoryWarning";

#pragma mark - PII Data
NSString * const BO_EVENT_CFUU_ID = @"cfUUID";
NSString * const BO_EVENT_VENDOR_ID = @"vendorID";
NSString * const BO_EVENT_CURRENT_IP_ADDRESS = @"currentIPAddress";
NSString * const BO_EVENT_EXTERNAL_IP_ADDRESS = @"externalIPAddress";
NSString * const BO_EVENT_CELL_IP_ADDRESS = @"cellIPAddress";
NSString * const BO_EVENT_CELL_NETMASK = @"cellNetMask";
NSString * const BO_EVENT_CELL_BROADCAST_ADDRESS = @"cellBroadcastAddress";
NSString * const BO_EVENT_WIFI_IP_ADDRESS = @"wifiIPAddress";
NSString * const BO_EVENT_WIFI_NET_MASK = @"wifiNetMask";
NSString * const BO_EVENT_WIFI_BROADCAST_ADDRESS = @"wifiBroadcastAddress";
NSString * const BO_EVENT_WIFI_ROUTER_ADDRESS = @"wifiRouterAddress";
NSString * const BO_EVENT_WIFI_SSID = @"wifiSSID";
NSString * const BO_EVENT_CONNECTED_WIFI = @"connectedToWifi";
NSString * const BO_EVENT_CONNECTED_TO_CELL_NETWORK = @"connectedToCellNetwork";
