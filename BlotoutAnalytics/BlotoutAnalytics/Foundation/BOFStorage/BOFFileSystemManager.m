//
//  BOFFileSystemManager.m
//  BlotoutAnalytics
//
//  Copyright © 2019 Blotout. All rights reserved.
//

/**
 * The BOFFileSystemManager is class to save and fetch SDK's data
 */

#import "BOFFileSystemManager.h"
#include <sys/xattr.h>
#include "BOFConstants.h"
#import "BOFUtilities.h"
#import "BOFLogs.h"
#import "BOCrypt.h"
@import UIKit;

static BOOL sIsDataWriteEnabled = YES;
static BOOL sIsSDKEnabled = YES;

@implementation BOFFileSystemManager

//iOS 5.0.1 method //https://developer.apple.com/library/ios/qa/qa1719/_index.html
+(BOOL)addSkipBackupAttributeToFilePath:(NSString *)filePath {
  @try {
    if (!filePath) {
      return 0;
    }
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    int result = setxattr([filePath cStringUsingEncoding: NSUTF8StringEncoding], attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return NO;
}

//iOS 5.1 & Above method //https://developer.apple.com/library/ios/qa/qa1719/_index.html
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
  BOOL success = NO;
  
  @try {
    if ([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]) {
      NSError *error = nil;
      success = [URL setResourceValue:[NSNumber numberWithBool: YES]
                               forKey: NSURLIsExcludedFromBackupKey error: &error];
      if (!success) {
        BOFLogDebug(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
      }
    }
  } @catch (NSException *exception) {
    //Exception will allow backup to iCloud, so either change URL or make alternative
    BOFLogDebug(@"Error excluding %@ from backup %@", [URL lastPathComponent], exception.userInfo);
  }
  return success;
}

+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path {
  @try {
    if (path) {
      return [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:path]];
    }
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return NO;
}

/**
 * method to set data write permission, by default its true and sdk doesn't write data only if its value is false
 * @param isDataWriteEnabled as BOOL
 */
+(void)setIsDataWriteEnabled:(BOOL)isDataWriteEnabled{
  sIsDataWriteEnabled = isDataWriteEnabled;
}

/**
 * method to make sdk enable, by default its true
 * @param isSDKEnabled as BOOL
 */
+(void)setIsSDKEnabled:(BOOL)isSDKEnabled{
  sIsSDKEnabled = isSDKEnabled;
}

/**
 * method to remove file from location path in file system
 * @param fileLocationPath as NSString
 * @param removalError as NSError
 * @return success as BOOL
 */
+(BOOL)removeFileFromLocationPath:(NSString*)fileLocationPath removalError:(NSError**)removalError {
  @try {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *deleteError = nil;
    BOOL success = [fileManager removeItemAtPath:fileLocationPath error:&deleteError];
    if (removalError) {
      *removalError = deleteError;
    }
    return success;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return NO;
}

/**
 * method to remove file from location in file system
 * @param fileLocation as NSString
 * @param removalError as NSError
 * @return success as BOOL
 */
+(BOOL)removeFileFromLocation:(NSURL*)fileLocation removalError:(NSError**)removalError {
  @try {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *deleteError = nil;
    BOOL success = [fileManager removeItemAtURL:fileLocation error:&deleteError];
    *removalError = deleteError;
    return success;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return NO;
}

/**
 * method to move file from one location to another location in file system
 * @param fileLocation as NSURL
 * @param newLocation as NSURL
 * @param relocationError as NSError
 * @return success as BOOL
 */
+(BOOL)moveFileFromLocation:(NSURL*)fileLocation toLocation:(NSURL*)newLocation relocationError:(NSError**)relocationError {
  @try {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = NO;
    BOOL isDir = NO;
    BOOL isNewDir = NO;
    
    NSError *moveError = nil;
    
    NSString *filePath = [fileLocation path];
    NSString *newFilePath = [newLocation path];
    
    BOOL existAndDic = ([fileManager fileExistsAtPath:filePath isDirectory:&isDir] && isDir);
    BOOL newExistAndDic = ([fileManager fileExistsAtPath:newFilePath isDirectory:&isNewDir] && isNewDir);
    if (!existAndDic && newExistAndDic) {
      NSString* fileName = [fileLocation lastPathComponent];
      newFilePath = [newFilePath stringByAppendingPathComponent:fileName];
      success = [fileManager moveItemAtURL:fileLocation toURL:[NSURL fileURLWithPath:newFilePath] error:&moveError];
    } else {
      success = [fileManager moveItemAtURL:fileLocation toURL:[NSURL fileURLWithPath:newFilePath] error:&moveError];
    }
    *relocationError = moveError;
    return success;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return NO;
}

/**
 * method to move file from one location path to another location path in file system
 * @param fileLocation as NSString
 * @param newLocation as NSString
 * @param relocationError as NSError
 * @return success as BOOL
 */
+(BOOL)moveFileFromLocationPath:(NSString*)fileLocation toLocationPath:(NSString*)newLocation relocationError:(NSError**)relocationError {
  @try {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = NO;
    BOOL isDir = NO;
    BOOL isNewDir = NO;
    
    NSError *moveError = nil;
    NSString *filePath = fileLocation;
    NSString *newFilePath = newLocation;
    
    BOOL existAndDic = ([fileManager fileExistsAtPath:filePath isDirectory:&isDir] && isDir);
    BOOL newExistAndDic = ([fileManager fileExistsAtPath:newFilePath isDirectory:&isNewDir] && isNewDir);
    if (!existAndDic && newExistAndDic) {
      NSString* fileName = [fileLocation lastPathComponent];
      newFilePath = [newFilePath stringByAppendingPathComponent:fileName];
      success = [fileManager moveItemAtPath:fileLocation toPath:newFilePath error:&moveError];
    } else {
      success = [fileManager moveItemAtPath:fileLocation toPath:newLocation error:&moveError];
    }
    *relocationError = moveError;
    return success;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return NO;
}

+(BOOL)moveFileFromLocation:(NSURL*)fileLocation toLocation:(NSURL*)newLocation mergeIfExist:(BOOL)doMerge relocationError:(NSError**)relocationError {
  return NO;
}

+(BOOL)moveFileFromLocation:(NSURL*)fileLocation toLocation:(NSURL*)newLocation replaceIfExist:(BOOL)doReplace relocationError:(NSError**)relocationError {
  return NO;
}

/**
 * method to check is writable dir at path exists in file system
 * @param path as NSString
 * @return isDir as BOOL
 */
+(BOOL)isWritableDirectoryAtPath:(NSString*)path {
  @try {
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir) {
      isDir = [[NSFileManager defaultManager] isWritableFileAtPath:path];
    }
    return isDir;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return NO;
}

/**
 * method to check is writable file path exists in file system
 * @param path as NSString
 * @return isDir as BOOL
 */
+(BOOL)isWritableFileAtPath:(NSString*)path {
  @try {
    BOOL isWritableFile = NO;
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && !isDir) {
      isWritableFile = [[NSFileManager defaultManager] isWritableFileAtPath:path];
    } else if (!isDir) {
      isWritableFile = [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    }
    return isWritableFile;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return NO;
}

/**
 * method to check and return writable file path exists in file system
 * @param givenPath as id
 * @return writableFilePath as NSString
 */
+(NSString*)checkAndReturnWritableFilePath:(id)givenPath {
  @try {
    NSString* filePath = nil;
    if ([givenPath isKindOfClass:[NSURL class]]) {
      filePath = [(NSURL*)givenPath path];
    } else if ([givenPath isKindOfClass:[NSString class]]) {
      filePath = givenPath;
    }
    
    if (!filePath) {
      @throw [NSException exceptionWithName:@"BOFFilePathException" reason:@"Path must be String or URL" userInfo:@{@"Description":@"Path provided is not appropiate, must be either String or URL"}];
    }
    
    NSString* writableFilePath = filePath;
    if ([self isWritableDirectoryAtPath:filePath]) {
      writableFilePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"BOFFile%ui",arc4random()]];
    } else if (![self isWritableFileAtPath:filePath]) {
      @throw [NSException exceptionWithName:@"BOFFileWritingException" reason:@"Directory is not writable" userInfo:@{@"Description":@"Directory or file path is not writable, use with writable file path"}];
    }
        
    return writableFilePath;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return nil;
}

/**
 * method to get path after writing string to file path with should append policy
 * @param contentString as NSString
 * @param filePath as NSString
 * @param shouldAppend as BOOL
 * @param error as NSError
 * @return writableFilePath as NSString
 */
+(NSString*)pathAfterWritingString:(NSString*)contentString toFilePath:(NSString*)filePath appendIfExist:(BOOL)shouldAppend writingError:(NSError**)error {
  @try {
    if (sIsDataWriteEnabled && sIsSDKEnabled) {
      NSString* writableFilePath = [self checkAndReturnWritableFilePath:filePath];
      
      NSMutableString *completeString = [contentString mutableCopy];
      NSError *writeError = nil;
      if (shouldAppend) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:writableFilePath] error:&writeError];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[contentString dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
      } else {
        BOOL success = [completeString writeToFile:writableFilePath atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
        
        if (!success) {
          writableFilePath = nil;
        }
      }
      *error = writeError;
      return writableFilePath;
    } else {
      NSError *writeError = [NSError errorWithDomain:@"io.blotout.FileSystem" code:90001 userInfo:@{@"info":@"data write for blotout SDK not allowed"}];
      *error = writeError;
      return nil;
    }
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return nil;
}

/**
 * method to get path after writing string to file path
 * @param contentString as NSString
 * @param filePath as NSString
 * @param error as NSError
 * @return writableFilePath as NSString
 */
+(NSString*)pathAfterWritingString:(NSString*)contentString toFilePath:(NSString*)filePath writingError:(NSError**)error {
  @try {
    if (sIsDataWriteEnabled && sIsSDKEnabled) {
      NSString* writableFilePath = [self checkAndReturnWritableFilePath:filePath];
      NSError *writeError = nil;
      BOOL success;
      //write without encryption
      success = [contentString writeToFile:writableFilePath atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
      
      if (!success) {
        writableFilePath = nil;
      }
      *error = writeError;
      return writableFilePath;
    } else {
      NSError *writeError = [NSError errorWithDomain:@"io.blotout.FileSystem" code:90001 userInfo:@{@"info":@"data write for blotout SDK not allowed"}];
      *error = writeError;
      return nil;
    }
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return nil;
}

/**
 * method to get path after writing string to file url
 * @param contentString as NSString
 * @param fileUrl as NSURL
 * @param error as NSError
 * @return fileUrlPath as NSURL
 */
+(NSURL*)pathAfterWritingString:(NSString*)contentString toFileUrl:(NSURL*)fileUrl writingError:(NSError**)error {
  @try {
    if (sIsDataWriteEnabled && sIsSDKEnabled) {
      NSURL* fileUrlPath = [NSURL fileURLWithPath:[self checkAndReturnWritableFilePath:fileUrl]];
      NSError *writeError = nil;
      BOOL success = fileUrlPath ? [contentString writeToURL:fileUrlPath atomically:YES encoding:NSUTF8StringEncoding error:&writeError] : NO;
      if (!success) {
          fileUrlPath = nil;
      }
      *error = writeError;
      return fileUrlPath;
    } else {
      NSError *writeError = [NSError errorWithDomain:@"io.blotout.FileSystem" code:90001 userInfo:@{@"info":@"data write for blotout SDK not allowed"}];
      *error = writeError;
      return nil;
    }
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return nil;
}

/**
 * method to get content of file at path
 * @param filePath as NSString
 * @param encoding as NSStringEncoding
 * @param err as NSError
 * @return fileContent as NSString
 */
+(NSString*)contentOfFileAtPath:(NSString*)filePath withEncoding:(NSStringEncoding)encoding andError:(NSError**)err {
  @try {
    NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:encoding error:err];
    return fileContent;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return nil;
}

/**
 * method to get application support directory path
 * @return dirPath as NSString
 */
+(NSString*)getApplicationSupportDirectoryPath {
  @try {
    NSString* bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSURL*    dirPath = nil;
    
    // Find the application support directory in the home directory.
    //NSLibraryDirectory
    //NSCachesDirectory
    //NSApplicationSupportDirectory
    NSArray* appSupportDir = [fm URLsForDirectory:NSApplicationSupportDirectory
                                        inDomains:NSUserDomainMask];
    if ([appSupportDir count] > 0) {
      // Append the bundle ID to the URL for the
      // Application Support directory
      dirPath = [[appSupportDir objectAtIndex:0] URLByAppendingPathComponent:bundleID];
      
      // If the directory does not exist, this method creates it.
      // This method is only available in OS X v10.7 and iOS 5.0 or later.
      NSError*    theError = nil;
      if (![fm createDirectoryAtURL:dirPath withIntermediateDirectories:YES attributes:nil error:&theError]) {
        // Handle the error.
        return nil;
      }
    }
    
    return [dirPath path];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return nil;
}

/**
 * method to get document directory path
 * @return sBOFSDKDocumentsDirectory as NSString
 */
+(NSString*)getDocumentDirectoryPath {
  @try {
    static NSString *sBOFSDKDocumentsDirectory = nil;
    if (!sBOFSDKDocumentsDirectory) {
      NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
      sBOFSDKDocumentsDirectory = [paths objectAtIndex:0];
    }
    return sBOFSDKDocumentsDirectory;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return nil;
}

#pragma mark Directory creation generic function

/**
 * method to create directory if required and return path
 * @param directoryPath as NSString
 * @return directoryPath as NSArray
 */
+(NSString*)createDirectoryIfRequiredAndReturnPath:(NSString*)directoryPath {
  @try {
    NSError *dirError = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
      if (![[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:&dirError]) {
        directoryPath = nil;
      }
    }
    return directoryPath;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return nil;
}

/**
 * method to get BOSDK root direcoty possible existance path
 * @return BOFSDKRootDir as NSString
 */
+(NSString*)getBOSDKRootDirecotyPossibleExistancePath{
  @try {
    NSString *systemRootDirectory = nil;
    if (IS_OS_6_OR_LATER) {
      systemRootDirectory = [self getApplicationSupportDirectoryPath];
    } else {
      systemRootDirectory = [self getDocumentDirectoryPath];
    }
    NSString *BOFSDKRootDir = [systemRootDirectory stringByAppendingPathComponent:kBOSDKRootDirectoryName];
    
    return BOFSDKRootDir;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return nil;
}

/**
 * method to check is file exist at path
 * @param filePath as NSString
 * @return status as BOOL
 */
+(BOOL)isFileExistAtPath:(NSString*)filePath{
  @try {
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return NO;
}

/**
 * method to get SDK's root dir
 * @return BOFSDKRootDir as NSString
 */
+(NSString*)getBOSDKRootDirectory{
  @try {
    NSString *BOFSDKRootDir = [self createDirectoryIfRequiredAndReturnPath:[self getBOSDKRootDirecotyPossibleExistancePath]];
    [self addSkipBackupAttributeToItemAtPath:BOFSDKRootDir];
    return BOFSDKRootDir;
  } @catch (NSException *exception) {
    BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
  }
  return nil;
}

/**
 * method to get child directory creating in parents
 * @param childDirName as NSString
 * @param parentPath as NSString
 * @return childDirPath as NSString
 */
+(NSString*)getChildDirectory:(NSString*)childDirName byCreatingInParent:(NSString*)parentPath{
    @try {
        NSString *childDirPossiblePath = [parentPath stringByAppendingPathComponent:childDirName];
        NSString *childDirPath = [self createDirectoryIfRequiredAndReturnPath:childDirPossiblePath];
        [self addSkipBackupAttributeToItemAtPath:childDirPath];
        return childDirPath;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get bundle id
 * @return sBofBundleid as NSString
 */
+ (NSString *)bundleId{
    @try {
        static NSString *sBofBundleid = @"";
        if ([sBofBundleid isEqualToString:@""]) {
            sBofBundleid = [[NSBundle mainBundle] bundleIdentifier];
        }
        return sBofBundleid;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get SDK manifest dir path
 * @return sdkManifestData as NSString
 */
+(NSString*)getSDKManifestDirectoryPath{
    @try {
        NSString *eventsRootDir = [self getBOSDKRootDirectory];
        NSString *sdkManifestData = [BOFFileSystemManager getChildDirectory:@"SDKManifestData" byCreatingInParent:eventsRootDir];
        return sdkManifestData;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

@end
