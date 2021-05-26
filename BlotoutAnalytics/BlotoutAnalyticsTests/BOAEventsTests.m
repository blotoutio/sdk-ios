//
//  BOAEventsTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 19/11/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOAEvents.h"
#import <BlotoutFoundation/BOFUserDefaults.h>
#import "BOAConstants.h"
#import "BOAppSessionData.h"
#import "BOALocalDefaultJSONs.h"
#import "BOAAppLifetimeData.h"
#import "BOAUtilities.h"
#import "BOAAppSessionEvents.h"
#import "BOAUtilities.h"


@interface BOAEventsTests : XCTestCase

@end

@implementation BOAEventsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

-(void)testTopViewController {
    BOAEvents *events = [[BOAEvents alloc] init];
    UIViewController *controller = [events topViewController];
    XCTAssertNil(controller);
    
    NSNumber *number = [BOAUtilities codeForCustomCodifiedEvent:@"sendToServer"];
    XCTAssertNotNil(number);
    XCTAssertGreaterThan([number intValue], 0);
}

-(void)testGetDirPath {
    NSString *dirPath = [BOAEvents getSessionDirectoryPath];
    XCTAssertNotNil(dirPath);
    
    dirPath = [BOAEvents getSyncedDirectoryPath];
    XCTAssertNotNil(dirPath);
    
    dirPath = [BOAEvents getNotSyncedDirectoryPath];
    XCTAssertNotNil(dirPath);
    
    dirPath = [BOAEvents getLifeTimeDirectoryPath];
    XCTAssertNotNil(dirPath);
    
    dirPath = [BOAEvents getLifeTimeDataSyncedDirectoryPath];
    XCTAssertNotNil(dirPath);
    
    dirPath = [BOAEvents getLifeTimeDataNotSyncedDirectoryPath];
    XCTAssertNotNil(dirPath);
}

-(void)testSyncWithServer {
    NSDictionary *appSpecInfo = [NSDictionary dictionaryWithObject:@"Blotout" forKey:@"appName"];
    NSDictionary *envInfo = [NSDictionary dictionaryWithObject:@"dev" forKey:@"envMode"];
    
    NSArray *arrAppInfo = [NSArray arrayWithObjects:envInfo, appSpecInfo, nil];
    
    NSDictionary *appInfoDic = [NSDictionary dictionaryWithObject:arrAppInfo forKey:@"appInfo"];
    NSDictionary *singleDaySessions = [NSDictionary dictionaryWithObject:appInfoDic forKey:@"singleDaySessions"];
    
    [BOAEvents storePreviousDayAppInfoViaNotification:singleDaySessions];
    
    BOFUserDefaults *analyticsRootUD = [BOFUserDefaults userDefaultsForProduct:BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY];
    NSDictionary *dic = [analyticsRootUD objectForKey:BO_ANALYTICS_ROOT_USER_DEFAULTS_PREVIOUS_DAY_APP_INFO];
    XCTAssertNotNil(dic);
    
    NSString *dirPath = [BOAEvents getSessionDirectoryPath];
    [BOAEvents syncWithServerForFile:dirPath];
    [BOAEvents syncWithServerAllFilesWithExtention:@".txt" InDirectory:dirPath];
    
    
    BOAppSessionData *currentDaySessionObj = nil;
    currentDaySessionObj = [BOAppSessionData sharedInstanceFromJSONDictionary: singleDaySessions];
    [BOAEvents syncRecursiveWithServerForSession: currentDaySessionObj];
    
    [BOAEvents syncWithServerAfterDelay:[[NSDate date] timeIntervalSince1970] forSession: currentDaySessionObj];
    
}

-(void)testAppSessionMethods {
    BOOL status = [BOAEvents isAppLifeModelInitialised];
    XCTAssertFalse(status);
    
    status = [BOAEvents isSessionModelInitialised];
    XCTAssertTrue(status);
    
    NSError *jsonError;
    NSString *jsonStr = [self getDummyJson];
    NSData *objectData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    
    BOAppSessionData *appSessionData = [BOAppSessionData sharedInstanceFromJSONDictionary:json];
    [BOAEvents setAppSessionModel:appSessionData];
    
    BOAppSessionData *appSessionDataTmp = [BOAEvents appSessionModel];
    XCTAssertNotNil(appSessionDataTmp);
    
    BOAAppLifetimeData *lifeTimeData = [BOAAppLifetimeData sharedInstanceFromJSONDictionary:[BOALocalDefaultJSONs appLifeTimeDataJSONDict]];
    [BOAEvents syncRecursiveWithServerForLifeTimeSession:lifeTimeData];
    
    NSDate *date = [BOAUtilities getCurrentDate];
    NSTimeInterval interval = [BOAUtilities getTimeIntervalSicneNowOfDate:date];
    [BOAEvents syncWithServerForLifeTimeSessionAfterDelay:interval forSession:lifeTimeData];
    
    [BOAEvents performSDKInitFunctionalityAsOnRelaunch];
    
    [BOAEvents setAppLifeTimeModel:lifeTimeData];
    XCTAssertNotNil(BOAEvents.appLifeTimeModel);
    
    BOAAppLifetimeData *lifeTimeDataTmp = [BOAEvents appLifeTimeModel];
    XCTAssertNotNil(lifeTimeDataTmp);
    
    [BOAEvents setIsSessionModelInitialised:YES];
    XCTAssertTrue(BOAEvents.isSessionModelInitialised);
    
    [BOAEvents setIsAppLifeModelInitialised:YES];
    XCTAssertTrue(BOAEvents.isAppLifeModelInitialised);
}
/*
 - (void)testFetchManifestAndSetup {
 [BOAEvents fetchManifestAndSetup:YES];
 BOOL status = [[BOAAppSessionEvents sharedInstance] isEnabled];
 XCTAssertTrue(status);
 [self waitForExpectationsWithTimeout:5.0 handler:nil];
 }
 */

- (void)testInitSuccessForAppDailySession {
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"app daily session init"];
    [BOAEvents initSuccessForAppDailySession:^(BOOL isSuccess, NSError * _Nullable error) {
        if(isSuccess) {
            [completionExpectation fulfill];
        } else {
            XCTFail();
        }
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testInitSuccessForAppLifeSession {
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"app life session init"];
    [BOAEvents initSuccessForAppLifeSession:^(BOOL isSuccess, NSError * _Nullable error) {
        if(isSuccess) {
            [completionExpectation fulfill];
        } else {
            XCTFail();
        }
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (void)testInitDefaultConfigurationWithHandler {
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"Init Default Configuration With Handler"];
    [BOAEvents initDefaultConfigurationWithHandler:^(BOOL isSuccess, NSError * _Nullable error) {
        if(isSuccess) {
            [completionExpectation fulfill];
        } else {
            XCTFail();
        }
    }];
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

- (NSString *)getDummyJson {
    return @"{\"date\":\"2020-12-03\",\"appBundle\":\"com.blotout.saleDemoApp\",\"singleDaySessions\":{\"sentToServer\":false,\"deviceInfo\":{\"numberOfAttachedAccessories\":[{\"timeStamp\":1607018403817,\"number\":0,\"mid\":\"478-21500-0e24b4c5a73b294f1b4ec950e715b344-1607018403817\",\"session_id\":\"1607018388441\",\"sentToServer\":false}],\"headphoneAttached\":[{\"status\":false,\"timeStamp\":1607018403803,\"mid\":\"360-21408-aa351ea9b265a41d5a369ddbce275210-1607018403803\",\"session_id\":\"1607018388441\",\"sentToServer\":false}],\"jailBroken\":[{\"status\":false,\"timeStamp\":1607018403785,\"mid\":\"249-21297-da4bfeabfae70525eabefa2304bcd4cd-1607018403785\",\"session_id\":\"1607018388441\",\"sentToServer\":false}],\"batteryLevel\":[{\"timeStamp\":1607018403818,\"mid\":\"319-21367-c6b9d1a622ec8d12966b84826768f206-1607018403818\",\"session_id\":\"1607018388441\",\"percentage\":-1,\"sentToServer\":true}],\"accessoriesAttached\":[{\"status\":false,\"timeStamp\":1607018403800,\"mid\":\"420-21468-fea3d98d448c67409ac5b3394ae280ab-1607018403800\",\"session_id\":\"1607018388441\",\"sentToServer\":false}],\"processorsUsage\":[{\"timeStamp\":1607018403789,\"processorID\":0,\"mid\":\"464-21512-061cfac0a3e65aa2a6ece733bd6e6070-1607018403789\",\"session_id\":\"1607018388441\",\"usagePercentage\":29.18960154056549,\"sentToServer\":false},{\"timeStamp\":1607018403793,\"processorID\":1,\"mid\":\"464-21512-061cfac0a3e65aa2a6ece733bd6e6070-1607018403793\",\"session_id\":\"1607018388441\",\"usagePercentage\":7.451223582029343,\"sentToServer\":false},{\"timeStamp\":1607018403796,\"processorID\":2,\"mid\":\"464-21512-061cfac0a3e65aa2a6ece733bd6e6070-1607018403796\",\"session_id\":\"1607018388441\",\"usagePercentage\":25.88476538658142,\"sentToServer\":false},{\"timeStamp\":1607018403796,\"processorID\":3,\"mid\":\"464-21512-061cfac0a3e65aa2a6ece733bd6e6070-1607018403796\",\"session_id\":\"1607018388441\",\"usagePercentage\":6.860391050577164,\"sentToServer\":false},{\"timeStamp\":1607018403797,\"processorID\":4,\"mid\":\"464-21512-061cfac0a3e65aa2a6ece733bd6e6070-1607018403797\",\"session_id\":\"1607018388441\",\"usagePercentage\":21.82975560426712,\"sentToServer\":false},{\"timeStamp\":1607018403797,\"processorID\":5,\"mid\":\"464-21512-061cfac0a3e65aa2a6ece733bd6e6070-1607018403797\",\"session_id\":\"1607018388441\",\"usagePercentage\":6.2413375824689865,\"sentToServer\":false},{\"timeStamp\":1607018403798,\"processorID\":6,\"mid\":\"464-21512-061cfac0a3e65aa2a6ece733bd6e6070-1607018403798\",\"session_id\":\"1607018388441\",\"usagePercentage\":18.66494119167328,\"sentToServer\":false},{\"timeStamp\":1607018403799,\"processorID\":7,\"mid\":\"464-21512-061cfac0a3e65aa2a6ece733bd6e6070-1607018403799\",\"session_id\":\"1607018388441\",\"usagePercentage\":5.395356938242912,\"sentToServer\":false}],\"pluggedIn\":[{\"status\":false,\"timeStamp\":1607018403782,\"mid\":\"237-21285-4cd87233574078c4ffe81c0f401cd7f3-1607018403782\",\"session_id\":\"1607018388441\",\"sentToServer\":false}],\"debuggerAttached\":[{\"status\":true,\"timeStamp\":1607018403780,\"mid\":\"484-21506-faf4619659b09270e30a47db5437ebb2-1607018403780\",\"session_id\":\"1607018388441\",\"sentToServer\":true}],\"nameOfAttachedAccessories\":[{\"timeStamp\":1607018403818,\"mid\":\"390-21412-3f066b68b04edf4c1d81f74d26ee2f05-1607018403818\",\"session_id\":\"1607018388441\",\"names\":null,\"sentToServer\":false}],\"cfUUID\":[{\"cfUUID\":\"2C541CAB-CE1E-47DE-B565-54871510701A\",\"timeStamp\":1607018403823,\"mid\":\"280-21224-64cbaf310728faa146762107fd370d8d-1607018403823\",\"session_id\":\"1607018388441\",\"sentToServer\":false}],\"isCharging\":[{\"status\":false,\"timeStamp\":1607018403820,\"mid\":\"360-21409-c77a1ce4171f75adeebdd096e779e90a-1607018403820\",\"session_id\":\"1607018388441\",\"sentToServer\":false}],\"vendorID\":[{\"timeStamp\":1607018403824,\"vendorID\":\"2A69578E-A438-419F-AC8B-EBAEC98C67B3\",\"mid\":\"249-21271-67b16ba404bb91748d557ad2b351bb7f-1607018403824\",\"session_id\":\"1607018388441\",\"sentToServer\":false}],\"numberOfActiveProcessors\":[{\"timeStamp\":1607018403786,\"number\":8,\"mid\":\"390-21438-5ecb37d5959d54b2dd6d565e3ad5d757-1607018403786\",\"session_id\":\"1607018388441\",\"sentToServer\":false}],\"fullyCharged\":[{\"status\":false,\"timeStamp\":1607018403821,\"mid\":\"446-21469-a80d8e69d2ea8c023c04c7a7bbc4d41f-1607018403821\",\"session_id\":\"1607018388441\",\"sentToServer\":false}],\"deviceOrientation\":[{\"timeStamp\":1607018403822,\"sentToServer\":false,\"mid\":\"410-21458-793d781c37bda15b74ba151030c78d58-1607018403822\",\"session_id\":\"1607018388441\",\"orientation\":-1}],\"proximitySensorEnabled\":[{\"status\":false,\"timeStamp\":1607018403777,\"mid\":\"582-21604-42c4964efa411d8b2dec6f0953c580e7-1607018403777\",\"session_id\":\"1607018388441\",\"sentToServer\":true}],\"multitaskingEnabled\":[{\"status\":true,\"timeStamp\":1607018403774,\"mid\":\"469-21491-7f030c7a053767f5b5fa235b6c6a27b0-1607018403774\",\"session_id\":\"1607018388441\",\"sentToServer\":true}]},\"lastServerSyncTimeStamp\":1607105139757,\"networkInfo\":{\"cellNetMask\":[],\"cellBroadcastAddress\":[],\"connectedToWifi\":[{\"timeStamp\":1607018403837,\"mid\":\"393-21415-04e38461bf3683e1f3072b53cad4030c-1607018403837\",\"session_id\":\"1607018388441\",\"isConnected\":true,\"sentToServer\":false}],\"wifiBroadcastAddress\":[{\"timeStamp\":1607018403833,\"broadcastAddress\":\"192.168.43.255\",\"mid\":\"478-21501-26d6856337df9915cf4bdea190855fed-1607018403833\",\"session_id\":\"1607018388441\",\"sentToServer\":false}],\"wifiRouterAddress\":[{\"timeStamp\":1607018403835,\"mid\":\"462-21484-12786b613b39608d6355de72217336fb-1607018403835\",\"session_id\":\"1607018388441\",\"routerAddress\":\"192.168.43.1\",\"sentToServer\":false}],\"wifiSSID\":[{\"timeStamp\":1607018403836,\"mid\":\"308-21278-562378e7bada9619504fee5a86d34a6a-1607018403836\",\"session_id\":\"1607018388441\",\"ssid\":\"NotAllowed\",\"sentToServer\":false}],\"wifiIPAddress\":[{\"ipAddress\":\"192.168.43.38\",\"timeStamp\":1607018403830,\"mid\":\"376-21372-fb9eb7fb869882ea2a7a88b7d66ea606-1607018403830\",\"session_id\":\"1607018388441\",\"sentToServer\":false}],\"currentIPAddress\":[{\"ipAddress\":\"192.168.43.38\",\"timeStamp\":1607018403828,\"mid\":\"458-21454-54ff896615b16b48d41926637a445e1f-1607018403828\",\"session_id\":\"1607018388441\",\"sentToServer\":true}],\"wifiNetMask\":[{\"timeStamp\":1607018403832,\"mid\":\"318-21340-82169a03f78328a89c8b859d4c1a4f68-1607018403832\",\"session_id\":\"1607018388441\",\"netmask\":\"255.255.255.0\",\"sentToServer\":false}],\"connectedToCellNetwork\":[{\"timeStamp\":1607018403838,\"mid\":\"473-21470-a0debfcfbee25d595a9aaf05e2f829d0-1607018403838\",\"session_id\":\"1607018388441\",\"isConnected\":false,\"sentToServer\":false}],\"externalIPAddress\":[],\"cellIPAddress\":[]},\"crashDetails\":[],\"ubiAutoDetected\":{\"appGesture\":{\"touchOrClick\":[],\"screenEdgePan\":[],\"moreThanTwoFingerTap\":[{\"objectType\":\"UIPanGestureRecognizer\",\"mid\":null,\"visibleClassName\":\"<MXScrollViewController: 0x7f82fdd8c3d0>\",\"sentToServer\":null,\"session_id\":\"1607018388441\",\"timeStamp\":1607018418044,\"objectRect\":null,\"screenRect\":null},{\"objectType\":\"UIPanGestureRecognizer\",\"mid\":null,\"visibleClassName\":\"<MXScrollViewController: 0x7f82fdd8c3d0>\",\"sentToServer\":null,\"session_id\":\"1607018388441\",\"timeStamp\":1607018419576,\"objectRect\":null,\"screenRect\":null},{\"objectType\":\"UIPanGestureRecognizer\",\"mid\":null,\"visibleClassName\":\"<MXScrollViewController: 0x7f82fde5e790>\",\"sentToServer\":null,\"session_id\":\"1607018388441\",\"timeStamp\":1607018424463,\"objectRect\":null,\"screenRect\":null},{\"objectType\":\"UIPanGestureRecognizer\",\"mid\":null,\"visibleClassName\":\"<MXScrollViewController: 0x7f82fde5e790>\",\"sentToServer\":null,\"session_id\":\"1607018388441\",\"timeStamp\":1607018425703,\"objectRect\":null,\"screenRect\":null},{\"objectType\":\"UIPanGestureRecognizer\",\"mid\":null,\"visibleClassName\":\"<CategoryViewController: 0x7f82fdf4b880>\",\"sentToServer\":null,\"session_id\":\"1607018388441\",\"timeStamp\":1607018689504,\"objectRect\":null,\"screenRect\":null},{\"objectType\":\"UIPanGestureRecognizer\",\"mid\":null,\"visibleClassName\":\"<CategoryViewController: 0x7f82fdf4b880>\",\"sentToServer\":null,\"session_id\":\"1607018388441\",\"timeStamp\":1607018689504,\"objectRect\":null,\"screenRect\":null}],\"flick\":[],\"swipe\":[],\"pinch\":[],\"rotate\":[],\"twoFingerTap\":[],\"shake\":[],\"moreThanDoubleTap\":[],\"touchAndHold\":[],\"doubleTap\":[],\"drag\":[]},\"screenShotsTaken\":[],\"appNavigation\":[{\"timeStamp\":null,\"sentToServer\":null,\"mid\":null,\"actionObjectTitle\":null,\"actionTime\":null,\"timeSpent\":6.199996471405029,\"from\":\"LoginViewController\",\"action\":null,\"session_id\":\"1607018388441\",\"actionObject\":null,\"networkIndicatorVisible\":true,\"to\":\"CategoryViewController\"},{\"timeStamp\":null,\"sentToServer\":null,\"mid\":null,\"actionObjectTitle\":null,\"actionTime\":null,\"timeSpent\":0.5,\"from\":\"CategoryViewController\",\"action\":null,\"session_id\":\"1607018388441\",\"actionObject\":null,\"networkIndicatorVisible\":true,\"to\":\"ListItemViewController\"},{\"timeStamp\":null,\"sentToServer\":null,\"mid\":null,\"actionObjectTitle\":null,\"actionTime\":null,\"timeSpent\":1.500000238418579,\"from\":\"ListItemViewController\",\"action\":null,\"session_id\":\"1607018388441\",\"actionObject\":null,\"networkIndicatorVisible\":true,\"to\":\"ListItemCartViewController\"},{\"timeStamp\":null,\"sentToServer\":null,\"mid\":null,\"actionObjectTitle\":null,\"actionTime\":null,\"timeSpent\":2.1000001430511475,\"from\":\"ListItemCartViewController\",\"action\":null,\"session_id\":\"1607018388441\",\"actionObject\":null,\"networkIndicatorVisible\":true,\"to\":\"ListItemViewController\"},{\"timeStamp\":null,\"sentToServer\":null,\"mid\":null,\"actionObjectTitle\":null,\"actionTime\":null,\"timeSpent\":1.1000001430511475,\"from\":\"ListItemViewController\",\"action\":null,\"session_id\":\"1607018388441\",\"actionObject\":null,\"networkIndicatorVisible\":true,\"to\":\"MXScrollViewController\"},{\"timeStamp\":null,\"sentToServer\":null,\"mid\":null,\"actionObjectTitle\":null,\"actionTime\":null,\"timeSpent\":3.2999989986419678,\"from\":\"MXScrollViewController\",\"action\":null,\"session_id\":\"1607018388441\",\"actionObject\":null,\"networkIndicatorVisible\":true,\"to\":\"ListItemViewController\"},{\"timeStamp\":null,\"sentToServer\":null,\"mid\":null,\"actionObjectTitle\":null,\"actionTime\":null,\"timeSpent\":1.3000001907348633,\"from\":\"ListItemViewController\",\"action\":null,\"session_id\":\"1607018388441\",\"actionObject\":null,\"networkIndicatorVisible\":true,\"to\":\"MXScrollViewController\"},{\"timeStamp\":null,\"sentToServer\":null,\"mid\":null,\"actionObjectTitle\":null,\"actionTime\":null,\"timeSpent\":2.5999996662139893,\"from\":\"MXScrollViewController\",\"action\":null,\"session_id\":\"1607018388441\",\"actionObject\":null,\"networkIndicatorVisible\":true,\"to\":\"ListItemViewController\"},{\"timeStamp\":null,\"sentToServer\":null,\"mid\":null,\"actionObjectTitle\":null,\"actionTime\":null,\"timeSpent\":0.9000000953674316,\"from\":\"ListItemViewController\",\"action\":null,\"session_id\":\"1607018388441\",\"actionObject\":null,\"networkIndicatorVisible\":true,\"to\":\"CategoryViewController\"},{\"timeStamp\":null,\"sentToServer\":null,\"mid\":null,\"actionObjectTitle\":null,\"actionTime\":null,\"timeSpent\":0.9000000953674316,\"from\":\"CategoryViewController\",\"action\":null,\"session_id\":\"1607018388441\",\"actionObject\":null,\"networkIndicatorVisible\":true,\"to\":\"ListItemCartViewController\"},{\"timeStamp\":null,\"sentToServer\":null,\"mid\":null,\"actionObjectTitle\":null,\"actionTime\":null,\"timeSpent\":255.2063751220703,\"from\":\"ListItemCartViewController\",\"action\":null,\"session_id\":\"1607018388441\",\"actionObject\":null,\"networkIndicatorVisible\":true,\"to\":\"UIAlertController\"},{\"timeStamp\":null,\"sentToServer\":null,\"mid\":null,\"actionObjectTitle\":null,\"actionTime\":null,\"timeSpent\":1.600000262260437,\"from\":\"UIAlertController\",\"action\":null,\"session_id\":\"1607018388441\",\"actionObject\":null,\"networkIndicatorVisible\":true,\"to\":\"CategoryViewController\"}]},\"commonEvents\":[],\"appInfo\":[{\"osVersion\":\"12.0\",\"deviceMft\":\"Apple\",\"language\":\"en\",\"timeStamp\":null,\"mid\":null,\"session_id\":\"1607018388441\",\"averageSessionsDuration\":288083,\"version\":\"1.0.1\",\"name\":\"SalesDemoApp\",\"dcompStatus\":true,\"vpnStatus\":false,\"sentToServer\":null,\"platform\":14,\"jbnStatus\":true,\"sdkVersion\":\"1.0.0\",\"launchTimeStamp\":1607018403775,\"terminationTimeStamp\":1607018691858,\"deviceModel\":\"iPhone\",\"bundle\":\"com.blotout.saleDemoApp\",\"sessionsDuration\":288083,\"launchReason\":null,\"currentLocation\":null,\"acompStatus\":false,\"osName\":\"iOS\"}],\"location\":[],\"developerCodified\":{\"touchClick\":[],\"swipe\":[],\"screenEdgePan\":[],\"moreThanTwoFingerTap\":[],\"touchAndHold\":[],\"doubleTap\":[],\"twoFingerTap\":[],\"moreThanDoubleTap\":[],\"shake\":[],\"chargeTransaction\":[],\"listUpdated\":[],\"piiEvents\":[{\"visibleClassName\":\"LoginViewController\",\"mid\":\"294-21290-274ab4bfc5a3816792f9d889c18f85a0-1607018403800\",\"eventInfo\":{\"emailid\":\"ankuradhikari08@gmail.com\"},\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018403797,\"eventName\":\"PII Event\",\"eventSubCode\":21290}],\"phiEvents\":[],\"rotate\":[],\"addToCart\":[],\"pinch\":[],\"drag\":[],\"timedEvent\":[],\"flick\":[],\"view\":[],\"customEvents\":[{\"visibleClassName\":\"LoginViewController\",\"mid\":\"264-21312-969b9694f136521f103e771235d9fdac-1607018403791\",\"eventInfo\":null,\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018403773,\"eventName\":\"AppLaunched1\",\"eventSubCode\":21312},{\"visibleClassName\":\"LoginViewController\",\"mid\":\"258-21306-398cedeecff8c1813cf15bff3e78c695-1607018403794\",\"eventInfo\":null,\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018403791,\"eventName\":\"LoginView\",\"eventSubCode\":21306},{\"visibleClassName\":\"LoginViewController\",\"mid\":\"265-21313-05352ef87feeb6f91655937e67864b07-1607018403797\",\"eventInfo\":null,\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018403794,\"eventName\":\"AppLaunched2\",\"eventSubCode\":21313},{\"visibleClassName\":\"CategoryViewController\",\"mid\":\"325-21373-4e3b5e00da1290a6f6e29e1441957412-1607018407919\",\"eventInfo\":null,\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018407885,\"eventName\":\"CategoryView\",\"eventSubCode\":21373},{\"visibleClassName\":\"CategoryViewController\",\"mid\":\"389-21437-38bde76cba06c217f15c2b62f602e19e-1607018409145\",\"eventInfo\":{\"Item Name\":\"Business & Industrial\",\"time\":\"2020-12-03\"},\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018409119,\"eventName\":\"Category Selected\",\"eventSubCode\":21437},{\"visibleClassName\":\"CategoryViewController\",\"mid\":\"325-21373-4e3b5e00da1290a6f6e29e1441957412-1607018409146\",\"eventInfo\":null,\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018409145,\"eventName\":\"CategoryView\",\"eventSubCode\":21373},{\"visibleClassName\":\"CategoryViewController\",\"mid\":\"389-21437-38bde76cba06c217f15c2b62f602e19e-1607018410847\",\"eventInfo\":{\"Item Name\":\"Electrical Equipment & Supplies\",\"time\":\"2020-12-03\"},\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018410825,\"eventName\":\"Category Selected\",\"eventSubCode\":21437},{\"visibleClassName\":\"CategoryViewController\",\"mid\":\"325-21373-4e3b5e00da1290a6f6e29e1441957412-1607018410849\",\"eventInfo\":null,\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018410847,\"eventName\":\"CategoryView\",\"eventSubCode\":21373},{\"visibleClassName\":\"CategoryViewController\",\"mid\":\"389-21437-38bde76cba06c217f15c2b62f602e19e-1607018411846\",\"eventInfo\":{\"Item Name\":\"Electrical Plugs, Outlets & Covers\",\"time\":\"2020-12-03\"},\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018411824,\"eventName\":\"Category Selected\",\"eventSubCode\":21437},{\"visibleClassName\":\"CategoryViewController\",\"mid\":\"325-21373-4e3b5e00da1290a6f6e29e1441957412-1607018411847\",\"eventInfo\":null,\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018411846,\"eventName\":\"CategoryView\",\"eventSubCode\":21373},{\"visibleClassName\":\"ListItemViewController\",\"mid\":\"384-21406-524001d8e004da804e0e1d981b855f6d-1607018412443\",\"eventInfo\":null,\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018412414,\"eventName\":\"List Item View\",\"eventSubCode\":21406},{\"visibleClassName\":\"ListItemCartViewController\",\"mid\":\"396-21418-4b69865b32deb505ac31c0195c480563-1607018414030\",\"eventInfo\":{\"VC Name\":\"ListItemVC\",\"time\":\"2020-12-03\"},\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018414004,\"eventName\":\"View Cart Clicked\",\"eventSubCode\":21418},{\"visibleClassName\":\"ListItemCartViewController\",\"mid\":\"502-21498-fd0f50a19bb944b872071fa02f883824-1607018414033\",\"eventInfo\":null,\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018414030,\"eventName\":\"List Item Cart View\",\"eventSubCode\":21498},{\"visibleClassName\":\"MXScrollViewController\",\"mid\":\"302-21350-c731ba9c18bf71503cb6388a3a7863d2-1607018417303\",\"eventInfo\":{\"Item Name\":\"10x Auto Car Accessories Red Air Conditioner Outlet Decoration Strip Universal\",\"time\":\"2020-12-03\"},\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018417255,\"eventName\":\"Item Selected\",\"eventSubCode\":21350},{\"visibleClassName\":\"MXScrollViewController\",\"mid\":\"395-21417-09b1ae6652e90d3a4b51475b486f6435-1607018417305\",\"eventInfo\":null,\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018417303,\"eventName\":\"Item Detail View\",\"eventSubCode\":21417},{\"visibleClassName\":\"MXScrollViewController\",\"mid\":\"330-21378-d7e2973c31e6ac8989f2cbd8d41340d6-1607018417308\",\"eventInfo\":null,\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018417305,\"eventName\":\"Parallex View\",\"eventSubCode\":21378},{\"visibleClassName\":\"MXScrollViewController\",\"mid\":\"274-21296-b64c83286ace832c0ec837ac4c1c8057-1607018420540\",\"eventInfo\":{\"color\":\"green\",\"item\":\"iPhone\"},\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018420536,\"eventName\":\"Add To Cart\",\"eventSubCode\":21296},{\"visibleClassName\":\"MXScrollViewController\",\"mid\":\"166-21240-e35b0e8d1996925efa9e5bd7836229b6-1607018420542\",\"eventInfo\":{\"addedToCart\":\"iPhone\",\"color\":\"green\"},\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018420540,\"eventName\":\"myCart\",\"eventSubCode\":21240},{\"visibleClassName\":\"MXScrollViewController\",\"mid\":\"177-21225-8b8763d46f52609e2c0295b183553e07-1607018420544\",\"eventInfo\":{\"product\":\"iPhone\",\"color\":\"green\"},\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018420542,\"eventName\":\"InCart\",\"eventSubCode\":21225},{\"visibleClassName\":\"MXScrollViewController\",\"mid\":\"302-21350-c731ba9c18bf71503cb6388a3a7863d2-1607018423361\",\"eventInfo\":{\"Item Name\":\"Interior Air Vent Outlet Ring Cover Decor For Chevrolet Camaro 2017+ Accessories\",\"time\":\"2020-12-03\"},\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018423337,\"eventName\":\"Item Selected\",\"eventSubCode\":21350},{\"visibleClassName\":\"MXScrollViewController\",\"mid\":\"395-21417-09b1ae6652e90d3a4b51475b486f6435-1607018423362\",\"eventInfo\":null,\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018423361,\"eventName\":\"Item Detail View\",\"eventSubCode\":21417},{\"visibleClassName\":\"MXScrollViewController\",\"mid\":\"330-21378-d7e2973c31e6ac8989f2cbd8d41340d6-1607018423364\",\"eventInfo\":null,\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018423363,\"eventName\":\"Parallex View\",\"eventSubCode\":21378},{\"visibleClassName\":\"MXScrollViewController\",\"mid\":\"274-21296-b64c83286ace832c0ec837ac4c1c8057-1607018425712\",\"eventInfo\":{\"color\":\"green\",\"item\":\"iPhone\"},\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018425709,\"eventName\":\"Add To Cart\",\"eventSubCode\":21296},{\"visibleClassName\":\"MXScrollViewController\",\"mid\":\"166-21240-e35b0e8d1996925efa9e5bd7836229b6-1607018425714\",\"eventInfo\":{\"addedToCart\":\"iPhone\",\"color\":\"green\"},\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018425712,\"eventName\":\"myCart\",\"eventSubCode\":21240},{\"visibleClassName\":\"MXScrollViewController\",\"mid\":\"177-21225-8b8763d46f52609e2c0295b183553e07-1607018425714\",\"eventInfo\":{\"product\":\"iPhone\",\"color\":\"green\"},\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018425714,\"eventName\":\"InCart\",\"eventSubCode\":21225},{\"visibleClassName\":\"ListItemCartViewController\",\"mid\":\"396-21418-4b69865b32deb505ac31c0195c480563-1607018428902\",\"eventInfo\":{\"VC Name\":\"CategoryViewVC\",\"time\":\"2020-12-03\"},\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018428871,\"eventName\":\"View Cart Clicked\",\"eventSubCode\":21418},{\"visibleClassName\":\"ListItemCartViewController\",\"mid\":\"502-21498-fd0f50a19bb944b872071fa02f883824-1607018428903\",\"eventInfo\":null,\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018428902,\"eventName\":\"List Item Cart View\",\"eventSubCode\":21498},{\"visibleClassName\":\"UIAlertController\",\"mid\":\"402-21450-7328ece051e5ff6d76db92ad471745a6-1607018685075\",\"eventInfo\":null,\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018685072,\"eventName\":\"Purchase Complete\",\"eventSubCode\":21450}]},\"systemUptime\":[168867.300429895,169155.38971661802],\"retentionEvent\":{\"DAST\":{\"timeStamp\":1607105136142,\"payload\":{\"sessionsDuration\":\"(\\n    288083\\n)\",\"sessionsCount\":\"1\"},\"mid\":\"188-21184-21906c778fff7d2dff43352e55a81e1f-1607105136142\",\"session_id\":\"1607018388441\",\"averageSessionTime\":288083,\"sentToServer\":false},\"mid\":null,\"customEvents\":[],\"sentToServer\":false,\"session_id\":\"1607018388441\",\"dau\":{\"timeStamp\":1607018403775,\"mid\":\"134-21156-2f7fa88c04e70db50e362c5a91b0f991-1607018403775\",\"session_id\":\"1607018388441\",\"dauInfo\":{\"date\":\"2020-12-03\"},\"sentToServer\":false},\"dpu\":null,\"newUser\":{\"mid\":\"227-21275-5717be2478c707846b3bcf6a78fb825b-1607018403782\",\"newUserInfo\":null,\"session_id\":\"1607018388441\",\"timeStamp\":1607018403782,\"sentToServer\":false,\"isNewUser\":true},\"appInstalled\":{\"timeStamp\":1607018380653,\"isFirstLaunch\":true,\"mid\":\"301-21349-6e10a1e7217fe0c031bf13830fbda947-1607018403779\",\"session_id\":\"1607018388441\",\"appInstalledInfo\":{\"date\":\"2020-12-03\"},\"sentToServer\":false}},\"adInfo\":null,\"storageInfo\":[{\"unit\":\"GB\",\"usedDiskSpace\":\"467.83 GB\",\"totalDiskSpace\":\"500.07 GB\",\"mid\":\"291-21339-765fab4f5bafa6bc540ae9a45c013ee3-1607018403839\",\"freeDiskSpace\":\"32.24 GB\",\"sentToServer\":true,\"session_id\":\"1607018388441\",\"timeStamp\":1607018403839}],\"allEventsSyncTimeStamp\":1607105139757,\"appStates\":{\"appInBackground\":[{\"timeStamp\":1607018691856,\"mid\":\"354-21402-57674bd48659ac19f9349b4c4bb875ff-1607018691856\",\"session_id\":\"1607018388441\",\"visibleClassName\":\"CategoryViewController\",\"sentToServer\":true}],\"sentToServer\":false,\"appResignActive\":[{\"timeStamp\":1607018689517,\"mid\":\"393-21416-0a70a6b004812282b72d4dcfe70cb1a8-1607018689517\",\"session_id\":\"1607018388441\",\"visibleClassName\":\"CategoryViewController\",\"sentToServer\":true}],\"appNotificationReceived\":[],\"appSessionInfo\":[{\"end\":1607018691858,\"start\":1607018403781,\"mid\":\"237-21311-bad794afb8cb528dd447ced935bf063c-1607018403781\",\"sentToServer\":true,\"timeStamp\":1607018403781,\"session_id\":\"1607018388441\",\"duration\":288077}],\"appNotificationClicked\":[],\"appBackgroundRefreshStatusChange\":[],\"appActive\":[],\"appStatusbarFrameChange\":[],\"appSignificantTimeChange\":[],\"appOrientationPortrait\":[],\"appInForeground\":[],\"appOrientationLandscape\":[],\"appBackgroundRefreshAvailable\":[],\"appReceiveMemoryWarning\":[],\"appLaunched\":[{\"timeStamp\":1607018403781,\"mid\":\"237-21311-bad794afb8cb528dd447ced935bf063c-1607018403781\",\"session_id\":\"1607018388441\",\"visibleClassName\":\"LoginViewController\",\"sentToServer\":true}],\"appNotificationViewed\":[]},\"memoryInfo\":[{\"timeStamp\":1607018403826,\"sentToServer\":true,\"mid\":\"425-21395-aed9d7c947736d200652dc2e4dc7e180-1607018403826\",\"usedMemory\":1527.04296875,\"atMemoryWarning\":false,\"freeMemory\":407.21875,\"activeMemory\":5221.99609375,\"inActiveMemory\":5056.01953125,\"purgeableMemory\":43.59765625,\"session_id\":\"1607018388441\",\"wiredMemory\":3537.03125,\"totalRAM\":16384}]}}";
}





@end
