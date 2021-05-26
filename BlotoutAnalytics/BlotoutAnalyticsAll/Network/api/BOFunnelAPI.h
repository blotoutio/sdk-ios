//
//  BOEventPostAPI.h
//  BlotoutAnalytics
//
//  Created by Blotout on 05/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOBaseAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOFunnelAPI : BOBaseAPI

/* These method perform posting qualified funnel data to server */
-(void)postFunnelDataModel:(NSData*)eventData success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

/* These method perform getting new funnel data to server */
-(void)getFunnelDataModel:(NSData*)eventData success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
@end

NS_ASSUME_NONNULL_END
