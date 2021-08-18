//
//  BOServerDataConverter.h
//  BlotoutAnalytics
//
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class BOAppSessionData;
@interface BOServerDataConverter : NSObject {}
+ (NSDictionary *)prepareMetaData;

@end

NS_ASSUME_NONNULL_END
