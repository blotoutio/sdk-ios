//
//  BOFLogs.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 23/03/22.
//

import Foundation

private var sBOFLogsSharedInstance: Any? = nil

class BOFLogs:NSObject {
    
    var isSDKLogEnabled = false
    //    class func sharedInstance() -> Self? {
    //        // TODO: [Swiftify] ensure that the code below is executed only once (`dispatch_once()` is deprecated)
    //        { [self] in
    //            sBOFLogsSharedInstance = self.init()
    //        }
    //
    //        return sBOFLogsSharedInstance as! Self
    //    }
    public static let sharedInstance = BOFLogs()
    public override init() {}
}

func BOFLogDebug(frmt: String, args:CVarArg...) {
    
    if !BOFLogs.sharedInstance.isSDKLogEnabled  {
        return
    }
    
    let msg =  String(format: frmt , arguments: args)
    let logMessage = "[File Name : \(#file)] [Method Name: \(#function)] [Line No: \(#line)] \(msg)"
    print("Info: \(logMessage)")
    
}

func BOFLogError(_ frmt: String, args:CVarArg...) {
    if !(BOFLogs.sharedInstance.isSDKLogEnabled ) {
        return
    }
    let msg =  String(format: frmt , arguments: args)
    let logMessage = "[File Name : \(#file)] [Method Name: \(#function)] [Line No: \(#line)] \(msg)"
    print("Info: \(logMessage)")
    
}

func BOFLogInfo(_ frmt: String, args:CVarArg...) {
    if !(BOFLogs.sharedInstance.isSDKLogEnabled ) {
        return
    }
    let msg =  String(format: frmt , arguments: args)
    let logMessage = "[Method Name: \(#function)] [Line No: \(#line)] \(msg)"
    print("Info: \(logMessage)")
    
}
