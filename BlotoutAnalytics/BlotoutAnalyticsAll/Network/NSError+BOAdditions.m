//
//  NSError+BOAdditions.m
//  BlotoutAnalytics
//
//  Created by Blotout on 05/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "NSError+BOAdditions.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOANetworkConstants.h"

NSString *const BOErrorDomain                     = @"com.blotout.sdk";
NSString *const BOUnknownErrorMsg                 = @"Unable to process the request. Unknown error occurred from server. Please try again later";
NSString *const BONoInternetConnectionErrorMsg    = @"The Internet connection appears to be offline.";
NSString *const BOParsingErrorMsg                 = @"Parsing Error.";
NSString *const BOManifestSyncErrorMsg            = @"Server Sync failed, check your keys & network connection";

@implementation NSError (BOAdditions)

+(NSError*)boErrorForCode:(NSInteger)errorCode withMessage:(nullable NSString*)msg{
    @try {
        NSString *errorDesc = msg;
        
        if(errorDesc == nil) {
            errorDesc = [NSError boErrorMsgForCode:errorCode WithMessage:nil];
        }
        
        NSError *error = [[NSError alloc] initWithDomain:BOErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey: errorDesc}];
        
        return error;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
    return nil;
}

+(NSError*)boErrorForDict:(NSDictionary*)userInfo {
    return [NSError errorWithDomain:BOErrorDomain code:BOErrorUnknownn userInfo:userInfo];
}

+ (NSString *)boErrorMsgForCode:(BOErrorCodes)code WithMessage:(NSString*)msg {
    
    NSString *errorDesc = msg;
    switch (code) {
        case BOErrorNoInternetConnection:
            errorDesc = BONoInternetConnectionErrorMsg;
            break;
        case BOErrorParsingError:
            errorDesc = BOParsingErrorMsg;
            break;
        case BOManifestSyncError:
            errorDesc = BOManifestSyncErrorMsg;
            break;
        case BOErrorUnknownn:
        default:
            errorDesc = BOUnknownErrorMsg;
            break;
    }
    
    return errorDesc;
}
@end
