// To parse this JSON:
//
//   NSError *error;
//   BOASegmentEvents *segmentEvents = [BOASegmentEvents fromJSON:json encoding:NSUTF8Encoding error:&error];

#import <Foundation/Foundation.h>

@class BOASegmentEvents;
@class BOASegmentsGeo;
@class BOASegment;
@class BOARuleset;
@class BOARule;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface BOASegmentEvents : NSObject
@property (nonatomic, nullable, strong) BOASegmentsGeo *geo;
@property (nonatomic, nullable, copy)   NSArray<BOASegment *> *segments;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error;
- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
- (NSData *_Nullable)toData:(NSError *_Nullable *)error;
@end

@interface BOASegmentsGeo : NSObject
@property (nonatomic, nullable, copy)   NSString *continentCode;
@property (nonatomic, nullable, copy)   NSString *countryCode;
@property (nonatomic, nullable, copy)   NSString *regionCode;
@property (nonatomic, nullable, copy)   NSString *city;
@property (nonatomic, nullable, strong) NSNumber *zip;
@property (nonatomic, nullable, strong) NSNumber *latitude;
@property (nonatomic, nullable, strong) NSNumber *longitude;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;

@end

@interface BOASegment : NSObject
@property (nonatomic, nullable, strong) NSNumber *identifier;
@property (nonatomic, nullable, copy)   NSString *name;
@property (nonatomic, nullable, strong) NSNumber *state;
@property (nonatomic, nullable, strong) NSNumber *createdTime;
@property (nonatomic, nullable, strong) BOARuleset *ruleset;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;

@end

@interface BOARuleset : NSObject
@property (nonatomic, nullable, copy) NSArray<BOARule *> *rules;
@property (nonatomic, nullable, copy) NSString *condition;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;

@end

@interface BOARule : NSObject
@property (nonatomic, nullable, strong) NSString *eventName;
@property (nonatomic, nullable, strong) NSNumber *segmentID;
@property (nonatomic, nullable, strong) NSNumber *subEventCategory;
@property (nonatomic, nullable, strong) NSString *operatorKey;
@property (nonatomic, nullable, copy)   NSString *key;
@property (nonatomic, nullable, copy)   NSArray<NSString *> *value;
@property (nonatomic, nullable, copy)   NSArray<BOARule *> *rules;
@property (nonatomic, nullable, copy)   NSString *condition;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;

@end

NS_ASSUME_NONNULL_END
