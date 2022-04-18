//
//  NSData+CommonCrypto.swift
//  BlotoutAnalyticsSDK
//
//  Created by Poonam Tiwari on 31/03/22.
//

import Foundation

let kCommonCryptoErrorDomain = "CommonCryptoErrorDomain"

func loadAsNSDataCommonDigestFoundationCat() {
}

extension Error {
    convenience init?(ccCryptorStatus status: CCCryptorStatus) {
        let description: String? = nil
        let reason: String? = nil
        
        switch status {
        case kCCSuccess:
            description = NSLocalizedString("Success", comment: "Error description")
        case kCCParamError:
            description = NSLocalizedString("Parameter Error", comment: "Error description")
            reason = NSLocalizedString("Illegal parameter supplied to encryption/decryption algorithm", comment: "Error reason")
            
            
        case kCCBufferTooSmall:
            description = NSLocalizedString("Buffer Too Small", comment: "Error description")
            reason = NSLocalizedString("Insufficient buffer provided for specified operation", comment: "Error reason")
        case kCCMemoryFailure:
            description = NSLocalizedString("Memory Failure", comment: "Error description")
            reason = NSLocalizedString("Failed to allocate memory", comment: "Error reason")
            
        case kCCAlignmentError:
            description = NSLocalizedString("Alignment Error", comment: "Error description")
            reason = NSLocalizedString("Input size to encryption algorithm was not aligned correctly", comment: "Error reason")
        case kCCDecodeError:
            description = NSLocalizedString("Decode Error", comment: "Error description")
            reason = NSLocalizedString("Input data did not decode or decrypt correctly", comment: "Error reason")
            
        case kCCUnimplemented:
            description = NSLocalizedString("Unimplemented Function", comment: "Error description")
            reason = NSLocalizedString("Function not implemented for the current algorithm", comment: "Error reason")
        default:
            description = NSLocalizedString("Unknown Error", comment: "Error description")
        }
        
        var userInfo: [AnyHashable : Any] = [:]
        userInfo[NSLocalizedDescriptionKey] = description
        
        if let reason = reason {
            userInfo[NSLocalizedFailureReasonErrorKey] = reason
        }
        let result = NSError(domain: kCommonCryptoErrorDomain, code: status, userInfo: userInfo)
        
        return result
        
    }
}

extension Data {
    func md2Sum() -> Data? {
        let hash = [UInt8](repeating: 0, count: CC_MD2_DIGEST_LENGTH)
        CC_MD2(bytes, count as? CC_LONG, hash)
        return Data(bytes: &hash, length: CC_MD2_DIGEST_LENGTH)
    }
    
    func md4Sum() -> Data? {
        let hash = [UInt8](repeating: 0, count: CC_MD4_DIGEST_LENGTH)
        CC_MD4(bytes(), length() as? CC_LONG, hash)
        return Data(bytes: &hash, length: CC_MD4_DIGEST_LENGTH)
    }
    
    func md5Sum() -> Data? {
        let hash = [UInt8](repeating: 0, count: CC_MD5_DIGEST_LENGTH)
        CC_MD5(bytes(), length() as? CC_LONG, hash)
        return Data(bytes: &hash, length: CC_MD5_DIGEST_LENGTH)
    }
    
    func sha1Hash() -> Data? {
        let hash = [UInt8](repeating: 0, count: CC_SHA1_DIGEST_LENGTH)
        CC_SHA1(bytes(), length() as? CC_LONG, hash)
        return Data(bytes: &hash, length: CC_SHA1_DIGEST_LENGTH)
    }
    
    func sha1HashString() -> String? {
        let hash = [UInt8](repeating: 0, count: CC_SHA1_DIGEST_LENGTH)
        CC_SHA1(bytes(), length() as? CC_LONG, hash)
        
        var hashString = String(repeating: "\0", count: CC_SHA1_DIGEST_LENGTH * 2)
        for i in 0..<CC_SHA1_DIGEST_LENGTH {
            hashString += String(format: "%02x", hash[i])
        }
        
        return hashString
    }
    
    func sha224Hash() -> Data? {
        let hash = [UInt8](repeating: 0, count: CC_SHA224_DIGEST_LENGTH)
        CC_SHA224(bytes(), length() as? CC_LONG, hash)
        return Data(bytes: &hash, length: CC_SHA224_DIGEST_LENGTH)
    }
    
    func sha256Hash() -> Data? {
        let hash = [UInt8](repeating: 0, count: CC_SHA256_DIGEST_LENGTH)
        CC_SHA256(bytes(), length() as? CC_LONG, hash)
        return Data(bytes: &hash, length: CC_SHA256_DIGEST_LENGTH)
    }
    
    func sha256HashString() -> String? {
        let hash = [UInt8](repeating: 0, count: CC_SHA256_DIGEST_LENGTH)
        CC_SHA256(bytes(), length() as? CC_LONG, hash)
        
        var hashString = String(repeating: "\0", count: CC_SHA256_DIGEST_LENGTH * 2)
        for i in 0..<CC_SHA256_DIGEST_LENGTH {
            hashString += String(format: "%02x", hash[i])
        }
        
        return hashString
    }
    
    func sha384Hash() -> Data? {
        let hash = [UInt8](repeating: 0, count: CC_SHA384_DIGEST_LENGTH)
        CC_SHA384(bytes(), length() as? CC_LONG, hash)
        return Data(bytes: &hash, length: CC_SHA384_DIGEST_LENGTH)
    }
    
    func sha512Hash() -> Data? {
        let hash = [UInt8](repeating: 0, count: CC_SHA512_DIGEST_LENGTH)
        CC_SHA512(bytes(), length() as? CC_LONG, hash)
        return Data(bytes: &hash, length: CC_SHA512_DIGEST_LENGTH)
    }
    
    extension Data {
        func aes256EncryptedData(usingKey key: Any?, iv: Any?) throws -> Data? {
            var status = kCCSuccess
            let result = dataEncrypted(
                usingAlgorithm: kCCAlgorithmAES128,
                key: key,
                iv: iv,
                options: kCCOptionPKCS7Padding,
                error: &status)
            if let result = result {
                return result
            }
            if error != nil {
                error = Error(ccCryptorStatus: status)
            }
            return nil
        }
    }
    
    func decryptedAES256Data(usingKey key: Any?, iv: Any?) throws -> Data? {
        var status = kCCSuccess
        let result = decryptedData(
            usingAlgorithm: kCCAlgorithmAES128,
            key: key,
            iv: iv,
            options: kCCOptionPKCS7Padding,
            error: &status)
        
        if let result = result {
            return result
            
        }
        if error != nil {
            error = Error(ccCryptorStatus: status)
        }
        
        return nil
    }
    
    func desEncryptedData(usingKey key: Any?, iv: Any?) throws -> Data? {
        var status = kCCSuccess
        let result = dataEncrypted(
            usingAlgorithm: kCCAlgorithmDES,
            key: key,
            iv: iv,
            options: kCCOptionPKCS7Padding,
            error: &status)
        
        if let result = result {
            return result
        }
        
        if error != nil {
            error = Error(ccCryptorStatus: status)
        }
        
        return nil
    }
    
    func decryptedDESData(usingKey key: Any?, iv: Any?) throws -> Data? {
        var status = kCCSuccess
        let result = decryptedData(
            usingAlgorithm: kCCAlgorithmDES,
            key: key,
            iv: iv,
            options: kCCOptionPKCS7Padding,
            error: &status)
        
        if let result = result {
            return result
        }
        if error != nil {
            error = Error(ccCryptorStatus: status)
        }
        
        return nil
    }
    
    func castEncryptedData(usingKey key: Any?, iv: Any?) throws -> Data? {
        var status = kCCSuccess
        let result = dataEncrypted(
            usingAlgorithm: kCCAlgorithmCAST,
            key: key,
            iv: iv,
            options: kCCOptionPKCS7Padding,
            error: &status)
        
        if let result = result {
            return result
        }
        
        if error != nil {
            error = Error(ccCryptorStatus: status)
        }
        
        return nil
    }
    
    
    func decryptedCASTData(usingKey key: Any?, iv: Any?) throws -> Data? {
        var status = kCCSuccess
        let result = decryptedData(
            usingAlgorithm: kCCAlgorithmCAST,
            key: key,
            iv: iv,
            options: kCCOptionPKCS7Padding,
            error: &status)
        
        if let result = result {
            return result
        }
        if error != nil {
            error = Error(ccCryptorStatus: status)
        }
        
        return nil
    }
    
    
    private func FixKeyLengths(_ algorithm: CCAlgorithm, _ keyData: inout Data?, _ ivData: inout Data?) {
        let keyLength = keyData?.count ?? 0
        switch algorithm {
        case kCCAlgorithmRC4:
            if keyLength > 512 {
                keyData?.length = 512
            }
            
        case kCCAlgorithmAES128:
            if keyLength < 16 {
                keyData.setLength(16)
            } else if keyLength < 24 {
                keyData.setLength(24)
            } else {
                keyData.setLength(32)
            }
            
        case kCCAlgorithmDES:
            keyData.setLength(8)
        case kCCAlgorithm3DES:
            keyData.setLength(24)
            
        case kCCAlgorithmCAST:
            if keyLength < 5 {
                keyData.setLength(5)
            } else if keyLength > 16 {
                keyData.setLength(16)
            }
        default:
            break
        }
        
        ivData?.length = keyData?.count ?? 0
    }
}


extension Data {
    func _runCryptor(_ cryptor: CCCryptorRef, result status: CCCryptorStatus?) -> Data? {
        var status = status
        let bufsize = CCCryptorGetOutputLength(cryptor, size_t(count), true)
        let buf = malloc(bufsize)
        var bufused: size_t = 0
        let bytesTotal: size_t = 0
        status = CCCryptorUpdate(
            cryptor,
            bytes,
            size_t(count),
            buf,
            bufsize,
            &bufused)
        
        if status != kCCSuccess {
            free(buf)
            return nil
        }
        
        bytesTotal += bufused
        
        // From Brent Royal-Gordon (Twitter: architechies):
        //  Need to update buf ptr past used bytes when calling CCCryptorFinal()
        status = CCCryptorFinal(cryptor, buf + bufused, bufsize - bufused, &bufused)
        if status != kCCSuccess {
            free(buf)
            return nil
        }
        
        bytesTotal += bufused
        
        return (Data(bytesNoCopy: &buf, length: bytesTotal))
    }
    
    func dataEncrypted(
        using algorithm: CCAlgorithm,
        key: Any?,
        iv: Any?,
        error: CCCryptorStatus?
    ) -> Data? {
        return dataEncrypted(
            using: algorithm,
            key: key,
            initializationVector: nil,
            options: 0,
            error: error)
    }
    
    func dataEncrypted(
        using algorithm: CCAlgorithm,
        key: Any?,
        iv: Any?,
        options: CCOptions,
        error: CCCryptorStatus?
    ) -> Data? {
        return dataEncrypted(
            using: algorithm,
            key: key,
            initializationVector: iv,
            options: options,
            error: error)
    }
    
    
    func dataEncrypted(
        using algorithm: CCAlgorithm,
        key: Any?,
        initializationVector iv: Any?,
        options: CCOptions,
        error: CCCryptorStatus?
    ) -> Data? {
        let cryptor: CCCryptorRef? = nil
        let status = kCCSuccess
        
        assert((key is Data) || (key is NSString), "Invalid parameter not satisfying: (key is Data) || (key is NSString)")
        assert(iv == nil || (iv is Data) || (iv is NSString), "Invalid parameter not satisfying: iv == nil || (iv is Data) || (iv is NSString)")
        
        var keyData: Data?
        var ivData: Data?
        
        if key is Data {
            keyData = key as? Data
        } else {
            keyData = key.data(using: .utf8)
        }
        
        if iv is NSString {
            ivData = iv.data(using: .utf8)
        } else {
            ivData = iv as? Data // data or nil
        }
        
#if !__has_feature(objc_arc)
        keyData
        ivData
#endif
        // ensure correct lengths for key and iv data, based on algorithms
        FixKeyLengths(algorithm, keyData, ivData)
        
        status = CCCryptorCreate(
            kCCEncrypt,
            algorithm,
            options,
            keyData.bytes(),
            keyData.length(),
            ivData.bytes(),
            &cryptor)
        
        if status != kCCSuccess {
            if error != nil {
                error = status
            }
            return nil
        }
        
        let result = _runCryptor(cryptor, result: &status)
        if result == nil && error != nil {
            error = status
        }
        
        CCCryptorRelease(cryptor)
        
        return result
    }
    
    func decryptedData(
        using algorithm: CCAlgorithm,
        key: Any?,
        iv: Any?,
        error: CCCryptorStatus?
    ) -> Data? {
        return decryptedData(
            using: algorithm,
            key: key,
            initializationVector: nil,
            options: 0,
            error: error)
    }
    func decryptedData(
        using algorithm: CCAlgorithm,
        key: Any?,
        iv: Any?,
        options: CCOptions,
        error: CCCryptorStatus?
    ) -> Data? {
        return decryptedData(
            using: algorithm,
            key: key,
            initializationVector: iv,
            options: options,
            error: error)
    }
    
    
    func decryptedData(
        using algorithm: CCAlgorithm,
        key: Any?,
        initializationVector iv: Any?,
        options: CCOptions,
        error: CCCryptorStatus?
    ) -> Data? {
        let cryptor: CCCryptorRef? = nil
        let status = kCCSuccess
        
        
        assert((key is Data) || (key is NSString), "Invalid parameter not satisfying: (key is Data) || (key is NSString)")
        assert(iv == nil || (iv is Data) || (iv is NSString), "Invalid parameter not satisfying: iv == nil || (iv is Data) || (iv is NSString)")
        
        var keyData: Data?
        var ivData: Data?
        if key is Data {
            keyData = key as? Data
        } else {
            keyData = key.data(using: .utf8)
        }
        
        if iv is NSString {
            ivData = iv.data(using: .utf8)
        } else {
            ivData = iv as? Data // data or nil
        }
        
#if !__has_feature(objc_arc)
        keyData
        ivData
#endif
        
        // ensure correct lengths for key and iv data, based on algorithms
        FixKeyLengths(algorithm, keyData, ivData)
        
        status = CCCryptorCreate(
            kCCDecrypt,
            algorithm,
            options,
            keyData.bytes(),
            keyData.length(),
            ivData.bytes(),
            &cryptor)
        
        if status != kCCSuccess {
            if error != nil {
                error = status
            }
            return nil
        }
        
        let result = _runCryptor(cryptor, result: &status)
        if result == nil && error != nil {
            error = status
        }
        
        CCCryptorRelease(cryptor)
        
        return result
    }
    
}

extension Data {
    func hmac(with algorithm: CCHmacAlgorithm) -> Data? {
        return hmac(with: algorithm, key: nil)
    }
    
    func hmac(with algorithm: CCHmacAlgorithm, key: Any?) -> Data? {
        assert(key == nil || (key is Data) || (key is NSString), "Invalid parameter not satisfying: key == nil || (key is Data) || (key is NSString)")
        
        var keyData: Data? = nil
        if key is NSString {
            keyData = key?.data(using: .utf8)
        } else {
            keyData = key as? Data
            
            let buf = [UInt8](repeating: 0, count: CC_SHA1_DIGEST_LENGTH)
            CCHmac(algorithm, keyData.bytes(), keyData.length(), bytes(), length(), buf)
            
            return Data(bytes: &buf, length: algorithm == kCCHmacAlgMD5 ? CC_MD5_DIGEST_LENGTH : CC_SHA1_DIGEST_LENGTH)
        }
    }
}

