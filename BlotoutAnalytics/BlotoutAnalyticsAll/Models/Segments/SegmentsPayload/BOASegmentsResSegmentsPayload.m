#import "BOASegmentsResSegmentsPayload.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"

// Shorthand for simple blocks
#define λ(decl, expr) (^(decl) { return (expr); })

// nil → NSNull conversion for JSON dictionaries
static id NSNullify(id _Nullable x) {
    return (x == nil || x == NSNull.null) ? NSNull.null : x;
}

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private model interfaces

@interface BOASegmentsResSegmentsPayload (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOASegmentsResGeo (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOASegmentsResMeta (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOASegmentsResSegment (JSONConversion)
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

BOASegmentsResSegmentsPayload *_Nullable BOASegmentsResSegmentsPayloadFromData(NSData *data, NSError **error)
{
    @try {
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
        return *error ? nil : [BOASegmentsResSegmentsPayload fromJSONDictionary:json];
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

BOASegmentsResSegmentsPayload *_Nullable BOASegmentsResSegmentsPayloadFromJSON(NSString *json, NSStringEncoding encoding, NSError **error)
{
    return BOASegmentsResSegmentsPayloadFromData([json dataUsingEncoding:encoding], error);
}

NSData *_Nullable BOASegmentsResSegmentsPayloadToData(BOASegmentsResSegmentsPayload *segmentsPayload, NSError **error)
{
    @try {
        id json = [segmentsPayload JSONDictionary];
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:error];
        return *error ? nil : data;
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

NSString *_Nullable BOASegmentsResSegmentsPayloadToJSON(BOASegmentsResSegmentsPayload *segmentsPayload, NSStringEncoding encoding, NSError **error)
{
    @try {
        NSData *data = BOASegmentsResSegmentsPayloadToData(segmentsPayload, error);
        return data ? [[NSString alloc] initWithData:data encoding:encoding] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

@implementation BOASegmentsResSegmentsPayload
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"meta": @"meta",
            @"geo": @"geo",
            @"segments": @"segments",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error
{
    @try {
        return BOASegmentsResSegmentsPayloadFromData(data, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    @try {
        return BOASegmentsResSegmentsPayloadFromJSON(json, encoding, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOASegmentsResSegmentsPayload alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
        _meta = [BOASegmentsResMeta fromJSONDictionary:(id)_meta];
        _geo = [BOASegmentsResGeo fromJSONDictionary:(id)_geo];
        _segments = map(_segments, λ(id x, [BOASegmentsResSegment fromJSONDictionary:x]));
    }
    return self;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOASegmentsResSegmentsPayload.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"meta": NSNullify([_meta JSONDictionary]),
            @"geo": NSNullify([_geo JSONDictionary]),
            @"segments": NSNullify(map(_segments, λ(id x, [x JSONDictionary]))),
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
        return BOASegmentsResSegmentsPayloadToData(self, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    @try {
        return BOASegmentsResSegmentsPayloadToJSON(self, encoding, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOASegmentsResGeo
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
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
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOASegmentsResGeo alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(nullable id)value forKey:(NSString *)key
{
    @try {
        id resolved = BOASegmentsResGeo.properties[key];
        if (resolved) [super setValue:value forKey:resolved];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOASegmentsResGeo.properties.allValues] mutableCopy];
        
        // Rewrite property names that differ in JSON
        for (id jsonName in BOASegmentsResGeo.properties) {
            id propertyName = BOASegmentsResGeo.properties[jsonName];
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

@implementation BOASegmentsResMeta
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
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
            @"dm": @"dm"
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOASegmentsResMeta alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        return [self dictionaryWithValuesForKeys:BOASegmentsResMeta.properties.allValues];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOASegmentsResSegment
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"id": @"identifier",
            @"event_time": @"eventTime",
            @"message_id": @"messageID",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOASegmentsResSegment alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
    
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(nullable id)value forKey:(NSString *)key
{
    @try {
        id resolved = BOASegmentsResSegment.properties[key];
        if (resolved) [super setValue:value forKey:resolved];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOASegmentsResSegment.properties.allValues] mutableCopy];
        
        // Rewrite property names that differ in JSON
        for (id jsonName in BOASegmentsResSegment.properties) {
            id propertyName = BOASegmentsResSegment.properties[jsonName];
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

NS_ASSUME_NONNULL_END
