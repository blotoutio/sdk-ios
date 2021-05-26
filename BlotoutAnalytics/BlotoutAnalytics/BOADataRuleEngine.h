//
//  BOADataRuleEngine.h
//  BlotoutAnalytics
//
//  Created by Blotout on 06/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BOADataRuleEngine : NSObject

+(BOOL)isKey:(NSString*)key availableIn:(NSDictionary*)jsonDict;
+(BOOL)isValue:(NSString*)value availableIn:(NSDictionary*)jsonDict;
+(BOOL)is:(id)value availableIn:(NSDictionary*)jsonDict;

+(NSDictionary*)dictContainsKey:(NSString*)key fromRootDict:(NSDictionary*)jsonDict;
//+(NSDictionary*)dictContainsValue:(NSString*)value fromRootDict:(NSDictionary*)jsonDict;
+(NSDictionary*)dictContains:(id)value fromRootDict:(NSDictionary*)jsonDict;
+(NSArray<NSDictionary*>*)allDictContainsValue:(id)value fromRootDict:(NSDictionary*)jsonDict;

+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict;
+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItContains:(NSString*)str;

+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsGreaterThan:(double)conditionalvalue;
+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsGreaterThanOrEqualTo:(double)conditionalvalue;

+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsLessThan:(double)conditionalvalue;
+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsLessThanOrEqualTo:(double)conditionalvalue;
+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsEqualTo:(double)conditionalvalue;
+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsNotEqualTo:(double)conditionalvalue;

+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsGreaterThan:(double)value1 ANDLessThan:(double)value2;
+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsGreaterThanEqualTo:(double)value1 ANDLessThan:(double)value2;
+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsGreaterThan:(double)value1 ANDLessThanEqualTo:(double)value2;
+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsGreaterThanEqualTo:(double)value1 ANDLessThanEqualTo:(double)value2;

+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsGreaterThan:(double)value1 ORLessThan:(double)value2;
+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsGreaterThanEqualTo:(double)value1 ORLessThan:(double)value2;
+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsGreaterThan:(double)value1 ORLessThanEqualTo:(double)value2;
+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsGreaterThanEqualTo:(double)value1 ORLessThanEqualTo:(double)value2;

@end

NS_ASSUME_NONNULL_END
