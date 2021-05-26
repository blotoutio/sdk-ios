//
//  BOServerDataConverter.h
//  BlotoutAnalytics
//
//  Created by Blotout on 10/05/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOASegmentsResSegmentsPayload.h"
#import "BOAFunnelPayload.h"

NS_ASSUME_NONNULL_BEGIN

@class BOAppSessionData;
@interface BOServerDataConverter : NSObject {
}
+ (NSDictionary *)prepareMetaData;
+ (NSDictionary *)prepareGeoData;
+ (NSDictionary *)preparePreviousMetaData:(nullable BOAppSessionData*)sessionData;
+ (void)storePreviousDayAppInfoViaNotification:(nullable NSNotification*)notification;

@end

NS_ASSUME_NONNULL_END
