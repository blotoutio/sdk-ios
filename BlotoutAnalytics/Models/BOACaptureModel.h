//
//  BOCaptureModel.h
//  BlotoutAnalytics
//
//  Copyright © 2021 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BOACaptureModel : NSObject

@property (nonatomic, strong, nonnull) NSString *event;

@property (nonatomic, strong, nullable) NSDictionary *properties;

@property (nonatomic, strong, nullable) NSNumber *eventSubCode;

@property (nonatomic, strong, nullable) NSString *screenName;

@property (nonatomic, strong, nullable) NSString *type;

- (instancetype _Nonnull)initWithEvent:(NSString * _Nonnull)event
                             properties:(NSDictionary * _Nullable)properties screenName:(NSString* _Nullable)screenName withType:(NSString* _Nonnull)type;

@end
