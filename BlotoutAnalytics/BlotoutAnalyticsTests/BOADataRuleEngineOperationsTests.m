//
//  BOADataRuleEngineOperationsTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 12/11/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOADataRuleEngineOperations.h"
#import "BOASDKManifestController.h"

@interface BOADataRuleEngineOperationsTests : XCTestCase
@property (nonatomic) BOADataRuleEngineOperations *dataRuleEngineOperations;
@property (nonatomic) BOASDKManifestController *objBOASDKManifestController;
@property(nonatomic) NSDictionary *predefinedKeys;
@end

@implementation BOADataRuleEngineOperationsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.dataRuleEngineOperations = [BOADataRuleEngineOperations sharedInstance];
    NSDictionary *innerDict = @{ @"30001" : @1, @"detail": @{@"30001" : @2}, @"child":@{@"30001" : @3, @"innerChild":@{@"30001" : @4}}};
    
    self.predefinedKeys = @{
        @"10001":@[@"appBundle",@"date", @"singleDaySessions", @"sentToServer", @"systemUptime", @"lastServerSyncTimeStamp", @"allEventsSyncTimeStamp", @"appInfo", @"timeStamp", @"version", @"sdkVersion", @"name", @"bundle", @"language", @"launchTimeStamp", @"terminationTimeStamp", @"sessionsDuration", @"averageSessionsDuration", @"launchReason", @"currentLocation", @"city", @"state", @"country", @"zip", @"ubiAutoDetected", @"screenShotsTaken", @"currentView", @"appNavigation"],
        @"20001":@[@"click"],
        @"30001":innerDict,
    };
    
    
    
    self.objBOASDKManifestController = [BOASDKManifestController sharedInstance];
    
    NSError *manifestReadError = nil;
    BOASDKManifest *sdkManifestM = [BOASDKManifest fromJSON:[self manifestJsonString] encoding: NSUTF8StringEncoding error:&manifestReadError];
    self.objBOASDKManifestController.sdkManifestModel = sdkManifestM;
    [self.objBOASDKManifestController sdkManifestPathAfterWriting: [self manifestJsonString]];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSharedInstance {
    BOADataRuleEngineOperations *sharedObj = [BOADataRuleEngineOperations sharedInstance];
    XCTAssertNotNil(sharedObj);
}

- (void)testPredefinedKeysWithCategoryCode {
    NSDictionary *keys = [self.dataRuleEngineOperations predefinedKeysWithCategoryCode];
    XCTAssertNotNil(keys);
    
    BOOL status = [self.dataRuleEngineOperations isKey:@"sentToServer" belongsToPredefinedKeys:self.predefinedKeys];
    XCTAssertTrue(status);
}

- (void)testDataDictContains {
    NSArray *resultArr = [self.dataRuleEngineOperations allDataDictConatainsKey:@"sentToServer" fromSourceData:[NSArray arrayWithObject:self.predefinedKeys]];
    XCTAssertNotNil(resultArr);
    XCTAssertEqual(resultArr.count, 1);
    
    resultArr = [self.dataRuleEngineOperations allDataDictBetweenStart:[NSDate date] andEndDate:[NSDate date] fromSource:[self.objBOASDKManifestController latestSDKManifestPath]];
    XCTAssertNil(resultArr);
    
    resultArr = [self.dataRuleEngineOperations allDataDictBetweenStart:[NSDate date] andEndDate:[NSDate date] ConatainsKey:@"sentToServer" fromSourceData: [NSArray arrayWithObject:self.predefinedKeys]];
    XCTAssertNotNil(resultArr);
    XCTAssertEqual(resultArr.count, 1);
    
    resultArr = [self.dataRuleEngineOperations allDataDictConatainsValue:@"sentToServer" fromSourceData:[NSArray arrayWithObject:self.predefinedKeys]];
    XCTAssertNotNil(resultArr);
    XCTAssertEqual(resultArr.count, 1);
    
    resultArr = [self.dataRuleEngineOperations allDataDictBetweenStart:[NSDate date] andEndDate:[NSDate date] ConatainsValue:@"singleDaySessions" fromSourceData:[NSArray arrayWithObject:self.predefinedKeys]];
    XCTAssertNotNil(resultArr);
    XCTAssertEqual(resultArr.count, 1);
    
    resultArr = [self.dataRuleEngineOperations allDataDictConatains:@"singleDaySessions" fromSourceData:[NSArray arrayWithObject:self.predefinedKeys]];
    XCTAssertNotNil(resultArr);
    XCTAssertEqual(resultArr.count, 1);
    
    resultArr = [self.dataRuleEngineOperations allDataDictBetweenStart:[NSDate date] andEndDate:[NSDate date] Conatains:@"singleDaySessions" fromSourceData:[NSArray arrayWithObject:self.predefinedKeys]];
    XCTAssertNotNil(resultArr);
    XCTAssertEqual(resultArr.count, 1);
    
    resultArr = [self.dataRuleEngineOperations allDataDictBetweenStart:[NSDate date] andEndDate:[NSDate date] fromSourceData:[NSArray arrayWithObject:self.predefinedKeys]];
    XCTAssertNotNil(resultArr);
    XCTAssertEqual(resultArr.count, 1);
    
    resultArr = [self.dataRuleEngineOperations allDataDictBetweenStart:[NSDate date] andEndDate:[NSDate date] fromSource:[self.objBOASDKManifestController latestSDKManifestPath]];
    XCTAssertNil(resultArr);
    
    resultArr = [self.dataRuleEngineOperations allDataDictFromSource:[self.objBOASDKManifestController latestSDKManifestPath]];
    XCTAssertNotNil(resultArr);
    XCTAssertEqual(resultArr.count, 0);
    
    NSDictionary *dict = [self.dataRuleEngineOperations dataSubSectionContainsKey:@"10001" fromRootDict:self.predefinedKeys];
    XCTAssertNotNil(dict);
    
    resultArr = [self.dataRuleEngineOperations allDataSubSectionsContainsKey:@"10001" fromAllRootDict:[NSArray arrayWithObject:self.predefinedKeys]];
    XCTAssertNotNil(resultArr);
    
}

- (void)testValueForKey {
    NSArray *keys = [NSArray arrayWithObjects:@"10001", @"20001", nil];
    NSDictionary *dict = [self.dataRuleEngineOperations valuesForKeys:keys inDicts:[NSArray arrayWithObject:self.predefinedKeys]];
    XCTAssertNotNil(dict);
    
    NSArray *arr = [self.dataRuleEngineOperations valuesForKey:@"10001" inAllDicts:[NSArray arrayWithObject:self.predefinedKeys] whereItContains:@"sentToServer"];
    XCTAssertNotNil(arr);
    XCTAssertEqual(arr.count, 1);
    
    arr = [self.dataRuleEngineOperations valuesForKey:@"30001" inAllDicts:self.predefinedKeys whereItIsGreaterThan: 2];
    XCTAssertNotNil(arr);
    
    arr = [self.dataRuleEngineOperations valuesForKey:@"20001" inAllDicts:self.predefinedKeys whereItIsGreaterThanOrEqualTo: 2];
    XCTAssertNotNil(arr);
    
    arr = [self.dataRuleEngineOperations valuesForKey:@"20001" inAllDicts:self.predefinedKeys whereItIsLessThan: 2];
    XCTAssertNotNil(arr);
    
    arr = [self.dataRuleEngineOperations valuesForKey:@"20001" inAllDicts:self.predefinedKeys whereItIsLessThanOrEqualTo: 2];
    XCTAssertNotNil(arr);
    
    arr = [self.dataRuleEngineOperations valuesForKey:@"20001" inAllDicts:self.predefinedKeys whereItIsGreaterThan: 2 ANDLessThan:4];
    XCTAssertNotNil(arr);
    
    arr = [self.dataRuleEngineOperations valuesForKey:@"20001" inAllDicts:self.predefinedKeys whereItIsGreaterThanEqualTo: 2 ANDLessThan:4];
    XCTAssertNotNil(arr);
    
    arr = [self.dataRuleEngineOperations valuesForKey:@"20001" inAllDicts:self.predefinedKeys whereItIsGreaterThan: 2 ANDLessThanEqualTo:4];
    XCTAssertNotNil(arr);
    
    arr = [self.dataRuleEngineOperations valuesForKey:@"20001" inAllDicts:self.predefinedKeys whereItIsGreaterThanEqualTo: 2 ANDLessThanEqualTo:4];
    XCTAssertNotNil(arr);
    
    arr = [self.dataRuleEngineOperations valuesForKey:@"20001" inAllDicts:self.predefinedKeys whereItIsGreaterThan: 2 ORLessThan:4];
    XCTAssertNotNil(arr);
    
    arr = [self.dataRuleEngineOperations valuesForKey:@"20001" inAllDicts:self.predefinedKeys whereItIsGreaterThanEqualTo: 2 ORLessThan:4];
    XCTAssertNotNil(arr);
    
    arr = [self.dataRuleEngineOperations valuesForKey:@"20001" inAllDicts:self.predefinedKeys whereItIsGreaterThan: 2 ORLessThanEqualTo:4];
    XCTAssertNotNil(arr);
    
    arr = [self.dataRuleEngineOperations valuesForKey:@"20001" inAllDicts:self.predefinedKeys whereItIsGreaterThanEqualTo: 2 ORLessThanEqualTo:4];
    XCTAssertNotNil(arr);
}

- (NSString *)manifestJsonString {
    return @"{\"variables\":[{\"variableId\":5006,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Event_Codified_Mergecounter\",\"isEditable\":true},{\"variableId\":5007,\"value\":\"90\",\"variableDataType\":1,\"variableName\":\"Event_Offline_Interval\",\"isEditable\":true},{\"variableId\":5021,\"value\":\"v1/segment/pull\",\"variableDataType\":6,\"variableName\":\"Segment_Path\",\"isEditable\":true},{\"variableId\":5009,\"value\":\"https://sdk.blotout.io/sdk\",\"variableDataType\":6,\"variableName\":\"Api_Endpoint\",\"isEditable\":true},{\"variableId\":5022,\"value\":\"v1/segment/custom/feedback\",\"variableDataType\":6,\"variableName\":\"Segment_Feedback_Path\",\"isEditable\":true},{\"variableId\":5010,\"value\":\"30\",\"variableDataType\":1,\"variableName\":\"License_Expire_Day_Alive\",\"isEditable\":true},{\"variableId\":5011,\"value\":\"24\",\"variableDataType\":1,\"variableName\":\"Manifest_Refresh_Interval\",\"isEditable\":true},{\"variableId\":5999,\"value\":\"1593882555290\",\"variableDataType\":6,\"variableName\":\"Last_Updated_Time\",\"isEditable\":true},{\"variableId\":5003,\"value\":\"2\",\"variableDataType\":1,\"variableName\":\"Event_Geolocation_Grain\",\"isEditable\":true},{\"variableId\":5018,\"value\":\"v1/funnel/pull\",\"variableDataType\":6,\"variableName\":\"Event_Funnel_Path\",\"isEditable\":true},{\"variableId\":5019,\"value\":\"v1/funnel/feedback\",\"variableDataType\":6,\"variableName\":\"Event_Funnel_Feedback_Path\",\"isEditable\":true},{\"variableId\":5005,\"value\":\"-1\",\"variableDataType\":1,\"variableName\":\"Event_System_Mergecounter\",\"isEditable\":true},{\"variableId\":5013,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Retry_Interval\",\"isEditable\":true},{\"variableId\":5001,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Event_Push_Interval\",\"isEditable\":true},{\"variableId\":5014,\"value\":\"0\",\"variableDataType\":1,\"variableName\":\"Mode_Deployment\",\"isEditable\":true},{\"variableId\":5002,\"value\":\"15\",\"variableDataType\":1,\"variableName\":\"Event_Push_Eventscounter\",\"isEditable\":true},{\"variableId\":5015,\"value\":\"0\",\"variableDataType\":1,\"variableName\":\"Customer_Type\",\"isEditable\":true},{\"variableId\":5016,\"value\":\"v1/events/publish\",\"variableDataType\":6,\"variableName\":\"Event_Path\",\"isEditable\":true},{\"variableId\":5017,\"value\":\"v1/events/retention/publish\",\"variableDataType\":6,\"variableName\":\"Event_Retention_Path\",\"isEditable\":true}, {\"variableId\":5004,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Event_Deviceinfo_Grain\",\"isEditable\":true}, {\"variableId\":5012,\"value\":\"180\",\"variableDataType\":1,\"variableName\":\"Store_Events_Interval\",\"isEditable\":true}, {\"variableId\":5020,\"value\":\"v1/geo/city\",\"variableDataType\":6,\"variableName\":\"Geo_Ip_Path\",\"isEditable\":true}]}";
    
}

@end
