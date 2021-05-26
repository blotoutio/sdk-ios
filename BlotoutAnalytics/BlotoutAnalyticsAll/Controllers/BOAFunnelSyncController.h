//
//  FunnelRetrievalControl.h
//  BlotoutAnalytics
//
//  Created by Blotout on 25/10/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

/**
 * The BOASegmentsSyncController is class to fetch and sync funnel to server
 */

#import <Foundation/Foundation.h>
#import "BOAFunnelAndCodifiedEvents.h"
#import "BOAFunnelPayload.h"
#import "BOAEventsGetRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOAFunnelSyncController : NSObject {
}


@property(nonatomic, readwrite) BOOL isFunnelEnabled;

- (nullable instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (nullable instancetype)sharedInstanceFunnelController;

-(void)prepareFunnnelSyncAndAnalyser;
-(BOOL)isFunnnelAvailable;
-(void)recordDevEvent:(NSString*)eventName withEventSubCode:(NSNumber*)eventSubCode withDetails:(NSDictionary*)eventDetails;
-(void)recordNavigationEventFrom:(NSString*)fromVC to:(NSString*)toVC withDetails:(NSDictionary*)eventDetails;
-(void)appLaunchedWithInfo:(NSDictionary*)launchInfo;
-(void)appInBackgroundWithInfo:(nullable NSDictionary*)backgroudInfo;
-(void)appWillTerminatWithInfo:(nullable NSDictionary*)terminationInfo;
@end

NS_ASSUME_NONNULL_END
