//
//  BOFSSCarrierInfo.h
//  BlotoutFoundation
//
//  Created by Blotout on 27/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BOFSSCarrierInfo : NSObject

// Carrier Information

// Carrier Name
+ (nullable NSString *)carrierName;

// Carrier Country
+ (nullable NSString *)carrierCountry;

// Carrier Mobile Country Code
+ (nullable NSString *)carrierMobileCountryCode;

// Carrier ISO Country Code
+ (nullable NSString *)carrierISOCountryCode;

// Carrier Mobile Network Code
+ (nullable NSString *)carrierMobileNetworkCode;

// Carrier Allows VOIP
+ (BOOL)carrierAllowsVOIP;

@end
