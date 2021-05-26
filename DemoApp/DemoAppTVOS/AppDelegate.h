//
//  AppDelegate.h
//  DemoAppTVOS
//
//  Created by Ashish Nigam on 26/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

