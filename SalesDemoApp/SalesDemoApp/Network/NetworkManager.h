//
//  NetworkManager.h
//  SalesDemoApp
//
//  Created by ankuradhikari on 22/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkManager : NSObject

+ (void)asyncRequest:(NSURLRequest *)request
             success:(void(^)(id, NSURLResponse *))successBlock_
             failure:(void(^)(id, NSURLResponse *, NSError *))failureBlock_;

@end

NS_ASSUME_NONNULL_END
