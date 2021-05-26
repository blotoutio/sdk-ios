//
//  BOANetworkAndDataSyncTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 14/12/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOANetworkAndDataSync.h"

@interface BOANetworkAndDataSyncTests : XCTestCase
@property (nonatomic) BOANetworkAndDataSync *boaNetworkAndDataSync;
@end

@implementation BOANetworkAndDataSyncTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.boaNetworkAndDataSync = [BOANetworkAndDataSync sharedInstance];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testCheckForPiiAndSendToServer {
    NSString *jsonStr = @"{\"variableId\":5006,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Event_Codified_Mergecounter\",\"isEditable\":true}";
    
    [self.boaNetworkAndDataSync checkForPiiAndSendToServer:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]];
}



@end
