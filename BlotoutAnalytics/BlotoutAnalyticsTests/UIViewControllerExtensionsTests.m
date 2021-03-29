//
//  UIViewControllerExtensionsTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 19/12/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UIViewController+Extensions.h"

@interface UIViewControllerExtensionsTests : XCTestCase

@end

@implementation UIViewControllerExtensionsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExtensionMethods {
    //TODO: Need to check with Ankur
    [UIView load];
    UIViewController *controller = [UIViewController getTopmostViewController];
    XCTAssertNil(controller);
    
    UIViewController *controllerHolder = [UIViewController topmostViewController:[[UIViewController alloc] init]];
    XCTAssertNotNil(controllerHolder);
    
    [controllerHolder logged_viewDidAppear:YES];
}


@end
