//
//  BOFFileSystemManagerTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 12/09/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOASDKManifestController.h"
#import <BlotoutFoundation/BOFFileSystemManager.h>
#import <BlotoutFoundation/BOFConstants.h>
#import "BOAUtilities.h"

@interface BOFFileSystemManagerTests : XCTestCase
@property (nonatomic) BOASDKManifestController *objBOASDKManifestController;
@end

@implementation BOFFileSystemManagerTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.objBOASDKManifestController = [BOASDKManifestController sharedInstance];
    
    NSError *manifestReadError = nil;
    BOASDKManifest *sdkManifestM = [BOASDKManifest fromJSON:[self manifestJsonString] encoding: NSUTF8StringEncoding error:&manifestReadError];
    self.objBOASDKManifestController.sdkManifestModel = sdkManifestM;
    [self.objBOASDKManifestController sdkManifestPathAfterWriting: [self manifestJsonString]];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testIsFileExistAtPath {
    NSString *sdkManifestFilePath = [self.objBOASDKManifestController latestSDKManifestPath];
    BOOL status = [BOFFileSystemManager isFileExistAtPath: sdkManifestFilePath];
    XCTAssertTrue(status, @"File doesn't exist at given path");
}

//- (void)testIsFirstLaunchBOSDKFileSystemCheck {
//    BOOL status = [BOFFileSystemManager isFirstLaunchBOSDKFileSystemCheck];
//    XCTAssertTrue(status, @"First launch BOSDK file system check failed");
//}

- (void)testSetFirstLaunchBOSDKFileSystemCheckToFalse {
    [BOFFileSystemManager setFirstLaunchBOSDKFileSystemCheckToFalse];
    NSString *sdkRootDir = [BOFFileSystemManager getBOSDKRootDirecoty];
    NSString *childDir = [BOFFileSystemManager getChildDirectory:kBOSDKLaunchTestDirectoryName byCreatingInParent: sdkRootDir];
    XCTAssertNotNil(childDir, @"Set first launch BOSDK file system check to false failed");
}

- (void)testIsAppFirstLaunchFileSystemChecks {
    BOOL status = [BOFFileSystemManager isAppFirstLaunchFileSystemChecks];
    XCTAssertTrue(!status, @"App first launch file system checks failed");
}

- (void)testGetCreationDateOfItemAtPath {
    NSString *path = [self.objBOASDKManifestController latestSDKManifestPath];
    NSDate *creationDate = [BOFFileSystemManager getCreationDateOfItemAtPath: path];
    XCTAssertNotNil(creationDate, @"Get creation date of item at path failed");
}

- (void)testGetDocumentDirectoryPath {
    NSString *dirPath = [BOFFileSystemManager getDocumentDirectoryPath];
    XCTAssertNotNil(dirPath, @"Couldn't find directory path");
}

- (void)testGetApplicationSupportDirectoryPath {
    NSString *supportDirPath = [BOFFileSystemManager getApplicationSupportDirectoryPath];
    XCTAssertNotNil(supportDirPath, @"Couldn't find application support directory path");
}

- (void)testGetApplicationCacheDirectoryPath {
    NSString *cacheDirPath = [BOFFileSystemManager getApplicationCacheDirectoryPath];
    XCTAssertNotNil(cacheDirPath, @"Couldn't find application Cache directory path");
}

- (void)testgetApplicationDownloadsDirectoryPath {
    NSString *downloadDirPath = [BOFFileSystemManager getApplicationDownloadsDirectoryPath];
    XCTAssertNotNil(downloadDirPath, @"Couldn't find application download directory path");
}

- (void)testGetBOSDKRootDirecoty {
    NSString *rootDir = [BOFFileSystemManager getBOSDKRootDirecoty];
    XCTAssertNotNil(rootDir, @"Couldn't find BOSDK root directory");
}

- (void)testGetBOFNetworkDownloadsDirectoryPath {
    NSString *downloadDir = [BOFFileSystemManager getBOFNetworkDownloadsDirectoryPath];
    XCTAssertNotNil(downloadDir, @"Couldn't find download directory path");
}

- (void)testGetBOSDKVolatileRootDirectoryPath {
    NSString *volatileRootDir = [BOFFileSystemManager getBOSDKVolatileRootDirectoryPath];
    XCTAssertNotNil(volatileRootDir, @"Couldn't find volatile root directory path");
}

- (void)testGetBOSDKNonVolatileRootDirectoryPath {
    NSString *nonVolatileRootDir = [BOFFileSystemManager getBOSDKNonVolatileRootDirectoryPath];
    XCTAssertNotNil(nonVolatileRootDir, @"Couldn't find non volatile root directory path");
}

- (void)testGetAllFilesWithExtention {
    NSString *sdkManifestDir = [BOFFileSystemManager getSDKManifestDirectoryPath];
    NSArray *manifestLogFiles = [BOFFileSystemManager getAllFilesWithExtention:@"txt" fromDir: sdkManifestDir];
    XCTAssertNotNil(manifestLogFiles, @"Couldn't find files with given extenstion");
}

- (void)testGetAllDirsInside {
    NSArray *allDir = [BOFFileSystemManager getAllDirsInside: [BOFFileSystemManager getBOSDKRootDirecoty]];
    XCTAssertNotNil(allDir, @"Couldn't find dir inside given path");
}

- (void)testRemoveFileFromLocationPath {
    NSError *junkFileRemove;
    NSString *sdkManifestDir = [BOFFileSystemManager getSDKManifestDirectoryPath];
    BOOL status = [BOFFileSystemManager removeFileFromLocationPath: sdkManifestDir removalError:&junkFileRemove];
    XCTAssertTrue(status, @"Couldn't remove file from given location");
    
    status = [BOFFileSystemManager removeFileFromLocation:[NSURL URLWithString:sdkManifestDir] removalError:&junkFileRemove];
    XCTAssertTrue(status, @"Couldn't remove file from given location");
    
    status = [BOFFileSystemManager removeRecurrsiveEmptyDirFromLocationPath:sdkManifestDir removalError:&junkFileRemove];
    XCTAssertFalse(status, @"Couldn't remove file from given location");
}


- (void)testMoveFileFromLocationPath {
    NSError *fileRelocationError = nil;
    NSString *sdkManifestDir = [BOFFileSystemManager getSDKManifestDirectoryPath];
    NSString *sdkFunnelDir = [BOFFileSystemManager getActiveFunnelsDirectoryPath];
    
    BOOL status = [BOFFileSystemManager moveFileFromLocationPath: sdkManifestDir   toLocationPath: sdkFunnelDir  relocationError:&fileRelocationError];
    XCTAssertFalse(status, @"Couldn't move file from given location path");
    
    status = [BOFFileSystemManager moveFileFromLocation:[NSURL URLWithString:sdkManifestDir] toLocation:[NSURL URLWithString:sdkFunnelDir] relocationError:&fileRelocationError];
    XCTAssertFalse(status, @"Couldn't move file from given location path");
}


- (void)testDeleteFilesRecursively {
    NSError *removeError = nil;
    BOOL status = [BOFFileSystemManager deleteFilesRecursively:YES olderThanDays:[NSNumber numberWithFloat:180.0] underRootDirPath:[BOFFileSystemManager getBOSDKRootDirecoty] removalError:&removeError];
    XCTAssertTrue(status, @"Couldn't delete files recursively");
    
    status = [BOFFileSystemManager deleteFilesRecursively:YES olderThan:[NSDate now] underRootDirPath:[BOFFileSystemManager getBOSDKRootDirecoty] removalError:&removeError];
    XCTAssertTrue(status, @"Couldn't delete files recursively");
    
    status = [BOFFileSystemManager deleteFilesAndDirectoryRecursively:YES olderThan:[NSDate date] underRootDirPath:[BOFFileSystemManager getBOSDKRootDirecoty] removalError:&removeError];
    XCTAssertTrue(status, @"Couldn't delete files recursively");
    
    status = [BOFFileSystemManager deleteFilesAndDirectoryRecursively:YES olderThanDays:[NSNumber numberWithFloat:180.0] underRootDirPath:[BOFFileSystemManager getBOSDKRootDirecoty] removalError:&removeError];
    XCTAssertTrue(status, @"Couldn't delete files recursively");
}

- (void)testCopyFileFromLocationPath {
    NSError *fileRelocationError = nil;
    NSString *sdkManifestDir = [BOFFileSystemManager getSDKManifestDirectoryPath];
    NSString *sdkFunnelDir = [BOFFileSystemManager getActiveFunnelsDirectoryPath];
    
    BOOL status = [BOFFileSystemManager copyFileFromLocation:[NSURL URLWithString:sdkManifestDir] toLocation:[NSURL URLWithString:sdkFunnelDir] relocationError:&fileRelocationError];
    XCTAssertFalse(status, @"Couldn't copy file from given location path");
}

- (void)testSearchFilePathForFileName {
    BOOL status = [BOFFileSystemManager searchFilePathForFileName:@"local" ofType:@"txt"];
    XCTAssertFalse(status, @"Couldn't move file from given location path");
    
    NSString *sdkManifestDir = [BOFFileSystemManager getSDKManifestDirectoryPath];
    status = [BOFFileSystemManager searchFilePathForFileName:@"local" ofType:@"txt" inDirectory:sdkManifestDir];
    XCTAssertFalse(status, @"Couldn't move file from given location path");
}

- (void)testPathAfterWritingString {
    NSError *error = nil;
    NSString *sdkManifestDir = [BOFFileSystemManager getSDKManifestDirectoryPath];
    NSString *path = [BOFFileSystemManager pathAfterWritingString: [self manifestJsonString] toFilePath: sdkManifestDir writingError:&error];
    XCTAssertNotNil(path, @"Couldn't write data at given path");
    
    NSURL *pathUrl = [BOFFileSystemManager pathAfterWritingString:[self manifestJsonString] toFileUrl:[NSURL URLWithString:sdkManifestDir] writingError:&error];
    XCTAssertNil(pathUrl, @"Couldn't find path");
    
}

- (void)testContentOfFileAtPath {
    NSError *error = nil;
    NSString *sdkManifestDir = [BOFFileSystemManager getSDKManifestDirectoryPath];
    NSString *sdkManifestStr = [BOFFileSystemManager contentOfFileAtPath: sdkManifestDir withEncoding:NSUTF8StringEncoding andError:&error];
    XCTAssertNotNil(sdkManifestStr, @"Couldn't read content of file at given path");
    
    NSStringEncoding encoding;
    sdkManifestStr = [BOFFileSystemManager contentOfFileAtURL:[NSURL URLWithString:sdkManifestDir] usedEncoding:&encoding  andError:&error];
    XCTAssertNil(sdkManifestStr, @"Couldn't read content of file at given path");
    
    NSArray *content = [BOFFileSystemManager contentOfDirectoryAtPath:sdkManifestDir];
    XCTAssertNotNil(content, @"Couldn't find content of dir at path");
    XCTAssertGreaterThan([content count], 0);
    
}

- (void)testGetSyncPendingSessionFunnelMetaInfoDirectoryPathForDate {
    NSString *dateString = [NSString stringWithFormat:@"%@",[BOAUtilities convertDate:[BOAUtilities getCurrentDate] inFormat:@"yyyy-MM-dd"]];
    NSString *metaInfoDatePath = [BOFFileSystemManager getSyncPendingSessionFunnelMetaInfoDirectoryPathForDate:dateString];
    XCTAssertNotNil(metaInfoDatePath, @"Couldn't funnel sync meta data");
}

- (void)testGetSessionBasedSegmentsEventsSyncCompleteDirectoryPath {
    NSString *segmentsSyncCompleteDirPath = [BOFFileSystemManager getSessionBasedSegmentsEventsSyncCompleteDirectoryPath];
    XCTAssertNotNil(segmentsSyncCompleteDirPath, @"Couldn't find session based segment events");
}

- (void)testGetSessionBasedSegmentsEventsSyncPendingDirectoryPath {
    NSString *segmentsSyncPendingDirPath = [BOFFileSystemManager getSessionBasedSegmentsEventsSyncPendingDirectoryPath];
    XCTAssertNotNil(segmentsSyncPendingDirPath, @"Couldn't find session sync pending dir path");
}

- (void)testGetLogLevelDirAllSegmentsToAnalyseDirectoryPath {
    NSString *segmentDownloadLogsDir = [BOFFileSystemManager getLogLevelDirAllSegmentsToAnalyseDirectoryPath];
    XCTAssertNotNil(segmentDownloadLogsDir, @"Couldn't find segment to analyse dir path");
}

- (void)testGetLogLevelDirAllFunnelsToAnalyseDirectoryPath {
    NSString *funnelDownloadLogsDir = [BOFFileSystemManager getLogLevelDirAllFunnelsToAnalyseDirectoryPath];
    XCTAssertNotNil(funnelDownloadLogsDir, @"Couldn't find funnel download logs dir");
}

- (void)testGetDailyAggregatedFunnelEventsSyncPendingDirectoryPath {
    NSString *dailyAggregatedPendingDir = [BOFFileSystemManager getDailyAggregatedFunnelEventsSyncPendingDirectoryPath];
    XCTAssertNotNil(dailyAggregatedPendingDir, @"Couldn't find daily aggregated pending dir");
}

- (void)testGetDailyAggregatedFunnelEventsSyncCompleteDirectoryPath {
    NSString *dailyAggregatedCompleteDir = [BOFFileSystemManager getDailyAggregatedFunnelEventsSyncCompleteDirectoryPath];
    XCTAssertNotNil(dailyAggregatedCompleteDir, @"Couldn't find daily aggregated complete dir");
}

- (void)testGetAllSegmentsToAnalyseDirectoryPath {
    NSString *allSegmentsDirPath = [BOFFileSystemManager getAllSegmentsToAnalyseDirectoryPath];
    XCTAssertNotNil(allSegmentsDirPath, @"Couldn't find all segments dir path");
}

- (void)testGetAllFunnelsToAnalyseDirectoryPath {
    NSString *allFunnelsDirPath = [BOFFileSystemManager getAllFunnelsToAnalyseDirectoryPath];
    XCTAssertNotNil(allFunnelsDirPath, @"Couldn't find all funnel dir path");
}

- (void)testGetSyncedFilesLifeTimeEventsDirectoryPath {
    NSString *syncedPathLifeTime = [BOFFileSystemManager getSyncedFilesLifeTimeEventsDirectoryPath];
    XCTAssertNotNil(syncedPathLifeTime, @"Couldn't find synced path life time");
}

- (void)testGetNotSyncedFilesLifeTimeEventsDirectoryPath {
    NSString *notSyncedPathLifeTime = [BOFFileSystemManager getNotSyncedFilesLifeTimeEventsDirectoryPath];
    XCTAssertNotNil(notSyncedPathLifeTime, @"Couldn't find not-synced path life time");
}

- (void)testGetSyncedFilesSessionTimeEventsDirectoryPath {
    NSString *syncedPathSessionTime = [BOFFileSystemManager getSyncedFilesSessionTimeEventsDirectoryPath];
    XCTAssertNotNil(syncedPathSessionTime, @"Couldn't find synced path session time events dir path");
}

- (void)testGetNotSyncedFilesSessionTimeEventsDirectoryPath {
    NSString *notSyncedPathSessionTime = [BOFFileSystemManager getNotSyncedFilesSessionTimeEventsDirectoryPath];
    XCTAssertNotNil(notSyncedPathSessionTime, @"Couldn't find not-synced path session time events dir path");
}

- (void)testGetFunnelRootDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getFunnelRootDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find funnel root dir path");
}

- (void)testGetEventsRootDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getEventsRootDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find event root dir path");
}

- (void)testGetSegmentsRootDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getSegmentsRootDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find segment root dir path");
}

- (void)testGetCampaignsRootDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getCampaignsRootDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find Campaigns root dir path");
}

- (void)testGetNetworkDownloadsFunnelDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getNetworkDownloadsFunnelDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find downloads funnel dir path");
}

- (void)testGetArchivedFunnelsDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getArchivedFunnelsDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find archived funnel dir path");
}

- (void)testGetNetworkDownloadsSegmentsDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getNetworkDownloadsSegmentsDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find network download segment dir path");
}

- (void)testGetArchivedSegmentsDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getArchivedSegmentsDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find archived segment dir path");
}

- (void)testGetLifeTimeDataEventsDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getLifeTimeDataEventsDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find life cycle data event dir path");
}

- (void)testGetSessionDataEventsDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getSessionDataEventsDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find sessino data event dir path");
}

- (void)testGetExpiredFunnelsDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getExpiredFunnelsDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find expired funnel dir path");
}

- (void)testGetInActiveFunnelsDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getInActiveFunnelsDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find in-active funnel dir path");
}

- (void)testGetActiveSegmentsDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getActiveSegmentsDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find active segment dir path");
}

- (void)testGetExpiredSegmentsDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getExpiredSegmentsDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find expired segment dir path");
}

- (void)testGetInActiveSegmentsDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getInActiveSegmentsDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find in-active segment dir path");
}

- (void)testGetServerSyncCompleteFunnelEventsDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getServerSyncCompleteFunnelEventsDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find server sync complete funnel event dir path");
}

- (void)testGetServerSyncPendingFunnelEventsDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getServerSyncPendingFunnelEventsDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find server sync complete funnel events dir path");
}

- (void)testGetServerSyncCompleteSegmentsEventsDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getServerSyncCompleteSegmentsEventsDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find server sync complete segment events dir path");
}

- (void)testGetServerSyncPendingSegmentsEventsDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getServerSyncPendingSegmentsEventsDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find server sync pending segment events dir path");
}

- (void)testGetSessionBasedFunnelEventsSyncPendingDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getSessionBasedFunnelEventsSyncPendingDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find session basedfunnel events sync pending dir path");
}

- (void)testGetSessionBasedFunnelEventsSyncCompleteDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getSessionBasedFunnelEventsSyncCompleteDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find session based funnel sync complete events dir path");
}

- (void)testGetDailyAggregatedSegmentsEventsSyncPendingDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getDailyAggregatedSegmentsEventsSyncPendingDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find daily aggregate segments event sync pending dir path");
}

- (void)testGetDailyAggregatedSegmentsEventsSyncCompleteDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getDailyAggregatedSegmentsEventsSyncCompleteDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find daily aggregate segments event sync complete dir path");
}

- (void)testGetSyncPendingSessionFunnelInfoDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getSyncPendingSessionFunnelInfoDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find sync pending session funnel info dir path");
}

- (void)testGetSyncCompleteSessionFunnelMetaInfoDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getSyncCompleteSessionFunnelMetaInfoDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find sync complete session funnel meta info dir path");
}

- (void)testGetSyncCompleteSessionFunnelInfoDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getSyncCompleteSessionFunnelInfoDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find sync complete session funnel info dir path");
}

- (void)testGetSyncPendingSessionSegmentsMetaInfoDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getSyncPendingSessionSegmentsMetaInfoDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find sync pending session segment meta info dir path");
}

- (void)testGetSyncPendingSessionSegmentsInfoDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getSyncPendingSessionSegmentsInfoDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find sync pending session segments info dir path");
}

- (void)testGetSyncCompleteSessionSegmentsMetaInfoDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getSyncCompleteSessionSegmentsMetaInfoDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find sync complete session segments meta info dir path");
}

- (void)testGetSyncCompleteSessionSegmentsInfoDirectoryPath {
    NSString *pathStr = [BOFFileSystemManager getSyncCompleteSessionSegmentsInfoDirectoryPath];
    XCTAssertNotNil(pathStr, @"Couldn't find sync complete session segments info dir path");
}

- (void)testGetSyncPendingSessionFunnelInfoDirectoryPathForFunnelID {
    NSString *pathStr = [BOFFileSystemManager getSyncPendingSessionFunnelInfoDirectoryPathForFunnelID:@""];
    XCTAssertNotNil(pathStr, @"Couldn't find sync pending session funnel info dir path for funnleIdd");
}

- (void)testgetSyncCompleteSessionFunnelMetaInfoDirectoryPathForDate {
    NSString *dateString = [NSString stringWithFormat:@"%@",[BOAUtilities convertDate:[BOAUtilities getCurrentDate] inFormat:@"yyyy-MM-dd"]];
    NSString *pathStr = [BOFFileSystemManager getSyncCompleteSessionFunnelMetaInfoDirectoryPathForDate: dateString];
    XCTAssertNotNil(pathStr, @"Couldn't find sync complete session funnel meta info dir path for date");
}

- (void)testgetSyncCompleteSessionFunnelInfoDirectoryPathForFunnelID {
    NSString *pathStr = [BOFFileSystemManager getSyncCompleteSessionFunnelInfoDirectoryPathForFunnelID: @""];
    XCTAssertNotNil(pathStr, @"Couldn't find sync complete session funnel info dir path for funnelId");
}

- (void)testGetSyncPendingSessionSegmentsMetaInfoDirectoryPathForDate {
    NSString *dateString = [NSString stringWithFormat:@"%@",[BOAUtilities convertDate:[BOAUtilities getCurrentDate] inFormat:@"yyyy-MM-dd"]];
    NSString *pathStr = [BOFFileSystemManager getSyncPendingSessionSegmentsMetaInfoDirectoryPathForDate: dateString];
    XCTAssertNotNil(pathStr, @"Couldn't find sync pending session segments meta info dir path for date");
}

- (void)testGetSyncPendingSessionSegmentsInfoDirectoryPathForSegmentID {
    NSString *pathStr = [BOFFileSystemManager getSyncPendingSessionSegmentsInfoDirectoryPathForSegmentID: @""];
    XCTAssertNotNil(pathStr, @"Couldn't find sync pending session segment info dir path for segmentId");
}

- (void)testgetSyncCompleteSessionSegmentsMetaInfoDirectoryPathForDate {
    NSString *dateString = [NSString stringWithFormat:@"%@",[BOAUtilities convertDate:[BOAUtilities getCurrentDate] inFormat:@"yyyy-MM-dd"]];
    NSString *pathStr = [BOFFileSystemManager getSyncCompleteSessionSegmentsMetaInfoDirectoryPathForDate: dateString];
    XCTAssertNotNil(pathStr, @"Couldn't find sync complete session segments meta info dir path for date");
}

- (void)testgetSyncCompleteSessionSegmentsInfoDirectoryPathForSegmentID {
    NSString *pathStr = [BOFFileSystemManager getSyncCompleteSessionSegmentsInfoDirectoryPathForSegmentID: @""];
    XCTAssertNotNil(pathStr, @"Couldn't find sync complete session segment info dir path for segmentId");
}

- (void)testGetSyncPendingSessionFunnelInfoDirectoryPathForDate {
    NSString *dateString = [NSString stringWithFormat:@"%@",[BOAUtilities convertDate:[BOAUtilities getCurrentDate] inFormat:@"yyyy-MM-dd"]];
    NSString *pathStr = [BOFFileSystemManager getSyncPendingSessionFunnelInfoDirectoryPathForDate: dateString andFunnelID: @""];
    XCTAssertNotNil(pathStr, @"Couldn't find sync pending session funnel info dir path for date");
}

- (void)testGetSyncCompleteSessionFunnelInfoDirectoryPathForDate {
    NSString *dateString = [NSString stringWithFormat:@"%@",[BOAUtilities convertDate:[BOAUtilities getCurrentDate] inFormat:@"yyyy-MM-dd"]];
    NSString *pathStr = [BOFFileSystemManager getSyncCompleteSessionFunnelInfoDirectoryPathForDate:dateString andFunnelID: @""];
    XCTAssertNotNil(pathStr, @"Couldn't find sync complete session funnel info dir path for date");
}

- (void)testGetSyncPendingSessionSegmentsInfoDirectoryPathForDate {
    NSString *dateString = [NSString stringWithFormat:@"%@",[BOAUtilities convertDate:[BOAUtilities getCurrentDate] inFormat:@"yyyy-MM-dd"]];
    NSString *pathStr = [BOFFileSystemManager getSyncPendingSessionSegmentsInfoDirectoryPathForDate:dateString andSegmentID: @""];
    XCTAssertNotNil(pathStr, @"Couldn't find sync pending session segments info dir path for date");
}

- (void)testGetSyncCompleteSessionSegmentsInfoDirectoryPathForDate {
    NSString *dateString = [NSString stringWithFormat:@"%@",[BOAUtilities convertDate:[BOAUtilities getCurrentDate] inFormat:@"yyyy-MM-dd"]];
    NSString *pathStr = [BOFFileSystemManager getSyncCompleteSessionSegmentsInfoDirectoryPathForDate: dateString andSegmentID: @""];
    XCTAssertNotNil(pathStr, @"Couldn't find sync complete session segments info dir path for date");
}

- (void)testCleanDirectory {
    NSError *cleanDirError = nil;
    NSString *sdkManifestFilePath = [self.objBOASDKManifestController latestSDKManifestPath];
    [BOFFileSystemManager cleanDirectory: sdkManifestFilePath error:&cleanDirError];
    XCTAssertTrue([self.objBOASDKManifestController latestSDKManifestPath] != nil, @"Couldn't clean the given dir");
}

- (void)testDelateDirectory {
    NSError *cleanDirError = nil;
    NSString *sdkManifestFilePath = [self.objBOASDKManifestController latestSDKManifestPath];
    [BOFFileSystemManager delateDirectory: sdkManifestFilePath error:&cleanDirError];
    XCTAssertTrue([self.objBOASDKManifestController latestSDKManifestPath] != nil, @"Couldn't delete the given dir");
}

- (void)testMigrateIfExistsOldFile {
    NSString *path = [self.objBOASDKManifestController latestSDKManifestPath];
    BOOL status = [BOFFileSystemManager migrateIfExistsOldFile: path toNewFilePath: path];
    XCTAssertTrue(status, @"Couldn't migrate the given dir");
}

- (void)testGetBundleId {
    NSString *bundleId = [BOFFileSystemManager bundleId];
    XCTAssertNotNil(bundleId, @"Couldn't find bundle id");
    XCTAssertGreaterThan([bundleId length], 0);
}

- (void)testIsDirectoryExistAtPath {
    NSString *path = [self.objBOASDKManifestController latestSDKManifestPath];
    BOOL status = [BOFFileSystemManager isDirectoryExistAtPath:path];
    XCTAssertFalse(status, @"Couldn't find dir at path");
    
    status = [BOFFileSystemManager isDirectoryExistAtURL:[NSURL URLWithString:path]];
    XCTAssertFalse(status, @"Couldn't find dir at path");
}

- (void)testIsFileExist {
    NSString *path = [self.objBOASDKManifestController latestSDKManifestPath];
    BOOL status = [BOFFileSystemManager isFileExistAtURL:[NSURL URLWithString:path]];
    XCTAssertFalse(status, @"Couldn't find dir at path");
}

- (void)testGetAttributesOfItemAtPath {
    NSString *path = [self.objBOASDKManifestController latestSDKManifestPath];
    NSDictionary *atttributes = [BOFFileSystemManager getAttributesOfItemAtPath:path];
    XCTAssertNotNil(atttributes, @"Couldn't find attributes at path");
}

- (void)testGetDownloadSize {
    NSString *path = [self.objBOASDKManifestController latestSDKManifestPath];
    
    NSString *str = @"BlotoutAnalytics";
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSNumber *size = [BOFFileSystemManager getDownloadSize:[NSURL URLWithString:path] data:data];
    XCTAssertNotNil(size, @"Couldn't find attributes at path");
}

- (void)testSortFilesInFolderByCreationDate {
    NSString *path = [self.objBOASDKManifestController latestSDKManifestPath];
    NSArray *result = [BOFFileSystemManager sortFilesInFolderByCreationDate: path];
    XCTAssertNil(result, @"Couldn't find attributes at path");
}

- (void)testIsDirectoryAtPath {
    NSString *path = [self.objBOASDKManifestController latestSDKManifestPath];
    BOOL status = [BOFFileSystemManager isDirectoryAtPath:path];
    XCTAssertFalse(status, @"Couldn't find attributes at path");
}

- (void)testAddSkipBackupAttributeToFilePath {
    NSString *path = [self.objBOASDKManifestController latestSDKManifestPath];
    BOOL status = [BOFFileSystemManager addSkipBackupAttributeToFilePath:path];
    XCTAssertTrue(status, @"Couldn't find attributes at path");
}

- (void)testPathAfterWritingStringWithAppend {
    NSError *error = nil;
    NSString *sdkManifestDir = [BOFFileSystemManager getSDKManifestDirectoryPath];
    NSString *path = [BOFFileSystemManager pathAfterWritingString:[self manifestJsonString] toFilePath:sdkManifestDir appendIfExist:YES writingError:&error];
    XCTAssertNotNil(path, @"Couldn't write data at given path");
    
    NSURL *url = [BOFFileSystemManager pathAfterWritingString:[self manifestJsonString] toFileUrl:[NSURL URLWithString:sdkManifestDir] writingError:&error];
    XCTAssertNil(url, @"Couldn't write data at given path");
}





//+(NSArray *)sortFilesInFolderByCreationDate:(NSString *)folder

/*
 - (void)testContentOfFileAtUrl {
 NSError *error = nil;
 NSString *sdkManifestDir = [BOFFileSystemManager getSDKManifestDirectoryPath];
 NSURL *url = [NSURL URLWithString:sdkManifestDir];
 NSString *sdkManifestStr = [BOFFileSystemManager contentOfFileAtURL: url withEncoding:NSUTF8StringEncoding andError:&error];
 XCTAssertNotNil(sdkManifestStr, @"Couldn't find content of file at given url path");
 }
 
 - (void)testPathAfterWritingData {
 NSError *error = nil;
 NSString *jsonStr = [self manifestJsonString];
 NSData* jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
 NSString *filePath  = [BOFFileSystemManager getSDKManifestDirectoryPath];
 NSURL *path = [BOFFileSystemManager pathAfterWritingData: jsonData toFileUrl:[NSURL URLWithString:filePath] writingError:&error];
 XCTAssertNotNil(path, @"Couldn't find content of file at given url path");
 
 }
 */

- (NSString *)manifestJsonString {
    return @"{\"variables\":[{\"variableId\":5006,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Event_Codified_Mergecounter\",\"isEditable\":true},{\"variableId\":5007,\"value\":\"90\",\"variableDataType\":1,\"variableName\":\"Event_Offline_Interval\",\"isEditable\":true},{\"variableId\":5021,\"value\":\"v1/segment/pull\",\"variableDataType\":6,\"variableName\":\"Segment_Path\",\"isEditable\":true},{\"variableId\":5009,\"value\":\"https://sdk.blotout.io/sdk\",\"variableDataType\":6,\"variableName\":\"Api_Endpoint\",\"isEditable\":true},{\"variableId\":5022,\"value\":\"v1/segment/custom/feedback\",\"variableDataType\":6,\"variableName\":\"Segment_Feedback_Path\",\"isEditable\":true},{\"variableId\":5010,\"value\":\"30\",\"variableDataType\":1,\"variableName\":\"License_Expire_Day_Alive\",\"isEditable\":true},{\"variableId\":5011,\"value\":\"24\",\"variableDataType\":1,\"variableName\":\"Manifest_Refresh_Interval\",\"isEditable\":true},{\"variableId\":5999,\"value\":\"1593882555290\",\"variableDataType\":6,\"variableName\":\"Last_Updated_Time\",\"isEditable\":true},{\"variableId\":5003,\"value\":\"2\",\"variableDataType\":1,\"variableName\":\"Event_Geolocation_Grain\",\"isEditable\":true},{\"variableId\":5018,\"value\":\"v1/funnel/pull\",\"variableDataType\":6,\"variableName\":\"Event_Funnel_Path\",\"isEditable\":true},{\"variableId\":5019,\"value\":\"v1/funnel/feedback\",\"variableDataType\":6,\"variableName\":\"Event_Funnel_Feedback_Path\",\"isEditable\":true},{\"variableId\":5005,\"value\":\"-1\",\"variableDataType\":1,\"variableName\":\"Event_System_Mergecounter\",\"isEditable\":true},{\"variableId\":5013,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Retry_Interval\",\"isEditable\":true},{\"variableId\":5001,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Event_Push_Interval\",\"isEditable\":true},{\"variableId\":5014,\"value\":\"0\",\"variableDataType\":1,\"variableName\":\"Mode_Deployment\",\"isEditable\":true},{\"variableId\":5002,\"value\":\"15\",\"variableDataType\":1,\"variableName\":\"Event_Push_Eventscounter\",\"isEditable\":true},{\"variableId\":5015,\"value\":\"0\",\"variableDataType\":1,\"variableName\":\"Customer_Type\",\"isEditable\":true},{\"variableId\":5016,\"value\":\"v1/events/publish\",\"variableDataType\":6,\"variableName\":\"Event_Path\",\"isEditable\":true},{\"variableId\":5017,\"value\":\"v1/events/retention/publish\",\"variableDataType\":6,\"variableName\":\"Event_Retention_Path\",\"isEditable\":true}, {\"variableId\":5004,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Event_Deviceinfo_Grain\",\"isEditable\":true}, {\"variableId\":5012,\"value\":\"180\",\"variableDataType\":1,\"variableName\":\"Store_Events_Interval\",\"isEditable\":true}, {\"variableId\":5020,\"value\":\"v1/geo/city\",\"variableDataType\":6,\"variableName\":\"Geo_Ip_Path\",\"isEditable\":true}]}";
    
}

@end
