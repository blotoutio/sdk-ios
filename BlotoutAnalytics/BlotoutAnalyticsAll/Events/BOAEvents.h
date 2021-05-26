//
//  BOAEvents.h
//  BlotoutAnalytics
//
//  Created by Blotout on 25/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// nil → NSNull conversion for JSON dictionaries
static _Nullable id NSNullifyCheck(id _Nullable x) {
    return (x == nil || x == NSNull.null) ? NSNull.null : x;
}
static _Nullable id NSNullifyDictCheck(id _Nullable x) {
    if ([x isKindOfClass:[NSDictionary class]] || [x isKindOfClass:[NSMutableDictionary class]]) {
        return (x == nil || x == NSNull.null || (((NSDictionary *)x).allKeys.count <= 0)) ? NSNull.null : x;
    }
    return NSNull.null;
}
NS_ASSUME_NONNULL_BEGIN

@class BOAppSessionData, BOAAppLifetimeData;
@interface BOAEvents : NSObject

@property (class, nonatomic, readonly) BOAppSessionData *appSessionModel;
@property (class, nonatomic, readonly) BOAAppLifetimeData *appLifeTimeModel;

@property (class, nonatomic, readonly)  BOOL isSessionModelInitialised;
@property (class, nonatomic, readonly)  BOOL isAppLifeModelInitialised;

-(UIViewController *)topViewController;

+(NSString*)getSessionDirectoryPath;
+(NSString*)getSyncedDirectoryPath;
+(NSString*)getNotSyncedDirectoryPath;
+(NSString*)getLifeTimeDirectoryPath;
+(NSString*)getLifeTimeDataSyncedDirectoryPath;
+(NSString*)getLifeTimeDataNotSyncedDirectoryPath;


+(void)storePreviousDayAppInfoViaNotification:(nullable NSDictionary*)appSessionObject;
+(void)syncWithServerForFile:(NSString*)filePath;
+(void)syncWithServerAllFilesWithExtention:(NSString*)extention InDirectory:(NSString*)directoryPath;
+(void)syncRecursiveWithServerForSession:(BOAppSessionData*)sessionObject;
+(void)syncWithServerAfterDelay:(NSTimeInterval)milliSeconds forSession:(BOAppSessionData*)sessionObject;
+(void)syncRecursiveWithServerForLifeTimeSession:(BOAAppLifetimeData*)lifeTimeSessionObject;
+(void)syncWithServerForLifeTimeSessionAfterDelay:(NSTimeInterval)milliSeconds forSession:(BOAAppLifetimeData*)lifeTimeSessionObject;
+(void)initSuccessForAppDailySession:(void (^)(BOOL isSuccess, NSError * _Nullable error))completionHandler;
+(void)initSuccessForAppLifeSession:(void (^)(BOOL isSuccess, NSError * _Nullable error))completionHandler;
+(void)dayChangeNotification:(NSNotification*)notification;
+(void)fetchManifestAndSetup:(BOOL)shouldFetch;
+(void)performSDKInitFunctionalityAsOnRelaunch;
+(void)initDefaultConfigurationWithHandler:(void (^)(BOOL isSuccess, NSError * _Nullable error))completionHandler;
+(void)setAppLifeTimeModel:(BOAAppLifetimeData *)newAppLifeTimeModel;
+(BOAAppLifetimeData*)appLifeTimeModel;
+(void)setAppSessionModel:(BOAppSessionData *)newAppSessionModel;
+(BOAppSessionData*)appSessionModel;
+(void)setIsSessionModelInitialised:(BOOL)isSessionModelInitialised;
+(BOOL)isSessionModelInitialised;
+(void)setIsAppLifeModelInitialised:(BOOL)isAppLifeModelInitialised;
+(BOOL)isAppLifeModelInitialised;
//void recordUncaughtExceptionHandler(NSException *exception);






@end

NS_ASSUME_NONNULL_END
