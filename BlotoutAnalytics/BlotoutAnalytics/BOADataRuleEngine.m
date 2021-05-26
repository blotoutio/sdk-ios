//
//  BOADataRuleEngine.m
//  BlotoutAnalytics
//
//  Created by Blotout on 06/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOADataRuleEngine.h"
#import "BOAJSONQueryEngine.h"
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"

@implementation BOADataRuleEngine

+(BOOL)doesObject:(id)object contains:(NSString*)str{
    @try {
        BOOL isValidValue = NO;
        if ([object isKindOfClass:[NSString class]]) {
            isValidValue = [object localizedCaseInsensitiveContainsString:str];
        }
        if ([object isKindOfClass:[NSArray class]]) {
            isValidValue = [object containsObject:str];
        }
        if ([object isKindOfClass:[NSDictionary class]]) {
            for (id obj in [object allValues]) {
                isValidValue = [self doesObject:obj contains:str];
                if (isValidValue) {
                    break;
                }
            }
        }
        return isValidValue;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(BOOL)isKey:(NSString*)key availableIn:(NSDictionary*)jsonDict{
    @try {
        NSString *jsonStr = [BOAUtilities jsonStringFrom:jsonDict withPrettyPrint:NO];
        return [BOAJSONQueryEngine isKey:key availableInJSON:jsonStr];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(BOOL)isValue:(NSString*)value availableIn:(NSDictionary*)jsonDict{
    @try {
        NSString *jsonStr = [BOAUtilities jsonStringFrom:jsonDict withPrettyPrint:NO];
        return [BOAJSONQueryEngine isValue:value availableInJSON:jsonStr];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(BOOL)is:(id)value availableIn:(NSDictionary*)jsonDict{
    @try {
        return [BOAJSONQueryEngine isValue:value availableInDict:jsonDict];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(NSDictionary*)dictContainsKey:(NSString*)key fromRootDict:(NSDictionary*)jsonDict{
    @try {
        return [BOAJSONQueryEngine dictContainsKey:key fromRootDict:jsonDict];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSDictionary*)dictContains:(id)value fromRootDict:(NSDictionary*)jsonDict{
    @try {
        return [BOAJSONQueryEngine dictContainsValue:value fromRootDict:jsonDict];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSArray<NSDictionary*>*)allDictContainsValue:(id)value fromRootDict:(NSDictionary*)jsonDict{
    @try {
        return [BOAJSONQueryEngine allDictContainsValue:value fromRootDict:jsonDict];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict{
    @try {
        id valueForKey = [BOAJSONQueryEngine valueForKey:key inNestedDict:jsonDict];
        return valueForKey;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItContains:(NSString*)str{
    @try {
        id valueForKey = [BOAJSONQueryEngine valueForKey:key inNestedDict:jsonDict];
        BOOL isContained = [self doesObject:valueForKey contains:str];
        return isContained ? valueForKey : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsGreaterThan:(double)conditionalvalue{
    @try {
        id valueForKey = [BOAJSONQueryEngine valueForKey:key inNestedDict:jsonDict];
        BOOL isValidValue = NO;
        if (valueForKey && [valueForKey isKindOfClass:[NSNumber class]]) {
            isValidValue = [valueForKey doubleValue] > conditionalvalue;
        }
        return isValidValue ? valueForKey : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsGreaterThanOrEqualTo:(double)conditionalvalue{
    @try {
        id valueForKey = [BOAJSONQueryEngine valueForKey:key inNestedDict:jsonDict];
        BOOL isValidValue = NO;
        if (valueForKey && [valueForKey isKindOfClass:[NSNumber class]]) {
            isValidValue = [valueForKey doubleValue] >= conditionalvalue;
        }
        return isValidValue ? valueForKey : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsLessThan:(double)conditionalvalue{
    @try {
        id valueForKey = [BOAJSONQueryEngine valueForKey:key inNestedDict:jsonDict];
        BOOL isValidValue = NO;
        if (valueForKey && [valueForKey isKindOfClass:[NSNumber class]]) {
            isValidValue = [valueForKey doubleValue] < conditionalvalue;
        }
        return isValidValue ? valueForKey : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsLessThanOrEqualTo:(double)conditionalvalue{
    @try {
        id valueForKey = [BOAJSONQueryEngine valueForKey:key inNestedDict:jsonDict];
        BOOL isValidValue = NO;
        if (valueForKey && [valueForKey isKindOfClass:[NSNumber class]]) {
            isValidValue = [valueForKey doubleValue] <= conditionalvalue;
        }
        return isValidValue ? valueForKey : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsEqualTo:(double)conditionalvalue{
    @try {
        id valueForKey = [BOAJSONQueryEngine valueForKey:key inNestedDict:jsonDict];
        BOOL isValidValue = NO;
        if (valueForKey && [valueForKey isKindOfClass:[NSNumber class]]) {
            isValidValue = ([valueForKey doubleValue] == conditionalvalue);
        }
        return isValidValue ? valueForKey : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsNotEqualTo:(double)conditionalvalue{
    @try {
        id valueForKey = [BOAJSONQueryEngine valueForKey:key inNestedDict:jsonDict];
        BOOL isValidValue = NO;
        if (valueForKey && [valueForKey isKindOfClass:[NSNumber class]]) {
            isValidValue = ([valueForKey doubleValue] != conditionalvalue);
        }
        return isValidValue ? valueForKey : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsGreaterThan:(double)value1 ANDLessThan:(double)value2{
    @try {
        id valueForKey = [BOAJSONQueryEngine valueForKey:key inNestedDict:jsonDict];
        BOOL isValidValue = NO;
        if (valueForKey && [valueForKey isKindOfClass:[NSNumber class]]) {
            double doubleValue = [valueForKey doubleValue];
            if ((doubleValue > value1) && (doubleValue < value2)) {
                isValidValue = YES;
            }
        }
        return isValidValue ? valueForKey : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsGreaterThanEqualTo:(double)value1 ANDLessThan:(double)value2{
    @try {
        id valueForKey = [BOAJSONQueryEngine valueForKey:key inNestedDict:jsonDict];
        BOOL isValidValue = NO;
        if (valueForKey && [valueForKey isKindOfClass:[NSNumber class]]) {
            double doubleValue = [valueForKey doubleValue];
            if ((doubleValue >= value1) && (doubleValue < value2)) {
                isValidValue = YES;
            }
        }
        return isValidValue ? valueForKey : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsGreaterThan:(double)value1 ANDLessThanEqualTo:(double)value2{
    @try {
        id valueForKey = [BOAJSONQueryEngine valueForKey:key inNestedDict:jsonDict];
        BOOL isValidValue = NO;
        if (valueForKey && valueForKey && [valueForKey isKindOfClass:[NSNumber class]]) {
            double doubleValue = [valueForKey doubleValue];
            if ((doubleValue > value1) && (doubleValue <= value2)) {
                isValidValue = YES;
            }
        }
        return isValidValue ? valueForKey : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsGreaterThanEqualTo:(double)value1 ANDLessThanEqualTo:(double)value2{
    @try {
        id valueForKey = [BOAJSONQueryEngine valueForKey:key inNestedDict:jsonDict];
        BOOL isValidValue = NO;
        if (valueForKey && [valueForKey isKindOfClass:[NSNumber class]]) {
            double doubleValue = [valueForKey doubleValue];
            if ((doubleValue >= value1) && (doubleValue <= value2)) {
                isValidValue = YES;
            }
        }
        return isValidValue ? valueForKey : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsGreaterThan:(double)value1 ORLessThan:(double)value2{
    @try {
        id valueForKey = [BOAJSONQueryEngine valueForKey:key inNestedDict:jsonDict];
        BOOL isValidValue = NO;
        if (valueForKey && [valueForKey isKindOfClass:[NSNumber class]]) {
            double doubleValue = [valueForKey doubleValue];
            if ((doubleValue > value1) || (doubleValue < value2)) {
                isValidValue = YES;
            }
        }
        return isValidValue ? valueForKey : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsGreaterThanEqualTo:(double)value1 ORLessThan:(double)value2{
    @try {
        id valueForKey = [BOAJSONQueryEngine valueForKey:key inNestedDict:jsonDict];
        BOOL isValidValue = NO;
        if (valueForKey && [valueForKey isKindOfClass:[NSNumber class]]) {
            double doubleValue = [valueForKey doubleValue];
            if ((doubleValue >= value1) || (doubleValue < value2)) {
                isValidValue = YES;
            }
        }
        return isValidValue ? valueForKey : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsGreaterThan:(double)value1 ORLessThanEqualTo:(double)value2{
    
    @try {
        id valueForKey = [BOAJSONQueryEngine valueForKey:key inNestedDict:jsonDict];
        BOOL isValidValue = NO;
        if (valueForKey && [valueForKey isKindOfClass:[NSNumber class]]) {
            double doubleValue = [valueForKey doubleValue];
            if ((doubleValue > value1) || (doubleValue <= value2)) {
                isValidValue = YES;
            }
        }
        return isValidValue ? valueForKey : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(id)valueForKey:(NSString*)key inDict:(NSDictionary*)jsonDict whereItIsGreaterThanEqualTo:(double)value1 ORLessThanEqualTo:(double)value2{
    @try {
        id valueForKey = [BOAJSONQueryEngine valueForKey:key inNestedDict:jsonDict];
        BOOL isValidValue = NO;
        if (valueForKey && [valueForKey isKindOfClass:[NSNumber class]]) {
            double doubleValue = [valueForKey doubleValue];
            if ((doubleValue >= value1) || (doubleValue <= value2)) {
                isValidValue = YES;
            }
        }
        return isValidValue ? valueForKey : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

@end
