//
//  BlotoutFoundation.m
//  BlotoutFoundation
//
//  Created by Blotout on 25/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BlotoutFoundation.h"
#import "NSData+Base64.h"
#import "NSData+CommonCrypto.h"
#import "NSString+Base64.h"

static id sBOFSharedInstance = nil;

@implementation BlotoutFoundation

+ (instancetype)sharedInstance {
    static dispatch_once_t bofOnceToken = 0;
    dispatch_once(&bofOnceToken, ^{
        sBOFSharedInstance = [[[self class] alloc] init];
    });
    return  sBOFSharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        loadAsNSDataBase64FoundationCat();
        loadAsNSDataCommonDigestFoundationCat();
        loadAsNSStringBase64FoundationCat();
    }
    return self;
}

@end
