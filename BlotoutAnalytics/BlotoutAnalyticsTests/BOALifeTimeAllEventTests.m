//
//  BOALifeTimeAllEventTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 19/11/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOALifeTimeAllEvent.h"
#import "BlotoutAnalytics.h"

@interface BOALifeTimeAllEventTests : XCTestCase
@property (nonatomic) BOALifeTimeAllEvent *boaLifeTimeAllEvent;
@end

@implementation BOALifeTimeAllEventTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.boaLifeTimeAllEvent = [BOALifeTimeAllEvent sharedInstance];
    [[self.boaLifeTimeAllEvent superclass] setIsAppLifeModelInitialised:YES];
    
    [[BlotoutAnalytics sharedInstance] setPayingUser:YES];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testAppLifeTimeDefaultSingleDayDict {
    NSDictionary *dic = [BOALifeTimeAllEvent appLifeTimeDefaultSingleDayDict];
    XCTAssertNotNil(dic);
    int sendToServer = [[dic valueForKey:@"sentToServer"] intValue];
    XCTAssertEqual(sendToServer, 0);
    
    dic = [BOALifeTimeAllEvent appLifeTimeDefaultRetentionInfo];
    XCTAssertNotNil(dic);
    sendToServer = [[dic valueForKey:@"sentToServer"] intValue];
    XCTAssertEqual(sendToServer, 0);
    
    NSArray *allSessions = [BOALifeTimeAllEvent getAllSessionFilesForTheWeek:3];
    XCTAssertNil(allSessions);
    
    NSInteger wast = [BOALifeTimeAllEvent getWASTForTheWeek:3];
    XCTAssertEqual(wast, -1);
    
    allSessions = [BOALifeTimeAllEvent getAllSessionFilesForTheMonth:2];
    XCTAssertNil(allSessions);
    
    wast = [BOALifeTimeAllEvent getMASTForTheMonth:2];
    XCTAssertEqual(wast, -1);
    
    allSessions = [BOALifeTimeAllEvent lastWeekAllFiles:[NSDate date]];
    XCTAssertNil(allSessions);
    
    wast = [BOALifeTimeAllEvent lastWeekWAST:[NSDate date]];
    XCTAssertEqual(wast, -1);
    
    allSessions = [BOALifeTimeAllEvent lastMonthAllFiles:[NSDate date]];
    XCTAssertNil(allSessions);
    
    wast = [BOALifeTimeAllEvent lastMonthMAST:[NSDate date]];
    XCTAssertEqual(wast, -1);
}

-(void)testMastAndWastSetFor {
    BOOL status = [self.boaLifeTimeAllEvent isMASTAlreadySetForLastMonth];
    XCTAssertFalse(status);
    
    status = [self.boaLifeTimeAllEvent isWASTAlreadySetForLastWeek];
    XCTAssertFalse(status);
}

-(void)testLifeTimeMethods {
    //TODO: need to discuss with ankur for void type of methods
    [self.boaLifeTimeAllEvent setAppLifeTimeSystemInfoOnAppLaunch];
    [self.boaLifeTimeAllEvent setLifeTimeRetentionEventsOnAppLaunch];
    [self.boaLifeTimeAllEvent recordPayingUsersRetention];
    [self.boaLifeTimeAllEvent recordIfAppFirstLaunch];
    [self.boaLifeTimeAllEvent recordNewUser];
    
    NSDictionary *eventInfo = [NSDictionary dictionaryWithObject:@"test event" forKey:@"eventName"];
    [self.boaLifeTimeAllEvent recordDAST:[NSNumber numberWithInt:3] withPayload:eventInfo];
    [self.boaLifeTimeAllEvent recordWAST:[NSNumber numberWithInt:3] withPayload:eventInfo];
    [self.boaLifeTimeAllEvent recordMAST:[NSNumber numberWithInt:3] withPayload:eventInfo];
    [self.boaLifeTimeAllEvent recordCustomEventsWithName:@"custom event" andPaylod:eventInfo];
    
}


@end
