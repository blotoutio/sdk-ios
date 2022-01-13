//
//  Persona.m
//  BlotoutAnalyticsSDK
//
//  Created by Nitin Choudhary on 28/11/21.
//  Copyright © 2021 Blotout. All rights reserved.
//

#import "Persona.h"

@implementation Persona


-(instancetype)init
{
    self = [super init];
    
    self.persona_age = [NSNumber numberWithInt:0];
    self.persona_dob = @"";
    self.persona_zip = [NSNumber numberWithInt:0];
    self.persona_city = @"";
    self.persona_email = @"";
    self.persona_state = @"";
    self.persona_gender = @"";
    self.persona_number = @"";
    self.persona_address = @"";
    self.persona_country = @"";
    self.persona_lastname = @"";
    self.persona_username = @"";
    self.persona_firstname = @"";
    self.persona_middlename = @"";
    
    return self;
}

@end
