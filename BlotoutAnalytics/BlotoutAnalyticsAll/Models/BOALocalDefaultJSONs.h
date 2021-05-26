//
//  BOALocalDefaultJSONs.h
//  BlotoutAnalytics
//
//  Created by Blotout on 08/08/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BOALocalDefaultJSONs : NSObject

+(NSString*)appSessionJSONString;
+(NSDictionary*)appSessionJSONDict;
+(NSDictionary*)appSessionJSONDictFromJSONString:(NSString*)jsonString;
+(NSString*)appLifeTimeDataJSONString;
+(NSDictionary*)appLifeTimeDataJSONDict;
+(NSDictionary*)appLifeTimeDataJSONDictFromJSONString:(NSString*)jsonString;
@end

NS_ASSUME_NONNULL_END
