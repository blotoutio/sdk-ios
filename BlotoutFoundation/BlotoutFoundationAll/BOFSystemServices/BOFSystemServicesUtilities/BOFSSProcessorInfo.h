//
//  BOFSSProcessorInfo.h
//  BlotoutFoundation
//
//  Created by Blotout on 27/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BOFSSProcessorInfo : NSObject

// Processor Information

// Number of processors
+ (NSInteger)numberProcessors;

// Number of Active Processors
+ (NSInteger)numberActiveProcessors;

// Get Processor Usage Information (i.e. ["0.2216801", "0.1009614"])
+ (NSArray *)processorsUsage;

@end
