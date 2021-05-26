//
//  BOANetworkConstants.h
//  BlotoutAnalytics
//
//  Created by Blotout on 07/08/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BOEventPostAPI.h"

@class BOAppSessionData, BOAAppLifetimeData;

/* This class used to create NSOperation objects which are responsible for sending events to server in background
 * It send data from sessionObject or from saved files.
 */
@interface BOAPostEventsDataJob : NSOperation


-(instancetype)init;

@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) BOAppSessionData *sessionObject;

@property (strong, nonatomic) NSString *filePathLifetimeData;
@property (strong, nonatomic) BOAAppLifetimeData *lifetimeDataObject;

@end
