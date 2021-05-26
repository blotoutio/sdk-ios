//
//  BOASegmentsExecutorHelper.m
//  BlotoutAnalytics
//
//  Created by Blotout on 30/12/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOASegmentsExecutorHelper.h"
#import "BOAJSONQueryEngine.h"
#import "BOADataRuleEngine.h"
#import "BOADataRuleEngineOperations.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"

static id sBOASharedInstanceSegmentExeHelper = nil;

@interface BOASegmentsExecutorHelper (){
    BOOL isLowerCaseHandled;
    BOOL isUpperCaseHandled;
}
@end

@implementation BOASegmentsExecutorHelper

-(instancetype)init{
    self = [super init];
    if (self) {
        [self resetSettings];
    }
    return self;
}

+ (nullable instancetype)sharedInstanceSegmentExeHelper{
    static dispatch_once_t boaOnceTokenSegmentExeHelper = 0;
    dispatch_once(&boaOnceTokenSegmentExeHelper, ^{
        sBOASharedInstanceSegmentExeHelper = [[[self class] alloc] init];
    });
    return  sBOASharedInstanceSegmentExeHelper;
}

-(void)resetSettings{
    isLowerCaseHandled = NO;
    isUpperCaseHandled = NO;
}

-(BOOL)isKey:(NSString*)key foundIn:(NSDictionary*)jsonDic{
    @try {
        return [BOADataRuleEngine isKey:key availableIn:jsonDic];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return  NO;
}

-(BOOL)isValue:(NSString*)value foundIn:(NSDictionary*)jsonDic{
    @try {
        return [BOADataRuleEngine isValue:value availableIn:jsonDic];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

-(int)operatorIntForString:(NSString*)operatorStr{
    @try {
        int optIntVal = -1;
        if ([operatorStr isEqualToString:@"AND"]) {
            optIntVal = 1;
        }else if([operatorStr isEqualToString:@"OR"]){
            optIntVal = 2;
        }
        return optIntVal;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return -1;
}

//This function is now taking care of all the cases, where
//1: key/value is present only
//2: eventName present only
//3: eventName and key/Value for that event name both present

// In case any issues in logic fix it here to take care all future possibilities

-(BOOL)doesKey:(NSString*)keyName conatainsValues:(NSArray *)values byOperator:(NSNumber*)operatorVal inDict:(NSDictionary*)jsonDic forEventName:(NSString*)eventName{
    @try {
        int operatorInt = [operatorVal intValue];
        BOOL result = NO;
        BOOL keyValComboNotGood = NO;
        BOOL jsonHasEventName = NO;
        BOOL eventNameNotGood = NO;
        
        BOOL finalResult = NO;
        
        NSString *tempEventName = [eventName stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSArray <NSDictionary*> *eventNameDicts = nil;
        if (eventName && ![tempEventName isEqualToString:@""]) {
            if ([self isValue:eventName foundIn:jsonDic]) {
                jsonHasEventName = YES;
                eventNameDicts = [BOADataRuleEngine allDictContainsValue:eventName fromRootDict:jsonDic];
            }
        }else{
            jsonHasEventName = YES;
            eventNameNotGood = YES;
            eventNameDicts = [NSArray arrayWithObject:jsonDic];
        }
        
        for (NSDictionary *jsonDictName in eventNameDicts) {
            NSString *tempKeyName = [keyName stringByReplacingOccurrencesOfString:@" " withString:@""];
            if (keyName && ![tempKeyName isEqualToString:@""] && values && values.count > 0) {
                switch (operatorInt) {
                    case 801: //GREATER_THAN
                        result = [BOADataRuleEngine valueForKey:keyName inDict:jsonDictName whereItIsGreaterThan:[[values lastObject] doubleValue]] != nil;
                        break;
                    case 802: //GREATER_THAN_EQUALTO
                        result = [BOADataRuleEngine valueForKey:keyName inDict:jsonDictName whereItIsGreaterThanOrEqualTo:[[values lastObject] doubleValue]] != nil;
                        break;
                    case 803: //LESS_THAN
                        result = [BOADataRuleEngine valueForKey:keyName inDict:jsonDictName whereItIsLessThan:[[values lastObject] doubleValue]] != nil;
                        break;
                    case 804: //LESS_THAN_EQUALTO
                        result = [BOADataRuleEngine valueForKey:keyName inDict:jsonDictName whereItIsLessThanOrEqualTo:[[values lastObject] doubleValue]] != nil;
                        break;
                    case 805: //EQUAL
                        result = [BOADataRuleEngine valueForKey:keyName inDict:jsonDictName whereItIsEqualTo:[[values lastObject] doubleValue]] != nil;
                        break;
                    case 806: //NOT_EQUAL
                        result = [BOADataRuleEngine valueForKey:keyName inDict:jsonDictName whereItIsNotEqualTo:[[values lastObject] doubleValue]] != nil;
                        break;
                    case 807: //IN_RANGE
                        result = [BOADataRuleEngine valueForKey:keyName inDict:jsonDictName whereItIsGreaterThan:[[values firstObject] doubleValue] ANDLessThan:[[values lastObject] doubleValue]] != nil;
                        break;
                    case 808: //NOT_IN_RANGE
                        result = [BOADataRuleEngine valueForKey:keyName inDict:jsonDictName whereItIsGreaterThan:[[values firstObject] doubleValue] ANDLessThan:[[values lastObject] doubleValue]] == nil;
                        break;
                    case 809: //IN
                        //TODO:
                        //there are possibility for multiple values in [BOADataRuleEngine valueForKey:keyName inDict:jsonDic]
                        //Will consider later.
                        //Also cases lie update logevent should be provieded to consider the cases where.
                        //user added iPhone then removed it and then added samsung in cart and bought.
                        //As per our data user will be qualified for iPhone in cart until combined with remove event key
                        result = [values containsObject:[BOADataRuleEngine valueForKey:keyName inDict:jsonDictName]];
                        break;
                    case 810: //NOT_IN
                        result = ![values containsObject:[BOADataRuleEngine valueForKey:keyName inDict:jsonDictName]];
                        break;
                    case 811: //CONTAIN
                        result = [BOADataRuleEngine valueForKey:keyName inDict:jsonDictName whereItContains:[values lastObject]] != nil;
                        break;
                    case 812: //NOT_CONTAIN
                        result = [BOADataRuleEngine valueForKey:keyName inDict:jsonDictName whereItContains:[values lastObject]] == nil;
                        break;
                    case 813: //ANY
                        //Find Difference between In and Any case
                        result = [values containsObject:[BOADataRuleEngine valueForKey:keyName inDict:jsonDictName]];
                        break;
                    case 814: //ALL
                    {
                        id valuesObj = [BOADataRuleEngine valueForKey:keyName inDict:jsonDictName];
                        if ([valuesObj isKindOfClass:[NSArray class]]) {
                            result = [values isEqualToArray:valuesObj];
                            break;
                        }
                    }
                        break;
                    case 815: //NONE
                        //Find Difference between No In and NONE case
                        result = ![values containsObject:[BOADataRuleEngine valueForKey:keyName inDict:jsonDictName]];
                        break;
                    default:
                        BOFLogDebug(@"DEFAULT CASE= values = %@ and internal value type=%@ \n--------\n dict value if found = %@ and Type = %@",values, [[values lastObject] class], [BOADataRuleEngine valueForKey:keyName inDict:jsonDictName], [[BOADataRuleEngine valueForKey:keyName inDict:jsonDic] class]);
                        break;
                }
                if (result) {
                    break;
                }
            }else{
                result = YES;
                keyValComboNotGood = YES;
                break;
            }
        }
        
        BOFLogDebug(@"operatorVal= values = %@ and internal value type=%@ \n--------\n dict value if found = %@ and Type = %@",operatorVal, values, [[values lastObject] class], [BOADataRuleEngine valueForKey:keyName inDict:jsonDic], [[BOADataRuleEngine valueForKey:keyName inDict:jsonDic] class]);
        
        if (!result && !isLowerCaseHandled) {
            isLowerCaseHandled = YES;
            result = [self doesKey:[keyName lowercaseString] conatainsValues:values byOperator:operatorVal inDict:jsonDic forEventName:eventName];
        }
        if (!result && !isUpperCaseHandled) {
            isUpperCaseHandled = YES;
            result = [self doesKey:[keyName uppercaseString] conatainsValues:values byOperator:operatorVal inDict:jsonDic forEventName:eventName];
        }
        
        //This is ensuring that atleast one required param was present, either eventName or Key value, both present is welcome
        if (!(eventNameNotGood && keyValComboNotGood)) {
            finalResult = result && jsonHasEventName;
        }
        return finalResult;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}


-(BOOL)doesKey:(NSString*)keyName conatainsValues:(NSArray *)values byOperator:(NSNumber*)operatorVal inDict:(NSDictionary*)jsonDic{
    @try {
        int operatorInt = [operatorVal intValue];
        BOOL result = NO;
        
        switch (operatorInt) {
            case 801: //GREATER_THAN
                result = [BOADataRuleEngine valueForKey:keyName inDict:jsonDic whereItIsGreaterThan:[[values lastObject] doubleValue]] != nil;
                break;
            case 802: //GREATER_THAN_EQUALTO
                result = [BOADataRuleEngine valueForKey:keyName inDict:jsonDic whereItIsGreaterThanOrEqualTo:[[values lastObject] doubleValue]] != nil;
                break;
            case 803: //LESS_THAN
                result = [BOADataRuleEngine valueForKey:keyName inDict:jsonDic whereItIsLessThan:[[values lastObject] doubleValue]] != nil;
                break;
            case 804: //LESS_THAN_EQUALTO
                result = [BOADataRuleEngine valueForKey:keyName inDict:jsonDic whereItIsLessThanOrEqualTo:[[values lastObject] doubleValue]] != nil;
                break;
            case 805: //EQUAL
                result = [BOADataRuleEngine valueForKey:keyName inDict:jsonDic whereItIsEqualTo:[[values lastObject] doubleValue]] != nil;
                break;
            case 806: //NOT_EQUAL
                result = [BOADataRuleEngine valueForKey:keyName inDict:jsonDic whereItIsNotEqualTo:[[values lastObject] doubleValue]] != nil;
                break;
            case 807: //IN_RANGE
                result = [BOADataRuleEngine valueForKey:keyName inDict:jsonDic whereItIsGreaterThan:[[values firstObject] doubleValue] ANDLessThan:[[values lastObject] doubleValue]] != nil;
                break;
            case 808: //NOT_IN_RANGE
                result = [BOADataRuleEngine valueForKey:keyName inDict:jsonDic whereItIsGreaterThan:[[values firstObject] doubleValue] ANDLessThan:[[values lastObject] doubleValue]] == nil;
                break;
            case 809: //IN
                //TODO:
                //there are possibility for multiple values in [BOADataRuleEngine valueForKey:keyName inDict:jsonDic]
                //Will consider later.
                //Also cases lie update logevent should be provieded to consider the cases where.
                //user added iPhone then removed it and then added samsung in cart and bought.
                //As per our data user will be qualified for iPhone in cart until combined with remove event key
                result = [values containsObject:[BOADataRuleEngine valueForKey:keyName inDict:jsonDic]];
                break;
            case 810: //NOT_IN
                result = ![values containsObject:[BOADataRuleEngine valueForKey:keyName inDict:jsonDic]];
                break;
            case 811: //CONTAIN
                result = [BOADataRuleEngine valueForKey:keyName inDict:jsonDic whereItContains:[values lastObject]] != nil;
                break;
            case 812: //NOT_CONTAIN
                result = [BOADataRuleEngine valueForKey:keyName inDict:jsonDic whereItContains:[values lastObject]] == nil;
                break;
            case 813: //ANY
                //Find Difference between In and Any case
                result = [values containsObject:[BOADataRuleEngine valueForKey:keyName inDict:jsonDic]];
                break;
            case 814: //ALL
            {
                id valuesObj = [BOADataRuleEngine valueForKey:keyName inDict:jsonDic];
                if ([valuesObj isKindOfClass:[NSArray class]]) {
                    result = [values isEqualToArray:valuesObj];
                    break;
                }
            }
                break;
            case 815: //NONE
                //Find Difference between No In and NONE case
                result = ![values containsObject:[BOADataRuleEngine valueForKey:keyName inDict:jsonDic]];
                break;
            default:
                BOFLogDebug(@"DEFAULT CASE= values = %@ and internal value type=%@ \n--------\n dict value if found = %@ and Type = %@",values, [[values lastObject] class], [BOADataRuleEngine valueForKey:keyName inDict:jsonDic], [[BOADataRuleEngine valueForKey:keyName inDict:jsonDic] class]);
                break;
        }
        BOFLogDebug(@"operatorVal= values = %@ and internal value type=%@ \n--------\n dict value if found = %@ and Type = %@",operatorVal, values, [[values lastObject] class], [BOADataRuleEngine valueForKey:keyName inDict:jsonDic], [[BOADataRuleEngine valueForKey:keyName inDict:jsonDic] class]);
        
        if (!result && !isLowerCaseHandled) {
            isLowerCaseHandled = YES;
            result = [self doesKey:[keyName lowercaseString] conatainsValues:values byOperator:operatorVal inDict:jsonDic];
        }
        if (!result && !isUpperCaseHandled) {
            isUpperCaseHandled = YES;
            result = [self doesKey:[keyName uppercaseString] conatainsValues:values byOperator:operatorVal inDict:jsonDic];
        }
        return result;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

-(BOOL)conditionalResultForCondition:(NSString*)condition onvalue1:(NSString*)val1 andValue2:(NSString*)val2{
    @try {
        BOOL result = NO;
        if ([condition isEqualToString:@"AND"]) {
            result = val1 && val2;
        }else if([condition isEqualToString:@"OR"]){
            result = val1 || val2;
        }
        return result;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

-(BOOL)resultsOfBitwiseOperator:(NSString*)bitOperator onResult1:(BOOL)result1 andResult2:(BOOL)result2{
    @try {
        BOOL result = NO;
        if ([bitOperator isEqualToString:@"AND"]) {
            result = result1 && result2;
        }else if([bitOperator isEqualToString:@"OR"]){
            result = result1 || result2;
        }
        return result;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

@end
