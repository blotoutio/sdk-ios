//
//  NSString+Base64.h
//  BlotoutAnalytics
//
//  Created by Blotout on 27/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//
#import <Foundation/NSString.h>

@interface NSString (Base64Additions)
extern void loadAsNSStringBase64FoundationCat(void);


+ (NSString *)base64StringFromData:(NSData *)data length:(NSUInteger)length;

@end
