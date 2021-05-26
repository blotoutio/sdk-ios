// To parse this JSON:
//
//   NSError *error;
//   BOAAppLifetimeData *appLifetimeData = [BOAAppLifetimeData fromJSON:json encoding:NSUTF8Encoding error:&error];

#import <Foundation/Foundation.h>

@class BOAAppLifetimeData;
@class BOAAppLifeTimeInfo;
@class BOAAppInfo;
@class BOAAppLanguagesSupported;
@class BOAAppLaunchInfo;
@class BOABlotoutSDKsInfo;
@class BOADeviceInfo;
@class BOAOtherID;
@class BOAProcessorsUsage;
@class BOALocation;
@class BOANonPIILocation;
@class BOAPiiLocation;
@class BOAMemoryInfo;
@class BOANetworkInfo;
@class BOARetentionEvent;
@class BOAAppInstalled;
@class BOACustomEvents;
@class BOAAST;
@class BOADau;
@class BOADpu;
@class BOAMau;
@class BOAMPU;
@class BOANewUser;
@class BOAWau;
@class BOAWpu;
@class BOAStorageInfo;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface BOAAppLifetimeData : NSObject
@property (nonatomic, nullable, copy) NSString *appBundle;
@property (nonatomic, nullable, copy) NSString *appID;
@property (nonatomic, nullable, copy) NSString *date;
@property (nonatomic, nullable, strong) NSNumber *lastServerSyncTimeStamp;
@property (nonatomic, nullable, strong) NSNumber *allEventsSyncTimeStamp;
@property (nonatomic, nullable, copy) NSArray<BOAAppLifeTimeInfo *> *appLifeTimeInfo;

+ (instancetype)sharedInstanceFromJSONDictionary:(nullable NSDictionary *)dict;
+ (void)resetLifeTimeSharedInstanceToken;
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error;
- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
- (NSData *_Nullable)toData:(NSError *_Nullable *)error;
@end

@interface BOAAppLifeTimeInfo : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *dateAndTime;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, strong) BOAAppInfo *appInstallInfo;
@property (nonatomic, nullable, strong) BOAAppInfo *appUpdatesInfo;
@property (nonatomic, nullable, strong) BOAAppLaunchInfo *appLaunchInfo;
@property (nonatomic, nullable, strong) BOABlotoutSDKsInfo *blotoutSDKsInfo;
@property (nonatomic, nullable, copy)   NSArray<BOAAppLanguagesSupported *> *appLanguagesSupported;
@property (nonatomic, nullable, strong) NSNumber *appSupportShakeToEdit;
@property (nonatomic, nullable, strong) NSNumber *appSupportRemoteNotifications;
@property (nonatomic, nullable, copy)   NSArray<NSString *> *appCategory;
@property (nonatomic, nullable, strong) BOADeviceInfo *deviceInfo;
@property (nonatomic, nullable, strong) BOANetworkInfo *networkInfo;
@property (nonatomic, nullable, strong) BOAStorageInfo *storageInfo;
@property (nonatomic, nullable, strong) BOAMemoryInfo *memoryInfo;
@property (nonatomic, nullable, strong) BOALocation *location;
@property (nonatomic, nullable, strong) BOARetentionEvent *retentionEvent;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAAppInfo : NSObject
@property (nonatomic, nullable, copy) NSString *appVersion;
@property (nonatomic, nullable, copy) NSString *appName;
@property (nonatomic, nullable, copy) NSString *appBundle;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAAppLanguagesSupported : NSObject
@property (nonatomic, nullable, copy) NSString *languageName;
@property (nonatomic, nullable, copy) NSString *languageCode;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAAppLaunchInfo : NSObject
@property (nonatomic, nullable, copy) NSString *appVersion;
@property (nonatomic, nullable, copy) NSString *launchReason;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOABlotoutSDKsInfo : NSObject
@property (nonatomic, nullable, copy) NSString *sdkVersion;
@property (nonatomic, nullable, copy) NSString *sdkName;
@property (nonatomic, nullable, copy) NSString *sdkBundle;
@property (nonatomic, nullable, copy) NSString *appVersion;
@property (nonatomic, nullable, copy) NSString *appName;
@property (nonatomic, nullable, copy) NSString *appBundle;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOADeviceInfo : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, strong) NSNumber *multitaskingEnabled;
@property (nonatomic, nullable, strong) NSNumber *proximitySensorEnabled;
@property (nonatomic, nullable, strong) NSNumber *debuggerAttached;
@property (nonatomic, nullable, strong) NSNumber *pluggedIn;
@property (nonatomic, nullable, strong) NSNumber *jailBroken;
@property (nonatomic, nullable, strong) NSNumber *numberOfActiveProcessors;
@property (nonatomic, nullable, copy)   NSArray<BOAProcessorsUsage *> *processorsUsage;
@property (nonatomic, nullable, strong) NSNumber *accessoriesAttached;
@property (nonatomic, nullable, strong) NSNumber *headphoneAttached;
@property (nonatomic, nullable, strong) NSNumber *numberOfAttachedAccessories;
@property (nonatomic, nullable, copy)   NSArray<NSString *> *nameOfAttachedAccessories;
@property (nonatomic, nullable, strong) NSNumber *batteryLevelPercentage;
@property (nonatomic, nullable, strong) NSNumber *isCharging;
@property (nonatomic, nullable, strong) NSNumber *fullyCharged;
@property (nonatomic, nullable, copy)   NSString *deviceOrientation;
@property (nonatomic, nullable, copy)   NSString *cfUUID;
@property (nonatomic, nullable, copy)   NSString *vendorID;
@property (nonatomic, nullable, copy)   NSString *deviceModel;
@property (nonatomic, nullable, copy)   NSString *deviceName;
@property (nonatomic, nullable, copy)   NSString *systemName;
@property (nonatomic, nullable, copy)   NSString *systemVersion;
@property (nonatomic, nullable, copy)   NSString *systemDeviceTypeUnformatted;
@property (nonatomic, nullable, copy)   NSString *systemDeviceTypeFormatted;
@property (nonatomic, nullable, copy)   NSString *deviceScreenWidth;
@property (nonatomic, nullable, copy)   NSString *deviceScreenHeight;
@property (nonatomic, nullable, copy)   NSString *appUIWidth;
@property (nonatomic, nullable, copy)   NSString *appUIHeight;
@property (nonatomic, nullable, copy)   NSString *screenBrightness;
@property (nonatomic, nullable, strong) NSNumber *stepCountingAvailable;
@property (nonatomic, nullable, strong) NSNumber *distanceAvailbale;
@property (nonatomic, nullable, strong) NSNumber *floorCountingAvailable;
@property (nonatomic, nullable, strong) NSNumber *numberOfProcessors;
@property (nonatomic, nullable, copy)   NSString *country;
@property (nonatomic, nullable, copy)   NSString *language;
@property (nonatomic, nullable, copy)   NSString *timeZone;
@property (nonatomic, nullable, copy)   NSString *currency;
@property (nonatomic, nullable, copy)   NSString *clipboardContent;
@property (nonatomic, nullable, strong) NSNumber *doNotTrackEnabled;
@property (nonatomic, nullable, copy)   NSString *advertisingID;
@property (nonatomic, nullable, copy)   NSArray<BOAOtherID *> *otherIDs;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAOtherID : NSObject
@property (nonatomic, nullable, copy) NSString *theIDName;
@property (nonatomic, nullable, copy) NSString *theIDValue;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAProcessorsUsage : NSObject
@property (nonatomic, nullable, strong) NSNumber *processorID;
@property (nonatomic, nullable, strong) NSNumber *usagePercentage;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOALocation : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, strong) BOAPiiLocation *piiLocation;
@property (nonatomic, nullable, strong) BOANonPIILocation *nonPIILocation;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOANonPIILocation : NSObject
@property (nonatomic, nullable, copy) NSString *city;
@property (nonatomic, nullable, copy) NSString *state;
@property (nonatomic, nullable, copy) NSString *zip;
@property (nonatomic, nullable, copy) NSString *country;
@property (nonatomic, nullable, copy) NSString *activity;
@property (nonatomic, nullable, copy) NSString *source;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAPiiLocation : NSObject
@property (nonatomic, nullable, copy) NSString *latitude;
@property (nonatomic, nullable, copy) NSString *longitude;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAMemoryInfo : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, strong) NSNumber *totalRAM;
@property (nonatomic, nullable, strong) NSNumber *userMemory;
@property (nonatomic, nullable, strong) NSNumber *wireMemory;
@property (nonatomic, nullable, strong) NSNumber *activeMemory;
@property (nonatomic, nullable, strong) NSNumber *inActiveMemory;
@property (nonatomic, nullable, strong) NSNumber *freeMemory;
@property (nonatomic, nullable, strong) NSNumber *purgeableMemory;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOANetworkInfo : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSString *carrierName;
@property (nonatomic, nullable, copy)   NSString *carrierCountry;
@property (nonatomic, nullable, copy)   NSString *carrierMobileCountry;
@property (nonatomic, nullable, copy)   NSString *carrierISOCountryCode;
@property (nonatomic, nullable, copy)   NSString *carrierMobileNetworkCode;
@property (nonatomic, nullable, strong) NSNumber *carrierAllowVOIP;
@property (nonatomic, nullable, copy)   NSString *currentIPAddress;
@property (nonatomic, nullable, copy)   NSString *externalIPAddress;
@property (nonatomic, nullable, copy)   NSString *cellIPAddress;
@property (nonatomic, nullable, copy)   NSString *cellNetMask;
@property (nonatomic, nullable, copy)   NSString *cellBroadcastAddress;
@property (nonatomic, nullable, copy)   NSString *wifiIPAddress;
@property (nonatomic, nullable, copy)   NSString *wifiNetMask;
@property (nonatomic, nullable, copy)   NSString *wifiBroadcastAddress;
@property (nonatomic, nullable, copy)   NSString *wifiRouterAddress;
@property (nonatomic, nullable, copy)   NSString *wifiSSID;
@property (nonatomic, nullable, strong) NSNumber *connectedToWifi;
@property (nonatomic, nullable, strong) NSNumber *connectedToCellNetwork;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOARetentionEvent : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, strong) BOADau *dau;
@property (nonatomic, nullable, strong) BOAWau *wau;
@property (nonatomic, nullable, strong) BOAMau *mau;
@property (nonatomic, nullable, strong) BOADpu *dpu;
@property (nonatomic, nullable, strong) BOAWpu *wpu;
@property (nonatomic, nullable, strong) BOAMPU *mpu;
@property (nonatomic, nullable, strong) BOAAppInstalled *appInstalled;
@property (nonatomic, nullable, strong) BOANewUser *theNewUser;
@property (nonatomic, nullable, strong) BOAAST *dast;
@property (nonatomic, nullable, strong) BOAAST *wast;
@property (nonatomic, nullable, strong) BOAAST *mast;
@property (nonatomic, nullable, strong) BOACustomEvents *customEvents;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAAppInstalled : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *isFirstLaunch;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSDictionary *appInstalledInfo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOACustomEvents : NSObject
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *eventName;
@property (nonatomic, nullable, copy)   NSString *visibleClassName;
@property (nonatomic, nullable, copy)   NSDictionary *eventInfo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAAST : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, strong) NSNumber *averageSessionTime;
@property (nonatomic, nullable, copy) NSDictionary *dastInfo;
@property (nonatomic, nullable, copy) NSDictionary *mastInfo;
@property (nonatomic, nullable, copy) NSDictionary *wastInfo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOADau : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy) NSDictionary *dauInfo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOADpu : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy) NSDictionary *dpuInfo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAMau : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy) NSDictionary *mauInfo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAMPU : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy) NSDictionary *mpuInfo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOANewUser : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *isNewUser;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy) NSDictionary *theNewUserInfo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAWau : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy)   NSDictionary *wauInfo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAWpu : NSObject
@property (nonatomic, nullable, strong) NSNumber *sentToServer;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *session_id;
@property (nonatomic, nullable, strong) NSNumber *timeStamp;
@property (nonatomic, nullable, copy) NSDictionary *wpuInfo;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAStorageInfo : NSObject
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

NS_ASSUME_NONNULL_END
