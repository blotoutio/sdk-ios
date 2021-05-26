// To parse this JSON:
//
//   NSError *error;
//   BOAFunnelPayload *funnelPayload = [BOAFunnelPayload fromJSON:json encoding:NSUTF8Encoding error:&error];

#import <Foundation/Foundation.h>

@class BOAFunnelPayload;
@class BOAFunnelEvent;
@class BOAFunnelGeo;
@class BOAFunnelMeta;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface BOAFunnelPayload : NSObject
@property (nonatomic, nullable, strong) BOAFunnelMeta *meta;
@property (nonatomic, nullable, strong) BOAFunnelGeo *geo;
@property (nonatomic, nullable, copy)   NSArray<BOAFunnelEvent *> *funnelEvents;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error;
- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
- (NSData *_Nullable)toData:(NSError *_Nullable *)error;
@end

@interface BOAFunnelEvent : NSObject
@property (nonatomic, nullable, copy)   NSString *identifier;
@property (nonatomic, nullable, copy)   NSString *version;
@property (nonatomic, nullable, copy)   NSString *name;
@property (nonatomic, nullable, strong) NSNumber *eventTime;
@property (nonatomic, nullable, copy)   NSString *dayOfAnalysis;
@property (nonatomic, nullable, strong) NSNumber *daySessionCount;
@property (nonatomic, nullable, copy)   NSString *messageID;
@property (nonatomic, nullable, strong) NSNumber *isaDayEvent;
@property (nonatomic, nullable, strong) NSNumber *isTraversed;
@property (nonatomic, nullable, strong) NSNumber *dayTraversedCount;
@property (nonatomic, nullable, copy)   NSArray<NSNumber *> *visits;
@property (nonatomic, nullable, copy)   NSArray<NSNumber *> *navigationTime;
@property (nonatomic, nullable, strong) NSNumber *userReferral;
@property (nonatomic, nullable, strong) NSNumber *userTraversedCount;
@property (nonatomic, nullable, copy)   NSString *prevTraversalDay;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;

@end

@interface BOAFunnelGeo : NSObject
@property (nonatomic, nullable, copy)   NSString *conc;
@property (nonatomic, nullable, copy)   NSString *couc;
@property (nonatomic, nullable, copy)   NSString *reg;
@property (nonatomic, nullable, copy)   NSString *city;
@property (nonatomic, nullable, strong) NSNumber *zip;
@property (nonatomic, nullable, strong) NSNumber *latitude;
@property (nonatomic, nullable, strong) NSNumber *longitude;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAFunnelMeta : NSObject
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

NS_ASSUME_NONNULL_END
