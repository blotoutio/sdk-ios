//
//  BOAUtilities.swift
//  BlotoutAnalytics
//
//  Created by Poonam Tiwari on 16/04/22.
//

import Foundation
import UIKit

class BOAUtilities:NSObject {
    
    class func jsonData(from dictObject: [AnyHashable : Any]?, withPrettyPrint prettyPrint: Bool) -> Data? {
        do{
            if dictObject == nil || ((dictObject?.keys.count) == 0) {
                return nil
            }
            var error: Error?
            var jsonData: Data?
            jsonData = dictObject != nil ? try JSONSerialization.data(
                withJSONObject: dictObject,
                options: JSONSerialization.WritingOptions(rawValue: (prettyPrint ? JSONSerialization.WritingOptions.prettyPrinted.rawValue : 0))): nil
            if jsonData == nil
            {
                BOFLogDebug(frmt: "%s: error: %@", args: #function, error?.localizedDescription as! CVarArg )
                return nil
            }
            
            return jsonData
            
        }
        catch {
            BOFLogDebug(frmt: "%@:%@", args: BOA_DEBUG, error.localizedDescription)
        }
        return nil
    }
    
    class func getCurrentTimezoneOffsetInMin() -> Int {

            let timeZone = NSTimeZone.local as NSTimeZone
            let seconds = timeZone.secondsFromGMT
            let offset = seconds / 60
            return offset
        
    }
    
    class func get13DigitNumberObjTimeStamp() -> NSNumber {

            let timeStamp = Int(Date().timeIntervalSince1970 * 1000)
            let timeStampObj = NSNumber(value: timeStamp)
            return timeStampObj
    }
    
    class func get13DigitIntegerTimeStamp() -> Int {

            let timeStamp = Int(Date().timeIntervalSince1970 * 1000)
            return timeStamp
        
    }
    
  /* NOT being used
   class func getHashIntSum(_ input: String?) -> Int {
        var input = input
        do{
            input = input?.lowercased()
            let encoded = BOFUtilities.getSHA1(input)
            var sum = 0
            for index in 0..<encoded?.count ?? 0 {
                sum += Int(encoded[encoded.index(encoded.startIndex, offsetBy: UInt(index))])
            }
            return sum
        } catch {
            BOFLogDebug(frmt: "%@:%@", args: BOA_DEBUG, error.localizedDescription)
        }
        return 0
    }
    */
    class func getMessageID(forEvent eventName: String?) -> String? {

            let eventNameData = eventName?.data(using: .utf8)
            
        return String(format: "%@-%@-%ld", eventNameData?.base64EncodedString(options: []) ?? "", self.getUUIDString() as CVarArg, Int(self.get13DigitIntegerTimeStamp()))

    }
    
    class func currentPlatformCode() -> Int {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return 14
        case .pad:
            return 15
        case .tv:
            return 18
        case .carPlay, .unspecified:
            return 60
        default:
            return 0
        }
    }
    
    class func getDeviceId() -> String? {
        
        
        //This should return the cookiestring we get in the api response
        //cookie:
       // sdk_trends_user_id=000000-1651580197706-14020f11-4298-45c6-8943-1e273751330f
        //TODO: temporary change
        return ""
    }
    
    class func convertTo64CharUUID(_ stringToConvert: String?) -> String? {

            if stringToConvert == nil || (stringToConvert?.count ?? 0) == 0 {
                return stringToConvert
            }
            
            let str = stringToConvert
            let lengths = [NSNumber(value: 16), NSNumber(value: 8), NSNumber(value: 8), NSNumber(value: 8), NSNumber(value: 24)]
            var parts:[AnyHashable] = []
            var startRange = 0
            for i in 0..<lengths.count {
                let range = NSRange(location: startRange, length: (lengths[i]).intValue )
                let stringOfRange = (str! as NSString).substring(with: range)
                parts.append(stringOfRange)
                startRange += (lengths[i]).intValue
            }
            let uuid64Char = (parts as! Array).joined(separator:"-")
            return uuid64Char

    }
    
    static let generateRandomNumberLetters = "0123456789"
    
    class func generateRandomNumber(length:Int)-> String{
        var number = String()
        for _ in 1...length {
            number += "\(Int.random(in: 0...9))"
        }
        return number
    }
    
    class func getUUIDString() -> String {
        let uuid = UUID()
        let uuidStr = uuid.uuidString
        return uuidStr
    }
    
    class func getUUIDString(from uuidStr: String?) -> String? {
        // Create a new CFUUID (Unique, random ID number) (Always different)
        // Make the new UUID String
        let uuidRef = CFUUIDCreateFromString(kCFAllocatorDefault, uuidStr as CFString?)
        let tempUniqueID:String = CFUUIDCreateString(kCFAllocatorDefault, uuidRef) as String
        
        // Check to make sure it created it
        if tempUniqueID.count <= 0 {
            // Error, Unable to create
            // Release the UUID Reference
            // Return nil
            return uuidStr
        }
        
        // Release the UUID Reference
        return tempUniqueID
        
    }
    
    class func topViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        
            if !(rootViewController is UINavigationController) && !(rootViewController is UITabBarController) && rootViewController?.presentedViewController == nil {
                return rootViewController
            }
            
            if rootViewController is UINavigationController {
                let navigationController = rootViewController as? UINavigationController
                return topViewController(navigationController?.viewControllers.last)
            }
            
            if rootViewController is UITabBarController {
                let tabController = rootViewController as? UITabBarController
                return topViewController(tabController?.selectedViewController)
            }
            
            if rootViewController?.presentedViewController != nil {
                return topViewController(rootViewController?.presentedViewController)
            }
        return rootViewController
    }
    
    @objc class func systemName() -> String? {

            // Get the current system name
            if UIDevice.current.responds(to: #selector(getter: UIDevice.systemName)) {
                // Make a string for the system name
                let systemName = UIDevice.current.systemName
                // Set the output to the system name
                return systemName
            }

        return "Unknown"
    }
    
    @objc class func systemVersion() -> String? {

            // Get the current system version
            if UIDevice.current.responds(to: #selector(getter: UIDevice.systemVersion)) {
                // Make a string for the system version
                let systemVersion = UIDevice.current.systemVersion
                // Set the output to the system version
                return systemVersion
            }
            
            if ProcessInfo.processInfo.responds(to: #selector(getter: ProcessInfo.operatingSystemVersionString)) {
                //[[NSProcessInfo processInfo] operatingSystemVersion]; //use this to get Major, Minor and Patch
                let systemVersion = ProcessInfo.processInfo.operatingSystemVersionString
                return systemVersion
            }

        return "Unknown"
    }
    
    //TODO:check not being used
    class func deviceModel() -> String? {
        
        // Get the device model
        // Make a string for the device model
        let deviceModel = UIDevice.current.model
        // Set the output to the device model
        return deviceModel
        
    }
    
    //TODO:check not being used
    class func getUserBirthTimeStamp() -> NSNumber? {
        
        var timeStamp = NSNumber(value: 0)
        let analyticsRootUD = BOFUserDefaults(product: BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY)
        
        timeStamp = analyticsRootUD.value(forKey: BO_ANALYTICS_USER_BIRTH_TIME_STAMP_KEY) as! NSNumber
        //timeStamp = analyticsRootUD[BO_ANALYTICS_USER_BIRTH_TIME_STAMP_KEY]
        if timeStamp.intValue == 0 {
            timeStamp = BOAUtilities.get13DigitNumberObjTimeStamp()
            setUserBirthTimeStamp(timeStamp)
        }
        return timeStamp
    }
    
    class func setUserBirthTimeStamp(_ timeStamp: NSNumber?) {
        
        let analyticsRootUD = BOFUserDefaults(product: BO_ANALYTICS_ROOT_USER_DEFAULTS_KEY)
        analyticsRootUD.setObject(timeStamp, forKey: BO_ANALYTICS_USER_BIRTH_TIME_STAMP_KEY as NSCopying)
        // analyticsRootUD[BO_ANALYTICS_USER_BIRTH_TIME_STAMP_KEY] = timeStamp
    }
    
    class func data(fromPlist plist: Any) -> Data? {
        let error: Error? = nil
        var data: Data? = nil
        do {
            data = try PropertyListSerialization.data(
                fromPropertyList: plist,
                format: .xml,
                options: 0)
        } catch {
        }
        if let error = error {
            BOFLogDebug(frmt: "Unable to serialize data from plist object", args: error.localizedDescription, plist as! CVarArg)
        }
        return data
        
    }
    
    class func plist(from data: Data) -> Any? {
        let error: Error? = nil
        var plist: Any? = nil
        do {
            plist = try PropertyListSerialization.propertyList(
                from: data,
                options: [],
                format: nil)
        } catch {
        }
        if let error = error {
            BOFLogDebug(frmt: "Unable to parse plist from data %@", args: error.localizedDescription)
        }
        
        return plist
    }
    
    /*
     
     //TODO: check if commenting this method serves our purpose
     class func getIDFA() -> String? {
     let idForAdvertiser: String? = nil
     do{
     let identifierManager: AnyClass? = NSClassFromString("ASIdentifierManager")
     if identifierManager == nil {
     return idForAdvertiser
     }
     
     //TODO: convert this later
     
     let sharedManagerSelector = NSSelectorFromString("sharedManager")
     // SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
     id sharedManager =
     ((id (*)(id, SEL))
     [identifierManager methodForSelector:sharedManagerSelector])(identifierManager, sharedManagerSelector);
     // SEL advertisingIdentifierSelector =
     //NSSelectorFromString(@"advertisingIdentifier");
     let advertisingIdentifierSelector = NSSelectorFromString("advertisingIdentifier")
     NSUUID *uuid =
     ((NSUUID * (*)(id, SEL))
     [sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
     idForAdvertiser = [uuid UUIDString];
     
     } catch {
     BOFLogDebug(frmt: "%@:%@", args: BOA_DEBUG, error.localizedDescription)
     }
     return idForAdvertiser
     }
     */
    
    class func traverseJSONDict(_ dict: [AnyHashable : Any]?) -> [AnyHashable : Any]? {
        var dict = dict
        // make sure that a new dictionary exists even if the input is null
        dict = dict ?? [:]
        // coerce urls, and dates to the proper format
        return self.traverseJSON(dict) as? [AnyHashable : Any]
    }
    
    class func traverseJSON(_ obj: Any) -> Any? {
        // Hotfix: Storage format should support NSNull instead
        if obj is NSNull {
            return "<null>"
        }
        
        // if the object is a NSString, NSNumber
        // then we're good
        if (obj is NSString) || (obj is NSNumber) {
            return obj
        }
        
        if obj is [AnyHashable] {
            var array: [AnyHashable] = []
            for i in obj as! [AnyHashable]{
                // Hotfix: Storage format should support NSNull instead
                if i is NSNull {
                    continue
                }
                let newObjs = traverseJSON(i)
                array.insert(contentsOf: newObjs as! [AnyHashable], at: 0)
                //No exact matches in call to instance method 'append'
              //  (array as! [AnyHashable] ).insert(contentsOf: traverseJSON(i), at: 0)
            }
            return array
        }
        
        //TODO: this condition was different re check this
        if obj is [AnyHashable : Any] {
            var dict: [AnyHashable : Any] = [:]
            for key in (obj as! [AnyHashable : Any]).keys{
                // Hotfix for issue where SEGFileStorage uses plist which does NOT support NSNull
                // So when `[NSNull null]` gets passed in as track property values the queue serialization fails
                if (obj as! [AnyHashable : Any])[key] is NSNull {
                    continue
                }
                
                if !(key is NSString) {
                    BOFLogDebug(
                        frmt: """
                                    warning: dictionary keys should be strings. got: %@. coercing \
                                    to: %@
                                    """,
                        args: type(of: key) as! CVarArg,
                        key.description)
                }
                let newObjs = traverseJSON((obj as! [AnyHashable : Any])[key])
                dict[key.description] = newObjs
            }
            return dict
        }
        
        
        
        if obj is Date {
            return iso8601FormattedString(obj as? Date)
        }
        
        if obj is NSURL {
            return (obj as! NSURL).absoluteString
        }
        
        // default to sending the object's description
        BOFLogDebug(
            frmt: """
                    warning: dictionary values should be valid json types. got: %@. \
                    coercing to: %@
                    """,
            args: type(of: obj) as! CVarArg,
            "")
        return ""
        
        
    }
    
    static var iso8601DateFormatter: DateFormatter?
    
    
    class func iso8601FormattedString(_ date: Date?) -> String? {
        lazy var dateFormatter: DateFormatter? = nil
        
        if let date = date {
            return iso8601DateFormatter?.string(from: date)
        }
        
        // TODO: ensure that the code below is executed only once (`dispatch_once()` is deprecated)
        if dateFormatter == nil
        {
            dateFormatter = DateFormatter()
            dateFormatter?.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
            dateFormatter?.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
            dateFormatter?.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        }
        
        return nil
        
    }
}
