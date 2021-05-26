// To parse this JSON:
//
//   NSError *error;
//   BOASegmentsResSegmentsPayload *segmentsPayload = [BOASegmentsResSegmentsPayload fromJSON:json encoding:NSUTF8Encoding error:&error];

#import <Foundation/Foundation.h>

@class BOASegmentsResSegmentsPayload;
@class BOASegmentsResGeo;
@class BOASegmentsResMeta;
@class BOASegmentsResSegment;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface BOASegmentsResSegmentsPayload : NSObject
@property (nonatomic, nullable, strong) BOASegmentsResMeta *meta;
@property (nonatomic, nullable, strong) BOASegmentsResGeo *geo;
@property (nonatomic, nullable, copy)   NSArray<BOASegmentsResSegment *> *segments;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error;
- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
- (NSData *_Nullable)toData:(NSError *_Nullable *)error;
@end

@interface BOASegmentsResGeo : NSObject
@property (nonatomic, nullable, copy)   NSString *conc;
@property (nonatomic, nullable, copy)   NSString *couc;
@property (nonatomic, nullable, copy)   NSString *reg;
@property (nonatomic, nullable, copy)   NSString *city;
@property (nonatomic, nullable, strong) NSNumber *zip;
@property (nonatomic, nullable, strong) NSNumber *lat;
@property (nonatomic, nullable, strong) NSNumber *geoLong;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;

@end

@interface BOASegmentsResMeta : NSObject
@property (nonatomic, nullable, strong) NSNumber *plf;
@property (nonatomic, nullable, copy)   NSString *appv;
@property (nonatomic, nullable, copy)   NSString *appn;
@property (nonatomic, nullable, strong)   NSNumber *jbrkn;
@property (nonatomic, nullable, strong)   NSNumber *vpn;
@property (nonatomic, nullable, strong) NSNumber *dcomp;
@property (nonatomic, nullable, strong) NSNumber *acomp;
@property (nonatomic, nullable, copy)   NSString *osn;
@property (nonatomic, nullable, copy)   NSString *osv;
@property (nonatomic, nullable, copy)   NSString *dmft;
@property (nonatomic, nullable, copy)   NSString *dm;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;

@end

@interface BOASegmentsResSegment : NSObject
@property (nonatomic, nullable, copy)   NSString *identifier;
@property (nonatomic, nullable, strong) NSNumber *eventTime;
@property (nonatomic, nullable, copy)   NSString *messageID;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;

@end

NS_ASSUME_NONNULL_END
