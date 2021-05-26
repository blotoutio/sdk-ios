//
//  BOFNetworkPromiseExecutor_Private.h
//  BlotoutFoundation
//
//  Created by Blotout on 27/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#ifndef BOFNetworkPromiseExecutor_Private_h
#define BOFNetworkPromiseExecutor_Private_h

#import "BOFNetworkPromiseExecutor.h"

@interface BOFNetworkPromiseExecutor ()
@property (nullable, nonatomic, strong)  NSURLSession*              session;
@property (nullable, nonatomic, strong)  NSMapTable*                taskPromiseObjectMap;
@end


#endif /* BOFNetworkPromiseExecutor_Private_h */
