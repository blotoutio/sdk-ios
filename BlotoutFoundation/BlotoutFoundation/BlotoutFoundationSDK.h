//
//  BlotoutFoundationSDK.h
//  BlotoutFoundation
//
//  Created by ankuradhikari on 11/08/21.
//  Copyright © 2021 Blotout. All rights reserved.
//

#ifndef BlotoutFoundationSDK_h
#define BlotoutFoundationSDK_h

#import <Foundation/Foundation.h>

@interface BlotoutFoundationSDK : NSObject

@property (nonatomic, readwrite) BOOL isEnabled;
//set encryption key for encryption data
@property (nonatomic, strong) NSString* _Nullable encryptionKey;

- (nullable instancetype) init __attribute__((unavailable("Must use sharedInstance instead.")));
+ (nullable instancetype)sharedInstance;


@end

#endif /* BlotoutFoundationSDK_h */

