//
//  BOAJSONQueryEngine.m
//  BlotoutAnalytics
//
//  Created by Blotout on 21/08/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOAJSONQueryEngine.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"

NSString *const RDJSONKeyKey = @"dKey";
NSString *const RDJSONIndexKey = @"aIndex";

@interface NSObject (RDUtilityAdditions)

- (id)rdValueForKeyOrIndexDictionary:(NSDictionary *)dictionary;

@end

@implementation NSObject (RDUtilityAdditions)

- (id)rdValueForKeyOrIndexDictionary:(NSDictionary *)dictionary
{
    return nil;
}

@end


@implementation NSArray (RDUtilityAdditions)

- (id)rdValueForKeyOrIndexDictionary:(NSDictionary *)dictionary
{
    @try {
        id toReturn = nil;
        NSUInteger index = NSUIntegerMax;
        NSNumber *indexNumber = dictionary[RDJSONIndexKey];
        if ([indexNumber respondsToSelector:@selector(unsignedIntegerValue)]) {
            index = [indexNumber unsignedIntegerValue];
        }
        if (index < [self count]) {
            toReturn = self[index];
        }
        
        return toReturn;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

@end

@implementation NSDictionary (RDUtilityAdditions)

- (id)rdValueForKeyOrIndexDictionary:(NSDictionary *)dictionary
{
    @try {
        id toReturn = nil;
        id key = dictionary[RDJSONKeyKey];
        if (key) {
            toReturn = self[key];
        }
        return toReturn;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

@end

@implementation BOAJSONQueryEngine

+(id) objectFromNestedJSON:(id)JSONObject usingCascadedKeys:(NSDictionary*)firstArg,...

{
    @try {
        /*** rename for clarity - Objective-C style is usually very explicit about purpose and type ***/
        NSMutableArray *mutableKeysAndIndexes = [[NSMutableArray alloc] init];
        id subObject = nil;
        
        va_list args;
        va_start(args, firstArg);
        
        // Iterate through the list of arguments.
        for (NSDictionary *arg = firstArg; arg != nil; arg = va_arg(args, NSDictionary *))
        {
            if ( [[arg allKeys] containsObject:RDJSONKeyKey] || [[arg allKeys] containsObject:RDJSONIndexKey])
            {
                [mutableKeysAndIndexes addObject:arg];
            }
            else
            {
                BOFLogDebug(@"Invalid input types");
                return nil;
            }
        }
        
        subObject = JSONObject;
        
        for (NSDictionary *pathDictionary in mutableKeysAndIndexes) {
            subObject = [subObject rdValueForKeyOrIndexDictionary:pathDictionary];
        }
        
        return subObject;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSDictionary*)predefinedKeysWithCategoryCode{
    NSDictionary *preDefinedKeysWithCategory = @{
        @"10001":@[@"appBundle",@"date", @"singleDaySessions", @"sentToServer", @"systemUptime", @"lastServerSyncTimeStamp", @"allEventsSyncTimeStamp", @"appInfo", @"timeStamp", @"version", @"sdkVersion", @"name", @"bundle", @"language", @"launchTimeStamp", @"terminationTimeStamp", @"sessionsDuration", @"averageSessionsDuration", @"launchReason", @"currentLocation", @"city", @"state", @"country", @"zip", @"ubiAutoDetected", @"screenShotsTaken", @"currentView", @"appNavigation"],
        @"20001":@[@"click"],
        @"30001":@[@"click"],
        @"40001":@[@"click"],
        @"50001":@[@"click"],
        @"60001":@[@"click"],
        @"70001":@[@"click"] //Not defined by server but used in SDK
    };
    return preDefinedKeysWithCategory;
}

+(BOOL)isKey:(NSString*)testKey belongsToPredefinedKeys:(NSDictionary*)preDefinedKeysDict{
    @try {
        BOOL isKeyMatched = NO;
        for (NSString *categoryKey in [preDefinedKeysDict allKeys]) {
            NSArray *keysUnderCategoryKey = [preDefinedKeysDict objectForKey:categoryKey];
            for (NSString *keyDefined in keysUnderCategoryKey) {
                if ([keyDefined isEqualToString:testKey]) {
                    isKeyMatched = YES;
                    break;
                }
            }
            if (isKeyMatched) {
                break;
            }
        }
        return isKeyMatched;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(BOOL)isKey:(NSString*)key availableInDict:(NSDictionary*)jsonDict{
    @try {
        BOOL isAvailable = NO;
        BOFLogDebug(@"jsonDict 101 %@",jsonDict);
        NSArray *allKeys = [jsonDict allKeys];
        if ([allKeys containsObject:key]) {
            isAvailable = YES;
            BOFLogDebug(@"found Key and Object 105 %@",jsonDict);
        }else{
            for (NSString *singleKey in allKeys) {
                if (isAvailable) {
                    BOFLogDebug(@"found Key and Object 109 %@",jsonDict);
                    break;
                }
                id objectForSingleKey = [jsonDict objectForKey:singleKey];
                if ([objectForSingleKey isKindOfClass:[NSDictionary class]] || [objectForSingleKey isKindOfClass:[NSMutableDictionary class]]) {
                    isAvailable = [self isKey:key availableInDict:objectForSingleKey];
                    if (isAvailable) {
                        BOFLogDebug(@"found Key and Object 116 singleKey %@ object %@",singleKey, jsonDict);
                        break;
                    }
                }else if([objectForSingleKey isKindOfClass:[NSArray class]] || [objectForSingleKey isKindOfClass:[NSMutableArray class]]){
                    for (id arraySingleObj in objectForSingleKey) {
                        if ([arraySingleObj isKindOfClass:[NSDictionary class]] || [arraySingleObj isKindOfClass:[NSMutableDictionary class]]) {
                            isAvailable = [self isKey:key availableInDict:arraySingleObj];
                            if (isAvailable) {
                                BOFLogDebug(@"found Key and Object 124 arrarSingleObj %@ object %@",arraySingleObj, jsonDict);
                                break;
                            }
                        }else{
                            break;
                        }
                    }
                }
            }
        }
        return isAvailable;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(NSDictionary*)dictContainsKey:(NSString*)key fromRootDict:(NSDictionary*)jsonDict{
    @try {
        NSDictionary *dictContainsKey = nil;
        BOFLogDebug(@"jsonDict 101 %@",jsonDict);
        NSArray *allKeys = [jsonDict allKeys];
        if ([allKeys containsObject:key]) {
            dictContainsKey = [NSDictionary dictionaryWithDictionary:jsonDict];
            BOFLogDebug(@"found Key and Object 105 %@",jsonDict);
        }else{
            for (NSString *singleKey in allKeys) {
                if (dictContainsKey) {
                    BOFLogDebug(@"found Key and Object 109 %@",jsonDict);
                    break;
                }
                id objectForSingleKey = [jsonDict objectForKey:singleKey];
                if ([objectForSingleKey isKindOfClass:[NSDictionary class]] || [objectForSingleKey isKindOfClass:[NSMutableDictionary class]]) {
                    dictContainsKey = [self dictContainsKey:key fromRootDict:objectForSingleKey];
                    if (dictContainsKey) {
                        BOFLogDebug(@"found Key and Object 116 singleKey %@ object %@",singleKey, jsonDict);
                        break;
                    }
                }else if([objectForSingleKey isKindOfClass:[NSArray class]] || [objectForSingleKey isKindOfClass:[NSMutableArray class]]){
                    for (id arraySingleObj in objectForSingleKey) {
                        if ([arraySingleObj isKindOfClass:[NSDictionary class]] || [arraySingleObj isKindOfClass:[NSMutableDictionary class]]) {
                            dictContainsKey = [self dictContainsKey:key fromRootDict:arraySingleObj];
                            if (dictContainsKey) {
                                BOFLogDebug(@"found Key and Object 124 arrarSingleObj %@ object %@",arraySingleObj, jsonDict);
                                break;
                            }
                        }else{
                            break;
                        }
                    }
                }
            }
        }
        return dictContainsKey;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

//static int testRecurCount = 0;
+(id)valueForKey:(NSString*)key inNestedDict:(NSDictionary*)jsonDict{
    @try {
        id valueForKey = nil;
        //testRecurCount = testRecurCount + 1;
        //BOFLogDebug(@"jsonDict 101 %@",jsonDict);
        //BOFLogDebug(@"TestRecurCount 210 %d",testRecurCount);
        NSArray *allKeys = [jsonDict allKeys];
        if ([allKeys containsObject:key]) {
            valueForKey = [jsonDict valueForKey:key];
            //BOFLogDebug(@"found Key and Object 105 %@",jsonDict);
        }else{
            for (NSString *singleKey in allKeys) {
                if (valueForKey) {
                    //BOFLogDebug(@"found Key and Object 109 %@",jsonDict);
                    break;
                }
                id objectForSingleKey = [jsonDict objectForKey:singleKey];
                if ([objectForSingleKey isKindOfClass:[NSDictionary class]] || [objectForSingleKey isKindOfClass:[NSMutableDictionary class]]) {
                    valueForKey = [self valueForKey:key inNestedDict:objectForSingleKey];
                    if (valueForKey) {
                        //BOFLogDebug(@"found Key and Object 116 singleKey %@ object %@",singleKey, jsonDict);
                        break;
                    }
                }else if([objectForSingleKey isKindOfClass:[NSArray class]] || [objectForSingleKey isKindOfClass:[NSMutableArray class]]){
                    for (id arraySingleObj in objectForSingleKey) {
                        if ([arraySingleObj isKindOfClass:[NSDictionary class]] || [arraySingleObj isKindOfClass:[NSMutableDictionary class]]) {
                            valueForKey = [self valueForKey:key inNestedDict:arraySingleObj];
                            if (valueForKey) {
                                //BOFLogDebug(@"found Key and Object 124 arrarSingleObj %@ object %@",arraySingleObj, jsonDict);
                                break;
                            }
                        }else{
                            break;
                        }
                    }
                }
            }
        }
        return valueForKey;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(BOOL)isKey:(NSString*)key availableInJSON:(NSString*)jsonStr{
    @try {
        //[jsonStr containsString:key] ||
        return [[jsonStr lowercaseString] containsString:[key lowercaseString]];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(int)occuranceCountOf:(NSString*)key availableInDict:(NSDictionary*)jsonDict{
    @try {
        int count = 0;
        BOFLogDebug(@"jsonDict 221 %@",jsonDict);
        NSArray *allKeys = [jsonDict allKeys];
        if ([allKeys containsObject:key]) {
            count = count + 1;
            BOFLogDebug(@"found Key and Object 225 %@",jsonDict);
        }else{
            for (NSString *singleKey in allKeys) {
                id objectForSingleKey = [jsonDict objectForKey:singleKey];
                if ([objectForSingleKey isKindOfClass:[NSDictionary class]] || [objectForSingleKey isKindOfClass:[NSMutableDictionary class]]) {
                    count = count + [self occuranceCountOf:key availableInDict:objectForSingleKey];
                }else if([objectForSingleKey isKindOfClass:[NSArray class]] || [objectForSingleKey isKindOfClass:[NSMutableArray class]]){
                    for (id arraySingleObj in objectForSingleKey) {
                        if ([arraySingleObj isKindOfClass:[NSDictionary class]] || [arraySingleObj isKindOfClass:[NSMutableDictionary class]]) {
                            count = count + [self occuranceCountOf:key availableInDict:arraySingleObj];
                        }else{
                            break;
                        }
                    }
                }
            }
        }
        return count;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(int)occuranceCountOf:(NSString*)key availableInJSON:(NSString*)jsonStr{
    @try {
        NSRange searchRange = NSMakeRange(0,jsonStr.length);
        NSRange foundRange;
        int count = 0;
        while (searchRange.location < jsonStr.length) {
            searchRange.length = jsonStr.length-searchRange.location;
            foundRange = [jsonStr rangeOfString:key options:0 range:searchRange];
            if (foundRange.location != NSNotFound) {
                // found an occurrence of the substring! do stuff here
                count = count + 1;
                searchRange.location = foundRange.location+foundRange.length;
            } else {
                // no more substring to find
                break;
            }
        }
        return count;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(NSArray<NSDictionary*>*)allDictContainsKey:(NSString*)key fromRootDict:(NSDictionary*)jsonDict{
    @try {
        NSMutableArray <NSDictionary*> *allDictContaingKey = [NSMutableArray array];
        BOFLogDebug(@"jsonDict 101 %@",jsonDict);
        NSArray *allKeys = [jsonDict allKeys];
        if ([allKeys containsObject:key]) {
            NSDictionary *dictContainsKey = [NSDictionary dictionaryWithDictionary:jsonDict];
            [allDictContaingKey addObject:dictContainsKey];
            BOFLogDebug(@"found Key and Object 105 %@",jsonDict);
        }else{
            for (NSString *singleKey in allKeys) {
                id objectForSingleKey = [jsonDict objectForKey:singleKey];
                if ([objectForSingleKey isKindOfClass:[NSDictionary class]] || [objectForSingleKey isKindOfClass:[NSMutableDictionary class]]) {
                    NSArray<NSDictionary*> *dictArray = [self allDictContainsKey:key fromRootDict:objectForSingleKey];
                    [allDictContaingKey addObjectsFromArray:dictArray];
                }else if([objectForSingleKey isKindOfClass:[NSArray class]] || [objectForSingleKey isKindOfClass:[NSMutableArray class]]){
                    for (id arraySingleObj in objectForSingleKey) {
                        if ([arraySingleObj isKindOfClass:[NSDictionary class]] || [arraySingleObj isKindOfClass:[NSMutableDictionary class]]) {
                            NSArray<NSDictionary*> *dictArray = [self allDictContainsKey:key fromRootDict:arraySingleObj];
                            [allDictContaingKey addObjectsFromArray:dictArray];
                        }else{
                            break;
                        }
                    }
                }
            }
        }
        return allDictContaingKey;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSArray*)allValueForKey:(NSString*)key inNestedDict:(NSDictionary*)jsonDict{
    @try {
        NSMutableArray *allValueForKey = [NSMutableArray array];
        BOFLogDebug(@"jsonDict 101 %@",jsonDict);
        NSArray *allKeys = [jsonDict allKeys];
        if ([allKeys containsObject:key]) {
            id valueForKey = [jsonDict valueForKey:key];
            [allValueForKey addObject:valueForKey];
            BOFLogDebug(@"found Key and Object 105 %@",jsonDict);
        }else{
            for (NSString *singleKey in allKeys) {
                id objectForSingleKey = [jsonDict objectForKey:singleKey];
                if ([objectForSingleKey isKindOfClass:[NSDictionary class]] || [objectForSingleKey isKindOfClass:[NSMutableDictionary class]]) {
                    NSArray *valuesForKey = [self allValueForKey:key inNestedDict:objectForSingleKey];
                    //https://stackoverflow.com/questions/7903172/can-i-put-different-types-of-objects-in-the-same-nsmutablearray
                    //Using above link, check for same data type may not be mandatory, but before using always check.
                    //                if (allValueForKey.count > 0) {
                    //                    for (id obj in valuesForKey) {
                    //                        if ([[obj class] isKindOfClass:[[allValueForKey objectAtIndex:0] class]]) {
                    //                            [allValueForKey addObjectsFromArray:valuesForKey];
                    //                        }
                    //                    }
                    //                }else{
                    //                     [allValueForKey addObjectsFromArray:valuesForKey];
                    //                }
                    [allValueForKey addObjectsFromArray:valuesForKey];
                }else if([objectForSingleKey isKindOfClass:[NSArray class]] || [objectForSingleKey isKindOfClass:[NSMutableArray class]]){
                    for (id arraySingleObj in objectForSingleKey) {
                        if ([arraySingleObj isKindOfClass:[NSDictionary class]] || [arraySingleObj isKindOfClass:[NSMutableDictionary class]]) {
                            NSArray *valuesForKey = [self allValueForKey:key inNestedDict:arraySingleObj];
                            [allValueForKey addObjectsFromArray:valuesForKey];
                        }else{
                            break;
                        }
                    }
                }
            }
        }
        return allValueForKey;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSString*)getParentKeyForKey:(NSString*)key inNestedDict:(NSDictionary*)jsonDict{
    @try {
        NSString *parentKey = @"";
        BOFLogDebug(@"jsonDict 101 %@",jsonDict);
        NSArray *allKeys = [jsonDict allKeys];
        if ([allKeys containsObject:key]) {
            parentKey = nil;
            BOFLogDebug(@"found Key and Object 105 %@",jsonDict);
        }else{
            for (NSString *singleKey in allKeys) {
                if (!parentKey) {
                    BOFLogDebug(@"found Key and Object 109 %@",jsonDict);
                    break;
                }
                id objectForSingleKey = [jsonDict objectForKey:singleKey];
                if ([objectForSingleKey isKindOfClass:[NSDictionary class]] || [objectForSingleKey isKindOfClass:[NSMutableDictionary class]]) {
                    parentKey = [self getParentKeyForKey:key inNestedDict:objectForSingleKey];
                    if (!parentKey) {
                        BOFLogDebug(@"found Key and Object 116 singleKey %@ object %@",singleKey, jsonDict);
                        parentKey = singleKey;
                        break;
                    }
                }else if([objectForSingleKey isKindOfClass:[NSArray class]] || [objectForSingleKey isKindOfClass:[NSMutableArray class]]){
                    for (id arraySingleObj in objectForSingleKey) {
                        if ([arraySingleObj isKindOfClass:[NSDictionary class]] || [arraySingleObj isKindOfClass:[NSMutableDictionary class]]) {
                            parentKey = [self getParentKeyForKey:key inNestedDict:arraySingleObj];
                            if (!parentKey) {
                                BOFLogDebug(@"found Key and Object 124 arrarSingleObj %@ object %@",arraySingleObj, jsonDict);
                                parentKey = singleKey;
                                break;
                            }
                        }else{
                            break;
                        }
                    }
                }
            }
        }
        return parentKey;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

//Make sure that recursive call and for in loop operate in the same object sequence otherwise parent and key may be not same and wrong in certain cases
//Can be achieved by making sure json dict is same and key or value array produces same value or get it from one source i.e. caller
+(NSString*)getKeyPathForKey:(NSString*)key inNestedDict:(NSDictionary*)jsonDict{
    @try {
        BOOL isTrue = YES;
        NSMutableArray *allParentKeys = [NSMutableArray array];
        NSString *parentKeyL = key;
        do {
            parentKeyL = [self getParentKeyForKey:parentKeyL inNestedDict:jsonDict];
            if (parentKeyL) {
                [allParentKeys addObject:parentKeyL];
            }else{
                isTrue = NO;
            }
        } while (isTrue);
        NSMutableString *keyPath = [@"" mutableCopy];
        for (NSString *parentKey in allParentKeys) {
            [keyPath appendString:[NSString stringWithFormat:@"%@.",parentKey]];
        }
        [keyPath appendString:key];
        return keyPath;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSArray<NSString*>*)getAllParentKeyForKey:(NSString*)key inNestedDict:(NSDictionary*)jsonDict{
    @try {
        NSMutableArray<NSString *> *allParentKeys = [NSMutableArray array];
        NSArray *allKeys = [jsonDict allKeys];
        if ([allKeys containsObject:key]) {
            allParentKeys = nil;
            BOFLogDebug(@"found Key and Object 105 %@",jsonDict);
        }else{
            for (NSString *singleKey in allKeys) {
                id objectForSingleKey = [jsonDict objectForKey:singleKey];
                if ([objectForSingleKey isKindOfClass:[NSDictionary class]] || [objectForSingleKey isKindOfClass:[NSMutableDictionary class]]) {
                    allParentKeys = [[self getAllParentKeyForKey:key inNestedDict:objectForSingleKey] mutableCopy];
                    if (!allParentKeys) {
                        BOFLogDebug(@"found Key and Object 116 singleKey %@ object %@",singleKey, jsonDict);
                        [allParentKeys addObject:singleKey];
                    }
                }else if([objectForSingleKey isKindOfClass:[NSArray class]] || [objectForSingleKey isKindOfClass:[NSMutableArray class]]){
                    for (id arraySingleObj in objectForSingleKey) {
                        if ([arraySingleObj isKindOfClass:[NSDictionary class]] || [arraySingleObj isKindOfClass:[NSMutableDictionary class]]) {
                            allParentKeys = [[self getAllParentKeyForKey:key inNestedDict:arraySingleObj] mutableCopy];
                            if (!allParentKeys) {
                                BOFLogDebug(@"found Key and Object 124 arrarSingleObj %@ object %@",arraySingleObj, jsonDict);
                                [allParentKeys addObject:singleKey];
                            }
                        }else{
                            break;
                        }
                    }
                }
            }
        }
        return allParentKeys;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSArray<NSString*>*)getAllKeyPathForKey:(NSString*)key inNestedDict:(NSDictionary*)jsonDict{
    @try {
        NSArray *allParentKeys = [self getAllParentKeyForKey:key inNestedDict:jsonDict];
        NSMutableArray<NSString*>* allKeyPath = allParentKeys ? [NSMutableArray array] : [NSMutableArray arrayWithObject:key];
        NSMutableString *keyPath = nil;
        for (NSString *parentKey in allParentKeys) {
            keyPath = [[self getKeyPathForKey:parentKey inNestedDict:jsonDict] mutableCopy];
            [keyPath appendString:[NSString stringWithFormat:@".%@",key]];
            [allKeyPath addObject:keyPath];
        }
        return allKeyPath;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}



//========================================= Value based =======================================

+(BOOL)isValue:(id)value equalToObject:(id)object{
    @try {
        BOOL isEqual = NO;
        if (@available(iOS 10.0, *)) {
            if ([value isKindOfClass:[NSDateInterval class]] && [object isKindOfClass:[NSDateInterval class]]) {
                isEqual = [value isEqualToDateInterval:object];
            }
        }
        if (!isEqual) {
            if ([value isKindOfClass:[NSString class]] && [object isKindOfClass:[NSString class]]) {
                isEqual = [value isEqualToString:object];
            }else if ([value isKindOfClass:[NSNumber class]] && [object isKindOfClass:[NSNumber class]]) {
                isEqual = [value isEqualToNumber:object];
            }else if ([value isKindOfClass:[NSData class]] && [object isKindOfClass:[NSData class]]) {
                isEqual = [value isEqualToData:object];
            }else if ([value isKindOfClass:[NSDate class]] && [object isKindOfClass:[NSDate class]]) {
                isEqual = [value isEqualToDate:object];
            }else if ([value isKindOfClass:[NSValue class]] && [object isKindOfClass:[NSValue class]]) {
                isEqual = [value isEqualToValue:object];
            }else if ([value isKindOfClass:[NSArray class]] && [object isKindOfClass:[NSArray class]]) {
                isEqual = [value isEqualToArray:object];
            }else if ([value isKindOfClass:[NSDictionary class]] && [object isKindOfClass:[NSDictionary class]]) {
                isEqual = [value isEqualToDictionary:object];
            }else if ([value isKindOfClass:[NSSet class]] && [object isKindOfClass:[NSSet class]]) {
                isEqual = [value isEqualToSet:object];
            }else if ([value isKindOfClass:[NSIndexSet class]] && [object isKindOfClass:[NSIndexSet class]]) {
                isEqual = [value isEqualToIndexSet:object];
            }else if ([value isKindOfClass:[NSTimeZone class]] && [object isKindOfClass:[NSTimeZone class]]) {
                isEqual = [value isEqualToTimeZone:object];
            }else if ([value isKindOfClass:[NSHashTable class]] && [object isKindOfClass:[NSHashTable class]]) {
                isEqual = [value isEqualToHashTable:object];
            }else if ([value isKindOfClass:[NSOrderedSet class]] && [object isKindOfClass:[NSOrderedSet class]]) {
                isEqual = [value isEqualToOrderedSet:object];
            }else if ([value isKindOfClass:[NSAttributedString class]] && [object isKindOfClass:[NSAttributedString class]]) {
                isEqual = [value isEqualToAttributedString:object];
            }
        }
        return isEqual;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(BOOL)isValue:(id)value availableInDict:(NSDictionary*)jsonDict{
    @try {
        BOOL isAvailable = NO;
        NSArray *allValues = [jsonDict allValues];
        NSArray *allKeys = [jsonDict allKeys];
        if ([allValues containsObject:value]) {
            for (id oneValue in allValues) {
                isAvailable = [self isValue:value equalToObject:oneValue];
            }
            //        isAvailable = YES;
            //        BOFLogDebug(@"found Key and Object 105 %@",jsonDict);
        }else{
            for (NSString *singleKey in allKeys) {
                if (isAvailable) {
                    BOFLogDebug(@"found Key and Object 109 %@",jsonDict);
                    break;
                }
                id objectForSingleKey = [jsonDict objectForKey:singleKey];
                if ([objectForSingleKey isKindOfClass:[NSDictionary class]] || [objectForSingleKey isKindOfClass:[NSMutableDictionary class]]) {
                    //Remove this extra check if not needed after testing, logically not needed
                    if ([value isKindOfClass:[NSDictionary class]]) {
                        isAvailable = [objectForSingleKey isEqualToDictionary:value];
                    }
                    isAvailable = isAvailable ? isAvailable : [self isValue:value availableInDict:objectForSingleKey];
                    if (isAvailable) {
                        BOFLogDebug(@"found Key and Object 116 singleKey %@ object %@",singleKey, jsonDict);
                        break;
                    }
                }else if([objectForSingleKey isKindOfClass:[NSArray class]] || [objectForSingleKey isKindOfClass:[NSMutableArray class]]){
                    //Remove this extra check if not needed after testing, logically not needed
                    if ([value isKindOfClass:[NSArray class]]) {
                        isAvailable = [objectForSingleKey isEqualToArray:value];
                    }
                    if (!isAvailable) {
                        for (id arraySingleObj in objectForSingleKey) {
                            if ([arraySingleObj isKindOfClass:[NSDictionary class]] || [arraySingleObj isKindOfClass:[NSMutableDictionary class]]) {
                                //Remove this extra check if not needed after testing, logically not needed
                                if ([value isKindOfClass:[NSDictionary class]]) {
                                    isAvailable = [arraySingleObj isEqualToDictionary:value];
                                }
                                isAvailable = isAvailable ? isAvailable : [self isValue:value availableInDict:arraySingleObj];
                                if (isAvailable) {
                                    BOFLogDebug(@"found Key and Object 124 arrarSingleObj %@ object %@",arraySingleObj, jsonDict);
                                    break;
                                }
                            }else{
                                isAvailable = [self isValue:value equalToObject:arraySingleObj];
                                if (isAvailable) {
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
        return isAvailable;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(BOOL)isValue:(NSString*)value availableInJSON:(NSString*)jsonStr{
    @try {
        return [jsonStr containsString:value];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

+(int)occuranceCountOfValue:(id)value availableInDict:(NSDictionary*)jsonDict{
    @try {
        int count = 0;
        //BOFLogDebug(@"jsonDict 221 %@",jsonDict);
        NSArray *allKeys = [jsonDict allKeys];
        NSArray *allValues = [jsonDict allValues];
        if ([allValues containsObject:value]) {
            for (id oneValue in allValues) {
                if ([self isValue:value equalToObject:oneValue]) {
                    count = count + 1;
                }
            }
            //BOFLogDebug(@"found Key and Object 225 %@",jsonDict);
        }else{
            for (NSString *singleKey in allKeys) {
                id objectForSingleKey = [jsonDict objectForKey:singleKey];
                if ([objectForSingleKey isKindOfClass:[NSDictionary class]] || [objectForSingleKey isKindOfClass:[NSMutableDictionary class]]) {
                    count = count + [self occuranceCountOfValue:value availableInDict:objectForSingleKey];
                }else if([objectForSingleKey isKindOfClass:[NSArray class]] || [objectForSingleKey isKindOfClass:[NSMutableArray class]]){
                    for (id arraySingleObj in objectForSingleKey) {
                        if ([arraySingleObj isKindOfClass:[NSDictionary class]] || [arraySingleObj isKindOfClass:[NSMutableDictionary class]]) {
                            count = count + [self occuranceCountOfValue:value availableInDict:arraySingleObj];
                        }else{
                            if ([self isValue:value equalToObject:arraySingleObj]) {
                                count = count + 1;
                            }
                            break;
                        }
                    }
                }
            }
        }
        return count;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(int)occuranceCountOfValue:(NSString*)value availableInJSON:(NSString*)jsonStr{
    @try {
        NSRange searchRange = NSMakeRange(0,jsonStr.length);
        NSRange foundRange;
        int count = 0;
        while (searchRange.location < jsonStr.length) {
            searchRange.length = jsonStr.length-searchRange.location;
            foundRange = [jsonStr rangeOfString:value options:0 range:searchRange];
            if (foundRange.location != NSNotFound) {
                // found an occurrence of the substring! do stuff here
                count = count + 1;
                searchRange.location = foundRange.location+foundRange.length;
            } else {
                // no more substring to find
                break;
            }
        }
        return count;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return 0;
}

+(NSDictionary*)dictContainsValue:(id)value fromRootDict:(NSDictionary*)jsonDict{
    @try {
        NSDictionary *dictContainsKey = nil;
        BOFLogDebug(@"jsonDict 101 %@",jsonDict);
        NSArray *allKeys = [jsonDict allKeys];
        NSArray *allValues = [jsonDict allValues];
        if ([allValues containsObject:value]) {
            
            for (id oneValue in allValues) {
                if ([self isValue:value equalToObject:oneValue]) {
                    dictContainsKey = [NSDictionary dictionaryWithDictionary:jsonDict];
                    break;
                }
            }
            BOFLogDebug(@"found Key and Object 105 %@",jsonDict);
        }else{
            for (NSString *singleKey in allKeys) {
                if (dictContainsKey) {
                    BOFLogDebug(@"found Key and Object 109 %@",jsonDict);
                    break;
                }
                id objectForSingleKey = [jsonDict objectForKey:singleKey];
                if ([objectForSingleKey isKindOfClass:[NSDictionary class]] || [objectForSingleKey isKindOfClass:[NSMutableDictionary class]]) {
                    dictContainsKey = [self dictContainsValue:value fromRootDict:objectForSingleKey];
                    if (dictContainsKey) {
                        BOFLogDebug(@"found Key and Object 116 singleKey %@ object %@",singleKey, jsonDict);
                        break;
                    }
                }else if([objectForSingleKey isKindOfClass:[NSArray class]] || [objectForSingleKey isKindOfClass:[NSMutableArray class]]){
                    for (id arraySingleObj in objectForSingleKey) {
                        if ([arraySingleObj isKindOfClass:[NSDictionary class]] || [arraySingleObj isKindOfClass:[NSMutableDictionary class]]) {
                            dictContainsKey = [self dictContainsValue:value fromRootDict:arraySingleObj];
                            if (dictContainsKey) {
                                BOFLogDebug(@"found Key and Object 124 arrarSingleObj %@ object %@",arraySingleObj, jsonDict);
                                break;
                            }
                        }else{
                            if ([self isValue:value equalToObject:arraySingleObj]) {
                                dictContainsKey = [NSDictionary dictionaryWithDictionary:jsonDict];
                                break;
                            }
                        }
                    }
                }
            }
        }
        return dictContainsKey;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSString*)keyForValue:(id)value inNestedDict:(NSDictionary*)jsonDict{
    @try {
        NSString *keyForValue = nil;
        NSArray *allKeys = [jsonDict allKeys];
        NSArray *allValues = [jsonDict allValues];
        if ([allValues containsObject:value]) {
            for (NSString *key in allKeys) {
                if ([self isValue:value equalToObject:[jsonDict valueForKey:key]]) {
                    keyForValue = key;
                    break;
                }
            }
            BOFLogDebug(@"found Key and Object 105 %@",jsonDict);
        }else{
            for (NSString *singleKey in allKeys) {
                if (keyForValue) {
                    BOFLogDebug(@"found Key and Object 109 %@",jsonDict);
                    break;
                }
                id objectForSingleKey = [jsonDict objectForKey:singleKey];
                if ([objectForSingleKey isKindOfClass:[NSDictionary class]] || [objectForSingleKey isKindOfClass:[NSMutableDictionary class]]) {
                    keyForValue = [self keyForValue:value inNestedDict:objectForSingleKey];
                    if (keyForValue) {
                        BOFLogDebug(@"found Key and Object 116 singleKey %@ object %@",singleKey, jsonDict);
                        break;
                    }
                }else if([objectForSingleKey isKindOfClass:[NSArray class]] || [objectForSingleKey isKindOfClass:[NSMutableArray class]]){
                    for (id arraySingleObj in objectForSingleKey) {
                        if ([arraySingleObj isKindOfClass:[NSDictionary class]] || [arraySingleObj isKindOfClass:[NSMutableDictionary class]]) {
                            keyForValue = [self keyForValue:value inNestedDict:arraySingleObj];
                            if (keyForValue) {
                                BOFLogDebug(@"found Key and Object 124 arrarSingleObj %@ object %@",arraySingleObj, jsonDict);
                                break;
                            }
                        }else{
                            if ([self isValue:value equalToObject:arraySingleObj]) {
                                keyForValue = singleKey;
                                break;
                            }
                            break;
                        }
                    }
                }
            }
        }
        return keyForValue;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSArray<NSDictionary*>*)allDictContainsValue:(id)value fromRootDict:(NSDictionary*)jsonDict{
    @try {
        NSMutableArray <NSDictionary*> *allDictContaingValue = [NSMutableArray array];
        //NSDictionary *dictContainsKey = nil;
        BOFLogDebug(@"jsonDict 101 %@",jsonDict);
        NSArray *allKeys = [jsonDict allKeys];
        NSArray *allValues = [jsonDict allValues];
        if ([allValues containsObject:value]) {
            for (id oneValue in allValues) {
                if ([self isValue:value equalToObject:oneValue]) {
                    NSDictionary *dictContainsValue = [NSDictionary dictionaryWithDictionary:jsonDict];
                    [allDictContaingValue addObject:dictContainsValue];
                    break;
                }
            }
            BOFLogDebug(@"found Key and Object 105 %@",jsonDict);
        }else{
            for (NSString *singleKey in allKeys) {
                id objectForSingleKey = [jsonDict objectForKey:singleKey];
                if ([objectForSingleKey isKindOfClass:[NSDictionary class]] || [objectForSingleKey isKindOfClass:[NSMutableDictionary class]]) {
                    NSArray *dictContaingVal1 = [self allDictContainsValue:value fromRootDict:objectForSingleKey];
                    [allDictContaingValue addObjectsFromArray:dictContaingVal1];
                }else if([objectForSingleKey isKindOfClass:[NSArray class]] || [objectForSingleKey isKindOfClass:[NSMutableArray class]]){
                    for (id arraySingleObj in objectForSingleKey) {
                        if ([arraySingleObj isKindOfClass:[NSDictionary class]] || [arraySingleObj isKindOfClass:[NSMutableDictionary class]]) {
                            NSArray *dictContaingVal2 = [self allDictContainsValue:value fromRootDict:arraySingleObj];
                            [allDictContaingValue addObjectsFromArray:dictContaingVal2];
                        }else{
                            //possibly not needed as first if condition and loop will solve the purpose
                            if ([self isValue:value equalToObject:arraySingleObj]) {
                                NSDictionary *dictContainsVal = [NSDictionary dictionaryWithDictionary:jsonDict];
                                [allDictContaingValue addObject:dictContainsVal];
                                break;
                            }
                        }
                    }
                }
            }
        }
        return allDictContaingValue;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
//May not be directly useful but provided as helping method
+(NSArray*)allKeysForValue:(id)value inNestedDict:(NSDictionary*)jsonDict{
    @try {
        NSMutableArray *allKeysForValue = [NSMutableArray array];
        //NSString *keyForValue = nil;
        NSArray *allKeys = [jsonDict allKeys];
        NSArray *allValues = [jsonDict allValues];
        if ([allValues containsObject:value]) {
            for (NSString *key in allKeys) {
                if ([self isValue:value equalToObject:[jsonDict valueForKey:key]]) {
                    [allKeysForValue addObject:key];
                }
            }
            BOFLogDebug(@"found Key and Object 105 %@",jsonDict);
        }else{
            for (NSString *singleKey in allKeys) {
                id objectForSingleKey = [jsonDict objectForKey:singleKey];
                if ([objectForSingleKey isKindOfClass:[NSDictionary class]] || [objectForSingleKey isKindOfClass:[NSMutableDictionary class]]) {
                    NSArray *keyForVal1 = [self allKeysForValue:value inNestedDict:objectForSingleKey];
                    [allKeysForValue addObjectsFromArray:keyForVal1];
                }else if([objectForSingleKey isKindOfClass:[NSArray class]] || [objectForSingleKey isKindOfClass:[NSMutableArray class]]){
                    for (id arraySingleObj in objectForSingleKey) {
                        if ([arraySingleObj isKindOfClass:[NSDictionary class]] || [arraySingleObj isKindOfClass:[NSMutableDictionary class]]) {
                            NSArray *keyForVal2 = [self allKeysForValue:value inNestedDict:arraySingleObj];
                            [allKeysForValue addObjectsFromArray:keyForVal2];
                        }else{
                            if ([self isValue:value equalToObject:arraySingleObj]) {
                                [allKeysForValue addObject:singleKey];
                                break;
                            }
                            break;
                        }
                    }
                }
            }
        }
        return allKeysForValue;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

@end
