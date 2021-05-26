#import "BOASegmentEvents.h"
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

@interface BOASegmentEvents (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOASegmentsGeo (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOASegment (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOARuleset (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOARule (JSONConversion)
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

BOASegmentEvents *_Nullable BOASegmentEventsFromData(NSData *data, NSError **error)
{
    @try {
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
        return *error ? nil : [BOASegmentEvents fromJSONDictionary:json];
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

BOASegmentEvents *_Nullable BOASegmentEventsFromJSON(NSString *json, NSStringEncoding encoding, NSError **error)
{
    @try {
        return BOASegmentEventsFromData([json dataUsingEncoding:encoding], error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

NSData *_Nullable BOASegmentEventsToData(BOASegmentEvents *segmentEvents, NSError **error)
{
    @try {
        id json = [segmentEvents JSONDictionary];
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:error];
        return *error ? nil : data;
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

NSString *_Nullable BOASegmentEventsToJSON(BOASegmentEvents *segmentEvents, NSStringEncoding encoding, NSError **error)
{
    @try {
        NSData *data = BOASegmentEventsToData(segmentEvents, error);
        return data ? [[NSString alloc] initWithData:data encoding:encoding] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

@implementation BOASegmentEvents
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"geo": @"geo",
            @"segments": @"segments",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error
{
    @try {
        return BOASegmentEventsFromData(data, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
    
}

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    @try {
        return BOASegmentEventsFromJSON(json, encoding, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOASegmentEvents alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
    
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
        _geo = [BOASegmentsGeo fromJSONDictionary:(id)_geo];
        _segments = map(_segments, λ(id x, [BOASegment fromJSONDictionary:x]));
    }
    return self;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOASegmentEvents.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
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
        return BOASegmentEventsToData(self, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    @try {
        return BOASegmentEventsToJSON(self, encoding, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOASegmentsGeo
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"conc": @"continentCode",
            @"couc": @"countryCode",
            @"reg": @"regionCode",
            @"city": @"city",
            @"zip": @"zip",
            @"lat": @"latitude",
            @"long": @"longitude",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    //When geo is not sent by SDK then in funnel also geo comes as null or empty, also from server if geo is coming then geo selection for targeting should be there
    @try {
        return dict ? [[BOASegmentsGeo alloc] initWithJSONDictionary:dict] : nil;
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
        id resolved = BOASegmentsGeo.properties[key];
        if (resolved) [super setValue:value forKey:resolved];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOASegmentsGeo.properties.allValues] mutableCopy];
        
        // Rewrite property names that differ in JSON
        for (id jsonName in BOASegmentsGeo.properties) {
            id propertyName = BOASegmentsGeo.properties[jsonName];
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

@implementation BOASegment
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"id": @"identifier",
            @"name": @"name",
            @"state": @"state",
            @"createdTime": @"createdTime",
            @"ruleset": @"ruleset",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOASegment alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
        _ruleset = [BOARuleset fromJSONDictionary:(id)_ruleset];
    }
    return self;
}

- (void)setValue:(nullable id)value forKey:(NSString *)key
{
    @try {
        id resolved = BOASegment.properties[key];
        if (resolved) [super setValue:value forKey:resolved];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOASegment.properties.allValues] mutableCopy];
        
        // Rewrite property names that differ in JSON
        for (id jsonName in BOASegment.properties) {
            id propertyName = BOASegment.properties[jsonName];
            if (![jsonName isEqualToString:propertyName]) {
                dict[jsonName] = dict[propertyName];
                [dict removeObjectForKey:propertyName];
            }
        }
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"ruleset": NSNullify([_ruleset JSONDictionary]),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOARuleset
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"rules": @"rules",
            @"condition": @"condition",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOARuleset alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
        _rules = map(_rules, λ(id x, [BOARule fromJSONDictionary:x]));
    }
    return self;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOARuleset.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"rules": NSNullify(map(_rules, λ(id x, [x JSONDictionary]))),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
    
}
@end

@implementation BOARule
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"segmentId": @"segmentID",
            @"event_name": @"eventName",
            @"subEventCategory": @"subEventCategory",
            @"operator": @"operatorKey", //Check for this to fix if crash happen.
            @"key": @"key",
            @"value": @"value",
            @"rules": @"rules",
            @"condition": @"condition",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOARule alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
        _rules = map(_rules, λ(id x, [BOARule fromJSONDictionary:x]));
    }
    return self;
}

- (void)setValue:(nullable id)value forKey:(NSString *)key
{
    @try {
        id resolved = BOARule.properties[key];
        if (resolved) [super setValue:value forKey:resolved];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOARule.properties.allValues] mutableCopy];
        
        // Rewrite property names that differ in JSON
        for (id jsonName in BOARule.properties) {
            id propertyName = BOARule.properties[jsonName];
            if (![jsonName isEqualToString:propertyName]) {
                dict[jsonName] = dict[propertyName];
                [dict removeObjectForKey:propertyName];
            }
        }
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"rules": NSNullify(map(_rules, λ(id x, [x JSONDictionary]))),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

NS_ASSUME_NONNULL_END
