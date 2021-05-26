// To parse this JSON:
//
//   NSError *error;
//   BOAppSessionData *appSessionData = [BOAppSessionData fromJSON:json encoding:NSUTF8Encoding error:&error];

#import <Foundation/Foundation.h>

@class BOAppSessionData;
@class BOSingleDaySessions;
@class BOAppInfo;
@class BOCurrentLocation;
@class BOAppStates;
@class BOApp;
@class BOCrashDetail;
@class BODeveloperCodified;
@class BOAddToCart;
@class BOChargeTransaction;
@class BOCustomEvent;
@class BODoubleTap;
@class BOScreenRect;
@class BOListUpdated;
@class BOScreenEdgePan;
@class BOTimedEvent;
@class BOView;
@class BODeviceInfo;
@class BOAccessoriesAttached;
@class BOBatteryLevel;
@class BOCFUUID;
@class BODeviceOrientation;
@class BONameOfAttachedAccessory;
@class BONumberOfA;
@class BOProcessorsUsage;
@class BOVendorID;
@class BOLocation;
@class BONonPIILocation;
@class BOPiiLocation;
@class BOMemoryInfo;
@class BONetworkInfo;
@class BOBroadcastAddress;
@class BOIPAddress;
@class BONetMask;
@class BOConnectedTo;
@class BOWifiRouterAddress;
@class BOWifiSSID;
@class BORetentionEvent;
@class BOAppInstalled;
@class BODast;
@class BODau;
@class BODpu;
@class BONewUser;
@class BOStorageInfo;
@class BOUbiAutoDetected;
@class BOAppGesture;
@class BOAppNavigation;
@class BOScreenShotsTaken;
@class BOCommonEvent;
@class BOAdInfo;
@class BOSessionInfo;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface BOAppSessionData : NSObject
@property (nonatomic, nullable, copy)   NSString *appBundle;
@property (nonatomic, nullable, copy)   NSString *date;
@property (nonatomic, nullable, strong) BOSingleDaySessions *singleDaySessions;


+ (instancetype)sharedInstanceFromJSONDictionary:(nullable NSDictionary *)dict;
+ (void)resetDailySessionSharedInstanceToken;
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error;
- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
- (NSData *_Nullable)toData:(NSError *_Nullable *)error;
- (NSDictionary *)JSONDictionary;
@end

@interface BOSingleDaySessions : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSArray<NSNumber *> *systemUptime;
@property (nonatomic, nullable, strong) NSNumber *lastServerSyncTimeStamp;
@property (nonatomic, nullable, strong) NSNumber *allEventsSyncTimeStamp;
@property (nonatomic, nullable, copy)   NSArray<BOAppInfo *> *appInfo;
@property (nonatomic, nullable, strong) BOUbiAutoDetected *ubiAutoDetected;
@property (nonatomic, nullable, strong) BODeveloperCodified *developerCodified;
@property (nonatomic, nullable, strong) BOAppStates *appStates;
@property (nonatomic, nullable, strong) BODeviceInfo *deviceInfo;
@property (nonatomic, nullable, strong) BONetworkInfo *networkInfo;
@property (nonatomic, nullable, copy)   NSArray<BOStorageInfo *> *storageInfo;
@property (nonatomic, nullable, copy)   NSArray<BOMemoryInfo *> *memoryInfo;
@property (nonatomic, nullable, copy)   NSArray<BOLocation *> *location;
@property (nonatomic, nullable, copy)   NSArray<BOCrashDetail *> *crashDetails;
@property (nonatomic, nullable, copy)   NSArray<BOCommonEvent *> *commonEvents;
@property (nonatomic, nullable, copy)   NSArray<BOAdInfo *> *adInfo;

@property (nonatomic, nullable, strong) BORetentionEvent *retentionEvent;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAppInfo : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSString *version;
@property (nonatomic, nullable, strong) NSNumber *platform;
@property (nonatomic, nullable, copy)   NSString *osName;
@property (nonatomic, nullable, copy)   NSString *osVersion;
@property (nonatomic, nullable, copy)   NSString *deviceMft;
@property (nonatomic, nullable, copy)   NSString *deviceModel;
@property (nonatomic, nullable, copy)   NSString *sdkVersion;
@property (nonatomic, nullable, copy)   NSString *timeZoneOffset;
@property (nonatomic, nullable, strong) NSNumber *vpnStatus;
@property (nonatomic, nullable, strong) NSNumber *jbnStatus;
@property (nonatomic, nullable, strong) NSNumber *dcompStatus;
@property (nonatomic, nullable, strong) NSNumber *acompStatus;
@property (nonatomic, nullable, copy)   NSString *name;
@property (nonatomic, nullable, copy)   NSString *bundle;
@property (nonatomic, nullable, copy)   NSString *language;
@property (nonatomic, nullable, strong) NSNumber *launchTimeStamp;
@property (nonatomic, nullable, strong) NSNumber *terminationTimeStamp;
@property (nonatomic, nullable, strong) NSNumber *sessionsDuration;
@property (nonatomic, nullable, strong) NSNumber *averageSessionsDuration;
@property (nonatomic, nullable, copy)   NSString *launchReason;
@property (nonatomic, nullable, strong) BOCurrentLocation *currentLocation;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
@end

@interface BOCurrentLocation : NSObject
@property (nonatomic, nullable, copy) NSString *city;
@property (nonatomic, nullable, copy) NSString *state;
@property (nonatomic, nullable, copy) NSString *country;
@property (nonatomic, nullable, copy) NSString *zip;
@property (nonatomic, nullable, copy) NSString *continentCode;
@property (nonatomic, nullable, strong) NSNumber *latitude;
@property (nonatomic, nullable, strong) NSNumber *longitude;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAppStates : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSArray<BOApp *> *appLaunched;
@property (nonatomic, nullable, copy)   NSArray<BOApp *> *appActive;
@property (nonatomic, nullable, copy)   NSArray<BOApp *> *appResignActive;
@property (nonatomic, nullable, copy)   NSArray<BOApp *> *appInBackground;
@property (nonatomic, nullable, copy)   NSArray<BOApp *> *appInForeground;
@property (nonatomic, nullable, copy)   NSArray<BOApp *> *appBackgroundRefreshAvailable;
@property (nonatomic, nullable, copy)   NSArray<BOApp *> *appReceiveMemoryWarning;
@property (nonatomic, nullable, copy)   NSArray<BOApp *> *appSignificantTimeChange;
@property (nonatomic, nullable, copy)   NSArray<BOApp *> *appOrientationPortrait;
@property (nonatomic, nullable, copy)   NSArray<BOApp *> *appOrientationLandscape;
@property (nonatomic, nullable, copy)   NSArray<BOApp *> *appStatusbarFrameChange;
@property (nonatomic, nullable, copy)   NSArray<BOApp *> *appBackgroundRefreshStatusChange;
@property (nonatomic, nullable, copy)   NSArray<BOApp *> *appNotificationReceived;
@property (nonatomic, nullable, copy)   NSArray<BOApp *> *appNotificationViewed;
@property (nonatomic, nullable, copy)   NSArray<BOApp *> *appNotificationClicked;
@property (nonatomic, nullable, copy)   NSArray<BOSessionInfo *> *appSessionInfo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOSessionInfo : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, strong) NSNumber *start;
@property (nonatomic, nullable, strong) NSNumber *end;
@property (nonatomic, nullable, strong) NSNumber *duration;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOApp : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSString *visibleClassName;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOCrashDetail : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSString *name;
@property (nonatomic, nullable, copy)   NSString *reason;
@property (nonatomic, nullable, copy)   NSDictionary<NSString *, NSString *> *info;
@property (nonatomic, nullable, copy)   NSArray<NSString *> *callStackSymbols;
@property (nonatomic, nullable, copy)   NSArray<NSNumber *> *callStackReturnAddress;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BODeveloperCodified : NSObject
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *touchClick;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *drag;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *flick;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *swipe;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *doubleTap;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *moreThanDoubleTap;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *twoFingerTap;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *moreThanTwoFingerTap;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *pinch;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *touchAndHold;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *shake;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *rotate;
@property (nonatomic, nullable, copy) NSArray<BOScreenEdgePan *> *screenEdgePan;
@property (nonatomic, nullable, copy) NSArray<BOView *> *view;
@property (nonatomic, nullable, copy) NSArray<BOAddToCart *> *addToCart;
@property (nonatomic, nullable, copy) NSArray<BOChargeTransaction *> *chargeTransaction;
@property (nonatomic, nullable, copy) NSArray<BOListUpdated *> *listUpdated;
@property (nonatomic, nullable, copy) NSArray<BOTimedEvent *> *timedEvent;
@property (nonatomic, nullable, copy) NSArray<BOCustomEvent *> *customEvents;
@property (nonatomic, nullable, copy) NSArray<BOCustomEvent *> *piiEvents;
@property (nonatomic, nullable, copy) NSArray<BOCustomEvent *> *phiEvents;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAddToCart : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSString *cartClassName;
@property (nonatomic, nullable, copy)   NSDictionary<NSString *, NSString *> *additionalInfo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOChargeTransaction : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSString *transactionClassName;
@property (nonatomic, nullable, copy)   NSDictionary<NSString *, NSString *> *transactionInfo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOCustomEvent : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSString *eventName;
@property (nonatomic, nullable, strong) NSNumber *eventSubCode;
@property (nonatomic, nullable, copy)   NSString *visibleClassName;
@property (nonatomic, nullable, copy)   NSDictionary<NSString *, NSString *> *eventInfo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BODoubleTap : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSString *objectType;
@property (nonatomic, nullable, copy)   NSString *visibleClassName;
@property (nonatomic, nullable, copy)   NSDictionary<NSString *, NSNumber *> *objectRect;
@property (nonatomic, nullable, strong) BOScreenRect *screenRect;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOScreenRect : NSObject
@property (nonatomic, nullable, strong) NSNumber *screenX;
@property (nonatomic, nullable, strong) NSNumber *screenY;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOListUpdated : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSString *listClassName;
@property (nonatomic, nullable, copy)   NSDictionary<NSString *, NSString *> *updatesInfo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOScreenEdgePan : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSString *objectType;
@property (nonatomic, nullable, copy)   NSString *visibleClassName;
@property (nonatomic, nullable, strong) BOScreenRect *screenRectFrom;
@property (nonatomic, nullable, strong) BOScreenRect *screenRectTo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOTimedEvent : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSString *eventName;
@property (nonatomic, nullable, strong) NSNumber *startTime;
@property (nonatomic, nullable, copy)   NSString *startVisibleClassName;
@property (nonatomic, nullable, copy)   NSString *endVisibleClassName;
@property (nonatomic, nullable, strong) NSNumber *endTime;
@property (nonatomic, nullable, strong) NSNumber *eventDuration;
@property (nonatomic, nullable, copy)   NSDictionary<NSString *, NSString *> *timedEvenInfo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOView : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSString *viewClassName;
@property (nonatomic, nullable, copy)   NSDictionary<NSString *, NSString *> *viewInfo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BODeviceInfo : NSObject
@property (nonatomic, nullable, copy) NSArray<BOAccessoriesAttached *> *multitaskingEnabled;
@property (nonatomic, nullable, copy) NSArray<BOAccessoriesAttached *> *proximitySensorEnabled;
@property (nonatomic, nullable, copy) NSArray<BOAccessoriesAttached *> *debuggerAttached;
@property (nonatomic, nullable, copy) NSArray<BOAccessoriesAttached *> *pluggedIn;
@property (nonatomic, nullable, copy) NSArray<BOAccessoriesAttached *> *jailBroken;
@property (nonatomic, nullable, copy) NSArray<BONumberOfA *> *numberOfActiveProcessors;
@property (nonatomic, nullable, copy) NSArray<BOProcessorsUsage *> *processorsUsage;
@property (nonatomic, nullable, copy) NSArray<BOAccessoriesAttached *> *accessoriesAttached;
@property (nonatomic, nullable, copy) NSArray<BOAccessoriesAttached *> *headphoneAttached;
@property (nonatomic, nullable, copy) NSArray<BONumberOfA *> *numberOfAttachedAccessories;
@property (nonatomic, nullable, copy) NSArray<BONameOfAttachedAccessory *> *nameOfAttachedAccessories;
@property (nonatomic, nullable, copy) NSArray<BOBatteryLevel *> *batteryLevel;
@property (nonatomic, nullable, copy) NSArray<BOAccessoriesAttached *> *isCharging;
@property (nonatomic, nullable, copy) NSArray<BOAccessoriesAttached *> *fullyCharged;
@property (nonatomic, nullable, copy) NSArray<BODeviceOrientation *> *deviceOrientation;
@property (nonatomic, nullable, copy) NSArray<BOCFUUID *> *cfUUID;
@property (nonatomic, nullable, copy) NSArray<BOVendorID *> *vendorID;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAccessoriesAttached : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *status;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOBatteryLevel : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *percentage;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOCFUUID : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, copy)   NSString *cfUUID;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BODeviceOrientation : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, copy)   NSString *orientation;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BONameOfAttachedAccessory : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, copy)   NSArray<NSString *> *names;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BONumberOfA : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *number;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOProcessorsUsage : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *processorID;
@property (nonatomic, nullable, strong) NSNumber *usagePercentage;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOVendorID : NSObject
@property (nonatomic, nullable, copy)   NSString *vendorID;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOLocation : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, strong) BOPiiLocation *piiLocation;
@property (nonatomic, nullable, strong) BONonPIILocation *nonPIILocation;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BONonPIILocation : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, copy)   NSString *city;
@property (nonatomic, nullable, copy)   NSString *state;
@property (nonatomic, nullable, copy)   NSString *zip;
@property (nonatomic, nullable, copy)   NSString *country;
@property (nonatomic, nullable, copy)   NSString *activity;
@property (nonatomic, nullable, copy)   NSString *source;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOPiiLocation : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, copy)   NSString *latitude;
@property (nonatomic, nullable, copy)   NSString *longitude;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOMemoryInfo : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, strong) NSNumber *totalRAM;
@property (nonatomic, nullable, strong) NSNumber *usedMemory;
@property (nonatomic, nullable, strong) NSNumber *wiredMemory;
@property (nonatomic, nullable, strong) NSNumber *activeMemory;
@property (nonatomic, nullable, strong) NSNumber *inActiveMemory;
@property (nonatomic, nullable, strong) NSNumber *freeMemory;
@property (nonatomic, nullable, strong) NSNumber *purgeableMemory;
@property (nonatomic, nullable, strong) NSNumber *atMemoryWarning;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BONetworkInfo : NSObject
@property (nonatomic, nullable, copy) NSArray<BOIPAddress *> *currentIPAddress;
@property (nonatomic, nullable, copy) NSArray<BOIPAddress *> *externalIPAddress;
@property (nonatomic, nullable, copy) NSArray<BOIPAddress *> *cellIPAddress;
@property (nonatomic, nullable, copy) NSArray<BONetMask *> *cellNetMask;
@property (nonatomic, nullable, copy) NSArray<BOBroadcastAddress *> *cellBroadcastAddress;
@property (nonatomic, nullable, copy) NSArray<BOIPAddress *> *wifiIPAddress;
@property (nonatomic, nullable, copy) NSArray<BONetMask *> *wifiNetMask;
@property (nonatomic, nullable, copy) NSArray<BOBroadcastAddress *> *wifiBroadcastAddress;
@property (nonatomic, nullable, copy) NSArray<BOWifiRouterAddress *> *wifiRouterAddress;
@property (nonatomic, nullable, copy) NSArray<BOWifiSSID *> *wifiSSID;
@property (nonatomic, nullable, copy) NSArray<BOConnectedTo *> *connectedToWifi;
@property (nonatomic, nullable, copy) NSArray<BOConnectedTo *> *connectedToCellNetwork;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOBroadcastAddress : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, copy)   NSString *broadcastAddress;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOIPAddress : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, copy)   NSString *ipAddress;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BONetMask : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, copy)   NSString *netmask;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOConnectedTo : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *isConnected;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOWifiRouterAddress : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, copy)   NSString *routerAddress;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOWifiSSID : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, copy)   NSString *ssid;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BORetentionEvent : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) BODau *dau;
@property (nonatomic, nullable, strong) BODpu *dpu;
@property (nonatomic, nullable, strong) BOAppInstalled *appInstalled;
@property (nonatomic, nullable, strong) BONewUser *theNewUser;
@property (nonatomic, nullable, strong) BODast *dast;
@property (nonatomic, nullable, copy)   NSArray<BOCustomEvent *> *customEvents;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAppInstalled : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *isFirstLaunch;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSDictionary<NSString *, NSString *> *appInstalledInfo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BODast : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, strong) NSNumber *averageSessionTime;
@property (nonatomic, nullable, copy)   NSDictionary<NSString *, NSString *> *payload;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BODau : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSDictionary<NSString *, NSString *> *dauInfo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BODpu : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSDictionary<NSString *, NSString *> *dpuInfo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BONewUser : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *isNewUser;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSDictionary<NSString *, NSString *> *theNewUserInfo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOStorageInfo : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSString *unit;
@property (nonatomic, nullable, copy)   NSString *totalDiskSpace;
@property (nonatomic, nullable, copy)   NSString *usedDiskSpace;
@property (nonatomic, nullable, copy)   NSString *freeDiskSpace;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOUbiAutoDetected : NSObject
@property (nonatomic, nullable, copy)   NSArray<BOScreenShotsTaken *> *screenShotsTaken;
@property (nonatomic, nullable, copy)   NSArray<BOAppNavigation *> *appNavigation;
@property (nonatomic, nullable, strong) BOAppGesture *appGesture;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAppGesture : NSObject
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *touchOrClick;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *drag;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *flick;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *swipe;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *doubleTap;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *moreThanDoubleTap;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *twoFingerTap;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *moreThanTwoFingerTap;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *pinch;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *touchAndHold;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *shake;
@property (nonatomic, nullable, copy) NSArray<BODoubleTap *> *rotate;
@property (nonatomic, nullable, copy) NSArray<BOScreenEdgePan *> *screenEdgePan;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAppNavigation : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSString *from;
@property (nonatomic, nullable, copy)   NSString *to;
@property (nonatomic, nullable, copy)   NSString *action;
@property (nonatomic, nullable, copy)   NSString *actionObject;
@property (nonatomic, nullable, copy)   NSString *actionObjectTitle;
@property (nonatomic, nullable, strong) NSNumber *actionTime;
@property (nonatomic, nullable, strong) NSNumber *networkIndicatorVisible;
@property (nonatomic, nullable, strong) NSNumber *timeSpent;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;

@end

@interface BOScreenShotsTaken : NSObject
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, copy)   NSString *currentView;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, strong) NSNumber *sentToServer;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOCommonEvent : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *eventCode;
@property (nonatomic, nullable, strong) NSNumber *eventSubCode;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSDictionary *eventInfo;
@property (nonatomic, nullable, copy)   NSString *eventName;
@property (nonatomic, nullable, copy)   NSString *visibleClassName;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAdInfo : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSString *advertisingId;
@property (nonatomic, nullable, strong) NSNumber *isAdDoNotTrack;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end


NS_ASSUME_NONNULL_END
