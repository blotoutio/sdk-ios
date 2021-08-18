//
//  BOAFileStorage.h
//  BlotoutAnalytics
//
//  Copyright © 2021 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOAStorage.h"
#import "BOACrypto.h"

@interface BOAFileStorage : NSObject <BOAStorage>

@property (nonatomic, strong, nullable) id<BOACrypto> crypto;

- (instancetype _Nonnull)init;
- (instancetype _Nonnull)initWithFolder:(NSURL *_Nonnull)fileURL crypto:(id<BOACrypto> _Nullable)crypto;

- (NSURL *_Nonnull)urlForKey:(NSString *_Nonnull)key;

@end
