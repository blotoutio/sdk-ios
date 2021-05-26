//
//  BlotoutFoundation.h
//  BlotoutFoundation
//
//  Created by Blotout on 25/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlotoutFoundation : NSObject

@property (nonatomic, readwrite) BOOL isProductionMode;
// Default Value is YES, only set to NO when you want to disable SDK
// Once you disable SDK, SDK won't collect any further information but already collected informtion,
// will be sent to server as per Blotout Contract
@property (nonatomic, readwrite) BOOL isEnabled;
@property (nonatomic, readwrite) BOOL isDataCollectionEnabled;
@property (nonatomic, readwrite) BOOL isNetworkSyncEnabled;

//Individual Module enable or disable control
//System Events, which SDK detect automatically
@property (nonatomic, readwrite) BOOL isSystemEventsEnabled;
//Rentention Events, which SDK detect for retention tracking like DAU, MAU
@property (nonatomic, readwrite) BOOL isRetentionEventsEnabled;
//Funnel Events, which SDK process for funnel analysis
@property (nonatomic, readwrite) BOOL isFunnelEventsEnabled;
//Segments Events, which SDK process for segment analysis
@property (nonatomic, readwrite) BOOL isSegmentEventsEnabled;
//Developer Codified Events, which SDK collects when developer send some events
@property (nonatomic, readwrite) BOOL isDeveloperEventsEnabled;

//set encryption key for encryption data
@property (nonatomic, strong) NSString* _Nullable encryptionKey;


- (nullable instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (nullable instancetype)sharedInstance;

@end
