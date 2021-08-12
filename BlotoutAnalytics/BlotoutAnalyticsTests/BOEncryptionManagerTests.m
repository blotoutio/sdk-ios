//
//  BOEncryptionManagerTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 23/11/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

@import XCTest;
#import "BOEncryptionManager.h"
#import "BOAUtilities.h"

@interface BOEncryptionManagerTests : XCTestCase

@end

NSString *message;
NSString *secretKey;
NSString *encodedStrWithPubKey;
NSData *encodedDataWithPubKey;
NSString *encodedStrWithPriKey;
NSData *encodedDataWithPriKey;

@implementation BOEncryptionManagerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    secretKey = [BOAUtilities getUUIDString];
    secretKey = [secretKey stringByReplacingOccurrencesOfString:@"-" withString:@""];
    message = [NSString stringWithFormat:@"This is blotout private message"];
    
    encodedStrWithPubKey = [[NSString alloc] init];
    encodedDataWithPubKey = [[NSData alloc] init];
    encodedStrWithPriKey = [[NSString alloc] init];
    encodedDataWithPriKey = [[NSData alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

//TODO: Need to discuss with ankur getting nil and "" after enctryption applied
- (void)testEncryptMethods {
    NSString *encodedStrWithPubKey = [BOEncryptionManager encryptString: message publicKey: secretKey];
    XCTAssertNotNil(encodedStrWithPubKey);
    
    NSData *encodedDataWithPubKey = [BOEncryptionManager encryptData:[message dataUsingEncoding:NSUTF8StringEncoding] publicKey:secretKey];
    XCTAssertNil(encodedDataWithPubKey);
    
    NSString *encodedStrWithPriKey = [BOEncryptionManager encryptString: message privateKey: secretKey];
    XCTAssertNotNil(encodedStrWithPriKey);
    
    NSData *encodedDataWithPriKey = [BOEncryptionManager encryptData:[message dataUsingEncoding:NSUTF8StringEncoding] privateKey:secretKey];
    XCTAssertNil(encodedDataWithPriKey);
}

- (void)testDecryptMethods {
    NSString *decodedStrPubKey = [BOEncryptionManager decryptString: encodedStrWithPubKey publicKey: secretKey];
    XCTAssertNotNil(decodedStrPubKey);
    
    NSData *decodedDataPubKey = [BOEncryptionManager decryptData:encodedDataWithPubKey publicKey:secretKey];
    XCTAssertNil(decodedDataPubKey);
    
    NSString *decodedStrPriKey = [BOEncryptionManager encryptString: encodedStrWithPriKey privateKey: secretKey];
    XCTAssertNotNil(decodedStrPriKey);
    
    NSData *decodedDataPriKey = [BOEncryptionManager encryptData:encodedDataWithPriKey privateKey:secretKey];
    XCTAssertNil(decodedDataPriKey);
}

@end


