//
//  BOFUtilities.h
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BOFUtilities : NSObject

+(NSString*)getSHA256:(NSString*)string;
+(NSString*)getSHA1:(NSString*)string;
@end

NS_ASSUME_NONNULL_END
