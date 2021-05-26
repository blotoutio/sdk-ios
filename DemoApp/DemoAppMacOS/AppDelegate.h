//
//  AppDelegate.h
//  DemoAppMacOS
//
//  Created by Ashish Nigam on 26/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;


@end

