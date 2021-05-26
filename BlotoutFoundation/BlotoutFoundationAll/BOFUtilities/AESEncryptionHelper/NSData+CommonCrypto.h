//
//  NSData+CommonCrypto.h
//  BlotoutFoundation
//
//  Created by Blotout on 27/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/NSData.h>
#import <Foundation/NSError.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>

extern NSString * const kCommonCryptoErrorDomain;
extern void loadAsNSDataCommonDigestFoundationCat(void);

@interface NSError (CommonCryptoErrorDomain)
+ (NSError *) errorWithCCCryptorStatus: (CCCryptorStatus) status;
@end

@interface NSData (CommonDigest)

- (NSData *) MD2Sum;
- (NSData *) MD4Sum;
- (NSData *) MD5Sum;

- (NSData *) SHA1Hash;
- (NSString *) SHA1HashString;
- (NSData *) SHA224Hash;
- (NSData *) SHA256Hash;
- (NSString *) SHA256HashString;
- (NSData *) SHA384Hash;
- (NSData *) SHA512Hash;

@end

@interface NSData (CommonCryptor)

- (NSData *) AES256EncryptedDataUsingKey: (id) key iv:(id)iv error: (NSError **) error;
- (NSData *) decryptedAES256DataUsingKey: (id) key iv:(id)iv error: (NSError **) error;

- (NSData *) DESEncryptedDataUsingKey: (id) key iv: (id) iv error: (NSError **) error;
- (NSData *) decryptedDESDataUsingKey: (id) key iv: (id) iv error: (NSError **) error;

- (NSData *) CASTEncryptedDataUsingKey: (id) key iv: (id) iv error: (NSError **) error;
- (NSData *) decryptedCASTDataUsingKey: (id) key iv: (id) iv error: (NSError **) error;

@end

@interface NSData (LowLevelCommonCryptor)

- (NSData *) dataEncryptedUsingAlgorithm: (CCAlgorithm) algorithm
                                     key: (id) key		// data or string
                                      iv: (id) iv        // data or string
                                   error: (CCCryptorStatus *) error;
- (NSData *) dataEncryptedUsingAlgorithm: (CCAlgorithm) algorithm
                                     key: (id) key		// data or string
                                      iv: (id) iv        // data or string
                                 options: (CCOptions) options
                                   error: (CCCryptorStatus *) error;
- (NSData *) dataEncryptedUsingAlgorithm: (CCAlgorithm) algorithm
                                     key: (id) key		// data or string
                    initializationVector: (id) iv		// data or string
                                 options: (CCOptions) options
                                   error: (CCCryptorStatus *) error;

- (NSData *) decryptedDataUsingAlgorithm: (CCAlgorithm) algorithm
                                     key: (id) key		// data or string
                                      iv: (id) iv        // data or string
                                   error: (CCCryptorStatus *) error;
- (NSData *) decryptedDataUsingAlgorithm: (CCAlgorithm) algorithm
                                     key: (id) key		// data or string
                                      iv: (id) iv        // data or string
                                 options: (CCOptions) options
                                   error: (CCCryptorStatus *) error;
- (NSData *) decryptedDataUsingAlgorithm: (CCAlgorithm) algorithm
                                     key: (id) key		// data or string
                    initializationVector: (id) iv		// data or string
                                 options: (CCOptions) options
                                   error: (CCCryptorStatus *) error;

@end

@interface NSData (CommonHMAC)

- (NSData *) HMACWithAlgorithm: (CCHmacAlgorithm) algorithm;
- (NSData *) HMACWithAlgorithm: (CCHmacAlgorithm) algorithm key: (id) key;

@end
