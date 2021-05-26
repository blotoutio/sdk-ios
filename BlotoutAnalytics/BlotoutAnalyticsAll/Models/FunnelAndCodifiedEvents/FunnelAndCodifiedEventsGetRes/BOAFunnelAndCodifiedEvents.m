#import "BOAFunnelAndCodifiedEvents.h"
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

@interface BOAFunnelAndCodifiedEvents (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAEventsCodified (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAEventsFunnel (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAEventList (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAGeoFunnelAndCodifed (JSONConversion)
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

BOAFunnelAndCodifiedEvents *_Nullable BOAFunnelAndCodifiedEventsFromData(NSData *data, NSError **error)
{
    @try {
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
        return *error ? nil : [BOAFunnelAndCodifiedEvents fromJSONDictionary:json];
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

BOAFunnelAndCodifiedEvents *_Nullable BOAFunnelAndCodifiedEventsFromJSON(NSString *json, NSStringEncoding encoding, NSError **error)
{
    @try {
        return BOAFunnelAndCodifiedEventsFromData([json dataUsingEncoding:encoding], error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

NSData *_Nullable BOAFunnelAndCodifiedEventsToData(BOAFunnelAndCodifiedEvents *funnelAndCodifiedEvents, NSError **error)
{
    @try {
        id json = [funnelAndCodifiedEvents JSONDictionary];
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:error];
        return *error ? nil : data;
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

NSString *_Nullable BOAFunnelAndCodifiedEventsToJSON(BOAFunnelAndCodifiedEvents *funnelAndCodifiedEvents, NSStringEncoding encoding, NSError **error)
{
    @try {
        NSData *data = BOAFunnelAndCodifiedEventsToData(funnelAndCodifiedEvents, error);
        return data ? [[NSString alloc] initWithData:data encoding:encoding] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

@implementation BOAFunnelAndCodifiedEvents
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"events_codified": @"eventsCodified",
            @"funnels": @"eventsFunnel",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error
{
    @try {
        return BOAFunnelAndCodifiedEventsFromData(data, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    @try {
        return BOAFunnelAndCodifiedEventsFromJSON(json, encoding, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAFunnelAndCodifiedEvents alloc] initWithJSONDictionary:dict] : nil;
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
                _eventsCodified = map(_eventsCodified, λ(id x, [BOAEventsCodified fromJSONDictionary:x]));
                _eventsFunnel = map(_eventsFunnel, λ(id x, [BOAEventsFunnel fromJSONDictionary:x]));
            }
            return self;
        }else if([dict isKindOfClass:[BOAFunnelAndCodifiedEvents class]]){
            return (BOAFunnelAndCodifiedEvents*)dict;
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
        id resolved = BOAFunnelAndCodifiedEvents.properties[key];
        if (resolved) [super setValue:value forKey:resolved];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOAFunnelAndCodifiedEvents.properties.allValues] mutableCopy];
        
        // Rewrite property names that differ in JSON
        for (id jsonName in BOAFunnelAndCodifiedEvents.properties) {
            id propertyName = BOAFunnelAndCodifiedEvents.properties[jsonName];
            if (![jsonName isEqualToString:propertyName]) {
                dict[jsonName] = dict[propertyName];
                [dict removeObjectForKey:propertyName];
            }
        }
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"events_codified": NSNullify(map(_eventsCodified, λ(id x, [x JSONDictionary]))),
            @"funnels": NSNullify(map(_eventsFunnel, λ(id x, [x JSONDictionary]))),
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
        return BOAFunnelAndCodifiedEventsToData(self, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
    
}

- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    @try {
        return BOAFunnelAndCodifiedEventsToJSON(self, encoding, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAEventsCodified
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"event_category": @"eventCategory",
            @"event_category_subtype": @"eventCategorySubtype",
            @"event_name": @"eventName",
            @"operation": @"operation",
            @"version": @"version",
            @"createdTime": @"createdTime",
            @"screen": @"screen",
            @"properties": @"properties",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAEventsCodified alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOAEventsCodified class]]){
            return (BOAEventsCodified*)dict;
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
        id resolved = BOAEventsCodified.properties[key];
        if (resolved) [super setValue:value forKey:resolved];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOAEventsCodified.properties.allValues] mutableCopy];
        
        // Rewrite property names that differ in JSON
        for (id jsonName in BOAEventsCodified.properties) {
            id propertyName = BOAEventsCodified.properties[jsonName];
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

@implementation BOAEventsFunnel
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"id": @"identifier",
            @"name": @"name",
            @"state":@"state",
            @"version": @"version",
            @"createdTime": @"createdTime",
            @"geo": @"geo",
            @"event_list": @"eventList",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAEventsFunnel alloc] initWithJSONDictionary:dict] : nil;
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
                _geo = [BOAGeoFunnelAndCodifed fromJSONDictionary:(id)_geo];
                _eventList = map(_eventList, λ(id x, [BOAEventList fromJSONDictionary:x]));
            }
            return self;
        }else if([dict isKindOfClass:[BOAEventsFunnel class]]){
            return (BOAEventsFunnel*)dict;
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
        id resolved = BOAEventsFunnel.properties[key];
        if (resolved) [super setValue:value forKey:resolved];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOAEventsFunnel.properties.allValues] mutableCopy];
        
        // Rewrite property names that differ in JSON
        for (id jsonName in BOAEventsFunnel.properties) {
            id propertyName = BOAEventsFunnel.properties[jsonName];
            if (![jsonName isEqualToString:propertyName]) {
                dict[jsonName] = dict[propertyName];
                [dict removeObjectForKey:propertyName];
            }
        }
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"geo": NSNullify([_geo JSONDictionary]),
            @"event_list": NSNullify(map(_eventList, λ(id x, [x JSONDictionary])))
        }];
        
        return dict;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOAEventList
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"event_category": @"eventCategory",
            @"subEventCategory": @"eventCategorySubtype",
            @"event_name": @"eventName",
            @"screen": @"screen",
            @"condition" : @"condition",
            @"properties": @"properties",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOAEventList alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOAEventList class]]){
            return (BOAEventList*)dict;
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
        id resolved = BOAEventList.properties[key];
        if (resolved) [super setValue:value forKey:resolved];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOAEventList.properties.allValues] mutableCopy];
        // Rewrite property names that differ in JSON
        for (id jsonName in BOAEventList.properties) {
            id propertyName = BOAEventList.properties[jsonName];
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

@implementation BOAGeoFunnelAndCodifed
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
    @try {
        return dict ? [[BOAGeoFunnelAndCodifed alloc] initWithJSONDictionary:dict] : nil;
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
        }else if([dict isKindOfClass:[BOAGeoFunnelAndCodifed class]]){
            return (BOAGeoFunnelAndCodifed*)dict;
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
        id resolved = BOAGeoFunnelAndCodifed.properties[key];
        if (resolved) [super setValue:value forKey:resolved];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOAGeoFunnelAndCodifed.properties.allValues] mutableCopy];
        
        // Rewrite property names that differ in JSON
        for (id jsonName in BOAGeoFunnelAndCodifed.properties) {
            id propertyName = BOAGeoFunnelAndCodifed.properties[jsonName];
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
