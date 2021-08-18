//
//  BOAStorage.h
//  BlotoutAnalytics
//
//  Copyright © 2021 Blotout. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "BOACrypto.h"

@protocol BOAStorage <NSObject>

@property (nonatomic, strong, nullable) id<BOACrypto> crypto;

- (void)removeKey:(NSString *_Nonnull)key;
- (void)resetAll;

- (void)setData:(NSData *_Nonnull)data forKey:(NSString *_Nonnull)key;
- (NSData *_Nullable)dataForKey:(NSString *_Nonnull)key;

- (void)setDictionary:(NSDictionary *_Nonnull)dictionary forKey:(NSString *_Nonnull)key;
- (NSDictionary *_Nullable)dictionaryForKey:(NSString *_Nonnull)key;

- (void)setArray:(NSArray *_Nonnull)array forKey:(NSString *_Nonnull)key;
- (NSArray *_Nullable)arrayForKey:(NSString *_Nonnull)key;

- (void)setString:(NSString *_Nonnull)string forKey:(NSString *_Nonnull)key;
- (NSString *_Nullable)stringForKey:(NSString *_Nonnull)key;

@end
