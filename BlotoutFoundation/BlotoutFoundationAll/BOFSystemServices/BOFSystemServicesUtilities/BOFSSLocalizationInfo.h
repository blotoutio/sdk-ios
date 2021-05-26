//
//  BOFSSLocalizationInfo.h
//  BlotoutFoundation
//
//  Created by Blotout on 27/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BOFSSLocalizationInfo : NSObject

// Localization Information

// Country
+ (nullable NSString *)country;

// Language
+ (nullable NSString *)language;

// TimeZone
+ (nullable NSString *)timeZone;

// Currency Symbol
+ (nullable NSString *)currency;

@end
