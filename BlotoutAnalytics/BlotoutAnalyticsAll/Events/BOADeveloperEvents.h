//
//  BOADeveloperEvents.h
//  BlotoutAnalytics
//
//  Created by Blotout on 25/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BOADeveloperEvents : NSObject

+(NSDictionary*)captureEvent:(NSString*)eventName withInformation:(NSDictionary*)eventInfo withEventCode:(NSNumber*)eventCode;
+(NSDictionary*)capturePersonalEvent:(NSString*)eventName withInformation:(NSDictionary*)eventInfo isPHI:(BOOL)phiEvent;
+(NSDictionary*)prepareServerPayload:(NSArray*)events;
@end

NS_ASSUME_NONNULL_END
