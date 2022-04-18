//
//  BOFNetworkPromiseProtocols.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 13/04/22.
//

import Foundation

typealias downloadProgressHandler = (Double, Int64, Int64, Int64) -> Void
typealias downloadResumeHandler = (Int64, Int64) -> Void


@objc protocol BOFNetworkPromiseDeleagte: NSObjectProtocol {
    @objc optional func bofNetworkPromise(_ networkDownloadPromise: BOFNetworkPromise?, didFinishDownloadingTo location: URL?)
    
    @objc optional func bofNetworkPromise(_ networkPromise: BOFNetworkPromise?, didCompleteWithError error: Error?)
    
    @objc optional func bofNetworkPromise(_ networkDownloadPromise: BOFNetworkPromise?, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    
    @objc optional func bofNetworkPromise(_ networkDownloadPromise: BOFNetworkPromise?, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64)
    
    @objc optional  func bofNetworkPromise(_ networkDataPromise: BOFNetworkPromise?, didReceive data: Data?)
}
