//
//  BOAUserDefaultsStorage.h
//  BlotoutAnalytics
//
//  Created by Blotout on 25/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOAStorageManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface BOAUserDefaultsStorage : BOAStorageManager

+(NSNumber *)getUserBirthTimeStamp;

@end

NS_ASSUME_NONNULL_END
