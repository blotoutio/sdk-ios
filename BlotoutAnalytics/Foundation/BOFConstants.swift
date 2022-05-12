//
//  BOFConstants.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 23/03/22.
//

import Foundation
import UIKit
#if !BOFConstants_h
//#define BOFConstants_h

let kBOFFoundationProductKeyForUserDefaults = "BOFFoundationDefaults"
let kBOSDKLaunchTestDirectoryName = "BOSDKLaunchTestDir"
let kBOSDKRootDirectoryName = "BOSDKRootDir"
let kBOSDKVolatileRootDirectoryName = "BOVolatileRootDirectory"
let kBOSDKNonVolatileRootDirectoryName = "BONonVolatileRootDirectory"
let kBOSDKNonVolatileRootDirectoryName_Stage = "BONonVolatileRootDirectory_Stage"

let kBOFoundationDirectoryName = "BOFoundationDirectory"
let kBOAnalyticsDirectoryName = "BOAnalyticsDirectory"
let BO_SDK_ROOT_USER_DEFAULTS_KEY = "com.blotout.sdk.root"
let BO_FOUNDATION_USER_DEFAULTS_KEY = "com.blotout.sdk.Foundation"
let BO_SDK_DEFAULT_QUEUE = "com.blotout.sdk.defaultsqueue"

let BOF_DEBUG = "BOF-DEBUG"


//encryption key & iv
let kEncryptionKey = "bbC2H19lkVbQDfakxcrtNMQdd0FloLyw" // length == 32
let kEncryptionIv = "gqLOHUioQ0QjhuvI" // length == 16
#endif
