//
//  BONetworkManager.h
//  BlotoutAnalytics
//
//  Created by Blotout on 05/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BONetworkManager : NSObject

+ (void)asyncRequest:(NSURLRequest *)request
             success:(void(^)(id, NSURLResponse *))successBlock_
             failure:(void(^)(id, NSURLResponse *, NSError *))failureBlock_;

@end

NS_ASSUME_NONNULL_END
