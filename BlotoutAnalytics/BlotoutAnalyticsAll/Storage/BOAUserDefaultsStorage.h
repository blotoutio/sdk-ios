//
//  BOAUserDefaultsStorage.h
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOACrypto.h"
#import "BOAStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOAUserDefaultsStorage : NSObject <BOAStorage>

@property (nonatomic, strong, nullable) id<BOACrypto> crypto;
@property (nonnull, nonatomic, readonly) NSUserDefaults *defaults;
@property (nullable, nonatomic, readonly) NSString *namespacePrefix;

- (instancetype _Nonnull)initWithDefaults:(NSUserDefaults *_Nonnull)defaults namespacePrefix:(NSString *_Nullable)namespacePrefix crypto:(id<BOACrypto> _Nullable)crypto;

@end

NS_ASSUME_NONNULL_END
