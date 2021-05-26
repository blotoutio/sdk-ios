#import "BOAAppLifetimeData.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"

// Shorthand for simple blocks
#define λ(decl, expr) (^(decl) { return (expr); })

// nil → NSNull conversion for JSON dictionaries
static id NSNullify(id _Nullable x) {
    return (x == nil || x == NSNull.null) ? NSNull.null : x;
}
static id sBOALifeTimeModelSharedInstance = nil;
static dispatch_once_t boaAppLifeTimeDataOnceToken = 0;
NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private model interfaces

@interface BOAAppLifetimeData (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAAppLifeTimeInfo (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAAppInfo (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAAppLanguagesSupported (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAAppLaunchInfo (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOABlotoutSDKsInfo (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOADeviceInfo (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAOtherID (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAProcessorsUsage (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOALocation (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOANonPIILocation (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAPiiLocation (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAMemoryInfo (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOANetworkInfo (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOARetentionEvent (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAAppInstalled (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOACustomEvents (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAAST (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOADau (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOADpu (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAMau (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAMPU (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOANewUser (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAWau (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAWpu (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAStorageInfo (JSONConversion)
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

BOAAppLifetimeData *_Nullable BOAAppLifetimeDataFromData(NSData *data, NSError **error)
{
    @try {
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
        return *error ? nil : [BOAAppLifetimeData fromJSONDictionary:json];
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
    return nil;
}

BOAAppLifetimeData *_Nullable BOAAppLifetimeDataFromJSON(NSString *json, NSStringEncoding encoding, NSError **error)
{
    @try {
        return BOAAppLifetimeDataFromData([json dataUsingEncoding:encoding], error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

NSData *_Nullable BOAAppLifetimeDataToData(BOAAppLifetimeData *appLifetimeData, NSError **error)
{
    @try {
        id json = [appLifetimeData JSONDictionary];
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:error];
        return *error ? nil : data;
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
    return nil;
}

NSString *_Nullable BOAAppLifetimeDataToJSON(BOAAppLifetimeData *appLifetimeData, NSStringEncoding encoding, NSError **error)
{
    @try {
        NSData *data = BOAAppLifetimeDataToData(appLifetimeData, error);
        return data ? [[NSString alloc] initWithData:data encoding:encoding] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

@implementation BOAAppLifetimeData
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"appBundle": @"appBundle",
            @"appID": @"appID",
            @"date": @"date",
            @"lastServerSyncTimeStamp": @"lastServerSyncTimeStamp",
            @"allEventsSyncTimeStamp": @"allEventsSyncTimeStamp",
            @"appLifeTimeInfo": @"appLifeTimeInfo",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error
{
    @try {
        return BOAAppLifetimeDataFromData(data, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    @try {
        return BOAAppLifetimeDataFromJSON(json, encoding, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAAppLifetimeData alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)sharedInstanceFromJSONDictionary:(nullable NSDictionary *)dict {
    @try {
        if (!dict) {
            return sBOALifeTimeModelSharedInstance;
        }
        dispatch_once(&boaAppLifeTimeDataOnceToken, ^{
            sBOALifeTimeModelSharedInstance = [BOAAppLifetimeData fromJSONDictionary:dict];
        });
        return  sBOALifeTimeModelSharedInstance;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (void)resetLifeTimeSharedInstanceToken{
    boaAppLifeTimeDataOnceToken = 0;
    //do not reset object as it will be reset to new object on creation
    // don't do this: sBOALifeTimeModelSharedInstance = nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
                _appLifeTimeInfo = map(_appLifeTimeInfo, λ(id x, [BOAAppLifeTimeInfo fromJSONDictionary:x]));
            }
            return self;
        }else if([dict isKindOfClass:[BOAAppLifetimeData class]]){
            return (BOAAppLifetimeData*)dict;
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
        id dict = [[self dictionaryWithValuesForKeys:BOAAppLifetimeData.properties.allValues] mutableCopy];
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"appLifeTimeInfo": NSNullify(map(_appLifeTimeInfo, λ(id x, [x JSONDictionary]))),
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
        return BOAAppLifetimeDataToData(self, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    @try {
        return BOAAppLifetimeDataToJSON(self, encoding, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAAppLifeTimeInfo
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"sentToServer": @"sentToServer",
            @"dateAndTime": @"dateAndTime",
            @"timeStamp": @"timeStamp",
            @"appInstallInfo": @"appInstallInfo",
            @"appUpdatesInfo": @"appUpdatesInfo",
            @"appLaunchInfo": @"appLaunchInfo",
            @"blotoutSDKsInfo": @"blotoutSDKsInfo",
            @"appLanguagesSupported": @"appLanguagesSupported",
            @"appSupportShakeToEdit": @"appSupportShakeToEdit",
            @"appSupportRemoteNotifications": @"appSupportRemoteNotifications",
            @"appCategory": @"appCategory",
            @"deviceInfo": @"deviceInfo",
            @"networkInfo": @"networkInfo",
            @"storageInfo": @"storageInfo",
            @"memoryInfo": @"memoryInfo",
            @"location": @"location",
            @"retentionEvent": @"retentionEvent",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAAppLifeTimeInfo alloc] initWithJSONDictionary:dict] : nil;
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
                _appInstallInfo = [BOAAppInfo fromJSONDictionary:(id)_appInstallInfo];
                _appUpdatesInfo = [BOAAppInfo fromJSONDictionary:(id)_appUpdatesInfo];
                _appLaunchInfo = [BOAAppLaunchInfo fromJSONDictionary:(id)_appLaunchInfo];
                _blotoutSDKsInfo = [BOABlotoutSDKsInfo fromJSONDictionary:(id)_blotoutSDKsInfo];
                _appLanguagesSupported = map(_appLanguagesSupported, λ(id x, [BOAAppLanguagesSupported fromJSONDictionary:x]));
                _deviceInfo = [BOADeviceInfo fromJSONDictionary:(id)_deviceInfo];
                _networkInfo = [BOANetworkInfo fromJSONDictionary:(id)_networkInfo];
                _storageInfo = [BOAStorageInfo fromJSONDictionary:(id)_storageInfo];
                _memoryInfo = [BOAMemoryInfo fromJSONDictionary:(id)_memoryInfo];
                _location = [BOALocation fromJSONDictionary:(id)_location];
                _retentionEvent = [BOARetentionEvent fromJSONDictionary:(id)_retentionEvent];
            }
            return self;
        }else if([dict isKindOfClass:[BOAAppLifeTimeInfo class]]){
            return (BOAAppLifeTimeInfo*)dict;
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
        id dict = [[self dictionaryWithValuesForKeys:BOAAppLifeTimeInfo.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"appInstallInfo": NSNullify([_appInstallInfo JSONDictionary]),
            @"appUpdatesInfo": NSNullify([_appUpdatesInfo JSONDictionary]),
            @"appLaunchInfo": NSNullify([_appLaunchInfo JSONDictionary]),
            @"blotoutSDKsInfo": NSNullify([_blotoutSDKsInfo JSONDictionary]),
            @"appLanguagesSupported": NSNullify(map(_appLanguagesSupported, λ(id x, [x JSONDictionary]))),
            @"deviceInfo": NSNullify([_deviceInfo JSONDictionary]),
            @"networkInfo": NSNullify([_networkInfo JSONDictionary]),
            @"storageInfo": NSNullify([_storageInfo JSONDictionary]),
            @"memoryInfo": NSNullify([_memoryInfo JSONDictionary]),
            @"location": NSNullify([_location JSONDictionary]),
            @"retentionEvent": NSNullify([_retentionEvent JSONDictionary]),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAAppInfo
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"appVersion": @"appVersion",
            @"appName": @"appName",
            @"appBundle": @"appBundle",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAAppInfo alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOAAppInfo class]]){
            return (BOAAppInfo*)dict;
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
        return [self dictionaryWithValuesForKeys:BOAAppInfo.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAAppLanguagesSupported
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"languageName": @"languageName",
            @"languageCode": @"languageCode",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAAppLanguagesSupported alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOAAppLanguagesSupported class]]){
            return (BOAAppLanguagesSupported*)dict;
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
        return [self dictionaryWithValuesForKeys:BOAAppLanguagesSupported.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAAppLaunchInfo
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"appVersion": @"appVersion",
            @"launchReason": @"launchReason",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAAppLaunchInfo alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOAAppLaunchInfo class]]){
            return (BOAAppLaunchInfo*)dict;
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
        return [self dictionaryWithValuesForKeys:BOAAppLaunchInfo.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOABlotoutSDKsInfo
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"sdkVersion": @"sdkVersion",
            @"sdkName": @"sdkName",
            @"sdkBundle": @"sdkBundle",
            @"appVersion": @"appVersion",
            @"appName": @"appName",
            @"appBundle": @"appBundle",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOABlotoutSDKsInfo alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOABlotoutSDKsInfo class]]){
            return (BOABlotoutSDKsInfo*)dict;
        }
        return nil;    } @catch (NSException *exception) {
            BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        }
    return nil;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOABlotoutSDKsInfo.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOADeviceInfo
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"sentToServer": @"sentToServer",
            @"timeStamp": @"timeStamp",
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
            @"batteryLevelPercentage": @"batteryLevelPercentage",
            @"isCharging": @"isCharging",
            @"fullyCharged": @"fullyCharged",
            @"deviceOrientation": @"deviceOrientation",
            @"cfUUID": @"cfUUID",
            @"vendorID": @"vendorID",
            @"deviceModel": @"deviceModel",
            @"deviceName": @"deviceName",
            @"systemName": @"systemName",
            @"systemVersion": @"systemVersion",
            @"systemDeviceTypeUnformatted": @"systemDeviceTypeUnformatted",
            @"systemDeviceTypeFormatted": @"systemDeviceTypeFormatted",
            @"deviceScreenWidth": @"deviceScreenWidth",
            @"deviceScreenHeight": @"deviceScreenHeight",
            @"appUIWidth": @"appUIWidth",
            @"appUIHeight": @"appUIHeight",
            @"screenBrightness": @"screenBrightness",
            @"stepCountingAvailable": @"stepCountingAvailable",
            @"distanceAvailbale": @"distanceAvailbale",
            @"floorCountingAvailable": @"floorCountingAvailable",
            @"numberOfProcessors": @"numberOfProcessors",
            @"country": @"country",
            @"Language": @"language",
            @"timeZone": @"timeZone",
            @"currency": @"currency",
            @"clipboardContent": @"clipboardContent",
            @"doNotTrackEnabled": @"doNotTrackEnabled",
            @"advertisingID": @"advertisingID",
            @"otherIDs": @"otherIDs",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOADeviceInfo alloc] initWithJSONDictionary:dict] : nil;
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
                _processorsUsage = map(_processorsUsage, λ(id x, [BOAProcessorsUsage fromJSONDictionary:x]));
                _otherIDs = map(_otherIDs, λ(id x, [BOAOtherID fromJSONDictionary:x]));
            }
            return self;
        }else if([dict isKindOfClass:[BOADeviceInfo class]]){
            return (BOADeviceInfo*)dict;
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
        id resolved = BOADeviceInfo.properties[key];
        if (resolved) [super setValue:value forKey:resolved];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOADeviceInfo.properties.allValues] mutableCopy];
        
        // Rewrite property names that differ in JSON
        for (id jsonName in BOADeviceInfo.properties) {
            id propertyName = BOADeviceInfo.properties[jsonName];
            if (![jsonName isEqualToString:propertyName]) {
                dict[jsonName] = dict[propertyName];
                [dict removeObjectForKey:propertyName];
            }
        }
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"processorsUsage": NSNullify(map(_processorsUsage, λ(id x, [x JSONDictionary]))),
            @"otherIDs": NSNullify(map(_otherIDs, λ(id x, [x JSONDictionary]))),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAOtherID
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"idName": @"theIDName",
            @"idValue": @"theIDValue",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAOtherID alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOAOtherID class]]){
            return (BOAOtherID*)dict;
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
        id resolved = BOAOtherID.properties[key];
        if (resolved) [super setValue:value forKey:resolved];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOAOtherID.properties.allValues] mutableCopy];
        
        // Rewrite property names that differ in JSON
        for (id jsonName in BOAOtherID.properties) {
            id propertyName = BOAOtherID.properties[jsonName];
            if (![jsonName isEqualToString:propertyName]) {
                dict[jsonName] = dict[propertyName];
                [dict removeObjectForKey:propertyName];
            }
        }
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAProcessorsUsage
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"processorID": @"processorID",
            @"usagePercentage": @"usagePercentage",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAProcessorsUsage alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOAProcessorsUsage class]]){
            return (BOAProcessorsUsage*)dict;
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
        return [self dictionaryWithValuesForKeys:BOAProcessorsUsage.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOALocation
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"sentToServer": @"sentToServer",
            @"timeStamp": @"timeStamp",
            @"piiLocation": @"piiLocation",
            @"nonPIILocation": @"nonPIILocation",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOALocation alloc] initWithJSONDictionary:dict] : nil;
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
                _piiLocation = [BOAPiiLocation fromJSONDictionary:(id)_piiLocation];
                _nonPIILocation = [BOANonPIILocation fromJSONDictionary:(id)_nonPIILocation];
            }
            return self;
        }else if([dict isKindOfClass:[BOALocation class]]){
            return (BOALocation*)dict;
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
        id dict = [[self dictionaryWithValuesForKeys:BOALocation.properties.allValues] mutableCopy];
        
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

@implementation BOANonPIILocation
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"city": @"city",
            @"state": @"state",
            @"zip": @"zip",
            @"country": @"country",
            @"activity": @"activity",
            @"source": @"source",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOANonPIILocation alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOANonPIILocation class]]){
            return (BOANonPIILocation*)dict;
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
        return [self dictionaryWithValuesForKeys:BOANonPIILocation.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAPiiLocation
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"latitude": @"latitude",
            @"longitude": @"longitude",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAPiiLocation alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOAPiiLocation class]]){
            return (BOAPiiLocation*)dict;
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
        id resolved = BOAPiiLocation.properties[key];
        if (resolved) [super setValue:value forKey:resolved];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOAPiiLocation.properties.allValues] mutableCopy];
        
        // Rewrite property names that differ in JSON
        for (id jsonName in BOAPiiLocation.properties) {
            id propertyName = BOAPiiLocation.properties[jsonName];
            if (![jsonName isEqualToString:propertyName]) {
                dict[jsonName] = dict[propertyName];
                [dict removeObjectForKey:propertyName];
            }
        }
        
        return dict;
        
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAMemoryInfo
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"sentToServer": @"sentToServer",
            @"timeStamp": @"timeStamp",
            @"totalRAM": @"totalRAM",
            @"userMemory": @"userMemory",
            @"wireMemory": @"wireMemory",
            @"activeMemory": @"activeMemory",
            @"inActiveMemory": @"inActiveMemory",
            @"freeMemory": @"freeMemory",
            @"purgeableMemory": @"purgeableMemory",
        };    } @catch (NSException *exception) {
            BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAMemoryInfo alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOAMemoryInfo class]]){
            return (BOAMemoryInfo*)dict;
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
        return [self dictionaryWithValuesForKeys:BOAMemoryInfo.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOANetworkInfo
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"sentToServer": @"sentToServer",
            @"timeStamp": @"timeStamp",
            @"carrierName": @"carrierName",
            @"carrierCountry": @"carrierCountry",
            @"carrierMobileCountry": @"carrierMobileCountry",
            @"carrierISOCountryCode": @"carrierISOCountryCode",
            @"carrierMobileNetworkCode": @"carrierMobileNetworkCode",
            @"carrierAllowVOIP": @"carrierAllowVOIP",
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
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOANetworkInfo alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOANetworkInfo class]]){
            return (BOANetworkInfo*)dict;
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
        return [self dictionaryWithValuesForKeys:BOANetworkInfo.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOARetentionEvent
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"sentToServer": @"sentToServer",
            @"DAU": @"dau",
            @"WAU": @"wau",
            @"MAU": @"mau",
            @"DPU": @"dpu",
            @"WPU": @"wpu",
            @"MPU": @"mpu",
            @"appInstalled": @"appInstalled",
            @"newUser": @"theNewUser",
            @"DAST": @"dast",
            @"WAST": @"wast",
            @"MAST": @"mast",
            @"customEvents": @"customEvents",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOARetentionEvent alloc] initWithJSONDictionary:dict] : nil;
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
                _dau = [BOADau fromJSONDictionary:(id)_dau];
                _wau = [BOAWau fromJSONDictionary:(id)_wau];
                _mau = [BOAMau fromJSONDictionary:(id)_mau];
                _dpu = [BOADpu fromJSONDictionary:(id)_dpu];
                _wpu = [BOAWpu fromJSONDictionary:(id)_wpu];
                _mpu = [BOAMPU fromJSONDictionary:(id)_mpu];
                _appInstalled = [BOAAppInstalled fromJSONDictionary:(id)_appInstalled];
                _theNewUser = [BOANewUser fromJSONDictionary:(id)_theNewUser];
                _dast = [BOAAST fromJSONDictionary:(id)_dast];
                _wast = [BOAAST fromJSONDictionary:(id)_wast];
                _mast = [BOAAST fromJSONDictionary:(id)_mast];
                _customEvents = [BOACustomEvents fromJSONDictionary:(id)_customEvents];
            }
            return self;
        }else if([dict isKindOfClass:[BOARetentionEvent class]]){
            return (BOARetentionEvent*)dict;
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
        id resolved = BOARetentionEvent.properties[key];
        if (resolved) [super setValue:value forKey:resolved];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOARetentionEvent.properties.allValues] mutableCopy];
        
        // Rewrite property names that differ in JSON
        for (id jsonName in BOARetentionEvent.properties) {
            id propertyName = BOARetentionEvent.properties[jsonName];
            if (![jsonName isEqualToString:propertyName]) {
                dict[jsonName] = dict[propertyName];
                [dict removeObjectForKey:propertyName];
            }
        }
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"DAU": NSNullify([_dau JSONDictionary]),
            @"WAU": NSNullify([_wau JSONDictionary]),
            @"MAU": NSNullify([_mau JSONDictionary]),
            @"DPU": NSNullify([_dpu JSONDictionary]),
            @"WPU": NSNullify([_wpu JSONDictionary]),
            @"MPU": NSNullify([_mpu JSONDictionary]),
            @"appInstalled": NSNullify([_appInstalled JSONDictionary]),
            @"newUser": NSNullify([_theNewUser JSONDictionary]),
            @"DAST": NSNullify([_dast JSONDictionary]),
            @"WAST": NSNullify([_wast JSONDictionary]),
            @"MAST": NSNullify([_mast JSONDictionary]),
            @"customEvents": NSNullify([_customEvents JSONDictionary]),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAAppInstalled
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"sentToServer": @"sentToServer",
            @"mid" : @"mid",
            @"session_id" : @"session_id",
            @"isFirstLaunch": @"isFirstLaunch",
            @"timeStamp": @"timeStamp",
            @"appInstalledInfo": @"appInstalledInfo",
        };    } @catch (NSException *exception) {
            BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
        }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAAppInstalled alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOAAppInstalled class]]){
            return (BOAAppInstalled*)dict;
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
        id dict = [[self dictionaryWithValuesForKeys:BOAAppInstalled.properties.allValues] mutableCopy];
        
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

@implementation BOACustomEvents
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"timeStamp": @"timeStamp",
            @"mid" : @"mid",
            @"session_id" : @"session_id",
            @"sentToServer": @"sentToServer",
            @"eventName": @"eventName",
            @"visibleClassName": @"visibleClassName",
            @"eventInfo": @"eventInfo",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOACustomEvents alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOACustomEvents class]]){
            return (BOACustomEvents*)dict;
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
        id dict = [[self dictionaryWithValuesForKeys:BOACustomEvents.properties.allValues] mutableCopy];
        
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

@implementation BOAAST
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"sentToServer": @"sentToServer",
            @"mid" : @"mid",
            @"session_id" : @"session_id",
            @"timeStamp": @"timeStamp",
            @"averageSessionTime": @"averageSessionTime",
            @"dastInfo": @"dastInfo",
            @"mastInfo": @"mastInfo",
            @"wastInfo": @"wastInfo",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAAST alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOAAST class]]){
            return (BOAAST*)dict;
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
        id dict = [[self dictionaryWithValuesForKeys:BOAAST.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"dastInfo": NSNullify(_dastInfo),
            @"mastInfo": NSNullify(_mastInfo),
            @"wastInfo": NSNullify(_wastInfo),
        }];
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOADau
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"sentToServer": @"sentToServer",
            @"mid" : @"mid",
            @"session_id" : @"session_id",
            @"timeStamp": @"timeStamp",
            @"dauInfo": @"dauInfo",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOADau alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOADau class]]){
            return (BOADau*)dict;
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
        id dict = [[self dictionaryWithValuesForKeys:BOADau.properties.allValues] mutableCopy];
        
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

@implementation BOADpu
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"sentToServer": @"sentToServer",
            @"mid" : @"mid",
            @"session_id" : @"session_id",
            @"timeStamp": @"timeStamp",
            @"dpuInfo": @"dpuInfo",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOADpu alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOADpu class]]){
            return (BOADpu*)dict;
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
        id dict = [[self dictionaryWithValuesForKeys:BOADpu.properties.allValues] mutableCopy];
        
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

@implementation BOAMau
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"sentToServer": @"sentToServer",
            @"mid" : @"mid",
            @"session_id" : @"session_id",
            @"timeStamp": @"timeStamp",
            @"mauInfo": @"mauInfo",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAMau alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOAMau class]]){
            return (BOAMau*)dict;
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
        id dict = [[self dictionaryWithValuesForKeys:BOAMau.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"mauInfo": NSNullify(_mauInfo),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAMPU
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"sentToServer": @"sentToServer",
            @"mid" : @"mid",
            @"session_id" : @"session_id",
            @"timeStamp": @"timeStamp",
            @"mpuInfo": @"mpuInfo",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAMPU alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOAMPU class]]){
            return (BOAMPU*)dict;
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
        id dict = [[self dictionaryWithValuesForKeys:BOAMPU.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"mpuInfo": NSNullify(_mpuInfo),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOANewUser
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"sentToServer": @"sentToServer",
            @"mid" : @"mid",
            @"session_id" : @"session_id",
            @"isNewUser": @"isNewUser",
            @"timeStamp": @"timeStamp",
            @"newUserInfo": @"theNewUserInfo",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOANewUser alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOANewUser class]]){
            return (BOANewUser*)dict;
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
        id resolved = BOANewUser.properties[key];
        if (resolved) [super setValue:value forKey:resolved];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOANewUser.properties.allValues] mutableCopy];
        
        // Rewrite property names that differ in JSON
        for (id jsonName in BOANewUser.properties) {
            id propertyName = BOANewUser.properties[jsonName];
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

@implementation BOAWau
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"sentToServer": @"sentToServer",
            @"mid" : @"mid",
            @"session_id" : @"session_id",
            @"timeStamp": @"timeStamp",
            @"wauInfo": @"wauInfo",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAWau alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOAWau class]]){
            return (BOAWau*)dict;
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
        id dict = [[self dictionaryWithValuesForKeys:BOAWau.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"wauInfo": NSNullify(_wauInfo),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAWpu
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"sentToServer": @"sentToServer",
            @"mid" : @"mid",
            @"session_id" : @"session_id",
            @"timeStamp": @"timeStamp",
            @"wpuInfo": @"wpuInfo",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAWpu alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOAWpu class]]){
            return (BOAWpu*)dict;
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
        id dict = [[self dictionaryWithValuesForKeys:BOAWpu.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"wpuInfo": NSNullify(_wpuInfo),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAStorageInfo
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
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
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAStorageInfo alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOAStorageInfo class]]){
            return (BOAStorageInfo*)dict;
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
        return [self dictionaryWithValuesForKeys:BOAStorageInfo.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

NS_ASSUME_NONNULL_END
