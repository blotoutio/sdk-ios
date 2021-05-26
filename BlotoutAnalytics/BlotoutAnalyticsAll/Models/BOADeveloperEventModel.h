//
//  BOADeveloperEventModel.h
//  BlotoutAnalytics
//
//  Created by Blotout on 30/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BOADeveloperEventModel : NSObject

@property (nonatomic, strong)   NSString *eventID;
@property (nonatomic, strong)   NSString *eventName;
@property (nonatomic, strong)   NSDictionary *eventInfo;

@property (nonatomic, strong)   NSNumber *eventTimeReference;
@property (nonatomic, strong)   NSDate *eventDate;

@property (nonatomic, strong)   NSNumber *eventStartTimeReference;
@property (nonatomic, strong)   NSNumber *eventEndTimeReference;
@property (nonatomic, strong)   NSDate *eventStartDate;
@property (nonatomic, strong)   NSDate *eventEndDate;
@property (nonatomic, strong)   NSNumber *eventDuration;

-(instancetype)initWithEventName:(NSString*)eventName andEventInfo:(NSDictionary*)eventInfo;
-(NSString*)updateEventID;
-(NSDictionary*)eventInfoForStorage;

@end

NS_ASSUME_NONNULL_END
