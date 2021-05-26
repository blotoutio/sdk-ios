//
//  BOADataRuleEngineOperations.h
//  BlotoutAnalytics
//
//  Created by Blotout on 07/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BOADataRuleEngineOperations : NSObject

@property (strong, nonatomic) NSString *dateKey;
@property (readwrite, nonatomic) BOOL isNSDate;
@property (strong, nonatomic) NSString *dateformat;

- (nullable instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (nullable instancetype)sharedInstance;

//category code as key
//keys will be array of keys under every category
//
-(NSDictionary*)predefinedKeysWithCategoryCode;
-(BOOL)isKey:(NSString*)testKey belongsToPredefinedKeys:(NSDictionary*)preDefinedKeysDict;
//Just validate key, whether exist or not and then return all the JSON who passed the test as it was in param
//So return result could be same or sub set of the data
-(NSArray<NSDictionary*>*)allDataDictConatainsKey:(NSString*)key fromSourceData:(NSArray<NSDictionary*>*)completeSource;
-(NSArray<NSDictionary*>*)allDataDictBetweenStart:(NSDate*)startDate andEndDate:(NSDate*)endDate ConatainsKey:(NSString*)key fromSourceData:(NSArray<NSDictionary*>*)completeSource;

-(NSArray<NSDictionary*>*)allDataDictConatainsValue:(NSString*)value fromSourceData:(NSArray<NSDictionary*>*)completeSource;
-(NSArray<NSDictionary*>*)allDataDictBetweenStart:(NSDate*)startDate andEndDate:(NSDate*)endDate ConatainsValue:(NSString*)value fromSourceData:(NSArray<NSDictionary*>*)completeSource;

-(NSArray<NSDictionary*>*)allDataDictConatains:(id)value fromSourceData:(NSArray<NSDictionary*>*)completeSource;
-(NSArray<NSDictionary*>*)allDataDictBetweenStart:(NSDate*)startDate andEndDate:(NSDate*)endDate Conatains:(id)value fromSourceData:(NSArray<NSDictionary*>*)completeSource;

-(NSArray<NSDictionary*>*)allDataDictBetweenStart:(NSDate*)startDate andEndDate:(NSDate*)endDate fromSourceData:(NSArray<NSDictionary*>*)completeSource;

//======================================= implemented ======================
//source, this method can read the data from directory to preapre list of source
-(NSArray<NSDictionary*>*)allDataDictBetweenStart:(NSDate*)startDate andEndDate:(NSDate*)endDate fromSource:(NSString*)jsonFilesDirectoryPath;
-(NSArray<NSDictionary*>*)allDataDictFromSource:(NSString*)jsonFilesDirectoryPath;

//Provides specific dict which contains key direclty, so no need to move deeper
-(NSDictionary*)dataSubSectionContainsKey:(NSString*)key fromRootDict:(NSDictionary*)jsonDict;
-(NSArray<NSDictionary*>*)allDataSubSectionsContainsKey:(NSString*)key fromAllRootDict:(NSArray<NSDictionary*>*)allJsonDict;

//Provides key value mapped dictionary
-(NSDictionary*)valuesForKeys:(NSArray<NSString*>*)keys inDicts:(NSArray<NSDictionary*>*)jsonDicts;
//Provides Array of values for same key from all dicts where constion met
-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSArray<NSDictionary*>*)allJsonDicts whereItContains:(NSString*)str;

-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSArray<NSDictionary*>*)allJsonDicts whereItIsGreaterThan:(double)conditionalvalue;
-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsGreaterThanOrEqualTo:(double)conditionalvalue;

-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsLessThan:(double)conditionalvalue;
-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsLessThanOrEqualTo:(double)conditionalvalue;


-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsGreaterThan:(double)value1 ANDLessThan:(double)value2;
-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsGreaterThanEqualTo:(double)value1 ANDLessThan:(double)value2;
-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsGreaterThan:(double)value1 ANDLessThanEqualTo:(double)value2;
-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsGreaterThanEqualTo:(double)value1 ANDLessThanEqualTo:(double)value2;


-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsGreaterThan:(double)value1 ORLessThan:(double)value2;
-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsGreaterThanEqualTo:(double)value1 ORLessThan:(double)value2;
-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsGreaterThan:(double)value1 ORLessThanEqualTo:(double)value2;
-(NSArray*)valuesForKey:(NSString*)key inAllDicts:(NSDictionary*)allJsonDicts whereItIsGreaterThanEqualTo:(double)value1 ORLessThanEqualTo:(double)value2;

@end

NS_ASSUME_NONNULL_END
