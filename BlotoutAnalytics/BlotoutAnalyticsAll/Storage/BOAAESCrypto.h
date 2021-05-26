//
//  BOAAESCrypto.h
//  BlotoutAnalytics
//
//  Created by ankuradhikari on 22/03/21.
//  Copyright © 2021 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOACrypto.h"


@interface BOAAESCrypto : NSObject <BOACrypto>

- (instancetype _Nonnull)initWithPassword:(NSString *_Nonnull)password iv:(NSString *_Nonnull)iv;

- (instancetype _Nonnull)initWithPassword:(NSString *_Nonnull)password;

@property (nonatomic, readonly, nonnull) NSString *password;
@property (nonatomic, readonly, nonnull) NSString *iv;

@end
