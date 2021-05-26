//
//  BOCrypt.h
//  BlotoutFoundation
//
//  Created by Blotout on 27/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BOCrypt : NSObject

+ (NSString *)encrypt:(NSString *)message key:(NSString *)key iv:(NSString *)iv;
+ (NSString *)decrypt:(NSString *)base64EncodedString key:(NSString *)key iv:(NSString *)iv;
+ (NSString *)encryptData:(NSData *)data key:(NSString *)key iv:(NSString *)iv;
+ (NSString *)encryptDataWithoutHash:(NSData *)data key:(NSString *)key iv:(NSString *)iv;
@end
