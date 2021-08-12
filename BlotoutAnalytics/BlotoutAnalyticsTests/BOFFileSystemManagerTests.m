//
//  BOFFileSystemManagerTests.m
//  BlotoutAnalyticsTests
//
//  Created by Pawan Singh Jat on 12/09/20.
//  Copyright © 2020 Blotout. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BOASDKManifestController.h"

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
    NSString *rootDir = [BOFFileSystemManager getBOSDKRootDirectory];
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
    NSArray *allDir = [BOFFileSystemManager getAllDirsInside: [BOFFileSystemManager getBOSDKRootDirectory]];
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

- (void)testDeleteFilesRecursively {
    NSError *removeError = nil;
    BOOL status = [BOFFileSystemManager deleteFilesRecursively:YES olderThanDays:[NSNumber numberWithFloat:180.0] underRootDirPath:[BOFFileSystemManager getBOSDKRootDirectory] removalError:&removeError];
    XCTAssertTrue(status, @"Couldn't delete files recursively");
    
    status = [BOFFileSystemManager deleteFilesRecursively:YES olderThan:[NSDate now] underRootDirPath:[BOFFileSystemManager getBOSDKRootDirectory] removalError:&removeError];
    XCTAssertTrue(status, @"Couldn't delete files recursively");
    
    status = [BOFFileSystemManager deleteFilesAndDirectoryRecursively:YES olderThan:[NSDate date] underRootDirPath:[BOFFileSystemManager getBOSDKRootDirectory] removalError:&removeError];
    XCTAssertTrue(status, @"Couldn't delete files recursively");
    
    status = [BOFFileSystemManager deleteFilesAndDirectoryRecursively:YES olderThanDays:[NSNumber numberWithFloat:180.0] underRootDirPath:[BOFFileSystemManager getBOSDKRootDirectory] removalError:&removeError];
    XCTAssertTrue(status, @"Couldn't delete files recursively");
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

- (NSString *)manifestJsonString {
    return @"{\"variables\":[{\"variableId\":5006,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Event_Codified_Mergecounter\",\"isEditable\":true},{\"variableId\":5007,\"value\":\"90\",\"variableDataType\":1,\"variableName\":\"Event_Offline_Interval\",\"isEditable\":true},{\"variableId\":5021,\"value\":\"v1/segment/pull\",\"variableDataType\":6,\"variableName\":\"Segment_Path\",\"isEditable\":true},{\"variableId\":5009,\"value\":\"https://sdk.blotout.io/sdk\",\"variableDataType\":6,\"variableName\":\"Api_Endpoint\",\"isEditable\":true},{\"variableId\":5022,\"value\":\"v1/segment/custom/feedback\",\"variableDataType\":6,\"variableName\":\"Segment_Feedback_Path\",\"isEditable\":true},{\"variableId\":5010,\"value\":\"30\",\"variableDataType\":1,\"variableName\":\"License_Expire_Day_Alive\",\"isEditable\":true},{\"variableId\":5011,\"value\":\"24\",\"variableDataType\":1,\"variableName\":\"Manifest_Refresh_Interval\",\"isEditable\":true},{\"variableId\":5999,\"value\":\"1593882555290\",\"variableDataType\":6,\"variableName\":\"Last_Updated_Time\",\"isEditable\":true},{\"variableId\":5003,\"value\":\"2\",\"variableDataType\":1,\"variableName\":\"Event_Geolocation_Grain\",\"isEditable\":true},{\"variableId\":5018,\"value\":\"v1/funnel/pull\",\"variableDataType\":6,\"variableName\":\"Event_Funnel_Path\",\"isEditable\":true},{\"variableId\":5019,\"value\":\"v1/funnel/feedback\",\"variableDataType\":6,\"variableName\":\"Event_Funnel_Feedback_Path\",\"isEditable\":true},{\"variableId\":5005,\"value\":\"-1\",\"variableDataType\":1,\"variableName\":\"Event_System_Mergecounter\",\"isEditable\":true},{\"variableId\":5013,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Retry_Interval\",\"isEditable\":true},{\"variableId\":5001,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Event_Push_Interval\",\"isEditable\":true},{\"variableId\":5014,\"value\":\"0\",\"variableDataType\":1,\"variableName\":\"Mode_Deployment\",\"isEditable\":true},{\"variableId\":5002,\"value\":\"15\",\"variableDataType\":1,\"variableName\":\"Event_Push_Eventscounter\",\"isEditable\":true},{\"variableId\":5015,\"value\":\"0\",\"variableDataType\":1,\"variableName\":\"Customer_Type\",\"isEditable\":true},{\"variableId\":5016,\"value\":\"v1/events/publish\",\"variableDataType\":6,\"variableName\":\"Event_Path\",\"isEditable\":true},{\"variableId\":5017,\"value\":\"v1/events/retention/publish\",\"variableDataType\":6,\"variableName\":\"Event_Retention_Path\",\"isEditable\":true}, {\"variableId\":5004,\"value\":\"1\",\"variableDataType\":1,\"variableName\":\"Event_Deviceinfo_Grain\",\"isEditable\":true}, {\"variableId\":5012,\"value\":\"180\",\"variableDataType\":1,\"variableName\":\"Store_Events_Interval\",\"isEditable\":true}, {\"variableId\":5020,\"value\":\"v1/geo/city\",\"variableDataType\":6,\"variableName\":\"Geo_Ip_Path\",\"isEditable\":true}]}";
    
}

@end
