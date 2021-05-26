//
//  BOCrypt.m
//  BlotoutFoundation
//
//  Created by Blotout on 27/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOCrypt.h"

#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "NSData+CommonCrypto.h"

@implementation BOCrypt

+ (NSString *)encrypt:(NSString *)message key:(NSString *)key iv:(NSString *)iv {
    NSData *encryptedData = [[message dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptedDataUsingKey: [[key dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] iv: [[iv dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error: nil];
  NSString *base64EncodedString = [NSString base64StringFromData:encryptedData length:[encryptedData length]];
  return base64EncodedString;
}

+ (NSString *)encryptData:(NSData *)data key:(NSString *)key iv:(NSString *)iv {
    NSData *encryptedData = [data AES256EncryptedDataUsingKey: [[key dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] iv: [[iv dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error: nil];
  NSString *base64EncodedString = [NSString base64StringFromData:encryptedData length:[encryptedData length]];
  return base64EncodedString;
}

+ (NSString *)encryptDataWithoutHash:(NSData *)data key:(NSString *)key iv:(NSString *)iv {
    NSData *encryptedData = [data AES256EncryptedDataUsingKey: [key dataUsingEncoding:NSUTF8StringEncoding] iv: [iv dataUsingEncoding:NSUTF8StringEncoding] error: nil];
  NSString *base64EncodedString = [NSString base64StringFromData:encryptedData length:[encryptedData length]];
  return base64EncodedString;
}


+ (NSString *)decrypt:(NSString *)base64EncodedString key:(NSString *)key iv:(NSString *)iv {
  NSData *encryptedData = [NSData base64DataFromString:base64EncodedString];
  NSData *decryptedData = [encryptedData decryptedAES256DataUsingKey:[[key dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] iv: [[iv dataUsingEncoding:NSUTF8StringEncoding] SHA256Hash] error:nil];
  return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}

@end
