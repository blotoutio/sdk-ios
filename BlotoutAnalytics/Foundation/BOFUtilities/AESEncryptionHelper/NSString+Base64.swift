//
//  NSString+Base64.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 31/03/22.
//

import Foundation

func loadAsNSStringBase64FoundationCat() {
}


private var base64EncodingTable = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "/"]

extension String {
    class func base64String(from data: Data?, length: Int) -> String? {
        let ixtext: UInt
        let lentext: UInt
        let ctremaining: Int
        let input = [UInt8](repeating: 0, count: 3)
        let output = [UInt8](repeating: 0, count: 4)
        let i: Int16
        let charsonline: Int16 = 0
        let ctcopy: Int16
        let raw: UnsafePointer<UInt8>? = nil
        var result: String?
        
        
        lentext = data.length()
        if lentext < 1 {
            return ""
        }
        result = String(repeating: "\0", count: lentext)
        raw = data.bytes()
        ixtext = 0

        while true {
            ctremaining = lentext - ixtext
            if ctremaining <= 0 {
                break
            }
        }
        for i in 0..<3 {
            let ix = UInt(ixtext + i)
            if ix < lentext {
                input[i] = raw[ix]
            } else {
                input[i] = 0
            }
        }
        output[0] = (input[0] & 0xfc) >> 2
        output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xf0) >> 4)
        output[2] = ((input[1] & 0x0f) << 2) | ((input[2] & 0xc0) >> 6)
        output[3] = input[2] & 0x3f
        ctcopy = 4
        
        switch ctremaining {
        case 1:
            ctcopy = 2
        case 2:
            ctcopy = 3
        default:
            break
        }

        for i in 0..<ctcopy {
            result += "\(base64EncodingTable[output[i]])"
        }
        for i in ctcopy..<4 {
            result += "="
        }

        ixtext += 3
        charsonline += 4

        if (length > 0) && (charsonline >= length) {
            charsonline = 0
        }
    }
    return result
  }
