//
//  BlotoutFoundation.h
//  BlotoutFoundation
//
//  Created by Blotout on 25/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlotoutFoundation : NSObject


@property (nonatomic, readwrite) BOOL isEnabled;

//set encryption key for encryption data
@property (nonatomic, strong) NSString* _Nullable encryptionKey;


- (nullable instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (nullable instancetype)sharedInstance;

@end
