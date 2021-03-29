//
//  BOCaptureModel.h
//  BlotoutAnalytics
//
//  Created by ankuradhikari on 22/03/21.
//  Copyright © 2021 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BOACaptureModel : NSObject

@property (nonatomic, strong, nonnull) NSString *event;

@property (nonatomic, strong, nullable) NSDictionary *properties;

@property (nonatomic, strong, nullable) NSNumber *eventSubCode;

- (instancetype _Nonnull )initWithEvent:(NSString * _Nonnull)event
                             properties:(NSDictionary * _Nonnull)properties eventCode:(NSNumber*_Nullable)eventCode;

@end
