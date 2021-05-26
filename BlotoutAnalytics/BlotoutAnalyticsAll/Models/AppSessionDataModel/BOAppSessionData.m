#import "BOAppSessionData.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"

// Shorthand for simple blocks
#define λ(decl, expr) (^(decl) { return (expr); })

// nil → NSNull conversion for JSON dictionaries
static id NSNullify(id _Nullable x) {
    return (x == nil || x == NSNull.null) ? NSNull.null : x;
}
static id sBOASessionModelSharedInstance = nil;
static dispatch_once_t boaAppSessionDataOnceToken = 0;
NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private model interfaces

@interface BOAppSessionData (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOSingleDaySessions (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAppInfo (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOCurrentLocation (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAppStates (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOSessionInfo (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOApp (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOCrashDetail (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BODeveloperCodified (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAddToCart (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOChargeTransaction (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOCustomEvent (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BODoubleTap (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOScreenRect (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOListUpdated (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOScreenEdgePan (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOTimedEvent (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOView (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BODeviceInfo (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAccessoriesAttached (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOBatteryLevel (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOCFUUID (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BODeviceOrientation (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BONameOfAttachedAccessory (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BONumberOfA (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOProcessorsUsage (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOVendorID (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOLocation (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BONonPIILocation (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOPiiLocation (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOMemoryInfo (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BONetworkInfo (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOBroadcastAddress (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOIPAddress (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BONetMask (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOConnectedTo (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOWifiRouterAddress (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOWifiSSID (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BORetentionEvent (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAppInstalled (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BODast (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BODau (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BODpu (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BONewUser (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOStorageInfo (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOUbiAutoDetected (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAppGesture (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAppNavigation (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOScreenShotsTaken (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

static id map(id collection, id (^f)(id value)) {
    @try {
        id result = nil;
        if ([collection isKindOfClass:NSArray.class]) {
            result = [NSMutableArray arrayWithCapacity:[collection count]];
            for (id x in collection) [result addObject:f(x)];
        } else if ([collection isKindOfClass:NSDictionary.class]) {
            result = [NSMutableDictionary dictionaryWithCapacity:[collection count]];
            for (id key in collection) [result setObject:f([collection objectForKey:key]) forKey:key];
        }
        return result;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

#pragma mark - JSON serialization

BOAppSessionData *_Nullable BOAppSessionDataFromData(NSData *data, NSError **error)
{
    @try {
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
        return *error ? nil : [BOAppSessionData fromJSONDictionary:json];
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
    return nil;
}

BOAppSessionData *_Nullable BOAppSessionDataFromJSON(NSString *json, NSStringEncoding encoding, NSError **error)
{
    @try {
        return BOAppSessionDataFromData([json dataUsingEncoding:encoding], error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

NSData *_Nullable BOAppSessionDataToData(BOAppSessionData *appSessionData, NSError **error)
{
    @try {
        id json = [appSessionData JSONDictionary];
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:error];
        return *error ? nil : data;
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
    return nil;
}

NSString *_Nullable BOAppSessionDataToJSON(BOAppSessionData *appSessionData, NSStringEncoding encoding, NSError **error)
{
    @try {
        NSData *data = BOAppSessionDataToData(appSessionData, error);
        return data ? [[NSString alloc] initWithData:data encoding:encoding] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

@implementation BOAppSessionData
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"appBundle": @"appBundle",
            @"date": @"date",
            @"singleDaySessions": @"singleDaySessions",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error
{
    @try {
        return BOAppSessionDataFromData(data, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    @try {
        return BOAppSessionDataFromJSON(json, encoding, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAppSessionData alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)sharedInstanceFromJSONDictionary:(nullable NSDictionary *)dict {
    
    @try {
        if (!dict) {
            return sBOASessionModelSharedInstance;
        }
        dispatch_once(&boaAppSessionDataOnceToken, ^{
            sBOASessionModelSharedInstance = [BOAppSessionData fromJSONDictionary:dict];
        });
        return  sBOASessionModelSharedInstance;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (void)resetDailySessionSharedInstanceToken{
    boaAppSessionDataOnceToken = 0;
    //do not reset object as it will be reset to new object on creation
    // don't do this: sBOASessionModelSharedInstance = nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
                _singleDaySessions = [BOSingleDaySessions fromJSONDictionary:(id)_singleDaySessions];
            }
            return self;
        }else if([dict isKindOfClass:[BOAppSessionData class]]){
            return (BOAppSessionData*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOAppSessionData.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"singleDaySessions": NSNullify([_singleDaySessions JSONDictionary]),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSData *_Nullable)toData:(NSError *_Nullable *)error
{
    @try {
        return BOAppSessionDataToData(self, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    @try {
        return BOAppSessionDataToJSON(self, encoding, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOSingleDaySessions
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"systemUptime": @"systemUptime",
        @"lastServerSyncTimeStamp": @"lastServerSyncTimeStamp",
        @"allEventsSyncTimeStamp": @"allEventsSyncTimeStamp",
        @"appInfo": @"appInfo",
        @"adInfo": @"adInfo",
        @"ubiAutoDetected": @"ubiAutoDetected",
        @"developerCodified": @"developerCodified",
        @"appStates": @"appStates",
        @"deviceInfo": @"deviceInfo",
        @"networkInfo": @"networkInfo",
        @"storageInfo": @"storageInfo",
        @"memoryInfo": @"memoryInfo",
        @"location": @"location",
        @"crashDetails": @"crashDetails",
        @"commonEvents": @"commonEvents",
        @"retentionEvent": @"retentionEvent",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOSingleDaySessions alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
                _appInfo = map(_appInfo, λ(id x, [BOAppInfo fromJSONDictionary:x]));
                _ubiAutoDetected = [BOUbiAutoDetected fromJSONDictionary:(id)_ubiAutoDetected];
                _developerCodified = [BODeveloperCodified fromJSONDictionary:(id)_developerCodified];
                _appStates = [BOAppStates fromJSONDictionary:(id)_appStates];
                _deviceInfo = [BODeviceInfo fromJSONDictionary:(id)_deviceInfo];
                _networkInfo = [BONetworkInfo fromJSONDictionary:(id)_networkInfo];
                _storageInfo = map(_storageInfo, λ(id x, [BOStorageInfo fromJSONDictionary:x]));
                _memoryInfo = map(_memoryInfo, λ(id x, [BOMemoryInfo fromJSONDictionary:x]));
                _location = map(_location, λ(id x, [BOLocation fromJSONDictionary:x]));
                _crashDetails = map(_crashDetails, λ(id x, [BOCrashDetail fromJSONDictionary:x]));
                _commonEvents = map(_commonEvents, λ(id x, [BOCommonEvent fromJSONDictionary:x]));
                _retentionEvent = [BORetentionEvent fromJSONDictionary:(id)_retentionEvent];
            }
            return self;
        }else if([dict isKindOfClass:[BOSingleDaySessions class]]){
            return (BOSingleDaySessions*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOSingleDaySessions.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"appInfo": NSNullify(map(_appInfo, λ(id x, [x JSONDictionary]))),
            @"adInfo": NSNullify(map(_adInfo, λ(id x, [x JSONDictionary]))),
            @"ubiAutoDetected": NSNullify([_ubiAutoDetected JSONDictionary]),
            @"developerCodified": NSNullify([_developerCodified JSONDictionary]),
            @"appStates": NSNullify([_appStates JSONDictionary]),
            @"deviceInfo": NSNullify([_deviceInfo JSONDictionary]),
            @"networkInfo": NSNullify([_networkInfo JSONDictionary]),
            @"storageInfo": NSNullify(map(_storageInfo, λ(id x, [x JSONDictionary]))),
            @"memoryInfo": NSNullify(map(_memoryInfo, λ(id x, [x JSONDictionary]))),
            @"location": NSNullify(map(_location, λ(id x, [x JSONDictionary]))),
            @"crashDetails": NSNullify(map(_crashDetails, λ(id x, [x JSONDictionary]))),
            @"commonEvents": NSNullify(map(_commonEvents, λ(id x, [x JSONDictionary]))),
            @"retentionEvent": NSNullify([_retentionEvent JSONDictionary]),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAppInfo
+ (NSDictionary<NSString *, NSString *> *)properties
{
    
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"timeStamp": @"timeStamp",
        @"version": @"version",
        @"platform": @"platform",
        @"osName": @"osName",
        @"osVersion": @"osVersion",
        @"deviceMft": @"deviceMft",
        @"deviceModel": @"deviceModel",
        @"platform": @"platform",
        @"sdkVersion": @"sdkVersion",
        @"timeZoneOffset": @"timeZoneOffset",
        @"vpnStatus": @"vpnStatus",
        @"jbnStatus": @"jbnStatus",
        @"dcompStatus": @"dcompStatus",
        @"acompStatus": @"acompStatus",
        @"name": @"name",
        @"bundle": @"bundle",
        @"language": @"language",
        @"launchTimeStamp": @"launchTimeStamp",
        @"terminationTimeStamp": @"terminationTimeStamp",
        @"sessionsDuration": @"sessionsDuration",
        @"averageSessionsDuration": @"averageSessionsDuration",
        @"launchReason": @"launchReason",
        @"currentLocation": @"currentLocation",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAppInfo alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
                _currentLocation = [BOCurrentLocation fromJSONDictionary:(id)_currentLocation];
            }
            return self;
        }else if([dict isKindOfClass:[BOAppInfo class]]){
            return (BOAppInfo*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOAppInfo.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"currentLocation": NSNullify([_currentLocation JSONDictionary]),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOCurrentLocation
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"city": @"city",
        @"state": @"state",
        @"country": @"country",
        @"zip": @"zip",
        @"continentCode":@"continentCode",
        @"latitude":@"latitude",
        @"longitude":@"longitude",
        @"timeStamp":@"timeStamp"
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOCurrentLocation alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOCurrentLocation class]]){
            return (BOCurrentLocation*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOCurrentLocation.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAppStates
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"appLaunched": @"appLaunched",
        @"appActive": @"appActive",
        @"appResignActive": @"appResignActive",
        @"appInBackground": @"appInBackground",
        @"appInForeground": @"appInForeground",
        @"appBackgroundRefreshAvailable": @"appBackgroundRefreshAvailable",
        @"appReceiveMemoryWarning": @"appReceiveMemoryWarning",
        @"appSignificantTimeChange": @"appSignificantTimeChange",
        @"appOrientationPortrait": @"appOrientationPortrait",
        @"appOrientationLandscape": @"appOrientationLandscape",
        @"appStatusbarFrameChange": @"appStatusbarFrameChange",
        @"appBackgroundRefreshStatusChange": @"appBackgroundRefreshStatusChange",
        @"appNotificationReceived": @"appNotificationReceived",
        @"appNotificationViewed": @"appNotificationViewed",
        @"appNotificationClicked": @"appNotificationClicked",
        @"appSessionInfo": @"appSessionInfo",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAppStates alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
                _appLaunched = map(_appLaunched, λ(id x, [BOApp fromJSONDictionary:x]));
                _appActive = map(_appActive, λ(id x, [BOApp fromJSONDictionary:x]));
                _appResignActive = map(_appResignActive, λ(id x, [BOApp fromJSONDictionary:x]));
                _appInBackground = map(_appInBackground, λ(id x, [BOApp fromJSONDictionary:x]));
                _appInForeground = map(_appInForeground, λ(id x, [BOApp fromJSONDictionary:x]));
                _appBackgroundRefreshAvailable = map(_appBackgroundRefreshAvailable, λ(id x, [BOApp fromJSONDictionary:x]));
                _appReceiveMemoryWarning = map(_appReceiveMemoryWarning, λ(id x, [BOApp fromJSONDictionary:x]));
                _appSignificantTimeChange = map(_appSignificantTimeChange, λ(id x, [BOApp fromJSONDictionary:x]));
                _appOrientationPortrait = map(_appOrientationPortrait, λ(id x, [BOApp fromJSONDictionary:x]));
                _appOrientationLandscape = map(_appOrientationLandscape, λ(id x, [BOApp fromJSONDictionary:x]));
                _appStatusbarFrameChange = map(_appStatusbarFrameChange, λ(id x, [BOApp fromJSONDictionary:x]));
                _appBackgroundRefreshStatusChange = map(_appBackgroundRefreshStatusChange, λ(id x, [BOApp fromJSONDictionary:x]));
                _appNotificationReceived = map(_appNotificationReceived, λ(id x, [BOApp fromJSONDictionary:x]));
                _appNotificationViewed = map(_appNotificationViewed, λ(id x, [BOApp fromJSONDictionary:x]));
                _appNotificationClicked = map(_appNotificationClicked, λ(id x, [BOApp fromJSONDictionary:x]));
                _appSessionInfo = map(_appSessionInfo, λ(id x, [BOSessionInfo fromJSONDictionary:x]));
                
            }
            return self;
        }else if([dict isKindOfClass:[BOAppStates class]]){
            return (BOAppStates*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOAppStates.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"appLaunched": NSNullify(map(_appLaunched, λ(id x, [x JSONDictionary]))),
            @"appActive": NSNullify(map(_appActive, λ(id x, [x JSONDictionary]))),
            @"appResignActive": NSNullify(map(_appResignActive, λ(id x, [x JSONDictionary]))),
            @"appInBackground": NSNullify(map(_appInBackground, λ(id x, [x JSONDictionary]))),
            @"appInForeground": NSNullify(map(_appInForeground, λ(id x, [x JSONDictionary]))),
            @"appBackgroundRefreshAvailable": NSNullify(map(_appBackgroundRefreshAvailable, λ(id x, [x JSONDictionary]))),
            @"appReceiveMemoryWarning": NSNullify(map(_appReceiveMemoryWarning, λ(id x, [x JSONDictionary]))),
            @"appSignificantTimeChange": NSNullify(map(_appSignificantTimeChange, λ(id x, [x JSONDictionary]))),
            @"appOrientationPortrait": NSNullify(map(_appOrientationPortrait, λ(id x, [x JSONDictionary]))),
            @"appOrientationLandscape": NSNullify(map(_appOrientationLandscape, λ(id x, [x JSONDictionary]))),
            @"appStatusbarFrameChange": NSNullify(map(_appStatusbarFrameChange, λ(id x, [x JSONDictionary]))),
            @"appBackgroundRefreshStatusChange": NSNullify(map(_appBackgroundRefreshStatusChange, λ(id x, [x JSONDictionary]))),
            @"appNotificationReceived": NSNullify(map(_appNotificationReceived, λ(id x, [x JSONDictionary]))),
            @"appNotificationViewed": NSNullify(map(_appNotificationViewed, λ(id x, [x JSONDictionary]))),
            @"appNotificationClicked": NSNullify(map(_appNotificationClicked, λ(id x, [x JSONDictionary]))),
            @"appSessionInfo": NSNullify(map(_appSessionInfo, λ(id x, [x JSONDictionary]))),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOSessionInfo
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"timeStamp": @"timeStamp",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"start": @"start",
        @"end": @"end",
        @"duration": @"duration",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOSessionInfo alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOSessionInfo class]]){
            return (BOSessionInfo*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOSessionInfo.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOApp
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"timeStamp": @"timeStamp",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"visibleClassName": @"visibleClassName",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOApp alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOApp class]]){
            return (BOApp*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOApp.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOCrashDetail
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"timeStamp": @"timeStamp",
        @"name": @"name",
        @"reason": @"reason",
        @"info": @"info",
        @"callStackSymbols": @"callStackSymbols",
        @"callStackReturnAddress": @"callStackReturnAddress",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOCrashDetail alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOCrashDetail class]]){
            return (BOCrashDetail*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOCrashDetail.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"info": NSNullify(_info),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BODeveloperCodified
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"touchClick": @"touchClick",
        @"drag": @"drag",
        @"flick": @"flick",
        @"swipe": @"swipe",
        @"doubleTap": @"doubleTap",
        @"moreThanDoubleTap": @"moreThanDoubleTap",
        @"twoFingerTap": @"twoFingerTap",
        @"moreThanTwoFingerTap": @"moreThanTwoFingerTap",
        @"pinch": @"pinch",
        @"touchAndHold": @"touchAndHold",
        @"shake": @"shake",
        @"rotate": @"rotate",
        @"screenEdgePan": @"screenEdgePan",
        @"view": @"view",
        @"addToCart": @"addToCart",
        @"chargeTransaction": @"chargeTransaction",
        @"listUpdated": @"listUpdated",
        @"timedEvent": @"timedEvent",
        @"customEvents": @"customEvents",
        @"piiEvents": @"piiEvents",
        @"phiEvents": @"phiEvents",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BODeveloperCodified alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
                _touchClick = map(_touchClick, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _drag = map(_drag, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _flick = map(_flick, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _swipe = map(_swipe, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _doubleTap = map(_doubleTap, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _moreThanDoubleTap = map(_moreThanDoubleTap, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _twoFingerTap = map(_twoFingerTap, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _moreThanTwoFingerTap = map(_moreThanTwoFingerTap, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _pinch = map(_pinch, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _touchAndHold = map(_touchAndHold, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _shake = map(_shake, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _rotate = map(_rotate, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _screenEdgePan = map(_screenEdgePan, λ(id x, [BOScreenEdgePan fromJSONDictionary:x]));
                _view = map(_view, λ(id x, [BOView fromJSONDictionary:x]));
                _addToCart = map(_addToCart, λ(id x, [BOAddToCart fromJSONDictionary:x]));
                _chargeTransaction = map(_chargeTransaction, λ(id x, [BOChargeTransaction fromJSONDictionary:x]));
                _listUpdated = map(_listUpdated, λ(id x, [BOListUpdated fromJSONDictionary:x]));
                _timedEvent = map(_timedEvent, λ(id x, [BOTimedEvent fromJSONDictionary:x]));
                _customEvents = map(_customEvents, λ(id x, [BOCustomEvent fromJSONDictionary:x]));
                _piiEvents = map(_piiEvents, λ(id x, [BOCustomEvent fromJSONDictionary:x]));
                _phiEvents = map(_phiEvents, λ(id x, [BOCustomEvent fromJSONDictionary:x]));
            }
            return self;
        }else if([dict isKindOfClass:[BODeveloperCodified class]]){
            return (BODeveloperCodified*)dict;
        }
        return nil;
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BODeveloperCodified.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"touchClick": NSNullify(map(_touchClick, λ(id x, [x JSONDictionary]))),
            @"drag": NSNullify(map(_drag, λ(id x, [x JSONDictionary]))),
            @"flick": NSNullify(map(_flick, λ(id x, [x JSONDictionary]))),
            @"swipe": NSNullify(map(_swipe, λ(id x, [x JSONDictionary]))),
            @"doubleTap": NSNullify(map(_doubleTap, λ(id x, [x JSONDictionary]))),
            @"moreThanDoubleTap": NSNullify(map(_moreThanDoubleTap, λ(id x, [x JSONDictionary]))),
            @"twoFingerTap": NSNullify(map(_twoFingerTap, λ(id x, [x JSONDictionary]))),
            @"moreThanTwoFingerTap": NSNullify(map(_moreThanTwoFingerTap, λ(id x, [x JSONDictionary]))),
            @"pinch": NSNullify(map(_pinch, λ(id x, [x JSONDictionary]))),
            @"touchAndHold": NSNullify(map(_touchAndHold, λ(id x, [x JSONDictionary]))),
            @"shake": NSNullify(map(_shake, λ(id x, [x JSONDictionary]))),
            @"rotate": NSNullify(map(_rotate, λ(id x, [x JSONDictionary]))),
            @"screenEdgePan": NSNullify(map(_screenEdgePan, λ(id x, [x JSONDictionary]))),
            @"view": NSNullify(map(_view, λ(id x, [x JSONDictionary]))),
            @"addToCart": NSNullify(map(_addToCart, λ(id x, [x JSONDictionary]))),
            @"chargeTransaction": NSNullify(map(_chargeTransaction, λ(id x, [x JSONDictionary]))),
            @"listUpdated": NSNullify(map(_listUpdated, λ(id x, [x JSONDictionary]))),
            @"timedEvent": NSNullify(map(_timedEvent, λ(id x, [x JSONDictionary]))),
            @"customEvents": NSNullify(map(_customEvents, λ(id x, [x JSONDictionary]))),
            @"piiEvents": NSNullify(map(_piiEvents, λ(id x, [x JSONDictionary]))),
            @"phiEvents": NSNullify(map(_phiEvents, λ(id x, [x JSONDictionary]))),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAddToCart
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"timeStamp": @"timeStamp",
        @"cartClassName": @"cartClassName",
        @"additionalInfo": @"additionalInfo",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAddToCart alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOAddToCart class]]){
            return (BOAddToCart*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOAddToCart.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"additionalInfo": NSNullify(_additionalInfo),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOChargeTransaction
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"timeStamp": @"timeStamp",
        @"transactionClassName": @"transactionClassName",
        @"transactionInfo": @"transactionInfo",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOChargeTransaction alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOChargeTransaction class]]){
            return (BOChargeTransaction*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOChargeTransaction.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"transactionInfo": NSNullify(_transactionInfo),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOCustomEvent
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"timeStamp": @"timeStamp",
        @"eventName": @"eventName",
        @"eventSubCode": @"eventSubCode",
        @"visibleClassName": @"visibleClassName",
        @"eventInfo": @"eventInfo",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOCustomEvent alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOCustomEvent class]]){
            return (BOCustomEvent*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOCustomEvent.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"eventInfo": NSNullify(_eventInfo),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BODoubleTap
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"timeStamp": @"timeStamp",
        @"objectType": @"objectType",
        @"visibleClassName": @"visibleClassName",
        @"objectRect": @"objectRect",
        @"screenRect": @"screenRect",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BODoubleTap alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
                _screenRect = [BOScreenRect fromJSONDictionary:(id)_screenRect];
            }
            return self;
        }else if([dict isKindOfClass:[BODoubleTap class]]){
            return (BODoubleTap*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BODoubleTap.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"screenRect": NSNullify([_screenRect JSONDictionary]),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOScreenRect
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"screenX": @"screenX",
        @"screenY": @"screenY",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOScreenRect alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOScreenRect class]]){
            return (BOScreenRect*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOScreenRect.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOListUpdated
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"timeStamp": @"timeStamp",
        @"listClassName": @"listClassName",
        @"updatesInfo": @"updatesInfo",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOListUpdated alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOListUpdated class]]){
            return (BOListUpdated*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOListUpdated.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"updatesInfo": NSNullify(_updatesInfo),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOScreenEdgePan
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"timeStamp": @"timeStamp",
        @"objectType": @"objectType",
        @"visibleClassName": @"visibleClassName",
        @"screenRectFrom": @"screenRectFrom",
        @"screenRectTo": @"screenRectTo",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOScreenEdgePan alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
                _screenRectFrom = [BOScreenRect fromJSONDictionary:(id)_screenRectFrom];
                _screenRectTo = [BOScreenRect fromJSONDictionary:(id)_screenRectTo];
            }
            return self;
        }else if([dict isKindOfClass:[BOScreenEdgePan class]]){
            return (BOScreenEdgePan*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOScreenEdgePan.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"screenRectFrom": NSNullify([_screenRectFrom JSONDictionary]),
            @"screenRectTo": NSNullify([_screenRectTo JSONDictionary]),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOTimedEvent
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"timeStamp": @"timeStamp",
        @"eventName": @"eventName",
        @"startTime": @"startTime",
        @"startVisibleClassName": @"startVisibleClassName",
        @"endVisibleClassName": @"endVisibleClassName",
        @"endTime": @"endTime",
        @"eventDuration": @"eventDuration",
        @"timedEvenInfo": @"timedEvenInfo",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOTimedEvent alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOTimedEvent class]]){
            return (BOTimedEvent*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOTimedEvent.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"timedEvenInfo": NSNullify(_timedEvenInfo),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOView
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"timeStamp": @"timeStamp",
        @"viewClassName": @"viewClassName",
        @"viewInfo": @"viewInfo",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOView alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOView class]]){
            return (BOView*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOView.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"viewInfo": NSNullify(_viewInfo),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BODeviceInfo
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"multitaskingEnabled": @"multitaskingEnabled",
        @"proximitySensorEnabled": @"proximitySensorEnabled",
        @"debuggerAttached": @"debuggerAttached",
        @"pluggedIn": @"pluggedIn",
        @"jailBroken": @"jailBroken",
        @"numberOfActiveProcessors": @"numberOfActiveProcessors",
        @"processorsUsage": @"processorsUsage",
        @"accessoriesAttached": @"accessoriesAttached",
        @"headphoneAttached": @"headphoneAttached",
        @"numberOfAttachedAccessories": @"numberOfAttachedAccessories",
        @"nameOfAttachedAccessories": @"nameOfAttachedAccessories",
        @"batteryLevel": @"batteryLevel",
        @"isCharging": @"isCharging",
        @"fullyCharged": @"fullyCharged",
        @"deviceOrientation": @"deviceOrientation",
        @"cfUUID": @"cfUUID",
        @"vendorID": @"vendorID",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BODeviceInfo alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
                _multitaskingEnabled = map(_multitaskingEnabled, λ(id x, [BOAccessoriesAttached fromJSONDictionary:x]));
                _proximitySensorEnabled = map(_proximitySensorEnabled, λ(id x, [BOAccessoriesAttached fromJSONDictionary:x]));
                _debuggerAttached = map(_debuggerAttached, λ(id x, [BOAccessoriesAttached fromJSONDictionary:x]));
                _pluggedIn = map(_pluggedIn, λ(id x, [BOAccessoriesAttached fromJSONDictionary:x]));
                _jailBroken = map(_jailBroken, λ(id x, [BOAccessoriesAttached fromJSONDictionary:x]));
                _numberOfActiveProcessors = map(_numberOfActiveProcessors, λ(id x, [BONumberOfA fromJSONDictionary:x]));
                _processorsUsage = map(_processorsUsage, λ(id x, [BOProcessorsUsage fromJSONDictionary:x]));
                _accessoriesAttached = map(_accessoriesAttached, λ(id x, [BOAccessoriesAttached fromJSONDictionary:x]));
                _headphoneAttached = map(_headphoneAttached, λ(id x, [BOAccessoriesAttached fromJSONDictionary:x]));
                _numberOfAttachedAccessories = map(_numberOfAttachedAccessories, λ(id x, [BONumberOfA fromJSONDictionary:x]));
                _nameOfAttachedAccessories = map(_nameOfAttachedAccessories, λ(id x, [BONameOfAttachedAccessory fromJSONDictionary:x]));
                _batteryLevel = map(_batteryLevel, λ(id x, [BOBatteryLevel fromJSONDictionary:x]));
                _isCharging = map(_isCharging, λ(id x, [BOAccessoriesAttached fromJSONDictionary:x]));
                _fullyCharged = map(_fullyCharged, λ(id x, [BOAccessoriesAttached fromJSONDictionary:x]));
                _deviceOrientation = map(_deviceOrientation, λ(id x, [BODeviceOrientation fromJSONDictionary:x]));
                _cfUUID = map(_cfUUID, λ(id x, [BOCFUUID fromJSONDictionary:x]));
                _vendorID = map(_vendorID, λ(id x, [BOVendorID fromJSONDictionary:x]));
            }
            return self;
        }else if([dict isKindOfClass:[BODeviceInfo class]]){
            return (BODeviceInfo*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BODeviceInfo.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"multitaskingEnabled": NSNullify(map(_multitaskingEnabled, λ(id x, [x JSONDictionary]))),
            @"proximitySensorEnabled": NSNullify(map(_proximitySensorEnabled, λ(id x, [x JSONDictionary]))),
            @"debuggerAttached": NSNullify(map(_debuggerAttached, λ(id x, [x JSONDictionary]))),
            @"pluggedIn": NSNullify(map(_pluggedIn, λ(id x, [x JSONDictionary]))),
            @"jailBroken": NSNullify(map(_jailBroken, λ(id x, [x JSONDictionary]))),
            @"numberOfActiveProcessors": NSNullify(map(_numberOfActiveProcessors, λ(id x, [x JSONDictionary]))),
            @"processorsUsage": NSNullify(map(_processorsUsage, λ(id x, [x JSONDictionary]))),
            @"accessoriesAttached": NSNullify(map(_accessoriesAttached, λ(id x, [x JSONDictionary]))),
            @"headphoneAttached": NSNullify(map(_headphoneAttached, λ(id x, [x JSONDictionary]))),
            @"numberOfAttachedAccessories": NSNullify(map(_numberOfAttachedAccessories, λ(id x, [x JSONDictionary]))),
            @"nameOfAttachedAccessories": NSNullify(map(_nameOfAttachedAccessories, λ(id x, [x JSONDictionary]))),
            @"batteryLevel": NSNullify(map(_batteryLevel, λ(id x, [x JSONDictionary]))),
            @"isCharging": NSNullify(map(_isCharging, λ(id x, [x JSONDictionary]))),
            @"fullyCharged": NSNullify(map(_fullyCharged, λ(id x, [x JSONDictionary]))),
            @"deviceOrientation": NSNullify(map(_deviceOrientation, λ(id x, [x JSONDictionary]))),
            @"cfUUID": NSNullify(map(_cfUUID, λ(id x, [x JSONDictionary]))),
            @"vendorID": NSNullify(map(_vendorID, λ(id x, [x JSONDictionary]))),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAccessoriesAttached
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"status": @"status",
        @"timeStamp": @"timeStamp",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAccessoriesAttached alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOAccessoriesAttached class]]){
            return (BOAccessoriesAttached*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOAccessoriesAttached.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOBatteryLevel
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"percentage": @"percentage",
        @"timeStamp": @"timeStamp",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOBatteryLevel alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOBatteryLevel class]]){
            return (BOBatteryLevel*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOBatteryLevel.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOCFUUID
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"cfUUID": @"cfUUID",
        @"timeStamp": @"timeStamp",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOCFUUID alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if (self = [super init]) {
            if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
                if (self = [super init]) {
                    [self setValuesForKeysWithDictionary:dict];
                }
                return self;
            }else if([dict isKindOfClass:[BOCFUUID class]]){
                return (BOCFUUID*)dict;
            }
            return nil;
        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOCFUUID.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BODeviceOrientation
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"orientation": @"orientation",
        @"timeStamp": @"timeStamp",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BODeviceOrientation alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BODeviceOrientation class]]){
            return (BODeviceOrientation*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BODeviceOrientation.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BONameOfAttachedAccessory
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"names": @"names",
        @"timeStamp": @"timeStamp",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BONameOfAttachedAccessory alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BONameOfAttachedAccessory class]]){
            return (BONameOfAttachedAccessory*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BONameOfAttachedAccessory.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BONumberOfA
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"number": @"number",
        @"timeStamp": @"timeStamp",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BONumberOfA alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BONumberOfA class]]){
            return (BONumberOfA*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BONumberOfA.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOProcessorsUsage
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"processorID": @"processorID",
        @"usagePercentage": @"usagePercentage",
        @"timeStamp": @"timeStamp",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOProcessorsUsage alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOProcessorsUsage class]]){
            return (BOProcessorsUsage*)dict;
        }
        return nil;
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOProcessorsUsage.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOVendorID
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"vendorID": @"vendorID",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"sentToServer": @"sentToServer",
        @"timeStamp": @"timeStamp",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOVendorID alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOVendorID class]]){
            return (BOVendorID*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOVendorID.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOLocation
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"timeStamp": @"timeStamp",
        @"piiLocation": @"piiLocation",
        @"nonPIILocation": @"nonPIILocation",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOLocation alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
                _piiLocation = [BOPiiLocation fromJSONDictionary:(id)_piiLocation];
                _nonPIILocation = [BONonPIILocation fromJSONDictionary:(id)_nonPIILocation];
            }
            return self;
        }else if([dict isKindOfClass:[BOLocation class]]){
            return (BOLocation*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOLocation.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"piiLocation": NSNullify([_piiLocation JSONDictionary]),
            @"nonPIILocation": NSNullify([_nonPIILocation JSONDictionary]),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BONonPIILocation
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"city": @"city",
        @"state": @"state",
        @"zip": @"zip",
        @"country": @"country",
        @"activity": @"activity",
        @"source": @"source",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BONonPIILocation alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BONonPIILocation class]]){
            return (BONonPIILocation*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BONonPIILocation.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOPiiLocation
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"latitude": @"latitude",
        @"longitude": @"longitude",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOPiiLocation alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOPiiLocation class]]){
            return (BOPiiLocation*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOPiiLocation.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOMemoryInfo
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"timeStamp": @"timeStamp",
        @"totalRAM": @"totalRAM",
        @"usedMemory": @"usedMemory",
        @"wiredMemory": @"wiredMemory",
        @"activeMemory": @"activeMemory",
        @"inActiveMemory": @"inActiveMemory",
        @"freeMemory": @"freeMemory",
        @"purgeableMemory": @"purgeableMemory",
        @"atMemoryWarning": @"atMemoryWarning",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOMemoryInfo alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOMemoryInfo class]]){
            return (BOMemoryInfo*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOMemoryInfo.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BONetworkInfo
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"currentIPAddress": @"currentIPAddress",
        @"externalIPAddress": @"externalIPAddress",
        @"cellIPAddress": @"cellIPAddress",
        @"cellNetMask": @"cellNetMask",
        @"cellBroadcastAddress": @"cellBroadcastAddress",
        @"wifiIPAddress": @"wifiIPAddress",
        @"wifiNetMask": @"wifiNetMask",
        @"wifiBroadcastAddress": @"wifiBroadcastAddress",
        @"wifiRouterAddress": @"wifiRouterAddress",
        @"wifiSSID": @"wifiSSID",
        @"connectedToWifi": @"connectedToWifi",
        @"connectedToCellNetwork": @"connectedToCellNetwork",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BONetworkInfo alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
                _currentIPAddress = map(_currentIPAddress, λ(id x, [BOIPAddress fromJSONDictionary:x]));
                _externalIPAddress = map(_externalIPAddress, λ(id x, [BOIPAddress fromJSONDictionary:x]));
                _cellIPAddress = map(_cellIPAddress, λ(id x, [BOIPAddress fromJSONDictionary:x]));
                _cellNetMask = map(_cellNetMask, λ(id x, [BONetMask fromJSONDictionary:x]));
                _cellBroadcastAddress = map(_cellBroadcastAddress, λ(id x, [BOBroadcastAddress fromJSONDictionary:x]));
                _wifiIPAddress = map(_wifiIPAddress, λ(id x, [BOIPAddress fromJSONDictionary:x]));
                _wifiNetMask = map(_wifiNetMask, λ(id x, [BONetMask fromJSONDictionary:x]));
                _wifiBroadcastAddress = map(_wifiBroadcastAddress, λ(id x, [BOBroadcastAddress fromJSONDictionary:x]));
                _wifiRouterAddress = map(_wifiRouterAddress, λ(id x, [BOWifiRouterAddress fromJSONDictionary:x]));
                _wifiSSID = map(_wifiSSID, λ(id x, [BOWifiSSID fromJSONDictionary:x]));
                _connectedToWifi = map(_connectedToWifi, λ(id x, [BOConnectedTo fromJSONDictionary:x]));
                _connectedToCellNetwork = map(_connectedToCellNetwork, λ(id x, [BOConnectedTo fromJSONDictionary:x]));
            }
            return self;
        }else if([dict isKindOfClass:[BONetworkInfo class]]){
            return (BONetworkInfo*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BONetworkInfo.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"currentIPAddress": NSNullify(map(_currentIPAddress, λ(id x, [x JSONDictionary]))),
            @"externalIPAddress": NSNullify(map(_externalIPAddress, λ(id x, [x JSONDictionary]))),
            @"cellIPAddress": NSNullify(map(_cellIPAddress, λ(id x, [x JSONDictionary]))),
            @"cellNetMask": NSNullify(map(_cellNetMask, λ(id x, [x JSONDictionary]))),
            @"cellBroadcastAddress": NSNullify(map(_cellBroadcastAddress, λ(id x, [x JSONDictionary]))),
            @"wifiIPAddress": NSNullify(map(_wifiIPAddress, λ(id x, [x JSONDictionary]))),
            @"wifiNetMask": NSNullify(map(_wifiNetMask, λ(id x, [x JSONDictionary]))),
            @"wifiBroadcastAddress": NSNullify(map(_wifiBroadcastAddress, λ(id x, [x JSONDictionary]))),
            @"wifiRouterAddress": NSNullify(map(_wifiRouterAddress, λ(id x, [x JSONDictionary]))),
            @"wifiSSID": NSNullify(map(_wifiSSID, λ(id x, [x JSONDictionary]))),
            @"connectedToWifi": NSNullify(map(_connectedToWifi, λ(id x, [x JSONDictionary]))),
            @"connectedToCellNetwork": NSNullify(map(_connectedToCellNetwork, λ(id x, [x JSONDictionary]))),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOBroadcastAddress
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"broadcastAddress": @"broadcastAddress",
        @"timeStamp": @"timeStamp",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOBroadcastAddress alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOBroadcastAddress class]]){
            return (BOBroadcastAddress*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOBroadcastAddress.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOIPAddress
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"ipAddress": @"ipAddress",
        @"timeStamp": @"timeStamp",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOIPAddress alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOIPAddress class]]){
            return (BOIPAddress*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOIPAddress.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BONetMask
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"netmask": @"netmask",
        @"timeStamp": @"timeStamp",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BONetMask alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BONetMask class]]){
            return (BONetMask*)dict;
        }
        return nil;
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BONetMask.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOConnectedTo
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"isConnected": @"isConnected",
        @"timeStamp": @"timeStamp",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOConnectedTo alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOConnectedTo class]]){
            return (BOConnectedTo*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOConnectedTo.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOWifiRouterAddress
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"routerAddress": @"routerAddress",
        @"timeStamp": @"timeStamp",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOWifiRouterAddress alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOWifiRouterAddress class]]){
            return (BOWifiRouterAddress*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOWifiRouterAddress.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOWifiSSID
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"ssid": @"ssid",
        @"timeStamp": @"timeStamp",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOWifiSSID alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOWifiSSID class]]){
            return (BOWifiSSID*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOWifiSSID.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BORetentionEvent
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"dau": @"dau",
        @"dpu": @"dpu",
        @"appInstalled": @"appInstalled",
        @"newUser": @"theNewUser",
        @"DAST": @"dast",
        @"customEvents": @"customEvents",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BORetentionEvent alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
                _dau = [BODau fromJSONDictionary:(id)_dau];
                _dpu = [BODpu fromJSONDictionary:(id)_dpu];
                _appInstalled = [BOAppInstalled fromJSONDictionary:(id)_appInstalled];
                _theNewUser = [BONewUser fromJSONDictionary:(id)_theNewUser];
                _dast = [BODast fromJSONDictionary:(id)_dast];
                _customEvents = map(_customEvents, λ(id x, [BOCustomEvent fromJSONDictionary:x]));
            }
            return self;
        }else if([dict isKindOfClass:[BORetentionEvent class]]){
            return (BORetentionEvent*)dict;
        }
        return nil;
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (void)setValue:(nullable id)value forKey:(NSString *)key
{
    @try {
        id resolved = BORetentionEvent.properties[key];
        if (resolved) [super setValue:value forKey:resolved];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BORetentionEvent.properties.allValues] mutableCopy];
        
        // Rewrite property names that differ in JSON
        for (id jsonName in BORetentionEvent.properties) {
            id propertyName = BORetentionEvent.properties[jsonName];
            if (![jsonName isEqualToString:propertyName]) {
                dict[jsonName] = dict[propertyName];
                [dict removeObjectForKey:propertyName];
            }
        }
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"dau": NSNullify([_dau JSONDictionary]),
            @"dpu": NSNullify([_dpu JSONDictionary]),
            @"appInstalled": NSNullify([_appInstalled JSONDictionary]),
            @"newUser": NSNullify([_theNewUser JSONDictionary]),
            @"DAST": NSNullify([_dast JSONDictionary]),
            @"customEvents": NSNullify(map(_customEvents, λ(id x, [x JSONDictionary]))),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAppInstalled
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"isFirstLaunch": @"isFirstLaunch",
        @"timeStamp": @"timeStamp",
        @"appInstalledInfo": @"appInstalledInfo",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAppInstalled alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOAppInstalled class]]){
            return (BOAppInstalled*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOAppInstalled.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"appInstalledInfo": NSNullify(_appInstalledInfo),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BODast
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"timeStamp": @"timeStamp",
        @"averageSessionTime": @"averageSessionTime",
        @"payload": @"payload",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BODast alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BODast class]]){
            return (BODast*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BODast.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"payload": NSNullify(_payload),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BODau
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"timeStamp": @"timeStamp",
        @"dauInfo": @"dauInfo",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BODau alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BODau class]]){
            return (BODau*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BODau.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"dauInfo": NSNullify(_dauInfo),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BODpu
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"timeStamp": @"timeStamp",
        @"dpuInfo": @"dpuInfo",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BODpu alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BODpu class]]){
            return (BODpu*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BODpu.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"dpuInfo": NSNullify(_dpuInfo),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BONewUser
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"isNewUser": @"isNewUser",
        @"timeStamp": @"timeStamp",
        @"newUserInfo": @"theNewUserInfo",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BONewUser alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BONewUser class]]){
            return (BONewUser*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (void)setValue:(nullable id)value forKey:(NSString *)key
{
    @try {
        id resolved = BONewUser.properties[key];
        if (resolved) [super setValue:value forKey:resolved];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BONewUser.properties.allValues] mutableCopy];
        
        // Rewrite property names that differ in JSON
        for (id jsonName in BONewUser.properties) {
            id propertyName = BONewUser.properties[jsonName];
            if (![jsonName isEqualToString:propertyName]) {
                dict[jsonName] = dict[propertyName];
                [dict removeObjectForKey:propertyName];
            }
        }
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"newUserInfo": NSNullify(_theNewUserInfo),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOStorageInfo
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"timeStamp": @"timeStamp",
        @"unit": @"unit",
        @"totalDiskSpace": @"totalDiskSpace",
        @"usedDiskSpace": @"usedDiskSpace",
        @"freeDiskSpace": @"freeDiskSpace",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOStorageInfo alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOStorageInfo class]]){
            return (BOStorageInfo*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOStorageInfo.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOUbiAutoDetected
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"screenShotsTaken": @"screenShotsTaken",
        @"appNavigation": @"appNavigation",
        @"appGesture": @"appGesture",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOUbiAutoDetected alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
                _screenShotsTaken = map(_screenShotsTaken, λ(id x, [BOScreenShotsTaken fromJSONDictionary:x]));
                _appNavigation = map(_appNavigation, λ(id x, [BOAppNavigation fromJSONDictionary:x]));
                _appGesture = [BOAppGesture fromJSONDictionary:(id)_appGesture];
            }
            return self;
        }else if([dict isKindOfClass:[BOUbiAutoDetected class]]){
            return (BOUbiAutoDetected*)dict;
        }
        return nil;
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOUbiAutoDetected.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"screenShotsTaken": NSNullify(map(_screenShotsTaken, λ(id x, [x JSONDictionary]))),
            @"appNavigation": NSNullify(map(_appNavigation, λ(id x, [x JSONDictionary]))),
            @"appGesture": NSNullify([_appGesture JSONDictionary]),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAppGesture
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"touchOrClick": @"touchOrClick",
        @"drag": @"drag",
        @"flick": @"flick",
        @"swipe": @"swipe",
        @"doubleTap": @"doubleTap",
        @"moreThanDoubleTap": @"moreThanDoubleTap",
        @"twoFingerTap": @"twoFingerTap",
        @"moreThanTwoFingerTap": @"moreThanTwoFingerTap",
        @"pinch": @"pinch",
        @"touchAndHold": @"touchAndHold",
        @"shake": @"shake",
        @"rotate": @"rotate",
        @"screenEdgePan": @"screenEdgePan",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAppGesture alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
                _touchOrClick = map(_touchOrClick, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _drag = map(_drag, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _flick = map(_flick, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _swipe = map(_swipe, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _doubleTap = map(_doubleTap, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _moreThanDoubleTap = map(_moreThanDoubleTap, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _twoFingerTap = map(_twoFingerTap, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _moreThanTwoFingerTap = map(_moreThanTwoFingerTap, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _pinch = map(_pinch, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _touchAndHold = map(_touchAndHold, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _shake = map(_shake, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _rotate = map(_rotate, λ(id x, [BODoubleTap fromJSONDictionary:x]));
                _screenEdgePan = map(_screenEdgePan, λ(id x, [BOScreenEdgePan fromJSONDictionary:x]));
            }
            return self;
        }else if([dict isKindOfClass:[BOAppGesture class]]){
            return (BOAppGesture*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOAppGesture.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"touchOrClick": NSNullify(map(_touchOrClick, λ(id x, [x JSONDictionary]))),
            @"drag": NSNullify(map(_drag, λ(id x, [x JSONDictionary]))),
            @"flick": NSNullify(map(_flick, λ(id x, [x JSONDictionary]))),
            @"swipe": NSNullify(map(_swipe, λ(id x, [x JSONDictionary]))),
            @"doubleTap": NSNullify(map(_doubleTap, λ(id x, [x JSONDictionary]))),
            @"moreThanDoubleTap": NSNullify(map(_moreThanDoubleTap, λ(id x, [x JSONDictionary]))),
            @"twoFingerTap": NSNullify(map(_twoFingerTap, λ(id x, [x JSONDictionary]))),
            @"moreThanTwoFingerTap": NSNullify(map(_moreThanTwoFingerTap, λ(id x, [x JSONDictionary]))),
            @"pinch": NSNullify(map(_pinch, λ(id x, [x JSONDictionary]))),
            @"touchAndHold": NSNullify(map(_touchAndHold, λ(id x, [x JSONDictionary]))),
            @"shake": NSNullify(map(_shake, λ(id x, [x JSONDictionary]))),
            @"rotate": NSNullify(map(_rotate, λ(id x, [x JSONDictionary]))),
            @"screenEdgePan": NSNullify(map(_screenEdgePan, λ(id x, [x JSONDictionary]))),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAppNavigation
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sentToServer": @"sentToServer",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"timeStamp": @"timeStamp",
        @"from": @"from",
        @"to": @"to",
        @"action": @"action",
        @"actionObject": @"actionObject",
        @"actionObjectTitle": @"actionObjectTitle",
        @"actionTime": @"actionTime",
        @"networkIndicatorVisible": @"networkIndicatorVisible",
        @"timeSpent": @"timeSpent",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAppNavigation alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOAppNavigation class]]){
            return (BOAppNavigation*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOAppNavigation.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOScreenShotsTaken
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"currentView": @"currentView",
        @"mid" : @"mid",
        @"session_id" : @"session_id",
        @"timeStamp": @"timeStamp",
        @"sentToServer": @"sentToServer",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOScreenShotsTaken alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOScreenShotsTaken class]]){
            return (BOScreenShotsTaken*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOScreenShotsTaken.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOCommonEvent
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"sentToServer": @"sentToServer",
            @"mid" : @"mid",
            @"session_id" : @"session_id",
            @"timeStamp": @"timeStamp",
            @"eventCode": @"eventCode",
            @"eventSubCode": @"eventSubCode",
            @"eventInfo": @"eventInfo",
            @"eventName": @"eventName",
            @"visibleClassName": @"visibleClassName",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOCommonEvent alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOCommonEvent class]]){
            return (BOCommonEvent*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOCommonEvent.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAdInfo
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"sentToServer": @"sentToServer",
            @"mid" : @"mid",
            @"session_id" : @"session_id",
            @"timeStamp": @"timeStamp",
            @"advertisingId": @"advertisingId",
            @"isAdDoNotTrack": @"isAdDoNotTrack",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAdInfo alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOAdInfo class]]){
            return (BOAdInfo*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOAdInfo.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end
NS_ASSUME_NONNULL_END
