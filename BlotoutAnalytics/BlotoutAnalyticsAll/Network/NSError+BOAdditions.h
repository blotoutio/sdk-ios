//
//  NSError+BOAdditions.h
//  BlotoutAnalytics
//
//  Created by Blotout on 05/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, BOErrorCodes) {
    BOErrorUnknownn = 10001,
    BOErrorNoInternetConnection,
    BOErrorParsingError,
    BOManifestSyncError
};

@interface NSError (BOAdditions)

+(NSError*)boErrorForCode:(NSInteger)errorCode withMessage:(nullable NSString*)msg;

+(NSError*)boErrorForDict:(NSDictionary*)userInfo;

@end

NS_ASSUME_NONNULL_END
