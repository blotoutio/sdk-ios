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
//let kBOFNetworkPromiseDownloadDirectoryName = "BOFNetworkPromiseDownloads"
let kBOFoundationDirectoryName = "BOFoundationDirectory"
let kBOAnalyticsDirectoryName = "BOAnalyticsDirectory"
let BO_SDK_ROOT_USER_DEFAULTS_KEY = "com.blotout.sdk.root"
let BO_FOUNDATION_USER_DEFAULTS_KEY = "com.blotout.sdk.Foundation"
let BO_SDK_DEFAULT_QUEUE = "com.blotout.sdk.defaultsqueue"
//let kBOFNetworkPromiseDefaultErrorDomain = "BOFNetworkPromiseNetworkSessionErrorDomain"
//let kBOFNetworkPromiseDefaultErrorCode = 90001
//let kBOFNetworkPromiseDefaultErrorUserInfo = [
 //   "Description": "Not able to stablish session, either session or network promise task is null"
//]
let BOF_DEBUG = "BOF-DEBUG"
let IS_OS_5_OR_LATER = Float(UIDevice.current.systemVersion) ?? 0.0 >= 5.0
let IS_OS_6_OR_LATER = Float(UIDevice.current.systemVersion) ?? 0.0 >= 6.0
let IS_OS_7_OR_LATER = Float(UIDevice.current.systemVersion) ?? 0.0 >= 7.0
let IS_OS_8_OR_LATER = Float(UIDevice.current.systemVersion) ?? 0.0 >= 8.0
let IS_OS_9_OR_LATER = Float(UIDevice.current.systemVersion) ?? 0.0 >= 9.0
let IS_OS_10_OR_LATER = Float(UIDevice.current.systemVersion) ?? 0.0 >= 10.0
let IS_OS_11_OR_LATER = Float(UIDevice.current.systemVersion) ?? 0.0 >= 11.0
let IS_OS_12_OR_LATER = Float(UIDevice.current.systemVersion) ?? 0.0 >= 12.0
let IS_OS_13_OR_LATER = Float(UIDevice.current.systemVersion) ?? 0.0 >= 13.0
let IS_OS_14_OR_LATER = Float(UIDevice.current.systemVersion) ?? 0.0 >= 14.0

let IS_OS_15_OR_LATER = Float(UIDevice.current.systemVersion) ?? 0.0 >= 15.0
let IS_OS_16_OR_LATER = Float(UIDevice.current.systemVersion) ?? 0.0 >= 16.0

//encryption key & iv
let kEncryptionKey = "bbC2H19lkVbQDfakxcrtNMQdd0FloLyw" // length == 32
let kEncryptionIv = "gqLOHUioQ0QjhuvI" // length == 16
#endif
