#import "BOASDKManifest.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOANetworkConstants.h"

// Shorthand for simple blocks
#define λ(decl, expr) (^(decl) { return (expr); })

// nil → NSNull conversion for JSON dictionaries
static id NSNullify(id _Nullable x) {
    return (x == nil || x == NSNull.null) ? NSNull.null : x;
}

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private model interfaces

@interface BOASDKManifest (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOASDKVariable (JSONConversion)
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

BOASDKManifest *_Nullable BOASDKManifestFromData(NSData *data, NSError **error)
{
    @try {
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
        return *error ? nil : [BOASDKManifest fromJSONDictionary:json];
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

BOASDKManifest *_Nullable BOASDKManifestFromJSON(NSString *json, NSStringEncoding encoding, NSError **error)
{
    @try {
        return BOASDKManifestFromData([json dataUsingEncoding:encoding], error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

NSData *_Nullable BOASDKManifestToData(BOASDKManifest *manifest, NSError **error)
{
    @try {
        id json = [manifest JSONDictionary];
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:error];
        return *error ? nil : data;
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

NSString *_Nullable BOASDKManifestToJSON(BOASDKManifest *manifest, NSStringEncoding encoding, NSError **error)
{
    @try {
        NSData *data = BOASDKManifestToData(manifest, error);
        return data ? [[NSString alloc] initWithData:data encoding:encoding] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

@implementation BOASDKManifest
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"variables": @"variables",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error
{
    @try {
        return BOASDKManifestFromData(data, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    @try {
        return BOASDKManifestFromJSON(json, encoding, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOASDKManifest alloc] initWithJSONDictionary:dict] : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
        _variables = map(_variables, λ(id x, [BOASDKVariable fromJSONDictionary:x]));
    }
    return self;
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOASDKManifest.properties.allValues] mutableCopy];
        
        // Map values that need translation
        [dict addEntriesFromDictionary:@{
            @"variables": NSNullify(map(_variables, λ(id x, [x JSONDictionary]))),
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
        return BOASDKManifestToData(self, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    @try {
        return BOASDKManifestToJSON(self, encoding, error);
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
@end

@implementation BOASDKVariable
+ (NSDictionary<NSString *, NSString *> *)properties
{
    @try {
        static NSDictionary<NSString *, NSString *> *properties;
        return properties = properties ? properties : @{
            @"variableId": @"variableID",
            @"value": @"value",
            @"variableDataType": @"variableDataType",
            @"variableName": @"variableName",
            @"isEditable": @"isEditable",
        };
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    @try {
        return dict ? [[BOASDKVariable alloc] initWithJSONDictionary:dict] : nil;
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
        id resolved = BOASDKVariable.properties[key];
        if (resolved) [super setValue:value forKey:resolved];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:BOASDKVariable.properties.allValues] mutableCopy];
        
        // Rewrite property names that differ in JSON
        for (id jsonName in BOASDKVariable.properties) {
            id propertyName = BOASDKVariable.properties[jsonName];
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
