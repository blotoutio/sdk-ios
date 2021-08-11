//
//  BlotoutFoundation.m
//  BlotoutFoundation
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BlotoutFoundationSDK.h"
#import "NSData+Base64.h"
#import "NSData+CommonCrypto.h"
#import "NSString+Base64.h"

static id sBOFSharedInstance = nil;

@implementation BlotoutFoundationSDK

+ (instancetype)sharedInstance {
  static dispatch_once_t bofOnceToken = 0;
  dispatch_once(&bofOnceToken, ^{
    sBOFSharedInstance = [[[self class] alloc] init];
  });
  return sBOFSharedInstance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    loadAsNSDataBase64FoundationCat();
    loadAsNSDataCommonDigestFoundationCat();
    loadAsNSStringBase64FoundationCat();
  }
  return self;
}

@end
