//
//  BOFConstants.h
//  BlotoutFoundation
//
//  Created by Blotout on 27/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#ifndef BOFConstants_h
#define BOFConstants_h

#define kBOFFoundationProductKeyForUserDefaults             @"BOFFoundationDefaults"
#define kBOFFoundationProductKeyForUserDefaults_Stage       @"BOFFoundationDefaults_Stage"

#define kBOSDKLaunchTestDirectoryName                       @"BOSDKLaunchTestDir"
#define kBOSDKLaunchTestDirectoryName_Stage                 @"BOSDKLaunchTestDir_Stage" //Not using this one & not needed as well.
//As this test dir and above one get's created within Root Dir, so if root is changed then this will also be changed

#define kBOSDKRootDirectoryName                             @"BOSDKRootDir"
#define kBOSDKRootDirectoryName_Stage                       @"BOSDKRootDir_Stage"

#define kBOSDKVolatileRootDirectoryName                     @"BOVolatileRootDirectory"
#define kBOSDKVolatileRootDirectoryName_Stage               @"BOVolatileRootDirectory_Stage"

#define kBOSDKNonVolatileRootDirectoryName                  @"BONonVolatileRootDirectory"
#define kBOSDKNonVolatileRootDirectoryName_Stage            @"BONonVolatileRootDirectory_Stage"

#define kBOFNetworkPromiseDownloadDirectoryName             @"BOFNetworkPromiseDownloads"
#define kBOFNetworkPromiseDownloadDirectoryName_Stage       @"BOFNetworkPromiseDownloads_Stage"

#define kBOFoundationDirectoryName                          @"BOFoundationDirectory"
#define kBOFoundationDirectoryName_Stage                    @"BOFoundationDirectory_Stage"

#define kBOAnalyticsDirectoryName                           @"BOAnalyticsDirectory"
#define kBOAnalyticsDirectoryName_Stage                     @"BOAnalyticsDirectory_Stage"

#define BO_SDK_ROOT_USER_DEFAULTS_KEY                       @"com.blotout.sdk.root"
#define BO_SDK_ROOT_USER_DEFAULTS_KEY_STAGE                 @"com.blotout.sdk.root_stage"

#define BO_FOUNDATION_USER_DEFAULTS_KEY                     @"com.blotout.sdk.Foundation"
#define BO_FOUNDATION_USER_DEFAULTS_KEY_STAGE               @"com.blotout.sdk.Foundation_Stage"

#define BO_SDK_DEFAULT_QUEUE                                "com.blotout.sdk.defaultsqueue"
#define BO_SDK_DEFAULT_QUEUE_STAGE                          "com.blotout.sdk.defaultsqueue_stage"

#define kBOFNetworkPromiseDefaultErrorDomain                @"BOFNetworkPromiseNetworkSessionErrorDomain"
#define kBOFNetworkPromiseDefaultErrorCode                  90001
#define kBOFNetworkPromiseDefaultErrorUserInfo              @{@"Description":@"Not able to stablish session, either session or network promise task is null"}

#define     BOF_DEBUG  @"BOF-DEBUG"

//#define IS_IPHONE5          (([[UIScreen mainScreen] bounds].size.height-568)? NO : YES)
//#define IS_IPHONE6          (([[UIScreen mainScreen] bounds].size.height-667)? NO : YES)
//#define IS_IPHONE6Plus      (([[UIScreen mainScreen] bounds].size.height-736)? NO : YES)
#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_OS_9_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define IS_OS_10_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#define IS_OS_11_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0)
#define IS_OS_12_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 12.0)
#define IS_OS_13_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13.0)
#define IS_OS_14_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 14.0)
#define IS_OS_15_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 15.0)
#define IS_OS_16_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 16.0)

//encryption key & iv
#define kEncryptionKey             @"bbC2H19lkVbQDfakxcrtNMQdd0FloLyw"// length == 32
#define kEncryptionIv             @"gqLOHUioQ0QjhuvI"// length == 16


#endif /* BOFConstants_h */
