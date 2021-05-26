// To parse this JSON:
//
//   NSError *error;
//   BOAFunnelAndCodifiedEvents *funnelAndCodifiedEvents = [BOAFunnelAndCodifiedEvents fromJSON:json encoding:NSUTF8Encoding error:&error];

#import <Foundation/Foundation.h>

@class BOAFunnelAndCodifiedEvents;
@class BOAEventsCodified;
@class BOAEventsFunnel;
@class BOAEventList;
@class BOAGeoFunnelAndCodifed;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface BOAFunnelAndCodifiedEvents : NSObject
@property (nonatomic, nullable, copy) NSArray<BOAEventsCodified *> *eventsCodified;
@property (nonatomic, nullable, copy) NSArray<BOAEventsFunnel *> *eventsFunnel;

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error;
- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
- (NSData *_Nullable)toData:(NSError *_Nullable *)error;
@end

@interface BOAEventsCodified : NSObject
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
+ (NSDictionary<NSString *, NSString *> *)properties;
- (instancetype)initWithJSONDictionary:(NSDictionary *)dict;
- (void)setValue:(nullable id)value forKey:(NSString *)key;
- (NSDictionary *)JSONDictionary;

@property (nonatomic, nullable, copy)   NSString *eventCategory;
@property (nonatomic, nullable, copy)   NSString *eventCategorySubtype;
@property (nonatomic, nullable, copy)   NSString *eventName;
@property (nonatomic, nullable, strong) NSNumber *operation;
@property (nonatomic, nullable, copy)   NSString *version;
@property (nonatomic, nullable, copy)   NSString *createdTime;
@property (nonatomic, nullable, copy)   NSString *screen;
@property (nonatomic, nullable, copy)   NSArray<NSDictionary<NSString *, NSString *> *> *properties;
@end

@interface BOAEventsFunnel : NSObject
+ (NSDictionary<NSString *, NSString *> *)properties;
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (instancetype)initWithJSONDictionary:(NSDictionary *)dict;
- (void)setValue:(nullable id)value forKey:(NSString *)key;
- (NSDictionary *)JSONDictionary;

@property (nonatomic, nullable, copy)   NSString *identifier;
@property (nonatomic, nullable, copy)   NSString *name;
@property (nonatomic, nullable, strong) NSNumber *state;
@property (nonatomic, nullable, copy)   NSString *version;
@property (nonatomic, nullable, copy)   NSString *createdTime;
@property (nonatomic, nullable, strong) BOAGeoFunnelAndCodifed *geo;
@property (nonatomic, nullable, copy)   NSArray<BOAEventList *> *eventList;
@end

@interface BOAEventList : NSObject
+ (NSDictionary<NSString *, NSString *> *)properties;
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (instancetype)initWithJSONDictionary:(NSDictionary *)dict;
- (void)setValue:(nullable id)value forKey:(NSString *)key;
- (NSDictionary *)JSONDictionary;

@property (nonatomic, nullable, copy) NSString *eventCategory;
@property (nonatomic, nullable, copy) NSString *eventCategorySubtype;
@property (nonatomic, nullable, copy) NSString *eventName;
@property (nonatomic, nullable, copy) NSString *screen;
@property (nonatomic, nullable, copy) NSString *condition;
@property (nonatomic, nullable, copy) NSArray<NSDictionary<NSString *, NSString *> *> *properties;
@end

@interface BOAGeoFunnelAndCodifed : NSObject
+ (NSDictionary<NSString *, NSString *> *)properties;
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (instancetype)initWithJSONDictionary:(NSDictionary *)dict;
- (void)setValue:(nullable id)value forKey:(NSString *)key;
- (NSDictionary *)JSONDictionary;

@property (nonatomic, nullable, copy)   NSString *continentCode;
@property (nonatomic, nullable, copy)   NSString *countryCode;
@property (nonatomic, nullable, copy)   NSString *regionCode;
@property (nonatomic, nullable, copy)   NSString *city;
@property (nonatomic, nullable, copy)   NSString *zip;
@property (nonatomic, nullable, strong) NSNumber *latitude;
@property (nonatomic, nullable, strong) NSNumber *longitude;
@end

NS_ASSUME_NONNULL_END
