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

+(NSDate*)getCreationDateOfItemAtPath:(NSString*)itemPath;
+(NSDate*)getModificationDateOfItemAtPath:(NSString*)itemPath;
+(NSDictionary*)getAttributesOfItemAtPath:(NSString*)itemPath;

+(NSString*)getDocumentDirectoryPath;
+(NSString*)getApplicationSupportDirectoryPath;
+(NSString*)getApplicationCacheDirectoryPath;
+(NSString*)getApplicationDownloadsDirectoryPath;
+(NSArray*)contentOfDirectoryAtPath:(NSString*)directoryPath;

+(NSString*)getBOSDKRootDirectory;
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

+(NSString*)getSDKManifestDirectoryPath;
@end

NS_ASSUME_NONNULL_END
