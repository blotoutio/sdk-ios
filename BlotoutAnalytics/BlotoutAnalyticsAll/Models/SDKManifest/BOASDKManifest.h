// To parse this JSON:
//
//   NSError *error;
//   BOASDKManifest *manifest = [BOASDKManifest fromJSON:json encoding:NSUTF8Encoding error:&error];

#import <Foundation/Foundation.h>

@class BOASDKManifest;
@class BOASDKVariable;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface BOASDKManifest : NSObject
@property (nonatomic, nullable, copy) NSArray<BOASDKVariable *> *variables;

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error;
- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
- (NSData *_Nullable)toData:(NSError *_Nullable *)error;
@end

@interface BOASDKVariable : NSObject
@property (nonatomic, nullable, strong) NSNumber *variableID;
@property (nonatomic, nullable, copy)   NSString *value;
@property (nonatomic, nullable, strong) NSNumber *variableDataType;
@property (nonatomic, nullable, copy)   NSString *variableName;
@property (nonatomic, nullable, strong) NSNumber *isEditable;

@end

NS_ASSUME_NONNULL_END
