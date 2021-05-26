// To parse this JSON:
//
//   NSError *error;
//   BOAEventsGetRequest *eventsGetRequest = [BOAEventsGetRequest fromJSON:json encoding:NSUTF8Encoding error:&error];

#import <Foundation/Foundation.h>

@class BOAEventsGetRequest;
@class BOAEventsGet;
@class BOAGeoEventsGet;
@class BOAMetaEventsGet;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface BOAEventsGetRequest : NSObject
@property (nonatomic, nullable, strong) BOAEventsGet *events;
@property (nonatomic, nullable, strong) BOAGeoEventsGet *geo;
@property (nonatomic, nullable, strong) BOAMetaEventsGet *meta;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error;
- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
- (NSData *_Nullable)toData:(NSError *_Nullable *)error;
@end

@interface BOAEventsGet : NSObject
@property (nonatomic, nullable, strong) NSNumber *lastUpdatedTime;
@end

@interface BOAGeoEventsGet : NSObject
@property (nonatomic, nullable, copy)   NSString *conc;
@property (nonatomic, nullable, copy)   NSString *couc;
@property (nonatomic, nullable, copy)   NSString *reg;
@property (nonatomic, nullable, copy)   NSString *city;
@property (nonatomic, nullable, strong) NSNumber *zip;
@end

@interface BOAMetaEventsGet : NSObject
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
@end

NS_ASSUME_NONNULL_END
