//
//  BOEventPostAPI.h
//  BlotoutAnalytics
//
//  Created by Blotout on 05/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOBaseAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOSegmentAPI : BOBaseAPI
-(void)postSegmentDataModel:(NSData*)eventData success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

-(void)getSegmentDataModel:(NSData*)eventData success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
@end

NS_ASSUME_NONNULL_END
