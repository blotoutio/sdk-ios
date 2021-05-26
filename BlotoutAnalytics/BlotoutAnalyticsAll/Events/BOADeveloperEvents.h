//
//  BOADeveloperEvents.h
//  BlotoutAnalytics
//
//  Created by Blotout on 25/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOACaptureModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOADeveloperEvents : NSObject

+(NSDictionary*)captureEvent:(BOACaptureModel*)model;
+(NSDictionary*)capturePersonalEvent:(BOACaptureModel*)model isPHI:(BOOL)phiEvent;
+(NSDictionary*)prepareServerPayload:(NSArray*)events;
@end

NS_ASSUME_NONNULL_END
