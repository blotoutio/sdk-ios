//
//  BOEventsManager.h
//  BlotoutAnalytics
//
//  Copyright © 2021 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOACaptureModel.h"
#import "BlotoutAnalyticsConfiguration.h"
#import "BOAStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOAEventsManager : NSObject

- (id)initWithConfiguration:(BlotoutAnalyticsConfiguration *)configuration storage:(id<BOAStorage>)storage;

-(void)capture:(BOACaptureModel *)payload;
-(void)capturePersonal:(BOACaptureModel *)payload isPHI:(BOOL)phiEvent;

- (void)applicationDidEnterBackground;
- (void)applicationWillTerminate;


@end

NS_ASSUME_NONNULL_END
