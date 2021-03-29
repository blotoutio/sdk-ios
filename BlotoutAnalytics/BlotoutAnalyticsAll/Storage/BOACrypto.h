//
//  BOACrypto.h
//  BlotoutAnalytics
//
//  Created by ankuradhikari on 22/03/21.
//  Copyright © 2021 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOACrypto.h"

@protocol BOACrypto <NSObject>

- (NSData *_Nullable)encrypt:(NSData *_Nonnull)data;
- (NSData *_Nullable)decrypt:(NSData *_Nonnull)data;

@end

