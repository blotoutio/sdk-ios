//
//  NSData+Base64.h
//  BlotoutAnalytics
//
//  Created by Blotout on 27/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSString;

extern void loadAsNSDataBase64FoundationCat(void);


@interface NSData (Base64Additions)

+ (NSData *)base64DataFromString:(NSString *)string;

@end
