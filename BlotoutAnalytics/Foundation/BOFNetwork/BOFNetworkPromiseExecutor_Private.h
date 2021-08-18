//
//  BOFNetworkPromiseExecutor_Private.h
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

#ifndef BOFNetworkPromiseExecutor_Private_h
#define BOFNetworkPromiseExecutor_Private_h

#import "BOFNetworkPromiseExecutor.h"

@interface BOFNetworkPromiseExecutor ()
@property (nullable, nonatomic, strong)  NSURLSession*              session;
@property (nullable, nonatomic, strong)  NSMapTable*                taskPromiseObjectMap;
@end

#endif
