//
//  BOAAESCrypto.m
//  BlotoutAnalytics
//
//  Created by ankuradhikari on 22/03/21.
//  Copyright © 2021 Blotout. All rights reserved.
//

#import "BOAAESCrypto.h"
#import "BOANetworkConstants.h"
#import "BOCrypt.h"


@implementation BOAAESCrypto

- (instancetype)initWithPassword:(NSString *)password iv:(NSString *_Nonnull)iv {
  if (self = [super init]) {
    _password = password;
    _iv = iv;
  }
  return self;
}

- (instancetype)initWithPassword:(NSString *)password {
  return [self initWithPassword:password iv:BO_CRYPTO_IVX];
}

- (NSData * _Nullable)decrypt:(NSData * _Nonnull)data {
  return [BOCrypt decryptAndReturnData:data key:self.password iv:self.iv];;
}

- (NSData * _Nullable)encrypt:(NSData * _Nonnull)data {
  @try {
    return [BOCrypt encryptAndReturnData:data key:self.password iv:self.iv];
  }@catch(NSException *exception) {
    NSLog(@"%@",exception);
  }
}

@end
