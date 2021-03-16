//
//  BOSharedManager.h
//  BlotoutAnalytics
//
//  Created by Blotout on 22/08/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOAppSessionData.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOSharedManager : NSObject

@property(nonatomic,retain) NSMutableDictionary *currentUserNavigation;
@property (nonatomic,nullable,strong) NSTimer *currentTimer;
@property (readwrite) float  currentTime;
@property (nonatomic,nullable,strong) BOAppNavigation *currentNavigation;
@property (nonatomic,nullable,strong) BOAppGesture *currentGesture;

@property (nonatomic,strong) NSOperationQueue *jobManager;
@property (nonatomic,strong) NSString *sessionId;
@property (nonatomic,readwrite) bool isViewDidAppeared;

+(instancetype)sharedInstance;


@end

NS_ASSUME_NONNULL_END
