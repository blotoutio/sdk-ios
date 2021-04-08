//
//  NetworkManager.m
//  SalesDemoApp
//
//  Created by ankuradhikari on 22/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "NetworkManager.h"

@implementation NetworkManager

+ (void)asyncRequest:(NSURLRequest *)request
             success:(void(^)(id, NSURLResponse *))successBlock_
             failure:(void(^)(id, NSURLResponse *, NSError *))failureBlock_ {
    
    NSURLSessionDownloadTask *downloadTask = [[NSURLSession sharedSession]
                                              downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSData *data = [NSData dataWithContentsOfURL:location];
        
        if (error == nil) {
            successBlock_(data,response);
        } else {
            failureBlock_(data,response,error);
        }
        
    }];
    
    [downloadTask resume];
    
}

@end
