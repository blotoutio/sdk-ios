//
//  BOEventPostAPI.h
//  BlotoutAnalytics
//
//  Created by Blotout on 05/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOBaseAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOManifestGeoAPI : BOBaseAPI

/* These method perform getting Manifest data from server */
-(void)getManifestDataModel:(NSData*)eventData success:(void (^)(id responseObject, id data))success failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
