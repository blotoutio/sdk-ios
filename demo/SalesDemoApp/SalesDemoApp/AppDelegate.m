//
//  AppDelegate.m
//  SalesDemoApp
//
//  Created by ankuradhikari on 22/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "AppDelegate.h"
#import <BlotoutAnalytics/BlotoutAnalytics.h>
#import <CommonCrypto/CommonDigest.h>
#import <BlotoutAnalytics/BlotoutAnalyticsConfiguration.h>
@interface AppDelegate ()

@end

@implementation AppDelegate

-(NSString*)md5HashOfString:(NSString*)strToHash{
    @try {
        // Create pointer to the string as UTF8
        const char *ptr = [strToHash UTF8String];
        // Create byte array of unsigned chars
        unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
        // Create 16 byte MD5 hash value, store in buffer
        CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
        // Convert MD5 value in the buffer to NSString of hex values
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
        return output;
    } @catch (NSException *exception) {
        NSLog(@"%@:%@", @"BOA_DEBUG", exception);
    }
    return  nil;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSLog(@"MD5 for 'User Login': %@ & 'UserLogin': %@", [self md5HashOfString:@"User Login"], [self md5HashOfString:@"UserLogin"]);
    BlotoutAnalytics *boaObj = [BlotoutAnalytics sharedInstance];
    //    2F34NE39RTAEAJJ ankur prod
    //    43SZ962GZ5R33WR ashish prod
    //43SZ962GZ5R33WR
    //5DNGP7DR2KD9JSY
    
    //    NSString *publicKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCtfDKGDkF6Da5wvyA53G9naA3POeSrKSsi/AIAISLhKDCBXzXe7MQsoW7IAEqFuDh2578BdzuVFDO/b5q8af4u+GSBIarGM75/biUIV6PcrteywsbgOVsrs5NYgHRoojG283V/f2+aRDN0p30YrlI0msT4epnNbkczIFCoXqK2YQIDAQAB";
    //
    //    NSString *privateKey = @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAK18MoYOQXoNrnC/IDncb2doDc855KspKyL8AgAhIuEoMIFfNd7sxCyhbsgASoW4OHbnvwF3O5UUM79vmrxp/i74ZIEhqsYzvn9uJQhXo9yu17LCxuA5Wyuzk1iAdGiiMbbzdX9/b5pEM3SnfRiuUjSaxPh6mc1uRzMgUKheorZhAgMBAAECgYAIupqKLzZxLzYLOzqiXqqGT/B98EJGsGwYtwhcvE4WeSCzqbg6rrwSKM87pfQZ9VJ1/SQZrUeksR8Hb1SgTU76NZz4rY1vsURM7IMMx5Es2HV+lV33mehxg1gJ7h4ZcU+OOaj5NV6kHN0xvWanC1xgnDKMzuhKuqGI9SQ6oLmhJwJBAPNXWynDLWKoNRYBtjZiQ0BGUjmrD8K9pyyQkuzVJx2SnwkoiAb+St96dOeK7gKTwDbTp3W5gIdu5BNTZGRqXY8CQQC2goxJ9J7bQfvezBNkX/YUDvKdo5mB/DztDrTLohW9N5qOtxp0/+Mroyz262qt9m5yD0hxmHpS7jvSjgh5XZUPAkB2V4V+Se1IjYVDrpFu4VrTZ1+VrBt+Gb2zbpwFkaP0PdoaGhwNSp4fEO7JrEcT+ccA4u4N0qkvND63J1crfo8BAkARapfUnuFh7wQIGNVo6Ldk5qBEZs5JVzbBMHwUSp1kdx/qqpJ9w8V77pBl58VAYJndjJPPM0vJCi7vQtqQKlwFAkEAxH8wdx/CEXyF+qQULEJcqGusT3Or4d5Orjrmsco6TnxnIdzeT/xkR7kB48VWj0fQZyVBjcrIOztRxjvZmEPMMw==";
    //
    //    NSString *convertedString = @"qRfnNUws3/3uBsZ+jNkS1CzEIN3v3gHMuZM/DmNmJ+BsoZoipZjZ0empOZALP0jdnl65VZ8h4A3iYGjhvBHVi2y+NOiuNYDO0hhWQmu6oEZEbzU0jUpQqkDQtqyNApUpgJfXbjhw+a1HDvOUftWtB0qyQK409P/Hp08llkObbLc=";
    //
    //    NSString *encryptedSTring = [BOEncryptionManager encryptString:@"hello world" publicKey:publicKey];
    //
    //    if([encryptedSTring isEqualToString:convertedString]) {
    //        NSLog(@"data sync in iOS and android");
    //    }
    //
    //    NSString *decryptString = [BOEncryptionManager decryptString:encryptedSTring privateKey:privateKey];
    
    //Test inProductionMode Yes/No and InDev mode also
    NSLog(@"start = %f", [[NSDate date] timeIntervalSince1970]);
    BlotoutAnalyticsConfiguration *config = [BlotoutAnalyticsConfiguration configurationWithToken:@"B6PSYZ355NS383V" withUrl:@"https://stage.blotout.io/sdk"];
    config.application = application;
    [boaObj init:config andCompletionHandler:^(BOOL isSuccess, NSError * _Nullable error) {
        NSLog(@"end %f", [[NSDate date] timeIntervalSince1970]);
        NSLog(@"BlotoutAnalytics Init %d:or Error: %@", isSuccess, error);
        [boaObj capture:@"AppLaunched2" withInformation:launchOptions];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:@"test@blotout.io" forKey:@"emailid"];
        //[boaObj logEvent:@"test" withInformation:dict];
        [boaObj capturePersonal:@"PII Event" withInformation:dict isPHI:NO];
        // [boaObj logPHIEvent:@"PHI Event" withInformation:@{@"covid":@"negative"} happendAt:nil];
    }];
    
    //    [boaObj initializeAnalyticsEngineUsingTest:@"V2KGWP3M89YUJB6" andProduction:@"V2KGWP3M89YUJB6" inProductionMode:false withCompletionHandler:^(BOOL isSuccess, NSError * _Nullable error) {
    //
    //        NSLog(@"BlotoutAnalytics SDK version%@ and Init %d:or Error: %@", [boaObj sdkVersion], isSuccess, error);
    //
    //        [boaObj logEvent:@"AppLaunched2" withInformation:launchOptions];
    //        [boaObj logPIIEvent:@"PII Event" withInformation:@{@"emailid":@"ankuradhikari08@gmail.com"} happendAt:nil];
    //        [boaObj logPHIEvent:@"PHI Event" withInformation:@{@"covid":@"negative"} happendAt:nil];
    //
    //        //Custom Crash Test
    //        //NSException *ex = [NSException exceptionWithName:@"test" reason:@"tested 1 Re" userInfo:@{@"key":@"value"}];
    //        //[ex raise];
    //
    //        //Unknown selector crash Test
    //        //[boaObj performSelector:@selector(CrashTest_InitializeAnalyticsEngine)];
    //    }];
    [boaObj capture:@"AppLaunched1" withInformation:launchOptions];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
