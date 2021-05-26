//
//  BOASegmentsExecutorHelper.h
//  BlotoutAnalytics
//
//  Created by Blotout on 30/12/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BOASegmentsExecutorHelper : NSObject

- (nullable instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (nullable instancetype)sharedInstanceSegmentExeHelper;

-(void)resetSettings;
-(BOOL)isKey:(NSString*)key foundIn:(NSDictionary*)jsonDic;
-(BOOL)isValue:(NSString*)value foundIn:(NSDictionary*)jsonDic;

-(BOOL)doesKey:(NSString*)keyName conatainsValues:(NSArray *)values byOperator:(NSNumber*)operatorVal inDict:(NSDictionary*)jsonDic forEventName:(NSString*)eventName;
-(BOOL)doesKey:(NSString*)keyName conatainsValues:(NSArray *)values byOperator:(NSNumber*)operatorVal inDict:(NSDictionary*)jsonDic;

-(BOOL)conditionalResultForCondition:(NSString*)condition onvalue1:(NSString*)val1 andValue2:(NSString*)val2;
-(BOOL)resultsOfBitwiseOperator:(NSString*)bitOperator onResult1:(BOOL)result1 andResult2:(BOOL)result2;

@end

NS_ASSUME_NONNULL_END
