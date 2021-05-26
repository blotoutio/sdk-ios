//
//  BOASDKManifestControllerTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 16/07/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOASDKManifestController.h"
#import "BOASDKManifestConstants.h"
#import <BlotoutFoundation/BOFUserDefaults.h>
#import "BOAConstants.h"
#import "BlotoutAnalytics.h"


@interface BOASDKManifestControllerTests : XCTestCase
@property (nonatomic) BOASDKManifestController *objBOASDKManifestController;
@end

@implementation BOASDKManifestControllerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.objBOASDKManifestController = [BOASDKManifestController sharedInstance];
    
    NSError *manifestReadError = nil;
    BOASDKManifest *sdkManifestM = [BOASDKManifest fromJSON:[self manifestJsonString] encoding: NSUTF8StringEncoding error:&manifestReadError];
    self.objBOASDKManifestController.sdkManifestModel = sdkManifestM;
    [self.objBOASDKManifestController sdkManifestPathAfterWriting: [self manifestJsonString]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForEventCodifiedMergecounter {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: Event_CodifiedMergeCounter];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testDictContainingValueForEventCodifiedMergecounter {
    NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: Event_CodifiedMergeCounter];
    XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
}

- (void)testRequiredValueUsingDictForVariableNameKeyValueForEventCodifiedMergecounter {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: Event_CodifiedMergeCounter];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForEventCodifiedMergecounter {
    BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: Event_CodifiedMergeCounter];
    XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
}

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForEventPushThresholdInterval {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: Event_PushThreshold_Interval];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testDictContainingValueForEventPushThresholdInterval {
    NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: Event_PushThreshold_Interval];
    XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
}

- (void)testRequiredValueUsingDictForVariableNameKeyValueForEventPushThresholdInterval {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: Event_PushThreshold_Interval];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForEventPushThresholdInterval {
    BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: Event_PushThreshold_Interval];
    XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
}

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForEventPushThresholdEventCounter {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: Event_PushThreshold_EventCounter];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testDictContainingValueForEventPushThresholdEventCounter {
    NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: Event_PushThreshold_EventCounter];
    XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
}

- (void)testRequiredValueUsingDictForVariableNameKeyValueForEventPushThresholdEventCounter {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: Event_PushThreshold_EventCounter];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForEventPushThresholdEventCounter {
    BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: Event_PushThreshold_EventCounter];
    XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
}

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForEventGEOLocationGrain {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: Event_GEOLocationGrain];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testDictContainingValueForEventGEOLocationGrain {
    NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: Event_GEOLocationGrain];
    XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
}

- (void)testRequiredValueUsingDictForVariableNameKeyValueForEventGEOLocationGrain {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: Event_GEOLocationGrain];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForEventGEOLocationGrain {
    BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: Event_GEOLocationGrain];
    XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
}

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForEventDeviceInfoGrain {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: Event_DeviceInfoGrain];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testDictContainingValueForEventDeviceInfoGrain {
    NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: Event_DeviceInfoGrain];
    XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
}

- (void)testRequiredValueUsingDictForVariableNameKeyValueForEventDeviceInfoGrain {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: Event_DeviceInfoGrain];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForEventDeviceInfoGrain {
    BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: Event_DeviceInfoGrain];
    XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
}

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForEventSystemMergeCounter {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: Event_SystemMergeCounter];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testDictContainingValueForEventSystemMergeCounter {
    NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: Event_SystemMergeCounter];
    XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
}

- (void)testRequiredValueUsingDictForVariableNameKeyValueForEventSystemMergeCounter {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: Event_SystemMergeCounter];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForEventSystemMergeCounter {
    BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: Event_SystemMergeCounter];
    XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
}

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForEventOfflineInterval {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: Event_Offline_Interval];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testDictContainingValueForEventOfflineInterval {
    NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: Event_Offline_Interval];
    XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
}

- (void)testRequiredValueUsingDictForVariableNameKeyValueForEventOfflineInterval {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: Event_Offline_Interval];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForEventOfflineInterval {
    BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: Event_Offline_Interval];
    XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
}

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForLicenseExpireDayAlive {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: License_Expire_Day_Alive];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testDictContainingValueForLicenseExpireDayAlive {
    NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: License_Expire_Day_Alive];
    XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
}

- (void)testRequiredValueUsingDictForVariableNameKeyValueForLicenseExpireDayAlive {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: License_Expire_Day_Alive];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForLicenseExpireDayAlive {
    BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: License_Expire_Day_Alive];
    XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
}

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForIntervalManifestRefresh {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: Interval_Manifest_Refresh];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testDictContainingValueForIntervalManifestRefresh {
    NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: Interval_Manifest_Refresh];
    XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
}

- (void)testRequiredValueUsingDictForVariableNameKeyValueForIntervalManifestRefresh {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: Interval_Manifest_Refresh];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForIntervalManifestRefresh {
    BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: Interval_Manifest_Refresh];
    XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
}

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForIntervalStoreEvents {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: Interval_Store_Events];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testDictContainingValueForIntervalStoreEvents {
    NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: Interval_Store_Events];
    XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
}

- (void)testRequiredValueUsingDictForVariableNameKeyValueForIntervalStoreEvents {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: Interval_Store_Events];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForIntervalStoreEvents {
    BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: Interval_Store_Events];
    XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
}

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForIntervalRetry {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: Interval_Retry];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testDictContainingValueForIntervalRetry {
    NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: Interval_Retry];
    XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
}

- (void)testRequiredValueUsingDictForVariableNameKeyValueForIntervalRetry {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: Interval_Retry];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForIntervalRetry {
    BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: Interval_Retry];
    XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
}

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForApiEndpoint {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: Api_Endpoint];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testDictContainingValueForApiEndpoint {
    NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: Api_Endpoint];
    XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
}

- (void)testRequiredValueUsingDictForVariableNameKeyValueForApiEndpoint {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: Api_Endpoint];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForApiEndpoint {
    BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: Api_Endpoint];
    XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
}

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForEventFunnelPath {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: EVENT_FUNNEL_PATH];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testDictContainingValueForEventFunnelPath {
    NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: EVENT_FUNNEL_PATH];
    XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
}

- (void)testRequiredValueUsingDictForVariableNameKeyValueForEventFunnelPath {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: EVENT_FUNNEL_PATH];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForEventFunnelPath {
    BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: EVENT_FUNNEL_PATH];
    XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
}

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForEventFunnelFeedbackPath {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: EVENT_FUNNEL_FEEDBACK_PATH];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testDictContainingValueForEventFunnelFeedbackPath {
    NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: EVENT_FUNNEL_FEEDBACK_PATH];
    XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
}

- (void)testRequiredValueUsingDictForVariableNameKeyValueForEventFunnelFeedbackPath {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: EVENT_FUNNEL_FEEDBACK_PATH];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForEventFunnelFeedbackPath {
    BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: EVENT_FUNNEL_FEEDBACK_PATH];
    XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
}

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForGeoIpPath {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: GEO_IP_PATH];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testDictContainingValueForGeoIpPath {
    NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: GEO_IP_PATH];
    XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
}

- (void)testRequiredValueUsingDictForVariableNameKeyValueForGeoIpPath {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: GEO_IP_PATH];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForGeoIpPath {
    BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: GEO_IP_PATH];
    XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
}

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForEventRetentionPath {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: EVENT_RETENTION_PATH];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testDictContainingValueForEventRetentionPath {
    NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: EVENT_RETENTION_PATH];
    XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
}

- (void)testRequiredValueUsingDictForEventRetentionPath {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: EVENT_RETENTION_PATH];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForEventRetentionPath {
    BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: EVENT_RETENTION_PATH];
    XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
}

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForEventPath {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: EVENT_PATH];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testDictContainingValueForEventPath {
    NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: EVENT_PATH];
    XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
}

- (void)testRequiredValueUsingDictForEventPath {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: EVENT_PATH];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForEventPath {
    BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: EVENT_PATH];
    XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
}

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForSegmentPullPath {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: SEGMENT_PULL_PATH];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testDictContainingValueForSegmentPullPath {
    NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: SEGMENT_PULL_PATH];
    XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
}

- (void)testRequiredValueUsingDictForSegmentPullPath {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: SEGMENT_PULL_PATH];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForSegmentPullPath {
    BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: SEGMENT_PULL_PATH];
    XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
}

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForSegmentFeedbackPath {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: SEGMENT_FEEDBACK_PATH];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testDictContainingValueForSegmentFeedbackPath {
    NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: SEGMENT_FEEDBACK_PATH];
    XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
}

- (void)testRequiredValueUsingDictForSegmentFeedbackPath {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: SEGMENT_FEEDBACK_PATH];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForSegmentFeedbackPath {
    BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: SEGMENT_FEEDBACK_PATH];
    XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
}

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForEventPushSystemEvents {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: Event_Push_System_Events];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

- (void)testDictContainingValueForEventPushSystemEvents {
    NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: Event_Push_System_Events];
    XCTAssertNil(dict, @"Can not find containing dict for key in manifest");
}

- (void)testRequiredValueUsingDictForEventPushSystemEvents {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: Event_Push_System_Events];
    XCTAssertNil(value, @"BO Server Not supporting these value as of now");
}

- (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForEventPushSystemEvents {
    BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: Event_Push_System_Events];
    XCTAssertNil(sdkVariable, @"BO Server Not supporting these value as of now");
}

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForEventPushPIIEvents {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: Event_Push_PII_Events];
    XCTAssertNotNil(value, @"BO Server Not supporting these value as of now");
}

/*
 - (void)testDictContainingValueForEventPushPIIEvents {
 NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: Event_Push_PII_Events];
 XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
 }
 
 - (void)testRequiredValueUsingDictForEventPushPIIEvents {
 NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: Event_Push_PII_Events];
 XCTAssertNotNil(value, @"Can not find value for key in manifest");
 }
 
 - (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForEventPushPIIEvents {
 BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: Event_Push_PII_Events];
 XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
 }
 */

- (void)testRequiredValueUsingModelOfVariableNameKeyValueForEventSDKMapUserId {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: Event_SDK_Map_User_Id];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

/*
 - (void)testDictContainingValueForEventSDKMapUserId {
 NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: Event_SDK_Map_User_Id];
 XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
 }
 
 - (void)testRequiredValueUsingDictForEventSDKMapUserId {
 NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: Event_SDK_Map_User_Id];
 XCTAssertNotNil(value, @"Can not find value for key in manifest");
 }
 
 - (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForEventSDKMapUserId {
 BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: Event_SDK_Map_User_Id];
 XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
 }
 */
- (void)testRequiredValueUsingModelOfVariableNameKeyValueForEventSDKBehaviourId {
    NSString *value = [self.objBOASDKManifestController requiredValueUsingModelOfVariableNameKeyValue: Event_SDK_Behaviour_Id];
    XCTAssertNotNil(value, @"Can not find value for key in manifest");
}

/*
 - (void)testDictContainingValueForEventSDKBehaviourId {
 NSDictionary *dict = [self.objBOASDKManifestController dictContainingValue: Event_SDK_Behaviour_Id];
 XCTAssertNotNil(dict, @"Can not find containing dict for key in manifest");
 }
 
 - (void)testRequiredValueUsingDictForEventSDKBehaviourId {
 NSString *value = [self.objBOASDKManifestController requiredValueUsingDictForVariableNameKeyValue: Event_SDK_Behaviour_Id];
 XCTAssertNotNil(value, @"Can not find value for key in manifest");
 }
 
 - (void)testRequiredVariableObjectUsingModelOfVariableNameKeyValueForEventSDKBehaviourId {
 BOASDKVariable *sdkVariable = [self.objBOASDKManifestController requiredVariableObjectUsingModelOfVariableNameKeyValue: Event_SDK_Behaviour_Id];
 XCTAssertNotNil(sdkVariable, @"Can not find SDK variable for key");
 }
 */

- (void)testGetAPIEndPointFromManifestFor {
    NSString *apiEndPoint = [self.objBOASDKManifestController getAPIEndPointFromManifestFor: @"Api_Endpoint"];
    XCTAssertNotNil(apiEndPoint, @"Can not find Api end point variable from manifest");
}

- (void)testIsManifestAvailable {
    BOOL status = [self.objBOASDKManifestController isManifestAvailable];
    XCTAssertTrue(status);
}

- (void)testLatestSDKManifestPath {
    NSString *sdkManifestFilePath = [self.objBOASDKManifestController latestSDKManifestPath];
    XCTAssertNotNil(sdkManifestFilePath, @"Can not find lastest manifest sdk path");
}

- (void)testLatestSDKManifestJSONString {
    NSString *sdkManifestStr = [self.objBOASDKManifestController latestSDKManifestJSONString];
    XCTAssertNotNil(sdkManifestStr, @"Can not find lastest manifest sdk json");
}

- (void)testSdkManifestPathAfterWriting {
    NSString *manifestPath = [self.objBOASDKManifestController sdkManifestPathAfterWriting:[self manifestJsonString]];
    XCTAssertNotNil(manifestPath, @"Can not find manifest path");
}

- (void)testManifestRefreshInterval {
    NSTimeInterval interval = [self.objBOASDKManifestController manifestRefreshInterval];
    XCTAssertEqual(interval, 86400);
}

- (void)testSetupManifestExtraParamOnSuccess {
    [self.objBOASDKManifestController setupManifestExtraParamOnSuccess];
    BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
    XCTAssertNotNil([analyticsRootUD objectForKey:BO_ANALYTICS_SDK_MANIFEST_LAST_TIMESTAMP_SYNC_DEFAULTS_KEY], @"Failed to set manifest extra param on success");
}

- (void)testSetupManifestExtraParamOnFailure {
    [self.objBOASDKManifestController setupManifestExtraParamOnFailure];
    XCTAssertTrue(self.objBOASDKManifestController.storageCutoffReached);
}

- (void)testSyncManifestWithServer {
    [self.objBOASDKManifestController syncManifestWithServer];
    XCTAssertTrue([BlotoutAnalytics sharedInstance].isEnabled);
}

- (void)testGetNumberFrom {
    NSNumber *number = [self.objBOASDKManifestController getNumberFrom:@"5"];
    XCTAssertEqual([number integerValue], 5);
}

- (void)testGetManifestVariable {
    NSError *manifestReadError = nil;
    BOASDKManifest *sdkManifestM = [BOASDKManifest fromJSON:[self manifestJsonString] encoding: NSUTF8StringEncoding error:&manifestReadError];
    BOASDKVariable *codifiedMergeCounter = [self.objBOASDKManifestController getManifestVariable:sdkManifestM forValue: Event_CodifiedMergeCounter];
    XCTAssertNotNil(codifiedMergeCounter);
}

- (NSString *)manifestJsonString {
    return @"{\"variables\":[{\"variableId\":5006,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Event_Codified_Mergecounter\",\"isEditable\":true},{\"variableId\":5007,\"value\":\"90\",\"variableDataType\":1,\"variableName\":\"Event_Offline_Interval\",\"isEditable\":true},{\"variableId\":5021,\"value\":\"v1/segment/pull\",\"variableDataType\":6,\"variableName\":\"Segment_Path\",\"isEditable\":true},{\"variableId\":5009,\"value\":\"https://sdk.blotout.io/sdk\",\"variableDataType\":6,\"variableName\":\"Api_Endpoint\",\"isEditable\":true},{\"variableId\":5022,\"value\":\"v1/segment/custom/feedback\",\"variableDataType\":6,\"variableName\":\"Segment_Feedback_Path\",\"isEditable\":true},{\"variableId\":5010,\"value\":\"30\",\"variableDataType\":1,\"variableName\":\"License_Expire_Day_Alive\",\"isEditable\":true},{\"variableId\":5011,\"value\":\"24\",\"variableDataType\":1,\"variableName\":\"Manifest_Refresh_Interval\",\"isEditable\":true},{\"variableId\":5999,\"value\":\"1593882555290\",\"variableDataType\":6,\"variableName\":\"Last_Updated_Time\",\"isEditable\":true},{\"variableId\":5003,\"value\":\"2\",\"variableDataType\":1,\"variableName\":\"Event_Geolocation_Grain\",\"isEditable\":true},{\"variableId\":5018,\"value\":\"v1/funnel/pull\",\"variableDataType\":6,\"variableName\":\"Event_Funnel_Path\",\"isEditable\":true},{\"variableId\":5019,\"value\":\"v1/funnel/feedback\",\"variableDataType\":6,\"variableName\":\"Event_Funnel_Feedback_Path\",\"isEditable\":true},{\"variableId\":5005,\"value\":\"-1\",\"variableDataType\":1,\"variableName\":\"Event_System_Mergecounter\",\"isEditable\":true},{\"variableId\":5013,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Retry_Interval\",\"isEditable\":true},{\"variableId\":5001,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Event_Push_Interval\",\"isEditable\":true},{\"variableId\":5014,\"value\":\"0\",\"variableDataType\":1,\"variableName\":\"Mode_Deployment\",\"isEditable\":true},{\"variableId\":5002,\"value\":\"15\",\"variableDataType\":1,\"variableName\":\"Event_Push_Eventscounter\",\"isEditable\":true},{\"variableId\":5015,\"value\":\"0\",\"variableDataType\":1,\"variableName\":\"Customer_Type\",\"isEditable\":true},{\"variableId\":5016,\"value\":\"v1/events/publish\",\"variableDataType\":6,\"variableName\":\"Event_Path\",\"isEditable\":true},{\"variableId\":5017,\"value\":\"v1/events/retention/publish\",\"variableDataType\":6,\"variableName\":\"Event_Retention_Path\",\"isEditable\":true}, {\"variableId\":5004,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Event_Deviceinfo_Grain\",\"isEditable\":true}, {\"variableId\":5012,\"value\":\"180\",\"variableDataType\":1,\"variableName\":\"Store_Events_Interval\",\"isEditable\":true}, {\"variableId\":5020,\"value\":\"v1/geo/city\",\"variableDataType\":6,\"variableName\":\"Geo_Ip_Path\",\"isEditable\":true}]}";
    
}


@end
