// To parse this JSON:
//
//   NSError *error;
//   BOASystemAndDeveloperEvents *systemAndDeveloperEvents = [BOASystemAndDeveloperEvents fromJSON:json encoding:NSUTF8Encoding error:&error];

#import <Foundation/Foundation.h>

@class BOASystemAndDeveloperEvents;
@class BOAEvent;
@class BOAGeo;
@class BOAMeta;
@class BOAPIIPHIEvent;
NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface BOASystemAndDeveloperEvents : NSObject
@property (nonatomic, nullable, strong) BOAMeta *meta;
@property (nonatomic, nullable, strong) BOAMeta *pmeta;
@property (nonatomic, nullable, strong) BOAGeo *geo;
@property (nonatomic, nullable, copy)   NSArray<BOAEvent *> *events;
@property (nonatomic, nullable, copy)   NSArray<BOAEvent *> *piiEvents;
@property (nonatomic, nullable, copy)   NSArray<BOAEvent *> *phiEvents;
@property (nonatomic, nullable, strong)   BOAPIIPHIEvent  *pii;
@property (nonatomic, nullable, strong)   BOAPIIPHIEvent  *phi;

+ (instancetype)sharedInstanceFromJSONDictionary:(nullable NSDictionary *)dict;
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error;
- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
- (NSData *_Nullable)toData:(NSError *_Nullable *)error;
- (NSData *_Nullable)toPIIData:(NSError *_Nullable *)error;
- (NSData *_Nullable)toEventsData:(NSError *_Nullable *)error;
@end

@interface BOAEvent : NSObject
@property (nonatomic, nullable, strong) NSNumber *evt;
@property (nonatomic, nullable, strong) NSNumber *evcs;
@property (nonatomic, nullable, copy)   NSString *mid;
@property (nonatomic, nullable, copy)   NSString *evn;
@property (nonatomic, nullable, strong) NSNumber *nmo;
@property (nonatomic, nullable, strong) NSNumber *identifier;
@property (nonatomic, nullable, strong) NSNumber *tst;
@property (nonatomic, nullable, strong) NSNumber *count;
@property (nonatomic, nullable, copy)   NSString *scrn;
@property (nonatomic, nullable, copy)   NSString *value;
@property (nonatomic, nullable, copy)   NSString *userid;
@property (nonatomic, nullable, copy)   NSArray<NSNumber *> *uustate;
@property (nonatomic, nullable, copy)   NSArray<NSString *> *nvg;
@property (nonatomic, nullable, copy)   NSArray<NSNumber *> *nvg_tm;
@property (nonatomic, nullable, copy)   NSDictionary *codifiedInfo;
@property (nonatomic, nullable, copy)   NSString *session_id;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface BOAPIIPHIEvent : NSObject

@property (nonatomic, nullable, copy) NSString *key;
@property (nonatomic, nullable, copy) NSString *data;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
@end



@interface BOAGeo : NSObject
@property (nonatomic, nullable, copy)   NSString *conc;
@property (nonatomic, nullable, copy)   NSString *couc;
@property (nonatomic, nullable, copy)   NSString *reg;
@property (nonatomic, nullable, copy)   NSString *city;
@property (nonatomic, nullable, strong) NSNumber *zip;
@property (nonatomic, nullable, strong) NSNumber *lat;
@property (nonatomic, nullable, strong) NSNumber *geoLong;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end

@interface BOAMeta : NSObject
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
@property (nonatomic, nullable, copy)   NSString *sdkv;
@property (nonatomic, nullable, copy)   NSNumber *tz_offset;
@property (nonatomic, nullable, copy)   NSNumber *user_id_created;

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;

@end


NS_ASSUME_NONNULL_END
