#import "BOASystemAndDeveloperEvents.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"

// Shorthand for simple blocks
#define λ(decl, expr) (^(decl) { return (expr); })

// nil → NSNull conversion for JSON dictionaries
static id NSNullify(id _Nullable x) {
    return (x == nil || x == NSNull.null) ? NSNull.null : x;
}
static id sBOASysDevEventsSharedInstance = nil;
NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private model interfaces

@interface BOASystemAndDeveloperEvents (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
- (NSDictionary *)PIIJSONDictionary;
- (NSDictionary *)EventsJSONDictionary;
@end

@interface BOAEvent (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAPIIPHIEvent (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAGeo (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAMeta (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

static id map(id collection, id (^f)(id value)) {
    @try {
        id result = nil;
        if ([collection isKindOfClass:NSArray.class]) {
            result = [NSMutableArray arrayWithCapacity:[(NSArray*)collection count]];
            for (id x in collection) [result addObject:f(x)];
        } else if ([collection isKindOfClass:NSDictionary.class]) {
            result = [NSMutableDictionary dictionaryWithCapacity:[(NSDictionary*)collection count]];
            for (id key in collection) [result setObject:f([collection objectForKey:key]) forKey:key];
        }
        return result;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

#pragma mark - JSON serialization

BOASystemAndDeveloperEvents *_Nullable BOASystemAndDeveloperEventsFromData(NSData *data, NSError **error)
{
    @try {
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
        return *error ? nil : [BOASystemAndDeveloperEvents fromJSONDictionary:json];
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

BOASystemAndDeveloperEvents *_Nullable BOASystemAndDeveloperEventsFromJSON(NSString *json, NSStringEncoding encoding, NSError **error)
{
    @try {
        return BOASystemAndDeveloperEventsFromData([json dataUsingEncoding:encoding], error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

NSData *_Nullable BOASystemAndDeveloperEventsToData(BOASystemAndDeveloperEvents *systemAndDeveloperEvents, NSError **error)
{
    @try {
        id json = [systemAndDeveloperEvents JSONDictionary];
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:error];
        return *error ? nil : data;
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

NSData *_Nullable BOASystemAndDeveloperEventsToPIIData(BOASystemAndDeveloperEvents *systemAndDeveloperEvents, NSError **error)
{
    @try {
        id json = [systemAndDeveloperEvents PIIJSONDictionary];
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:error];
        return *error ? nil : data;
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}


NSData *_Nullable BOASystemAndDeveloperEventsToEventsData(BOASystemAndDeveloperEvents *systemAndDeveloperEvents, NSError **error)
{
    @try {
        id json = [systemAndDeveloperEvents EventsJSONDictionary];
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:error];
        return *error ? nil : data;
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

NSString *_Nullable BOASystemAndDeveloperEventsToJSON(BOASystemAndDeveloperEvents *systemAndDeveloperEvents, NSStringEncoding encoding, NSError **error)
{
    @try {
        NSData *data = BOASystemAndDeveloperEventsToData(systemAndDeveloperEvents, error);
        return data ? [[NSString alloc] initWithData:data encoding:encoding] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

@implementation BOASystemAndDeveloperEvents
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"meta": @"meta",
        @"pmeta": @"pmeta",
        @"geo": @"geo",
        @"events": @"events",
        @"piiEvents": @"piiEvents",
        @"phiEvents": @"phiEvents",
        @"pii": @"pii",
        @"phi": @"phi",
    };
}

+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error
{
    @try {
        return BOASystemAndDeveloperEventsFromData(data, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    @try {
        return BOASystemAndDeveloperEventsFromJSON(json, encoding, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOASystemAndDeveloperEvents alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)sharedInstanceFromJSONDictionary:(nullable NSDictionary *)dict {
    @try {
        if (!dict) {
            return sBOASysDevEventsSharedInstance;
        }
        static dispatch_once_t boaSysDevEventsaOnceToken = 0;
        dispatch_once(&boaSysDevEventsaOnceToken, ^{
            sBOASysDevEventsSharedInstance = [BOASystemAndDeveloperEvents fromJSONDictionary:dict];
        });
        return  sBOASysDevEventsSharedInstance;
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
                _meta = [BOAMeta fromJSONDictionary:(id)_meta];
                _pmeta = [BOAMeta fromJSONDictionary:(id)_pmeta];
                _geo = [BOAGeo fromJSONDictionary:(id)_geo];
                _events = map(_events, λ(id x, [BOAEvent fromJSONDictionary:x]));
                _piiEvents = map(_piiEvents, λ(id x, [BOAEvent fromJSONDictionary:x]));
                _phiEvents = map(_phiEvents, λ(id x, [BOAEvent fromJSONDictionary:x]));
                _pii = [BOAPIIPHIEvent fromJSONDictionary:(id)_pii];
                _phi = [BOAPIIPHIEvent fromJSONDictionary:(id)_phi];
            }
            return self;
        }else if([dict isKindOfClass:[BOASystemAndDeveloperEvents class]]){
            return (BOASystemAndDeveloperEvents*)dict;
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
        id dict = [[self dictionaryWithValuesForKeys:BOASystemAndDeveloperEvents.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"meta": NSNullify([_meta JSONDictionary]),
            @"pmeta": NSNullify([_pmeta JSONDictionary]),
            @"geo": NSNullify([_geo JSONDictionary]),
            @"events": NSNullify(map(_events, λ(id x, [x JSONDictionary]))),
            @"piiEvents": NSNullify(map(_piiEvents, λ(id x, [x JSONDictionary]))),
            @"phiEvents": NSNullify(map(_phiEvents, λ(id x, [x JSONDictionary]))),
            @"pii": NSNullify([_pii JSONDictionary]),
            @"phi": NSNullify([_phi JSONDictionary])
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)EventsJSONDictionary
{
    @try {
        id dict = @{
            @"meta": NSNullify([_meta JSONDictionary]),
            @"pmeta": NSNullify([_pmeta JSONDictionary]),
            @"geo": NSNullify([_geo JSONDictionary]),
            @"events": NSNullify(map(_events, λ(id x, [x JSONDictionary]))),
        };
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSDictionary *)PIIJSONDictionary
{
    @try {
        id dict = @{
            @"meta": NSNullify([_meta JSONDictionary]),
            @"geo": NSNullify([_geo JSONDictionary]),
            @"pii": NSNullify([_pii JSONDictionary]),
            @"phi": NSNullify([_phi JSONDictionary])
        };
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSData *_Nullable)toData:(NSError *_Nullable *)error
{
    @try {
        return BOASystemAndDeveloperEventsToData(self, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSData *_Nullable)toPIIData:(NSError *_Nullable *)error
{
    @try {
        return BOASystemAndDeveloperEventsToPIIData(self, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSData *_Nullable)toEventsData:(NSError *_Nullable *)error
{
    @try {
        return BOASystemAndDeveloperEventsToEventsData(self, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}


- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    @try {
        return BOASystemAndDeveloperEventsToJSON(self, encoding, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAEvent
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"evt": @"evt",
        @"evcs": @"evcs",
        @"mid": @"mid",
        @"evn": @"evn",
        @"nmo": @"nmo",
        @"id": @"identifier",
        @"tst": @"tst",
        @"count": @"count",
        @"scrn": @"scrn",
        @"value": @"value",
        @"uustate": @"uustate",
        @"properties": @"properties",
        @"userid":@"userid",
        @"nvg":@"nvg",
        @"nvg_tm":@"nvg_tm"
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAEvent alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOAEvent class]]){
            return (BOAEvent*)dict;
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
        id resolved = BOAEvent.properties[key];
        if (resolved) [super setValue:value forKey:resolved];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOAEvent.properties.allValues] mutableCopy];
        
        // Rewrite property names that differ in JSON
        for (id jsonName in BOAEvent.properties) {
            id propertyName = BOAEvent.properties[jsonName];
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

@implementation BOAPIIPHIEvent
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"key": @"key",
        @"data": @"data"
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict {
    @try {
        return dict ? [[BOAPIIPHIEvent alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict {
    @try {
        if ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]]) {
            if (self = [super init]) {
                [self setValuesForKeysWithDictionary:dict];
            }
            return self;
        }else if([dict isKindOfClass:[BOAPIIPHIEvent class]]){
            return (BOAPIIPHIEvent*)dict;
        }
        return nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (void)setValue:(nullable id)value forKey:(NSString *)key {
    @try {
        id resolved = BOAPIIPHIEvent.properties[key];
        if (resolved) [super setValue:value forKey:resolved];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (NSDictionary *)JSONDictionary {
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOAPIIPHIEvent.properties.allValues] mutableCopy];
        
        // Rewrite property names that differ in JSON
        for (id jsonName in BOAPIIPHIEvent.properties) {
            id propertyName = BOAPIIPHIEvent.properties[jsonName];
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


@implementation BOAGeo
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"conc": @"conc",
        @"couc": @"couc",
        @"reg": @"reg",
        @"city": @"city",
        @"zip": @"zip",
        @"lat": @"lat",
        @"long": @"geoLong",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAGeo alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOAGeo class]]){
            return (BOAGeo*)dict;
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
        id resolved = BOAGeo.properties[key];
        if (resolved) [super setValue:value forKey:resolved];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOAGeo.properties.allValues] mutableCopy];
        
        // Rewrite property names that differ in JSON
        for (id jsonName in BOAGeo.properties) {
            id propertyName = BOAGeo.properties[jsonName];
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

@implementation BOAMeta
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"plf": @"plf",
        @"appv": @"appv",
        @"appn": @"appn",
        @"jbrkn": @"jbrkn",
        @"vpn": @"vpn",
        @"dcomp": @"dcomp",
        @"acomp": @"acomp",
        @"osn": @"osn",
        @"osv": @"osv",
        @"dmft": @"dmft",
        @"dm": @"dm",
        @"sdkv": @"sdkv",
        @"tz_offset": @"tz_offset",
        @"user_id_created": @"user_id_created"
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAMeta alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOAMeta class]]){
            return (BOAMeta*)dict;
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
        return [self dictionaryWithValuesForKeys:BOAMeta.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

NS_ASSUME_NONNULL_END
