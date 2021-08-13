//
//  BOEventPostAPI.h
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOBaseAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOManifestAPI : BOBaseAPI

/* These method perform getting Manifest data from server */
-(void)getManifestDataModel:(void (^)(id responseObject, id data))success failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
