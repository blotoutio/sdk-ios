//
//  BOFFileSystemManager.h
//  BlotoutFoundation
//
//  Created by Blotout on 27/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

/**
 * The BOFFileSystemManager is class to save and fetch SDK's data
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BOFFileSystemManager : NSObject

+(void)setIsDataWriteEnabled:(BOOL)isDataWriteEnabled;
+(void)setIsSDKEnabled:(BOOL)isSDKEnabled;
+(void)setNeverDeleteSDKData:(BOOL)neverDeleteSDKData; // not using for now but if needed then check before delete in all direcotry or file delete methods

+(BOOL)addSkipBackupAttributeToFilePath:(NSString *)filePath;
+(NSArray *)sortFilesInFolderByCreationDate:(NSString *)folder;
+(BOOL)isFileExistAtPath:(NSString*)filePath;
+(BOOL)isFileExistAtURL:(NSURL*)fileURL;
+(BOOL)isDirectoryExistAtPath:(NSString*)dirPath;
+(BOOL)isDirectoryExistAtURL:(NSURL*)fileURL;

+(BOOL)isFirstLaunchBOSDKFileSystemCheck;
+(void)setFirstLaunchBOSDKFileSystemCheckToFalse;
+(BOOL)isAppFirstLaunchFileSystemChecks;

+(NSDate*)getCreationDateOfItemAtPath:(NSString*)itemPath;
+(NSDate*)getModificationDateOfItemAtPath:(NSString*)itemPath;
+(NSDictionary*)getAttributesOfItemAtPath:(NSString*)itemPath;

+(NSString*)getDocumentDirectoryPath;
+(NSString*)getApplicationSupportDirectoryPath;
+(NSString*)getApplicationCacheDirectoryPath;
+(NSString*)getApplicationDownloadsDirectoryPath;
+(NSArray*)contentOfDirectoryAtPath:(NSString*)directoryPath;

+(NSString*)getBOSDKRootDirecoty;
+(NSString*)getBOFNetworkDownloadsDirectoryPath;
+(NSString*)getBOSDKVolatileRootDirectoryPath;
+(NSString*)getBOSDKNonVolatileRootDirectoryPath;

+(NSString*)getChildDirectory:(NSString*)childDirName byCreatingInParent:(NSString*)parentPath;
+(NSArray*)getAllFilesWithExtention:(NSString*)extention fromDir:(NSString*)filesDir;
+(NSArray*)getAllDirsInside:(NSString*)filesDir;
+(NSArray*)getAllContentInside:(NSString*)filesDir;

+(NSNumber*)getDownloadSize:(NSURL*)location data:(NSData*)data;
+(BOOL)copyFileFromLocation:(NSURL*)fileLocation toLocation:(NSURL*)newLocation
            relocationError:(NSError**)relocationError;
+(BOOL)moveFileFromLocation:(NSURL*)fileLocation toLocation:(NSURL*)newLocation relocationError:(NSError**)relocationError;
+(BOOL)moveFileFromLocationPath:(NSString*)fileLocation toLocationPath:(NSString*)newLocation relocationError:(NSError**)relocationError;
+(BOOL)removeFileFromLocation:(NSURL*)fileLocation removalError:(NSError**)removalError;
+(BOOL)removeFileFromLocationPath:(NSString*)fileLocationPath removalError:(NSError**)removalError;
+(BOOL)removeRecurrsiveEmptyDirFromLocationPath:(NSString*)dirLocationPath removalError:(NSError**)removalError;

+ (NSString *)bundleId;
+(BOOL)isDirectoryAtPath:(NSString*)path;


+(BOOL)deleteFilesRecursively:(BOOL)isRecursively olderThanDays:(NSNumber*)days underRootDirPath:(NSString*)dirPath removalError:(NSError**)removalError;
+(BOOL)deleteFilesRecursively:(BOOL)isRecursively olderThan:(NSDate*)dateTime underRootDirPath:(NSString*)dirPath removalError:(NSError**)removalError;
+(BOOL)deleteFilesAndDirectoryRecursively:(BOOL)isRecursively olderThanDays:(NSNumber*)days underRootDirPath:(NSString*)dirPath removalError:(NSError**)removalError;
+(BOOL)deleteFilesAndDirectoryRecursively:(BOOL)isRecursively olderThan:(NSDate*)dateTime underRootDirPath:(NSString*)dirPath removalError:(NSError**)removalError;

//Below 4 methods Will be implemented when required
//+(BOOL)copyFileFromLocation:(NSURL*)fileLocation toLocation:(NSURL*)newLocation mergeIfExist:(BOOL)doMerge relocationError:(NSError**)relocationError;
//+(BOOL)moveFileFromLocation:(NSURL*)fileLocation toLocation:(NSURL*)newLocation mergeIfExist:(BOOL)doMerge relocationError:(NSError**)relocationError;
//+(BOOL)copyFileFromLocation:(NSURL*)fileLocation toLocation:(NSURL*)newLocation replaceIfExist:(BOOL)doReplace relocationError:(NSError**)relocationError;
//+(BOOL)moveFileFromLocation:(NSURL*)fileLocation toLocation:(NSURL*)newLocation replaceIfExist:(BOOL)doReplace relocationError:(NSError**)relocationError;

//In case of append use NSUTF8StringEncoding if Unknown also use path method until URL is required
+(NSString*)pathAfterWritingString:(NSString*)contentString toFilePath:(NSString*)filePath appendIfExist:(BOOL)shouldAppend writingError:(NSError**)error;
+(NSString*)pathAfterWritingString:(NSString*)contentString toFilePath:(NSString*)filePath writingError:(NSError**)error;
+(NSURL*)pathAfterWritingString:(NSString*)contentString toFileUrl:(NSURL*)fileUrl writingError:(NSError**)error;

//In case of append use NSUTF8StringEncoding if Unknown also use path method until URL is required
+(NSString*)pathAfterWritingData:(NSData*)contentData toFilePath:(NSString*)filePath appendIfExist:(BOOL)shouldAppend writingError:(NSError**)error;
+(NSString*)pathAfterWritingData:(NSData*)contentData toFilePath:(NSString*)filePath writingError:(NSError**)error;
+(NSURL*)pathAfterWritingData:(NSData*)contentData toFileUrl:(NSURL*)fileUrl writingError:(NSError**)error;

//TODO: test by creating files in different folders under different directory and also in difference bundles
+(NSString*)searchFilePathForFileName:(NSString*)fileName ofType:(NSString*)fileType;
+(NSString*)searchFilePathForFileName:(NSString*)fileName ofType:(NSString*)fileType inDirectory:(NSString*)directoryName;

+(NSString*)contentOfFileAtPath:(NSString*)filePath usedEncoding:(NSStringEncoding*)encoding andError:(NSError**)err;
+(NSString*)contentOfFileAtURL:(NSURL*)fileURL usedEncoding:(NSStringEncoding*)encoding andError:(NSError**)err;
+(NSString*)contentOfFileAtPath:(NSString*)filePath withEncoding:(NSStringEncoding)encoding andError:(NSError**)err;
+(NSString*)contentOfFileAtURL:(NSURL*)fileURL withEncoding:(NSStringEncoding)encoding andError:(NSError**)err;

#pragma mark Directory cleaning
+(void)cleanDirectory:(NSString*)directoryPath error:(NSError**)error;
+(void)delateDirectory:(NSString*)directoryPath error:(NSError**)error;
+(BOOL)migrateIfExistsOldFile:(NSString *)oldFilePath toNewFilePath:(NSString *)newFile;


//BOSDK related dir structure
//BOSDK related dir structure
//===========================================Level 1================================================
//Level 1 Dir
//Funnel Root
+(NSString*)getFunnelRootDirectoryPath;
//Events Root
+(NSString*)getEventsRootDirectoryPath;
//Segments Root
+(NSString*)getSegmentsRootDirectoryPath;
//Campaigns Root
+(NSString*)getCampaignsRootDirectoryPath;

//===========================================Level 2================================================
//Level 2 Dir
//Funnel Network Downloads
+(NSString*)getNetworkDownloadsFunnelDirectoryPath;
//Funnel ArchivedFunnels
+(NSString*)getArchivedFunnelsDirectoryPath;

//Level 2 Dir
//Funnel Network Downloads
+(NSString*)getNetworkDownloadsSegmentsDirectoryPath;
//Funnel ArchivedFunnels
+(NSString*)getArchivedSegmentsDirectoryPath;

//Events LifeTime Data
+(NSString*)getLifeTimeDataEventsDirectoryPath;
//Events Session Data
+(NSString*)getSessionDataEventsDirectoryPath;
//Events Session Data
+(NSString*)getSDKManifestDirectoryPath;

//===========================================Level 3================================================
//Level 3 Dir
//Funnel Active Funnels
+(NSString*)getActiveFunnelsDirectoryPath;
//Funnel Expired Funnels
+(NSString*)getExpiredFunnelsDirectoryPath;
//Funnel InActive Funnels
+(NSString*)getInActiveFunnelsDirectoryPath;

//Level 3 Dir
//Segments Active Funnels
+(NSString*)getActiveSegmentsDirectoryPath;
//Funnel Expired Funnels
+(NSString*)getExpiredSegmentsDirectoryPath;
//Funnel InActive Funnels
+(NSString*)getInActiveSegmentsDirectoryPath;

//SyncedFilesEvents LifeTime Data
+(NSString*)getSyncedFilesLifeTimeEventsDirectoryPath;
//NotSyncedFilesEvents LifeTime Data
+(NSString*)getNotSyncedFilesLifeTimeEventsDirectoryPath;
//SyncedFilesEvents Session Data
+(NSString*)getSyncedFilesSessionTimeEventsDirectoryPath;
//NotSyncedFilesEvents Session Data
+(NSString*)getNotSyncedFilesSessionTimeEventsDirectoryPath;

//===========================================Level 4================================================
//Level 4 Dir
//Funnel All Funnels to Analyse
+(NSString*)getAllFunnelsToAnalyseDirectoryPath;
//Funnel Server Sync Completed Funnels to Analyse
+(NSString*)getServerSyncCompleteFunnelEventsDirectoryPath;
//Funnel Server Sync Pending Funnels to Analyse
+(NSString*)getServerSyncPendingFunnelEventsDirectoryPath;

//Level 4 Dir
//Segments All Segments to Analyse
+(NSString*)getAllSegmentsToAnalyseDirectoryPath;
//Funnel Server Sync Completed Funnels to Analyse
+(NSString*)getServerSyncCompleteSegmentsEventsDirectoryPath;
//Funnel Server Sync Pending Funnels to Analyse
+(NSString*)getServerSyncPendingSegmentsEventsDirectoryPath;

//===========================================Level 5================================================
//Level 5 Dir
//Funnel Log Level Files
+(NSString*)getLogLevelDirAllFunnelsToAnalyseDirectoryPath;
//Funnel Session Based Funnel Events Sync Pending Files
+(NSString*)getSessionBasedFunnelEventsSyncPendingDirectoryPath;
//Funnel Daily Aggregated Funnel Events Sync Pending Files
+(NSString*)getDailyAggregatedFunnelEventsSyncPendingDirectoryPath;
//Funnel Session Based Funnel Events Sync Complete Files
+(NSString*)getSessionBasedFunnelEventsSyncCompleteDirectoryPath;
//Funnel Daily Aggregated Funnel Events Sync Pending Files
+(NSString*)getDailyAggregatedFunnelEventsSyncCompleteDirectoryPath;


//Level 5 Dir
//Segments Log Level Files
+(NSString*)getLogLevelDirAllSegmentsToAnalyseDirectoryPath;
//Funnel Session Based Funnel Events Sync Pending Files
+(NSString*)getSessionBasedSegmentsEventsSyncPendingDirectoryPath;
//Funnel Daily Aggregated Funnel Events Sync Pending Files
+(NSString*)getDailyAggregatedSegmentsEventsSyncPendingDirectoryPath;
//Funnel Session Based Funnel Events Sync Complete Files
+(NSString*)getSessionBasedSegmentsEventsSyncCompleteDirectoryPath;
//Funnel Daily Aggregated Funnel Events Sync Pending Files
+(NSString*)getDailyAggregatedSegmentsEventsSyncCompleteDirectoryPath;

//===========================================Level 6================================================

+(NSString*)getSyncPendingSessionFunnelMetaInfoDirectoryPath;
+(NSString*)getSyncPendingSessionFunnelInfoDirectoryPath;
+(NSString*)getSyncCompleteSessionFunnelMetaInfoDirectoryPath;
+(NSString*)getSyncCompleteSessionFunnelInfoDirectoryPath;

+(NSString*)getSyncPendingSessionSegmentsMetaInfoDirectoryPath;
+(NSString*)getSyncPendingSessionSegmentsInfoDirectoryPath;
+(NSString*)getSyncCompleteSessionSegmentsMetaInfoDirectoryPath;
+(NSString*)getSyncCompleteSessionSegmentsInfoDirectoryPath;

//===========================================Level 7================================================
+(NSString*)getSyncPendingSessionFunnelMetaInfoDirectoryPathForDate:(NSString*)dateString;
+(NSString*)getSyncPendingSessionFunnelInfoDirectoryPathForFunnelID:(NSString*)funnelID;
+(NSString*)getSyncCompleteSessionFunnelMetaInfoDirectoryPathForDate:(NSString*)dateString;
+(NSString*)getSyncCompleteSessionFunnelInfoDirectoryPathForFunnelID:(NSString*)funnelID;

+(NSString*)getSyncPendingSessionSegmentsMetaInfoDirectoryPathForDate:(NSString*)dateString;
+(NSString*)getSyncPendingSessionSegmentsInfoDirectoryPathForSegmentID:(NSString*)segmentID;
+(NSString*)getSyncCompleteSessionSegmentsMetaInfoDirectoryPathForDate:(NSString*)dateString;
+(NSString*)getSyncCompleteSessionSegmentsInfoDirectoryPathForSegmentID:(NSString*)segmentID;

//===========================================Level 8================================================
+(NSString*)getSyncPendingSessionFunnelInfoDirectoryPathForDate:(NSString*)dateString andFunnelID:(NSString*)funnelID;
+(NSString*)getSyncCompleteSessionFunnelInfoDirectoryPathForDate:(NSString*)dateString andFunnelID:(NSString*)funnelID;

+(NSString*)getSyncPendingSessionSegmentsInfoDirectoryPathForDate:(NSString*)dateString andSegmentID:(NSString*)segmentID;
+(NSString*)getSyncCompleteSessionSegmentsInfoDirectoryPathForDate:(NSString*)dateString andSegmentID:(NSString*)segmentID;
//===========================================Level 9================================================
@end

NS_ASSUME_NONNULL_END
