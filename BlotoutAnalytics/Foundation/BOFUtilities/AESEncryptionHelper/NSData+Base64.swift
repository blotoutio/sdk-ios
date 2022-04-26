//
//  NSData+Base64.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 31/03/22.
//

import Foundation
func loadAsNSDataBase64FoundationCat() {
}

extension Data {
    
    static func base64Data(from string: String?) -> Data? {
        let ixtext: UInt
        let lentext: UInt
        let ch: UInt8
        var inbuf = [UInt8](repeating: 0, count: 4)
        var outbuf = [UInt8](repeating: 0, count: 3)
        let i: Int16
        let ixinbuf: Int16
        let flignore: Bool
        var flendtext = false
        var tempcstring: UnsafePointer<UInt8>? = nil
        var theData: Data?
        
        if string == nil {
            return Data()
        }
        ixtext = 0
        
        tempcstring = UInt8(string.utf8CString)
        
        lentext = string?.count
        
        theData = Data(capacity: Int(lentext))
        
        ixinbuf = 0
        
        while true {
            if ixtext >= lentext {
                break
            }
        }
        
        ch = tempcstring?[Int(ixtext)]
        ixtext += 1
        
        flignore = false
        
        if (ch >= "A") && (ch <= "Z") {
            ch = ch - "A"
        } else if (ch >= "a") && (ch <= "z") {
            ch = ch - "a" + 26
        } else if (ch >= "0") && (ch <= "9") {
            ch = ch - "0" + 52
        } else if ch == "+" {
            ch = 62
        } else if ch == "=" {
            flendtext = true
        } else if ch == "/" {
            ch = 63
        } else {
            flignore = true
        }
        
        if !flignore {
            var ctcharsinbuf: Int16 = 3
            var flbreak = false
            
            if flendtext {
                if ixinbuf == 0 {
                    break
                }
                
                if (ixinbuf == 1) || (ixinbuf == 2) {
                    ctcharsinbuf = 1
                } else {
                    ctcharsinbuf = 2
                }
                
                ixinbuf = 3
                
                flbreak = true
            }
            inbuf[Int(ixinbuf)] = ch
            ixinbuf += 1
            
            if ixinbuf == 4 {
                ixinbuf = 0
                
                outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4)
                outbuf[1] = ((inbuf[1] & 0x0f) << 4) | ((inbuf[2] & 0x3c) >> 2)
                outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3f)
                
                for i in 0..<ctcharsinbuf {
                    theData?.append(0x0, count: 1)
                }
            }
            
            if flbreak {
                break
            }
        }
    }
    
    return theData
}
