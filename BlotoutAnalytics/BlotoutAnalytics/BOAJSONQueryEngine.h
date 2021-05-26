//
//  BOAJSONQueryEngine.h
//  BlotoutAnalytics
//
//  Created by Blotout on 21/08/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * _Nullable const RDJSONKeyKey;
extern NSString * _Nullable const RDJSONIndexKey;

#define RDJSONKey(x) @{@"dKey":x}
#define RDJSONIndex(x) @{@"aIndex":@x}

NS_ASSUME_NONNULL_BEGIN

@interface BOAJSONQueryEngine : NSObject

+(NSDictionary*)predefinedKeysWithCategoryCode;
+(BOOL)isKey:(NSString*)testKey belongsToPredefinedKeys:(NSDictionary*)preDefinedKeysDict;

+(id)objectFromNestedJSON:(id)JSONObject usingCascadedKeys:(NSDictionary*)firstArg,...;

+(BOOL)isKey:(NSString*)key availableInDict:(NSDictionary*)jsonDict;
+(BOOL)isKey:(NSString*)key availableInJSON:(NSString*)jsonStr;

+(int)occuranceCountOf:(NSString*)key availableInDict:(NSDictionary*)jsonDict;
+(int)occuranceCountOf:(NSString*)key availableInJSON:(NSString*)jsonStr;

+(NSDictionary*)dictContainsKey:(NSString*)key fromRootDict:(NSDictionary*)jsonDict;
+(id)valueForKey:(NSString*)key inNestedDict:(NSDictionary*)jsonDict;

+(NSArray<NSDictionary*>*)allDictContainsKey:(NSString*)key fromRootDict:(NSDictionary*)jsonDict;
+(NSArray*)allValueForKey:(NSString*)key inNestedDict:(NSDictionary*)jsonDict;

+(NSString*)getParentKeyForKey:(NSString*)key inNestedDict:(NSDictionary*)jsonDict;
//Test when value and key falls inside dict, which is inside an Array
+(NSString*)getKeyPathForKey:(NSString*)key inNestedDict:(NSDictionary*)jsonDict;

+(NSArray<NSString*>*)getAllParentKeyForKey:(NSString*)key inNestedDict:(NSDictionary*)jsonDict;
//Test when value and key falls inside dict, which is inside an Array
+(NSArray<NSString*>*)getAllKeyPathForKey:(NSString*)key inNestedDict:(NSDictionary*)jsonDict;

//Use concept of indexing, where key paths gets prepared earlier and then data access tested using key path and accessed via keypath.
//This is similar to DB indexing, lot of key path indexed will cause certain delay and increased storage to use case fully.
/*
 //========================================= Need to work on this indexing concept as data grow ===========================================
 */
//+(NSArray<NSString*>*)keyPathForAllKeysInDict:(NSDictionary*)jsonDict;
//+(BOOL)generateAndSaveKeyPathForAllKeysInDict:(NSDictionary*)jsonDict atDirectory:(NSString*)directory withName:(NSString*)fileName;

+(BOOL)isValue:(id)value availableInDict:(NSDictionary*)jsonDict;
+(BOOL)isValue:(NSString*)value availableInJSON:(NSString*)jsonStr;

+(int)occuranceCountOfValue:(id)value availableInDict:(NSDictionary*)jsonDict;
+(int)occuranceCountOfValue:(NSString*)value availableInJSON:(NSString*)jsonStr;

+(NSDictionary*)dictContainsValue:(id)value fromRootDict:(NSDictionary*)jsonDict;
+(NSString*)keyForValue:(id)value inNestedDict:(NSDictionary*)jsonDict;

+(NSArray<NSDictionary*>*)allDictContainsValue:(id)value fromRootDict:(NSDictionary*)jsonDict;
//May not be directly useful but provided as helping method
+(NSArray*)allKeysForValue:(id)value inNestedDict:(NSDictionary*)jsonDict;
//
// use key concept methods for further parent keys or keypath once key is derived
//
//+(NSString*)getParentKeyForValue:(NSString*)key inNestedDict:(NSDictionary*)jsonDict;
//+(NSString*)getKeyPathForValue:(NSString*)key inNestedDict:(NSDictionary*)jsonDict;
//
//+(NSArray<NSString*>*)getAllParentKeyForValue:(NSString*)key inNestedDict:(NSDictionary*)jsonDict;
//+(NSArray<NSString*>*)getAllKeyPathForValue:(NSString*)key inNestedDict:(NSDictionary*)jsonDict;

@end

NS_ASSUME_NONNULL_END
