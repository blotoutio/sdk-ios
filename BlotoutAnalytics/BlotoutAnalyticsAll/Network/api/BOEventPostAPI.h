//
//  BOEventPostAPI.h
//  BlotoutAnalytics
//
//  Created by Blotout on 05/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOBaseAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOEventPostAPI : BOBaseAPI
/* This Method used to post events and retention events data */
-(void)postEventDataModel:(NSData*)eventData withAPICode:(BOUrlEndPoint)urlEndPoint success:(void (^)(id responseObject))success failure:(void (^)(NSURLResponse * urlResponse, id dataOrLocation, NSError *error))failure;
@end

NS_ASSUME_NONNULL_END
