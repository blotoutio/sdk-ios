//
//  BOFUserDefaults.h
//  BlotoutFoundation
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOFConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOFUserDefaults : NSObject

+(_Nonnull instancetype)userDefaultsForProduct:( NSString * _Nonnull)product;

-(void)setObject:(nullable id)obj forKey:(nonnull id<NSCopying>)aKey;
-(nullable id)objectForKey:(nonnull id<NSCopying>)key;
-(void)removeObjectForKey:(nonnull id<NSCopying>)aKey;

@end

NS_ASSUME_NONNULL_END
