//
//  BOADataRuleEngineOperations.m
//  BlotoutAnalytics
//
//  Created by Blotout on 07/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOADataRuleEngineOperations.h"
#import "BOADataRuleEngine.h"
#import "BOAJSONQueryEngine.h"
#import "BOAUtilities.h"
#import <BlotoutFoundation/BOFFileSystemManager.h>
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"


static id sBOASharedInstanceRE = nil;

@implementation BOADataRuleEngineOperations

-(instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t boaOnceTokenRE = 0;
    dispatch_once(&boaOnceTokenRE, ^{
        sBOASharedInstanceRE = [[[self class] alloc] init];
    });
    return  sBOASharedInstanceRE;
}

-(NSDictionary*)predefinedKeysWithCategoryCode{
    @try {
        return [BOAJSONQueryEngine predefinedKeysWithCategoryCode];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(BOOL)isKey:(NSString*)testKey belongsToPredefinedKeys:(NSDictionary*)preDefinedKeysDict{
    @try {
        return [BOAJSONQueryEngine isKey:testKey belongsToPredefinedKeys:preDefinedKeysDict];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return NO;
}

-(NSArray<NSDictionary*>*)allDataDictConatainsKey:(NSString*)key fromSourceData:(NSArray<NSDictionary*>*)completeSource{
    @try {
        NSMutableArray<NSDictionary*>* allDict = [NSMutableArray array];
        for (NSDictionary *sourceDict in completeSource) {
            if ([BOADataRuleEngine isKey:key availableIn:sourceDict]) {
                [allDict addObject:sourceDict];
            }
        }
        return (allDict.count > 0) ? allDict : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSArray<NSDictionary*>*)allDataDictBetweenStart:(NSDate*)startDate andEndDate:(NSDate*)endDate ConatainsKey:(NSString*)key fromSourceData:(NSArray<NSDictionary*>*)completeSource{
    @try {
        NSMutableArray<NSDictionary*>* allDict = [NSMutableArray array];
        
        for (NSDictionary *sourceDict in completeSource) {
            id dateObj = [sourceDict objectForKey:self.dateKey];
            NSDate *date = nil;
            if (self.isNSDate && [dateObj isKindOfClass:[NSDate class]]) {
                date = dateObj;
            }else if([dateObj isKindOfClass:[NSString class]]){
                date = [BOAUtilities dateStr:dateObj inFormat:self.dateformat];
            }
            BOOL isDateFine = [BOAUtilities isDate:date between:startDate andDate2:endDate];
            BOOL keyExist = [BOADataRuleEngine isKey:key availableIn:sourceDict];
            if (isDateFine && keyExist) {
                [allDict addObject:sourceDict];
            }
        }
        return (allDict.count > 0) ? allDict : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSArray<NSDictionary*>*)allDataDictConatainsValue:(NSString*)value fromSourceData:(NSArray<NSDictionary*>*)completeSource{
    
    @try {
        NSMutableArray<NSDictionary*>* allDict = [NSMutableArray array];
        for (NSDictionary *sourceDict in completeSource) {
            if ([BOADataRuleEngine isValue:value availableIn:sourceDict]) {
                [allDict addObject:sourceDict];
            }
        }
        return (allDict.count > 0) ? allDict : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
-(NSArray<NSDictionary*>*)allDataDictBetweenStart:(NSDate*)startDate andEndDate:(NSDate*)endDate ConatainsValue:(NSString*)value fromSourceData:(NSArray<NSDictionary*>*)completeSource{
    @try {
        NSMutableArray<NSDictionary*>* allDict = [NSMutableArray array];
        
        for (NSDictionary *sourceDict in completeSource) {
            id dateObj = [sourceDict objectForKey:self.dateKey];
            NSDate *date = nil;
            if (self.isNSDate && [dateObj isKindOfClass:[NSDate class]]) {
                date = dateObj;
            }else if([dateObj isKindOfClass:[NSString class]]){
                date = [BOAUtilities dateStr:dateObj inFormat:self.dateformat];
            }
            BOOL isDateFine = [BOAUtilities isDate:date between:startDate andDate2:endDate];
            BOOL valueExist = [BOADataRuleEngine isValue:value availableIn:sourceDict];
            if (isDateFine && valueExist) {
                [allDict addObject:sourceDict];
            }
        }
        return (allDict.count > 0) ? allDict : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSArray<NSDictionary*>*)allDataDictConatains:(id)value fromSourceData:(NSArray<NSDictionary*>*)completeSource{
    @try {
        NSMutableArray<NSDictionary*>* allDict = [NSMutableArray array];
        for (NSDictionary *sourceDict in completeSource) {
            if ([BOADataRuleEngine is:value availableIn:sourceDict]) {
                [allDict addObject:sourceDict];
            }
        }
        return (allDict.count > 0) ? allDict : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSArray<NSDictionary*>*)allDataDictBetweenStart:(NSDate*)startDate andEndDate:(NSDate*)endDate Conatains:(id)value fromSourceData:(NSArray<NSDictionary*>*)completeSource{
    @try {
        NSMutableArray<NSDictionary*>* allDict = [NSMutableArray array];
        
        for (NSDictionary *sourceDict in completeSource) {
            id dateObj = [sourceDict objectForKey:self.dateKey];
            NSDate *date = nil;
            if (self.isNSDate && [dateObj isKindOfClass:[NSDate class]]) {
                date = dateObj;
            }else if([dateObj isKindOfClass:[NSString class]]){
                date = [BOAUtilities dateStr:dateObj inFormat:self.dateformat];
            }
            BOOL isDateFine = [BOAUtilities isDate:date between:startDate andDate2:endDate];
            BOOL valueExist = [BOADataRuleEngine is:value availableIn:sourceDict];
            if (isDateFine && valueExist) {
                [allDict addObject:sourceDict];
            }
        }
        return (allDict.count > 0) ? allDict : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSArray<NSDictionary*>*)allDataDictBetweenStart:(NSDate*)startDate andEndDate:(NSDate*)endDate fromSourceData:(NSArray<NSDictionary*>*)completeSource{
    @try {
        NSMutableArray<NSDictionary*>* allDict = [NSMutableArray array];
        
        for (NSDictionary *sourceDict in completeSource) {
            id dateObj = [sourceDict objectForKey:self.dateKey];
            NSDate *date = nil;
            if (self.isNSDate && [dateObj isKindOfClass:[NSDate class]]) {
                date = dateObj;
            }else if([dateObj isKindOfClass:[NSString class]]){
                date = [BOAUtilities dateStr:dateObj inFormat:self.dateformat];
            }
            BOOL isDateFine = [BOAUtilities isDate:date between:startDate andDate2:endDate];
            if (isDateFine) {
                [allDict addObject:sourceDict];
            }
        }
        return (allDict.count > 0) ? allDict : nil;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}



-(NSArray<NSDictionary*>*)allDataDictBetweenStart:(NSDate*)startDate andEndDate:(NSDate*)endDate fromSource:(NSString*)jsonFilesDirectoryPath{
    @try {
        NSMutableArray <NSDictionary*> *allJsonDataDicts = [[self allDataDictFromSource:jsonFilesDirectoryPath] mutableCopy];
        return [self allDataDictBetweenStart:startDate andEndDate:endDate fromSourceData:allJsonDataDicts];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSArray<NSDictionary*>*)allDataDictFromSource:(NSString*)jsonFilesDirectoryPath{
    @try {
        NSArray *allJSONFiles = [BOFFileSystemManager getAllFilesWithExtention:@"txt" fromDir:jsonFilesDirectoryPath];
        NSMutableArray <NSDictionary*> *allJsonDataDicts = [NSMutableArray array];
        
        for (id filePath in allJSONFiles) {
            NSError *error = nil;
            NSString *jsonStr = [BOFFileSystemManager contentOfFileAtPath:filePath withEncoding:NSUTF8StringEncoding andError:&error];
            NSDictionary *jsonDict = [BOAUtilities jsonObjectFromString:jsonStr];
            [allJsonDataDicts addObject:jsonDict];
        }
        return allJsonDataDicts;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

//Provides specific dict which contains key direclty, so no need to move deeper
-(NSDictionary*)dataSubSectionContainsKey:(NSString*)key fromRootDict:(NSDictionary*)jsonDict{
    @try {
        return [BOADataRuleEngine dictContainsKey:key fromRootDict:jsonDict];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
-(NSArray<NSDictionary*>*)allDataSubSectionsContainsKey:(NSString*)key fromAllRootDict:(NSArray<NSDictionary*>*)allJsonDict{
    @try {
        NSMutableArray <NSDictionary*> *allSubSectionJsonDataDicts = [NSMutableArray array];
        for (NSDictionary *jsonDict in allJsonDict) {
            NSDictionary *jsonSubSectionDict = [self dataSubSectionContainsKey:key fromRootDict:jsonDict];
            [allSubSectionJsonDataDicts addObject:jsonSubSectionDict];
        }
        return allSubSectionJsonDataDicts;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

//Provides key value mapped dictionary
-(NSDictionary*)valuesForKeys:(NSArray<NSString*>*)keys inDicts:(NSArray<NSDictionary*>*)jsonDicts{
    @try {
        NSMutableDictionary *keysAndValue = [NSMutableDictionary dictionary];
        for (NSString *key in keys) {
            NSMutableArray *allDictValues = [NSMutableArray array];
            for (NSDictionary *dict in jsonDicts) {
                id value = [BOADataRuleEngine valueForKey:key inDict:dict];
                [allDictValues addObject:value];
            }
            [keysAndValue setObject:allDictValues forKey:key];
        }
        return keysAndValue;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
//Provides Array of values for same key from all dicts where constion met
-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSArray<NSDictionary*>*)allJsonDicts whereItContains:(NSString*)str{
    @try {
        NSMutableArray *allDictValues = [NSMutableArray array];
        for (NSDictionary *dict in allJsonDicts) {
            id value = [BOADataRuleEngine valueForKey:key inDict:dict whereItContains:str];
            value ? [allDictValues addObject:value] : nil;
        }
        return allDictValues;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}


-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSArray<NSDictionary*>*)allJsonDicts whereItIsGreaterThan:(double)conditionalvalue{
    @try {
        NSMutableArray *allDictValues = [NSMutableArray array];
        for (NSDictionary *dict in allJsonDicts) {
            id value = [BOADataRuleEngine valueForKey:key inDict:dict whereItIsGreaterThan:conditionalvalue];
            value ? [allDictValues addObject:value] : nil;
        }
        return allDictValues;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}
-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsGreaterThanOrEqualTo:(double)conditionalvalue{
    @try {
        NSMutableArray *allDictValues = [NSMutableArray array];
        for (NSDictionary *dict in allJsonDicts) {
            id value = [BOADataRuleEngine valueForKey:key inDict:dict whereItIsGreaterThanOrEqualTo:conditionalvalue];
            value ? [allDictValues addObject:value] : nil;
        }
        return allDictValues;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsLessThan:(double)conditionalvalue{
    @try {
        NSMutableArray *allDictValues = [NSMutableArray array];
        for (NSDictionary *dict in allJsonDicts) {
            id value = [BOADataRuleEngine valueForKey:key inDict:dict whereItIsLessThan:conditionalvalue];
            value ? [allDictValues addObject:value] : nil;
        }
        return allDictValues;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsLessThanOrEqualTo:(double)conditionalvalue{
    @try {
        NSMutableArray *allDictValues = [NSMutableArray array];
        for (NSDictionary *dict in allJsonDicts) {
            id value = [BOADataRuleEngine valueForKey:key inDict:dict whereItIsLessThanOrEqualTo:conditionalvalue];
            value ? [allDictValues addObject:value] : nil;
        }
        return allDictValues;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsGreaterThan:(double)value1 ANDLessThan:(double)value2{
    @try {
        NSMutableArray *allDictValues = [NSMutableArray array];
        for (NSDictionary *dict in allJsonDicts) {
            id value = [BOADataRuleEngine valueForKey:key inDict:dict whereItIsGreaterThan:value1 ANDLessThan:value2];
            value ? [allDictValues addObject:value] : nil;
        }
        return allDictValues;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsGreaterThanEqualTo:(double)value1 ANDLessThan:(double)value2{
    @try {
        NSMutableArray *allDictValues = [NSMutableArray array];
        for (NSDictionary *dict in allJsonDicts) {
            id value = [BOADataRuleEngine valueForKey:key inDict:dict whereItIsGreaterThanEqualTo:value1 ANDLessThan:value2];
            value ? [allDictValues addObject:value] : nil;
        }
        return allDictValues;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsGreaterThan:(double)value1 ANDLessThanEqualTo:(double)value2{
    @try {
        NSMutableArray *allDictValues = [NSMutableArray array];
        for (NSDictionary *dict in allJsonDicts) {
            id value = [BOADataRuleEngine valueForKey:key inDict:dict whereItIsGreaterThan:value1 ANDLessThanEqualTo:value2];
            value ? [allDictValues addObject:value] : nil;
        }
        return allDictValues;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsGreaterThanEqualTo:(double)value1 ANDLessThanEqualTo:(double)value2{
    @try {
        NSMutableArray *allDictValues = [NSMutableArray array];
        for (NSDictionary *dict in allJsonDicts) {
            id value = [BOADataRuleEngine valueForKey:key inDict:dict whereItIsGreaterThanEqualTo:value1 ANDLessThanEqualTo:value2];
            value ? [allDictValues addObject:value] : nil;
        }
        return allDictValues;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}


-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsGreaterThan:(double)value1 ORLessThan:(double)value2{
    @try {
        NSMutableArray *allDictValues = [NSMutableArray array];
        for (NSDictionary *dict in allJsonDicts) {
            id value = [BOADataRuleEngine valueForKey:key inDict:dict whereItIsGreaterThan:value1 ORLessThan:value2];
            value ? [allDictValues addObject:value] : nil;
        }
        return allDictValues;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsGreaterThanEqualTo:(double)value1 ORLessThan:(double)value2{
    @try {
        NSMutableArray *allDictValues = [NSMutableArray array];
        for (NSDictionary *dict in allJsonDicts) {
            id value = [BOADataRuleEngine valueForKey:key inDict:dict whereItIsGreaterThanEqualTo:value1 ORLessThan:value2];
            value ? [allDictValues addObject:value] : nil;
        }
        return allDictValues;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsGreaterThan:(double)value1 ORLessThanEqualTo:(double)value2{
    @try {
        NSMutableArray *allDictValues = [NSMutableArray array];
        for (NSDictionary *dict in allJsonDicts) {
            id value = [BOADataRuleEngine valueForKey:key inDict:dict whereItIsGreaterThan:value1 ORLessThanEqualTo:value2];
            value ? [allDictValues addObject:value] : nil;
        }
        return allDictValues;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsGreaterThanEqualTo:(double)value1 ORLessThanEqualTo:(double)value2{
    @try {
        NSMutableArray *allDictValues = [NSMutableArray array];
        for (NSDictionary *dict in allJsonDicts) {
            id value = [BOADataRuleEngine valueForKey:key inDict:dict whereItIsGreaterThanEqualTo:value1 ORLessThanEqualTo:value2];
            value ? [allDictValues addObject:value] : nil;
        }
        return allDictValues;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

@end
