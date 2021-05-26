//
//  BOANetworkConstants.h
//  BlotoutAnalytics
//
//  Created by Blotout on 07/08/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark-

extern  NSString *BO_GET;
extern  NSString *BO_POST;
extern  NSString *BO_PUT;
extern  NSString *BO_CONTENT_TYPE;
extern  NSString *BO_APPLICATION_JSON;
extern  NSString *BO_TOKEN;
extern  NSString *BO_ACCEPT;
extern  NSString *BO_VERSION;

extern  NSString *BO_META;
extern  NSString *BO_PMETA;
extern  NSString *BO_GEO;
extern  NSString *BO_KEY;
extern  NSString *BO_DATA;
extern  NSString *BO_IV;
extern  NSString *BO_PII;
extern  NSString *BO_PHI;
extern  NSString *BO_PII_EVENTS;
extern  NSString *BO_PHI_EVENTS;

extern  NSString *BO_TIME_ZONE_OFFSET;
extern  NSString *BO_USER_ID;

extern int const BO_EVENT_TYPE_SESSION;
extern int const BO_EVENT_TYPE_SESSION_WITH_TIME;
extern int const BO_EVENT_TYPE_PII;
extern int const BO_EVENT_TYPE_PHI;
extern int const BO_EVENT_TYPE_START_TIMED_EVENT;
extern int const BO_EVENT_TYPE_END_TIMED_EVENT;
extern int const BO_EVENT_TYPE_RETENTION_EVENT;

extern  NSString *BO_EVENT_MAP_ID;
extern  NSString *BO_EVENT_MAP_Provider;

extern  NSString *BO_EVENT_DATA_POST_API;
extern  NSString *BO_RETENTION_EVENT_DATA_POST_API;

extern int const BO_EVENT_SDK_START;
extern NSString * const BO_SDK_START;

extern NSString * const BO_EDGE_METADATA;
extern NSString * const BO_APP_NAMESPACE;
extern NSString * const BO_APP_VERSION;
extern NSString * const BO_DEVICE_MANUFACTURER;
extern NSString * const BO_EVENTS;
extern NSString * const BO_EVENTS_TIME;
extern NSString * const BO_EVENT_DAY_OCCURENCE_COUNT;
extern NSString * const BO_EVENT_CATEGORY;
extern NSString * const BO_MESSAGE_ID;
extern NSString * const BO_EVENT_CATEGORY_SUBTYPE;
extern NSString * const BO_TST;


extern NSString * const BO_EVENT_NAME_MAPPING;
extern NSString * const BO_SCREEN_NAME;
extern NSString * const BO_SCREEN_FROM;
extern NSString * const BO_SCREEN_TO;
extern NSString * const BO_CODIFIED_INFO;
extern NSString * const BO_QUANTITY;
extern NSString * const BO_OBJECT_TYPE;
extern NSString * const BO_OBJECT_RECT;
extern NSString * const BO_OBJECT_SCREEN_RECT;

extern NSString * const BO_VALUE;
extern NSString * const BO_NAVIGATION_SCREEN;
extern NSString * const BO_NAVIGATION_TIME;
extern NSString * const BO_APP_NAVIGATION;
extern NSString * const BO_AD_IDENTIFIER;
extern NSString * const BO_AD_DO_NOT_TRACK;

extern NSString * const BO_CLIENT_TIMEZONE;
extern NSString * const BO_EVENT_START_PERIOD;
extern NSString * const BO_EVENT_END_PERIOD;
extern NSString * const BO_TOTAL_SEESION_TIME;
extern NSString * const BO_TOTAL_SESSION_COUNT;
extern NSString * const BO_APP_BIRTH;
extern NSString * const BO_CUSTOM_KEY;
extern NSString * const BO_SESSION_ID;
#pragma mark - Event Category
extern int const BO_EVENT_SYSTEM_KEY;
extern int const BO_EVENT_DEVELOPER_CODED_KEY;
extern int const BO_EVENT_FUNNEL_KEY;
extern int const BO_EVENT_RETENTION_KEY;
extern int const BO_EVENT_EXCEPTION_KEY;
extern int const BO_EVENT_CAMPAIGN_KEY;
extern int const BO_EVENT_SEGMENT_KEY;

#pragma mark - Event SUB Category

#pragma mark - Event SYSYEM SUB EVENTS
extern int const BO_EVENT_APP_INSTALLED_KEY;
extern int const BO_EVENT_APP_UNINSTALLED_KEY;
extern int const BO_EVENT_APP_LAUNCHED_KEY;
extern int const BO_EVENT_APP_BACKGROUND_KEY;
extern int const BO_EVENT_APP_FOREGROUND_KEY;
extern int const BO_EVENT_APP_NOTIFICATION_RECEIVED_KEY;
extern int const BO_EVENT_APP_NOTIFICATION_VIEWED_KEY;
extern int const BO_EVENT_APP_NOTIFICATION_CLICKED_KEY;
extern int const BO_EVENT_APP_PORTRAIT_ORIENTATION_KEY;
extern int const BO_EVENT_APP_LANDSCAPE_ORIENTATION_KEY;
extern int const BO_EVENT_APP_SESSION_START_KEY;
extern int const BO_EVENT_APP_SESSION_END_KEY;
extern int const BO_EVENT_APP_CLICK_TAP_KEY;
extern int const BO_EVENT_APP_DOUBLE_TAP_KEY;
extern int const BO_EVENT_APP_VIEW_KEY;

extern int const BO_EVENT_APP_INSTALL_REFERRER;
extern int const BO_EVENT_APP_RUN_TIME_EXCEPTION;

extern int const BO_EVENT_APP_NAVIGATION;
extern int const BO_EVENT_APP_DEVICE_INFO;
extern int const BO_EVENT_APP_PERFORMANCE_INFO;
extern int const BO_EVENT_APP_DO_NOT_TRACK;
extern int const BO_EVENT_APP_DEEP_LINK;
extern int const BO_EVENT_APP_SESSION_INFO;

extern int const BO_FUNNEL_RECEIVED;
extern int const BO_FUNNEL_TRIGGERED;
extern int const BO_SEGMENT_RECEIVED;
extern int const BO_SEGMENT_TRIGGERED;

#pragma mark - Event DEVELOPER CODED SUB EVENTS
extern int const BO_DEV_EVENT_MAP_ID;
extern int const BO_DEV_EVENT_CLICK_TAP_KEY;
extern int const BO_DEV_EVENT_DOUBLE_CLICK_TAP_KEY;
extern int const BO_DEV_EVENT_VIEW_KEY;
extern int const BO_DEV_EVENT_ADD_TO_CART_KEY;
extern int const BO_DEV_EVENT_GESTURE_KEY;
extern int const BO_DEV_EVENT_SWIPE_UP_KEY;
extern int const BO_DEV_EVENT_SWIPE_DOWN_KEY;
extern int const BO_DEV_EVENT_SWIPE_LEFT_KEY;
extern int const BO_DEV_EVENT_SWIPE_RIGHT_KEY;
extern int const BO_DEV_EVENT_DRAG_KEY;
extern int const BO_DEV_EVENT_FLICK_KEY;
extern int const BO_DEV_EVENT_PINCH_KEY;
extern int const BO_DEV_EVENT_LONG_PRESS_KEY;
extern int const BO_DEV_EVENT_SHAKE_KEY;
extern int const BO_DEV_EVENT_EDGE_PAN_GESTURE_KEY;
extern int const BO_DEV_EVENT_CHARGE_TRANSACTION_BUTTON_KEY;
extern int const BO_DEV_EVENT_CANCEL_BUTTON_KEY;
extern int const BO_DEV_EVENT_APPLY_COUPAN_KEY;
extern int const BO_DEV_EVENT_CUSTOM_KEY;
extern int const BO_DEV_EVENT_TIMED_KEY;

#pragma mark - Event RETENTION CODED SUB EVENTS
extern int const BO_RETEN_DAU_KEY;
extern int const BO_RETEN_WAU_KEY;
extern int const BO_RETEN_MAU_KEY;
extern int const BO_RETEN_DPU_KEY;
extern int const BO_RETEN_WPU_KEY;
extern int const BO_RETEN_MPU_KEY;
extern int const BO_RETEN_APP_INSTALL_KEY;
extern int const BO_RETEN_APP_UNINSTALL_KEY;
extern int const BO_RETEN_NUO_KEY;
extern int const BO_RETEN_DAST_KEY;
extern int const BO_RETEN_WAST_KEY;
extern int const BO_RETEN_MAST_KEY;
extern int const BO_RETEN_CUS_KEY1;
extern int const BO_RETEN_CUS_KEY2;
extern int const BO_RETEN_CUS_KEY3;
extern int const BO_RETEN_CUS_KEY4;


#pragma mark - Event CAMPAIGN SUB EVENTS
extern int const BO_CAMP_EVENT_RECEIVED_KEY;
extern int const BO_CAMP_EVENT_TRIGGERED_KEY;
extern int const BO_CAMP_EVENT_CONVERTED_KEY;
extern int const BO_CAMP_EVENT_SYSTEM_NOTIFICATION_SHOW_KEY;
extern int const BO_CAMP_EVENT_SYSTEM_NOTIFICATION_CLICK_KEY;
extern int const BO_CAMP_EVENT_ALERT_SHOW_KEY;
extern int const BO_CAMP_EVENT_ALERT_CLICK_KEY;
extern int const BO_CAMP_EVENT_EMAIL_SENT_KEY;
extern int const BO_CAMP_EVENT_SMS_SENT_KEY;

extern NSString * const BO_ADD_TO_CART;
extern NSString * const BO_CHARGE_TRANSACTION;
extern NSString * const BO_SCREEN_EDGE_PAN;
extern NSString * const BO_VIEW;
extern NSString * const BO_TOUCH_CLICK;
extern NSString * const BO_DRAG;
extern NSString * const BO_FLICK;
extern NSString * const BO_SWIPE;
extern NSString * const BO_DOUBLE_TAP;
extern NSString * const BO_TWO_FINGER_TAP;
extern NSString * const BO_PINCH;
extern NSString * const BO_TOUCH_AND_HOLD;
extern NSString * const BO_SHAKE;

//APPSTATE Events
extern NSString * const BO_APP_LAUNCHED;
extern NSString * const BO_RESIGN_ACTIVE;
extern NSString * const BO_APP_IN_BACKGROUND;
extern NSString * const BO_APP_IN_FOREGROUND;
extern NSString * const BO_APP_ORIENTATION_LANDSCAPE;
extern NSString * const BO_APP_ORIENTATION_PORTRAIT;
extern NSString * const BO_APP_NOTIFICATION_RECEIVED;
extern NSString * const BO_APP_NOTIFICATION_VIEWED;
extern NSString * const BO_APP_NOTIFICATION_CLICKED;


#pragma mark - Developer codified events
extern NSString * const BO_ADD_TO_CART;
extern NSString * const BO_CHARGE_TRANSACTION;
extern NSString * const BO_SCREEN_EDGE_PAN;
extern NSString * const BO_VIEW;
extern NSString * const BO_CLIENT_TIMEZONE;
extern NSString * const BO_TOUCH_CLICK;
extern NSString * const BO_DRAG;
extern NSString * const BO_FLICK;
extern NSString * const BO_SWIPE;
extern NSString * const BO_DOUBLE_TAP;
extern NSString * const BO_TWO_FINGER_TAP;
extern NSString * const BO_PINCH;
extern NSString * const BO_TOUCH_AND_HOLD;
extern NSString * const BO_SHAKE;


#pragma mark - App state events
//extern NSString * const BO_APP_LAUNCHED;
//extern NSString * const BO_APP_IN_BACKGROUND;
//extern NSString * const BO_APP_IN_FOREGROUND;
extern NSString * const BO_APP_ORIENTATION_LANDSCAPE;
extern NSString * const BO_APP_ORIENTATION_PORTRAIT;
extern NSString * const BO_APP_NOTIFICATION_RECEIVED;
extern NSString * const BO_APP_NOTIFICATION_VIEWED;
extern NSString * const BO_APP_NOTIFICATION_CLICKED;
extern NSString * const BO_APP_SESSION_INFO;
#pragma mark - Event retention events
extern NSString * const BO_RETEN_EVENT_NAME_DAU;
extern NSString * const BO_RETEN_EVENT_NAME_DPU;
extern NSString * const BO_RETEN_EVENT_NAME_NUO;
extern NSString * const BO_RETEN_EVENT_NAME_MAU;
extern NSString * const BO_RETEN_EVENT_NAME_WAU;
extern NSString * const BO_RETEN_EVENT_NAME_WPU;
extern NSString * const BO_RETEN_EVENT_NAME_MPU;
extern NSString * const BO_RETEN_EVENT_NAME_DAST;
extern NSString * const BO_RETEN_EVENT_NAME_WAST;
extern NSString * const BO_RETEN_EVENT_NAME_MAST;

extern NSString * const BO_EVENT_AD_INFO;


//Device Event Name
extern NSString * const BO_EVENT_MULTITASKING_ENABLED;
extern NSString * const BO_EVENT_PROXIMITY_SENSOR_ENABLED;
extern NSString * const BO_EVENT_DEBUGGER_ATTACHED;
extern NSString * const BO_EVENT_PLUGGEDIN;
extern NSString * const BO_EVENT_JAIL_BROKEN;
extern NSString * const BO_EVENT_NUMBER_OF_ACTIVE_PROCESSORS;
extern NSString * const BO_EVENT_PROCESSORS_USAGE;
extern NSString * const BO_EVENT_ACCESSORIES_ATTACHED;
extern NSString * const BO_EVENT_HEADPHONE_ATTACHED;
extern NSString * const BO_EVENT_NUMBER_OF_ATTACHED_ACCESSORIES;
extern NSString * const BO_EVENT_NAME_OF_ATTACHED_ACCESSORIES;
extern NSString * const BO_EVENT_BATTERY_LEVEL;
extern NSString * const BO_EVENT_IS_CHARGING;
extern NSString * const BO_EVENT_FULLY_CHARGED;

//Storage Events
extern NSString * const BO_EVENT_MEMORY_INFO;
extern NSString * const BO_EVENT_STORAGE_INFO;
extern NSString * const BO_EVENT_UNIT;
extern NSString * const BO_EVENT_TOTAL_DISK_SPACE;
extern NSString * const BO_EVENT_USED_DISK_SPACE;
extern NSString * const BO_EVENT_FREE_DISK_SPACE;
extern NSString * const BO_EVENT_TOTAL_RAM;
extern NSString * const BO_EVENT_USED_MEMORY;
extern NSString * const BO_EVENT_WIRED_MEMORY;
extern NSString * const BO_EVENT_ACTIVE_MEMORY;
extern NSString * const BO_EVENT_INACTIVE_MEMORY;
extern NSString * const BO_EVENT_FREE_MEMORY;
extern NSString * const BO_EVENT_PURGEABLE_MEMORY;
extern NSString * const BO_EVENT_AT_MEMORY_WARNING;

//PII DATA
extern NSString * const BO_EVENT_CFUU_ID;
extern NSString * const BO_EVENT_VENDOR_ID;
extern NSString * const BO_EVENT_CURRENT_IP_ADDRESS;
extern NSString * const BO_EVENT_EXTERNAL_IP_ADDRESS;
extern NSString * const BO_EVENT_CELL_IP_ADDRESS;
extern NSString * const BO_EVENT_CELL_NETMASK;
extern NSString * const BO_EVENT_CELL_BROADCAST_ADDRESS;
extern NSString * const BO_EVENT_WIFI_IP_ADDRESS;
extern NSString * const BO_EVENT_WIFI_NET_MASK;
extern NSString * const BO_EVENT_WIFI_BROADCAST_ADDRESS;
extern NSString * const BO_EVENT_WIFI_ROUTER_ADDRESS;
extern NSString * const BO_EVENT_WIFI_SSID;
extern NSString * const BO_EVENT_CONNECTED_WIFI;
extern NSString * const BO_EVENT_CONNECTED_TO_CELL_NETWORK;

NS_ASSUME_NONNULL_END
