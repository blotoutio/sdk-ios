//
//  BOASegmentsSyncController.h
//  BlotoutAnalytics
//
//  Created by Blotout on 27/12/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

/**
 * The BOASegmentsSyncController is class to fetch and sync segment to server
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BOASegmentsSyncController : NSObject

@property(nonatomic, readwrite) BOOL isSegmentsEnabled;

- (nullable instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (nullable instancetype)sharedInstanceSegmentSyncController;

-(void)prepareSegmentsSyncAndAnalyser;
-(void)pauseSegmentsSyncAndAnalyser;
-(BOOL)isSegmentAvailable;
-(NSData*)getSegmentPayload;


//-(void)recordDevEvent:(NSString*)eventName withEventSubCode:(NSNumber*)eventSubCode withDetails:(NSDictionary*)eventDetails;
//-(void)recordNavigationEventFrom:(NSString*)fromVC to:(NSString*)toVC withDetails:(NSDictionary*)eventDetails;
-(void)appLaunchedWithInfo:(NSDictionary*)launchInfo;
-(void)appInBackgroundWithInfo:(NSDictionary*)backgroudInfo;
-(void)appWillTerminatWithInfo:(NSDictionary*)terminationInfo;

@end

NS_ASSUME_NONNULL_END
