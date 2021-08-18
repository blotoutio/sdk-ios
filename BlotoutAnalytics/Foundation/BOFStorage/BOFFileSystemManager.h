//
//  BOFFileSystemManager.h
//  BlotoutAnalytics
//
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

+(BOOL)addSkipBackupAttributeToFilePath:(NSString *)filePath;
+(BOOL)isFileExistAtPath:(NSString*)filePath;

+(NSString*)getDocumentDirectoryPath;
+(NSString*)getApplicationSupportDirectoryPath;
+(NSString*)getBOSDKRootDirectory;

+(NSString*)getChildDirectory:(NSString*)childDirName byCreatingInParent:(NSString*)parentPath;

+(BOOL)moveFileFromLocation:(NSURL*)fileLocation toLocation:(NSURL*)newLocation relocationError:(NSError**)relocationError;
+(BOOL)moveFileFromLocationPath:(NSString*)fileLocation toLocationPath:(NSString*)newLocation relocationError:(NSError**)relocationError;
+(BOOL)removeFileFromLocation:(NSURL*)fileLocation removalError:(NSError**)removalError;
+(BOOL)removeFileFromLocationPath:(NSString*)fileLocationPath removalError:(NSError**)removalError;

+(NSString *)bundleId;

//In case of append use NSUTF8StringEncoding if Unknown also use path method until URL is required
+(NSString*)pathAfterWritingString:(NSString*)contentString toFilePath:(NSString*)filePath appendIfExist:(BOOL)shouldAppend writingError:(NSError**)error;
+(NSString*)pathAfterWritingString:(NSString*)contentString toFilePath:(NSString*)filePath writingError:(NSError**)error;
+(NSURL*)pathAfterWritingString:(NSString*)contentString toFileUrl:(NSURL*)fileUrl writingError:(NSError**)error;

+(NSString*)contentOfFileAtPath:(NSString*)filePath withEncoding:(NSStringEncoding)encoding andError:(NSError**)err;

+(NSString*)getSDKManifestDirectoryPath;
@end

NS_ASSUME_NONNULL_END
