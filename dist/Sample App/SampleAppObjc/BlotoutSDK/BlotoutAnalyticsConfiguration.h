//
//  BlotoutAnalyticsConfiguration.h
//  BlotoutAnalytics
//
//  Created by ankuradhikari on 12/03/21.
//  Copyright © 2021 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BlotoutAnalyticsConfiguration : NSObject

/**
 * Creates and returns a configuration with default settings and the given write key.
 *
 * @param token Your project's  key from Dashboard
 * @param endPointUrl Url where you will be sending data
 */
+ (_Nonnull instancetype)configurationWithToken:(NSString *_Nonnull)token withUrl:(NSString *_Nonnull)endPointUrl;

/**
 * Application token that you can get in your dashboard
*/
@property (nonatomic, copy, readonly, nonnull) NSString *token;

/**
 * Url where you will be sending data
*/
@property (nonatomic, copy, readonly, nonnull) NSString *endPointUrl;


@end

NS_ASSUME_NONNULL_END
