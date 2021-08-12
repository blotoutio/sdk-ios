//
//  BOFUtilities.m
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOFUtilities.h"
#import "BOFLogs.h"
#include "BOFConstants.h"
#import "NSData+CommonCrypto.h"

@implementation BOFUtilities

+(NSString*)getSHA256:(NSString*)string {
  return [[string dataUsingEncoding:NSUTF8StringEncoding] SHA256HashString];
}

+(NSString*)getSHA1:(NSString*)string {
  return [[string dataUsingEncoding:NSUTF8StringEncoding] SHA1HashString];
}

@end
