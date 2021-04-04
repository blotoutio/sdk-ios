//
//  BOSharedManager.h
//  BlotoutAnalytics
//
//  Created by Blotout on 22/08/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BOSharedManager : NSObject

@property (nonatomic,strong) NSString *sessionId;
@property (nonatomic,readwrite) bool isViewDidAppeared;
@property (nonatomic,strong) NSString *currentScreenName;
@property (nonatomic,strong) NSString *referrer;

+(instancetype)sharedInstance;


@end

NS_ASSUME_NONNULL_END
