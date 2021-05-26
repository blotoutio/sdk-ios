//
//  BOANetworkAndDataSync.h
//  BlotoutAnalytics
//
//  Created by Blotout on 20/08/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BOANetworkAndDataSync : NSObject

- (nullable instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (nullable instancetype)sharedInstance;

- (void)checkForPiiAndSendToServer:(NSData*)serverFormatJSON;
- (void)checkForPiiAndSendToServer:(NSData*)serverFormatJSON usingRequest:(NSURLRequest*)request;

@end

NS_ASSUME_NONNULL_END
