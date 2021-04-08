//
//  BOFLogs.h
//  BlotoutFoundation
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

void BOFLogError(NSString *frmt, ...);
void BOFLogInfo(NSString *frmt, ...);
void BOFLogDebug(NSString *frmt, ...);

@interface BOFLogs : NSObject

+ (nullable instancetype)sharedInstance;

@property (nonatomic,readwrite) BOOL isSDKLogEnabled;

@end

NS_ASSUME_NONNULL_END
