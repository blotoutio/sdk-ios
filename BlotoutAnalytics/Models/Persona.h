//
//  Persona.h
//  BlotoutAnalyticsSDK
//
//  Created by Nitin Choudhary on 28/11/21.
//  Copyright © 2021 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Persona : NSObject

@property (nonatomic, strong, nonnull) NSString *persona_id;

@property (nonatomic, strong, nullable) NSString *persona_firstname;

@property (nonatomic, strong, nullable) NSString *persona_lastname;

@property (nonatomic, strong, nullable) NSString *persona_middlename;

@property (nonatomic, strong, nullable) NSString *persona_username;

@property (nonatomic, strong, nullable) NSString *persona_dob;

@property (nonatomic, strong, nullable) NSString *persona_email;

@property (nonatomic, strong, nullable) NSString *persona_number;

@property (nonatomic, strong, nullable) NSString *persona_address;

@property (nonatomic, strong, nullable) NSString *persona_city;

@property (nonatomic, strong, nullable) NSString *persona_state;

@property (nonatomic, assign, nullable) NSInteger *persona_zip;

@property (nonatomic, strong, nullable) NSString *persona_country;

@property (nonatomic, strong, nullable) NSString *persona_gender;

@property (nonatomic, assign, nullable) NSInteger *persona_age;

@end

NS_ASSUME_NONNULL_END
