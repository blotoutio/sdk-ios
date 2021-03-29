//
//  BOFFileSystemManager.m
//  BlotoutFoundation
//
//  Created by Blotout on 27/07/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

/**
 * The BOFFileSystemManager is class to save and fetch SDK's data
 */

#import "BOFFileSystemManager.h"
#include <sys/xattr.h>
#include "BOFConstants.h"
#import <UIKit/UIKit.h>

#import "BOFUtilities.h"
#import "BOFLogs.h"
#import "BlotoutFoundation.h"
#import "BOCrypt.h"


static BOOL sIsDataWriteEnabled = YES;
static BOOL sIsSDKEnabled = YES;
static BOOL sNeverDeleteSDKData = NO;

@implementation BOFFileSystemManager

//iOS 5.0.1 method //https://developer.apple.com/library/ios/qa/qa1719/_index.html
+(BOOL)addSkipBackupAttributeToFilePath:(NSString *)filePath
{
    @try {
        if(!filePath)
            return 0;
        
        const char* attrName = "com.apple.MobileBackup";                                                                                            //ADDED
        u_int8_t attrValue = 1;
        int result = setxattr([filePath cStringUsingEncoding: NSUTF8StringEncoding], attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return NO;
}

//iOS 5.1 & Above method //https://developer.apple.com/library/ios/qa/qa1719/_index.html
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    BOOL success = NO;
    @try {
        if ([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]) {
            NSError *error = nil;
            success = [URL setResourceValue:[NSNumber numberWithBool: YES]
                                     forKey: NSURLIsExcludedFromBackupKey error: &error];
            if(!success){
                BOFLogDebug(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
            }
        }
    }
    @catch (NSException *exception) {
        //Exception will allow backup to iCloud, so either change URL or make alternative
        BOFLogDebug(@"Error excluding %@ from backup %@", [URL lastPathComponent], exception.userInfo);
    }
    return success;
}

+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path{
    @try {
        return path ? [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:path]] : NO;
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
 * method to set never delete sdk data, by default its false
 * @param neverDeleteSDKData as BOOL
 */
+(void)setNeverDeleteSDKData:(BOOL)neverDeleteSDKData{
    sNeverDeleteSDKData = neverDeleteSDKData;
}

/**
 * method to sort folder files by creation date
 * @param folder as NSString
 * @return files as NSArray
 */
+(NSArray *)sortFilesInFolderByCreationDate:(NSString *)folder
{
    NSAssert((folder && [folder isKindOfClass:[NSString class]]), @"folder name cannot be nil");
    NSArray *files = nil;
    @try {
        NSError *err = nil;
        files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:folder isDirectory:YES]
                                              includingPropertiesForKeys:@[NSURLCreationDateKey]
                                                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                   error:&err];
        NSAssert(!err, [err localizedDescription]);
        NSMutableDictionary *urlWithDate = [NSMutableDictionary dictionaryWithCapacity:files.count];
        for (NSURL *f in files) {
            NSDate *creationDate;
            if ([f getResourceValue:&creationDate forKey:NSURLCreationDateKey error:&err]) {
                if(creationDate)
                    [urlWithDate setObject:creationDate forKey:f];
            }
        }
        files = [urlWithDate keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
    }
    @catch (NSException *exception) {
    }
    return files;
}

/**
 * method to get download size
 * @param data as NSData
 * @return downloadSizeL as NSNumber
 */
+(NSNumber*)getDownloadSize:(NSURL*)location data:(NSData*)data{
    @try {
        unsigned long long fileSize = 0;
        if (location) {
            fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:[location path] error:nil] fileSize];
        }else if(data){
            fileSize = [data length];
        }
        NSNumber *downloadSizeL = [NSNumber numberWithUnsignedLongLong:fileSize];
        return downloadSizeL;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

/**
 * method to remove file from location path in file system
 * @param fileLocationPath as NSString
 * @param removalError as NSError
 * @return success as BOOL
 */
+(BOOL)removeFileFromLocationPath:(NSString*)fileLocationPath removalError:(NSError**)removalError{
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
+(BOOL)removeFileFromLocation:(NSURL*)fileLocation removalError:(NSError**)removalError{
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
 * method to remove recurrsive empty diretory from location path
 * @param dirLocationPath as NSString
 * @param removalError as NSError
 * @return success as BOOL
 */
+(BOOL)removeRecurrsiveEmptyDirFromLocationPath:(NSString*)dirLocationPath removalError:(NSError**)removalError{
    @try {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *deleteError = nil;
        BOOL success = NO;
        BOOL isDir = NO;
        BOOL isDirExist = [fileManager fileExistsAtPath:dirLocationPath isDirectory:&isDir];
        if (isDirExist && isDir) {
            NSArray *allDirAndFile = [self getAllDirsInside:dirLocationPath];
            for (NSString *dirPath in allDirAndFile) {
                if ([self getAllContentInside:dirPath].count == 0) {
                    success = [fileManager removeItemAtPath:dirPath error:&deleteError];
                    *removalError = deleteError;
                }else{
                    NSError *removeError = nil;
                    [self removeRecurrsiveEmptyDirFromLocationPath:dirPath removalError:&removeError];
                }
            }
        }else if(isDirExist && !isDir){
            //don't remove files as we are removing emptry dir only
        }
        return success;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return NO;
}

/**
 * method to delete files recurrsively from file system
 * @param isRecursively as BOOL
 * @param days as NSNumber
 * @param dirPath as NSString
 * @param removalError as NSError
 * @return isAllFiledDeleted as BOOL
 */
+(BOOL)deleteFilesRecursively:(BOOL)isRecursively olderThanDays:(NSNumber*)days underRootDirPath:(NSString*)dirPath removalError:(NSError**)removalError{
    @try {
        BOOL isAllFiledDeleted = YES;
        dirPath = (dirPath &&  ![dirPath isEqualToString:@""]) ? dirPath : [self getBOSDKRootDirectory];
        days = days != nil ? days : [NSNumber numberWithFloat:180.0];
        NSArray *allContent = [self getAllContentInside:dirPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        for (NSString *oneContent in allContent) {
            
            //stop removing sdkManifest file
            if([oneContent containsString:@"sdkManifest.txt"])
                continue;
            
            BOOL isDir = NO;
            BOOL isDirExist = [fileManager fileExistsAtPath:oneContent isDirectory:&isDir];
            if (isDirExist && isDir && isRecursively) {
                isAllFiledDeleted = [self deleteFilesRecursively:isRecursively olderThanDays:days underRootDirPath:oneContent removalError:removalError];
            }else if (isDirExist && !isDir){
                //NSDate *fileCreationDate = [self getCreationDateOfItemAtPath:oneContent];
                NSDate *fileModificationDate = [self getModificationDateOfItemAtPath:oneContent];
                
                NSTimeInterval expiryInterval = [days floatValue] * 24 * 60 * 60;
                NSDate *expiryDate = [fileModificationDate dateByAddingTimeInterval:expiryInterval];
                NSDate *todaysDate = [NSDate date];
                
                //Greater is checked with the logic as 7th April 2020 is greater than 6th April 2020
                // so 7th is today and 6th is expiry, working with seconds accuracy
                if ([BOFUtilities isDate:todaysDate greaterThan:expiryDate]) {
                    //File should get deleted
                    NSError *removalErrorL = nil;
                    isAllFiledDeleted = isAllFiledDeleted && [self removeFileFromLocationPath:oneContent removalError:&removalErrorL];
                    if (removalErrorL) {
                        *removalError = removalErrorL;
                        break;
                    }
                }
            }
        }
        return isAllFiledDeleted;    } @catch (NSException *exception) {
            BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
        }
    return NO;
}

/**
 * method to delete files recurrsively from file system older than date
 * @param isRecursively as BOOL
 * @param dateTime as NSDate
 * @param dirPath as NSString
 * @param removalError as NSError
 * @return isAllFiledDeleted as BOOL
 */
+(BOOL)deleteFilesRecursively:(BOOL)isRecursively olderThan:(NSDate*)dateTime underRootDirPath:(NSString*)dirPath removalError:(NSError**)removalError{
    @try {
        BOOL isAllFiledDeleted = YES;
        dirPath = (dirPath &&  ![dirPath isEqualToString:@""]) ? dirPath : [self getBOSDKRootDirectory];
        if (!dateTime) {
            return NO;
        }
        NSArray *allContent = [self getAllContentInside:dirPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        for (NSString *oneContent in allContent) {
            BOOL isDir = NO;
            BOOL isDirExist = [fileManager fileExistsAtPath:oneContent isDirectory:&isDir];
            if (isDirExist && isDir && isRecursively) {
                isAllFiledDeleted = [self deleteFilesRecursively:isRecursively olderThan:dateTime underRootDirPath:oneContent removalError:removalError];
            }else if (isDirExist && !isDir){
                //NSDate *fileCreationDate = [self getCreationDateOfItemAtPath:oneContent];
                NSDate *fileModificationDate = [self getModificationDateOfItemAtPath:oneContent];
                
                NSTimeInterval expiryInterval =  [dateTime timeIntervalSinceNow];//180 * 24 * 60 * 60;
                NSDate *expiryDate = [fileModificationDate dateByAddingTimeInterval:expiryInterval];
                NSDate *todaysDate = [NSDate date];
                
                //Greater is checked with the logic as 7th April 2020 is greater than 6th April 2020
                // so 7th is today and 6th is expiry, working with seconds accuracy
                if ([BOFUtilities isDate:todaysDate greaterThan:expiryDate]) {
                    //File should get deleted
                    NSError *removalErrorL = nil;
                    isAllFiledDeleted = isAllFiledDeleted && [self removeFileFromLocationPath:oneContent removalError:&removalErrorL];
                    if (removalErrorL) {
                        *removalError = removalErrorL;
                        break;
                    }
                }
            }
        }
        return isAllFiledDeleted;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return NO;
}

/**
 * method to delete files and directory recurrsively from file system
 * @param isRecursively as BOOL
 * @param days as NSNumber
 * @param dirPath as NSString
 * @param removalError as NSError
 * @return isAllFiledDeleted as BOOL
 */
+(BOOL)deleteFilesAndDirectoryRecursively:(BOOL)isRecursively olderThanDays:(NSNumber*)days underRootDirPath:(NSString*)dirPath removalError:(NSError**)removalError{
    @try {
        BOOL isAllFiledDeleted = YES;
        dirPath = (dirPath &&  ![dirPath isEqualToString:@""]) ? dirPath : [self getBOSDKRootDirectory];
        days = days != nil ? days : [NSNumber numberWithFloat:180.0];
        NSArray *allContent = [self getAllContentInside:dirPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        for (NSString *oneContent in allContent) {
            BOOL isDir = NO;
            BOOL isDirExist = [fileManager fileExistsAtPath:oneContent isDirectory:&isDir];
            if (isDirExist && isDir && isRecursively) {
                isAllFiledDeleted = [self deleteFilesAndDirectoryRecursively:isRecursively olderThanDays:days underRootDirPath:oneContent removalError:removalError];
            }else if(isDirExist){
                //NSDate *fileCreationDate = [self getCreationDateOfItemAtPath:oneContent];
                NSDate *fileModificationDate = [self getModificationDateOfItemAtPath:oneContent];
                
                NSTimeInterval expiryInterval = [days floatValue] * 24 * 60 * 60;
                NSDate *expiryDate = [fileModificationDate dateByAddingTimeInterval:expiryInterval];
                NSDate *todaysDate = [NSDate date];
                
                //Greater is checked with the logic as 7th April 2020 is greater than 6th April 2020
                // so 7th is today and 6th is expiry, working with seconds accuracy
                if ([BOFUtilities isDate:todaysDate greaterThan:expiryDate]) {
                    //File should get deleted
                    NSError *removalErrorL = nil;
                    isAllFiledDeleted = isAllFiledDeleted && [self removeFileFromLocationPath:oneContent removalError:&removalErrorL];
                    if (removalErrorL) {
                        *removalError = removalErrorL;
                        break;
                    }
                }
            }
        }
        return isAllFiledDeleted;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return NO;
}

/**
 * method to delete files and directory recurrsively from file system older than date
 * @param isRecursively as BOOL
 * @param dateTime as NSDate
 * @param dirPath as NSString
 * @param removalError as NSError
 * @return isAllFiledDeleted as BOOL
 */
+(BOOL)deleteFilesAndDirectoryRecursively:(BOOL)isRecursively olderThan:(NSDate*)dateTime underRootDirPath:(NSString*)dirPath removalError:(NSError**)removalError{
    @try {
        BOOL isAllFiledDeleted = YES;
        dirPath = (dirPath &&  ![dirPath isEqualToString:@""]) ? dirPath : [self getBOSDKRootDirectory];
        if (!dateTime) {
            return NO;
        }
        NSArray *allContent = [self getAllContentInside:dirPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        for (NSString *oneContent in allContent) {
            BOOL isDir = NO;
            BOOL isDirExist = [fileManager fileExistsAtPath:oneContent isDirectory:&isDir];
            if (isDirExist && isDir && isRecursively) {
                isAllFiledDeleted = [self deleteFilesAndDirectoryRecursively:isRecursively olderThan:dateTime underRootDirPath:oneContent removalError:removalError];
            }else if(isDirExist){
                //NSDate *fileCreationDate = [self getCreationDateOfItemAtPath:oneContent];
                NSDate *fileModificationDate = [self getModificationDateOfItemAtPath:oneContent];
                
                NSTimeInterval expiryInterval =  [dateTime timeIntervalSinceNow];//180 * 24 * 60 * 60;
                NSDate *expiryDate = [fileModificationDate dateByAddingTimeInterval:expiryInterval];
                NSDate *todaysDate = [NSDate date];
                
                //Greater is checked with the logic as 7th April 2020 is greater than 6th April 2020
                // so 7th is today and 6th is expiry, working with seconds accuracy
                if ([BOFUtilities isDate:todaysDate greaterThan:expiryDate]) {
                    //File should get deleted
                    NSError *removalErrorL = nil;
                    isAllFiledDeleted = isAllFiledDeleted && [self removeFileFromLocationPath:oneContent removalError:&removalErrorL];
                    if (removalErrorL) {
                        *removalError = removalErrorL;
                        break;
                    }
                }
            }
        }
        return isAllFiledDeleted;
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
+(BOOL)moveFileFromLocation:(NSURL*)fileLocation toLocation:(NSURL*)newLocation relocationError:(NSError**)relocationError{
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
        if(!existAndDic && newExistAndDic){
            NSString* fileName = [fileLocation lastPathComponent];
            newFilePath = [newFilePath stringByAppendingPathComponent:fileName];
            success = [fileManager moveItemAtURL:fileLocation toURL:[NSURL fileURLWithPath:newFilePath] error:&moveError];
        }else{
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
+(BOOL)moveFileFromLocationPath:(NSString*)fileLocation toLocationPath:(NSString*)newLocation relocationError:(NSError**)relocationError{
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
        if(!existAndDic && newExistAndDic){
            NSString* fileName = [fileLocation lastPathComponent];
            newFilePath = [newFilePath stringByAppendingPathComponent:fileName];
            success = [fileManager moveItemAtPath:fileLocation toPath:newFilePath error:&moveError];
        }else{
            success = [fileManager moveItemAtPath:fileLocation toPath:newLocation error:&moveError];
        }
        *relocationError = moveError;
        return success;    } @catch (NSException *exception) {
            BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
        }
    return NO;
}

/**
 * method to copy file from one location to another location in file system
 * @param fileLocation as NSURL
 * @param newLocation as NSURL
 * @param relocationError as NSError
 * @return success as BOOL
 */
+(BOOL)copyFileFromLocation:(NSURL*)fileLocation toLocation:(NSURL*)newLocation relocationError:(NSError**)relocationError{
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
        if(!existAndDic && newExistAndDic){
            NSString* fileName = [fileLocation lastPathComponent];
            newFilePath = [newFilePath stringByAppendingPathComponent:fileName];
            success = [fileManager copyItemAtURL:fileLocation toURL:[NSURL fileURLWithPath:newFilePath] error:&moveError];
        }else{
            success = [fileManager copyItemAtURL:fileLocation toURL:newLocation error:&moveError];
        }
        *relocationError = moveError;
        return success;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return NO;
}

/**
 * method to copy file from one location to another location in file system with merge if exist
 * @param fileLocation as NSURL
 * @param newLocation as NSURL
 * @param doMerge as BOOL
 * @param relocationError as NSError
 * @return success as BOOL
 */
+(BOOL)copyFileFromLocation:(NSURL*)fileLocation toLocation:(NSURL*)newLocation mergeIfExist:(BOOL)doMerge relocationError:(NSError**)relocationError{
    @try {
        NSError *moveError = nil;
        BOOL success = [self copyFileFromLocation:fileLocation toLocation:newLocation relocationError:&moveError];
        //file exist error code 516 message
        //""file name" couldn’t be moved to “new location” because an item with the same name already exists."
        if (!success && (moveError.code == 516)) {
            //Will implement later
        }
        return NO;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return NO;
}
+(BOOL)moveFileFromLocation:(NSURL*)fileLocation toLocation:(NSURL*)newLocation mergeIfExist:(BOOL)doMerge relocationError:(NSError**)relocationError{
    return NO;
}
+(BOOL)copyFileFromLocation:(NSURL*)fileLocation toLocation:(NSURL*)newLocation replaceIfExist:(BOOL)doReplace relocationError:(NSError**)relocationError{
    return NO;
}
+(BOOL)moveFileFromLocation:(NSURL*)fileLocation toLocation:(NSURL*)newLocation replaceIfExist:(BOOL)doReplace relocationError:(NSError**)relocationError{
    return NO;
}

/**
 * method to check is dir at path exists in file system
 * @param path as NSString
 * @return isDir as BOOL
 */
+(BOOL)isDirectoryAtPath:(NSString*)path{
    @try {
        BOOL isDir = NO;
        if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir){
        }
        return isDir;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return NO;
}

/**
 * method to check is writable dir at path exists in file system
 * @param path as NSString
 * @return isDir as BOOL
 */
+(BOOL)isWritableDirectoryAtPath:(NSString*)path{
    @try {
        BOOL isDir = NO;
        if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir){
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
+(BOOL)isWritableFileAtPath:(NSString*)path{
    @try {
        BOOL isWritableFile = NO;
        BOOL isDir = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && !isDir) {
            isWritableFile = [[NSFileManager defaultManager] isWritableFileAtPath:path];
        }else if(!isDir){
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
+(NSString*)checkAndReturnWritableFilePath:(id)givenPath{
    @try {
        NSString* filePath = nil;
        if ([givenPath isKindOfClass:[NSURL class]]) {
            filePath = [(NSURL*)givenPath path];
        }else if ([givenPath isKindOfClass:[NSString class]]){
            filePath = givenPath;
        }
        
        if (!filePath) {
            @throw [NSException exceptionWithName:@"BOFFilePathException" reason:@"Path must be String or URL" userInfo:@{@"Description":@"Path provided is not appropiate, must be either String or URL"}];
        }
        
        NSString* writableFilePath = filePath;
        if ([self isWritableDirectoryAtPath:filePath]) {
            writableFilePath = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"BOFFile%ui",arc4random()]];
        }else if (![self isWritableFileAtPath:filePath]) {
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
+(NSString*)pathAfterWritingString:(NSString*)contentString toFilePath:(NSString*)filePath appendIfExist:(BOOL)shouldAppend writingError:(NSError**)error{
    @try {
        if (sIsDataWriteEnabled && sIsSDKEnabled) {
            NSString* writableFilePath = [self checkAndReturnWritableFilePath:filePath];
            
            NSMutableString *completeString = [contentString mutableCopy];
            NSError *writeError = nil;
            if (shouldAppend) {
                //In case handler behaves bad then we can use this method with string files
                
                //        NSString *existingString = [NSString stringWithContentsOfFile:writableFilePath encoding:NSUTF8StringEncoding error:nil];
                //        completeString = [[existingString stringByAppendingString:contentString] mutableCopy];
                //        BOOL success = [completeString writeToFile:writableFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
                //        if (!success) {
                //            writableFilePath = nil;
                //        }
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
        }else{
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
+(NSString*)pathAfterWritingString:(NSString*)contentString toFilePath:(NSString*)filePath writingError:(NSError**)error
{
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
        }else{
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
+(NSURL*)pathAfterWritingString:(NSString*)contentString toFileUrl:(NSURL*)fileUrl writingError:(NSError**)error
{
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
        }else{
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
 * method to get path after writing data to file path with append policy if exist
 * @param contentData as NSData
 * @param filePath as NSString
 * @param shouldAppend as BOOL
 * @param error as NSError
 * @return writableFilePath as NSString
 */
+(NSString*)pathAfterWritingData:(NSData*)contentData toFilePath:(NSString*)filePath appendIfExist:(BOOL)shouldAppend writingError:(NSError**)error{
    @try {
        if (sIsDataWriteEnabled && sIsSDKEnabled) {
            NSString* writableFilePath = [self checkAndReturnWritableFilePath:filePath];
            NSError *writeError = nil;
            if (shouldAppend) {
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:writableFilePath] error:&writeError];
                [fileHandle seekToEndOfFile];
                [fileHandle writeData:contentData];
                [fileHandle closeFile];
            }else{
                BOOL success = [contentData writeToFile:writableFilePath options:NSDataWritingAtomic error:&writeError];
                if (!success) {
                    writableFilePath = nil;
                }
            }
            *error = writeError;
            return writableFilePath;
        }else{
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
 * method to get path after writing data to file path
 * @param contentData as NSData
 * @param filePath as NSString
 * @param error as NSError
 * @return writableFilePath as NSString
 */
+(NSString*)pathAfterWritingData:(NSData*)contentData toFilePath:(NSString*)filePath writingError:(NSError**)error{
    @try {
        if (sIsDataWriteEnabled && sIsSDKEnabled) {
            NSString* writableFilePath = [self checkAndReturnWritableFilePath:filePath];
            NSError *writeError = nil;
            BOOL success = [contentData writeToFile:writableFilePath options:NSDataWritingAtomic error:&writeError];
            if (!success) {
                writableFilePath = nil;
            }
            *error = writeError;
            return writableFilePath;
        }else{
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
 * method to get path after writing data to file url
 * @param contentData as NSData
 * @param fileUrl as NSURL
 * @param error as NSError
 * @return fileUrlPath as NSString
 */
+(NSURL*)pathAfterWritingData:(NSData*)contentData toFileUrl:(NSURL*)fileUrl writingError:(NSError**)error{
    @try {
        if (sIsDataWriteEnabled && sIsSDKEnabled) {
            NSURL* fileUrlPath = [NSURL fileURLWithPath:[self checkAndReturnWritableFilePath:fileUrl]];
            NSError *writeError = nil;
            BOOL success = fileUrlPath ? [contentData writeToURL:fileUrlPath options:NSDataWritingAtomic error:&writeError] : NO;
            if (!success) {
                fileUrlPath = nil;
            }
            *error = writeError;
            return fileUrlPath;
        }else{
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
 * method to get application cache directory path from file system
 * @return cacheDirectory as NSString
 */
+(NSString*)getApplicationCacheDirectoryPath{
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cacheDirectory = [paths objectAtIndex:0];
        return cacheDirectory;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get application downloads directory path from file system
 * @return downloadsDirectory as NSString
 */
+(NSString*)getApplicationDownloadsDirectoryPath{
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES);
        NSString *downloadsDirectory = [paths objectAtIndex:0];
        return downloadsDirectory;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get content of directory at path
 * @param directoryPath as NSString
 * @return directoryItems as NSArray
 */
+(NSArray*)contentOfDirectoryAtPath:(NSString*)directoryPath{
    @try {
        NSError *error;
        NSArray *directoryItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];
        return directoryItems;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get application support directory path
 * @return dirPath as NSString
 */
+(NSString*)getApplicationSupportDirectoryPath
{
    @try {
        //    //In Sandbox mode it does not exist by default so create if not exist
        //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        //    NSString *applicationSupportDirectory = [paths firstObject];
        //    DDLogDebug(@"applicationSupportDirectory: '%@'", applicationSupportDirectory);
        //
        //    if (applicationSupportDirectory) {
        //        return applicationSupportDirectory;
        //    }
        
        NSString* bundleID = [[NSBundle mainBundle] bundleIdentifier];
        NSFileManager* fm = [NSFileManager defaultManager];
        NSURL*    dirPath = nil;
        
        // Find the application support directory in the home directory.
        //NSLibraryDirectory
        //NSCachesDirectory
        //NSApplicationSupportDirectory
        NSArray* appSupportDir = [fm URLsForDirectory:NSApplicationSupportDirectory
                                            inDomains:NSUserDomainMask];
        if ([appSupportDir count] > 0)
        {
            // Append the bundle ID to the URL for the
            // Application Support directory
            dirPath = [[appSupportDir objectAtIndex:0] URLByAppendingPathComponent:bundleID];
            
            //dirPath = [appSupportDir objectAtIndex:0];
            
            // If the directory does not exist, this method creates it.
            // This method is only available in OS X v10.7 and iOS 5.0 or later.
            NSError*    theError = nil;
            if (![fm createDirectoryAtURL:dirPath withIntermediateDirectories:YES
                               attributes:nil error:&theError])
            {
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
+(NSString*)getDocumentDirectoryPath{
    @try {
        static NSString *sBOFSDKDocumentsDirectory = nil;
        if( !sBOFSDKDocumentsDirectory )
        {
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
+(NSString*)createDirectoryIfRequiredAndReturnPath:(NSString*)directoryPath{
    @try {
        NSError *dirError = nil;
        if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]){
            if(![[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:&dirError]){
                directoryPath = nil;
            }//Create folder
        }
        //*error = dirError; //if i do not include error argument then path will be nil in case of error
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
        if(IS_OS_6_OR_LATER){
            systemRootDirectory = [self getApplicationSupportDirectoryPath];
        }else{
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
 * method to get creation date of item at path
 * @param itemPath as NSString
 * @return itemAttribsCreateDate as NSDate
 */
+(NSDate*)getCreationDateOfItemAtPath:(NSString*)itemPath{
    @try {
        NSError *attGetError = nil;
        NSDictionary* itemAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:itemPath error:&attGetError];
        NSDate *itemAttribsCreateDate = [itemAttribs fileCreationDate]; //or fileModificationDate
        return itemAttribsCreateDate;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get modification date of item at path
 * @param itemPath as NSString
 * @return itemAttribsModifyDate as NSDate
 */
+(NSDate*)getModificationDateOfItemAtPath:(NSString*)itemPath{
    @try {
        NSDictionary* itemAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:itemPath error:nil];
        NSDate *itemAttribsModifyDate = [itemAttribs fileModificationDate]; //or fileModificationDate
        return itemAttribsModifyDate;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get attributes of item at path
 * @param itemPath as NSString
 * @return itemAttribs as NSDictionary
 */
+(NSDictionary*)getAttributesOfItemAtPath:(NSString*)itemPath{
    @try {
        NSDictionary* itemAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:itemPath error:nil];
        return itemAttribs;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

/**
 * method to find is file exists at path
 * @param fileURL as NSURL
 * @return status as BOOL
 */
+(BOOL)isFileExistAtURL:(NSURL*)fileURL{
    @try {
        if (fileURL.isFileURL) {
            return [[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]];
        }
        return NO;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return NO;
}

/**
 * method to get is directory exist at path
 * @param dirPath as NSString
 * @return status as BOOL
 */
+(BOOL)isDirectoryExistAtPath:(NSString*)dirPath{
    @try {
        BOOL isDirectory = NO;
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDirectory];
        return isDirectory && isExist;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return NO;
}

/**
 * method to get is directory exist at url
 * @param fileURL as NSURL
 * @return status as BOOL
 */
+(BOOL)isDirectoryExistAtURL:(NSURL*)fileURL{
    @try {
        if (fileURL.isFileURL) {
            return [self isDirectoryAtPath:fileURL.path];
        }
        return NO;
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

#pragma mark
#pragma mark Generic child directory path creation

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

//Directory Specific functions
#pragma mark
#pragma mark Directory specific functions
#pragma mark
#pragma mark Network Downloads Directory

/**
 * method to get BOF network downloads directory possible existance path
 * @return BOFNetworkDirectory as NSString
 */
+(NSString*)getBOFNetworkDownloadsDirectoryPossibleExistancePath{
    @try {
        NSString *BOFSDKRootDir = [self getBOSDKRootDirectory];
        NSString *BOFNetworkDirectory = [BOFSDKRootDir stringByAppendingPathComponent:kBOFNetworkPromiseDownloadDirectoryName];
        
        return BOFNetworkDirectory;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get BOF network downloads directory path
 * @return BOFNetworkDirectory as NSString
 */
+(NSString*)getBOFNetworkDownloadsDirectoryPath{
    @try {
        NSString *BOFNetworkDirectory = [self createDirectoryIfRequiredAndReturnPath:[self getBOFNetworkDownloadsDirectoryPossibleExistancePath]];
        [self addSkipBackupAttributeToItemAtPath:BOFNetworkDirectory];
        return BOFNetworkDirectory;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

#pragma mark Volatile Directory
/**
 * method to get BOSDK volatile root directory possible existance path in file system
 * @return boVolatileDirectory as NSString
 */
+(NSString*)getBOSDKVolatileRootDirectoryPossibleExistancePath{
    @try {
        NSString *BOSDKRootDir = [self getBOSDKRootDirectory];
        NSString *boVolatileDirectory = [BOSDKRootDir stringByAppendingPathComponent:kBOSDKVolatileRootDirectoryName];
        return boVolatileDirectory;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get BOSDK volatile root directory path in file system
 * @return boVolatileDirectory as NSString
 */
+(NSString*)getBOSDKVolatileRootDirectoryPath{
    @try {
        NSString *boVolatileDirectory = [self createDirectoryIfRequiredAndReturnPath:[self getBOSDKVolatileRootDirectoryPossibleExistancePath]];
        [self addSkipBackupAttributeToItemAtPath:boVolatileDirectory];
        return boVolatileDirectory;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

#pragma mark Non-Volatile Directory
/**
 * method to get BOSDK non volatile root directory possible existance path in file system
 * @return boNonVolatileDirectory as NSString
 */
+(NSString*)getBOSDKNonVolatileRootDirectoryPossibleExistancePath{
    @try {
        NSString *BOSDKRootDir = [self getBOSDKRootDirectory];
        NSString *boNonVolatileDirectory = [BOSDKRootDir stringByAppendingPathComponent:kBOSDKNonVolatileRootDirectoryName];
        return boNonVolatileDirectory;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get BOSDK non volatile root directory path in file system
 * @return boNonVolatileDirectory as NSString
 */
+(NSString*)getBOSDKNonVolatileRootDirectoryPath{
    @try {
        NSString *boNonVolatileDirectory = [self createDirectoryIfRequiredAndReturnPath:[self getBOSDKNonVolatileRootDirectoryPossibleExistancePath]];
        [self addSkipBackupAttributeToItemAtPath:boNonVolatileDirectory];
        return boNonVolatileDirectory;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

#pragma mark Directory cleaning
/**
 * method to clean dir in file system
 * @param directoryPath as NSString
 * @param error as NSError
 */
+(void)cleanDirectory:(NSString*)directoryPath error:(NSError**)error{
    @try {
        NSError *dirError = nil;
        if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath]){
            [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:&dirError];
            //Will recreate a blank directory
            [self createDirectoryIfRequiredAndReturnPath:directoryPath];
        }
        *error = dirError;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}

/**
 * method to delete dir in file system
 * @param directoryPath as NSString
 * @param error as NSError
 */
+(void)delateDirectory:(NSString*)directoryPath error:(NSError**)error{
    @try {
        NSError *dirError = nil;
        if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath]){
            [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:&dirError];
        }
        *error = dirError;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
}

/**
 * method to get bundle id
 * @return sBofBundleid as NSString
 */
+ (NSString *)bundleId{
    @try {
        static NSString *sBofBundleid = @"";
        if( [sBofBundleid isEqualToString:@""] ){
            sBofBundleid = [[NSBundle mainBundle] bundleIdentifier];
        }
        return sBofBundleid;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

/**
 * method to migrate file if old file already exists in file system
 * @param oldFilePath as NSString
 * @param newFile as NSString
 * @return isMigrationSuccess as BOOL
 */
+(BOOL)migrateIfExistsOldFile:(NSString *)oldFilePath toNewFilePath:(NSString *)newFile{
    @try {
        BOOL isMigrationSuccess = NO;
        if( [[NSFileManager defaultManager] fileExistsAtPath:oldFilePath] ){
            isMigrationSuccess = [[NSFileManager defaultManager] moveItemAtPath:oldFilePath toPath:newFile error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:oldFilePath error:nil];
        }
        else{
            isMigrationSuccess = YES;
        }
        return isMigrationSuccess;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return NO;
}

/**
 * method to search file in file system with file name and type
 * @param fileName as NSString
 * @param fileType as NSString
 * @return filePath as NSString
 */
+(NSString*)searchFilePathForFileName:(NSString*)fileName ofType:(NSString*)fileType{
    @try {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
        if (!filePath) {
            for (NSBundle *bundle in [NSBundle allBundles]) {
                filePath = [bundle pathForResource:fileName ofType:fileType];
                if (filePath) {
                    break;
                }
            }
        }
        return filePath;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

/**
 * method to search file path for file name
 * @param fileName as NSString
 * @param fileType as NSString
 * @param directoryName as NSString
 * @return filePath as NSString
 */
+(NSString*)searchFilePathForFileName:(NSString*)fileName ofType:(NSString*)fileType inDirectory:(NSString*)directoryName{
    @try {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType inDirectory:directoryName];
        if (!filePath) {
            for (NSBundle *bundle in [NSBundle allBundles]) {
                filePath = [bundle pathForResource:fileName ofType:fileType inDirectory:directoryName];
                if (filePath) {
                    break;
                }
            }
        }
        return filePath;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get content of file path at path in file system
 * @param filePath as NSString
 * @param encoding as NSStringEncoding
 * @param err as NSError
 * @return fileContent as NSString
 */
+(NSString*)contentOfFileAtPath:(NSString*)filePath usedEncoding:(NSStringEncoding*)encoding andError:(NSError**)err{
    @try {
        NSString *fileContent = [NSString stringWithContentsOfFile:filePath usedEncoding:encoding error:err];
        return fileContent;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get content of file at url
 * @param fileURL as NSURL
 * @param encoding as NSStringEncoding
 * @param err as NSError
 * @return fileContent as NSString
 */
+(NSString*)contentOfFileAtURL:(NSURL*)fileURL usedEncoding:(NSStringEncoding*)encoding andError:(NSError**)err{
    @try {
        NSString *fileContent = [NSString stringWithContentsOfURL:fileURL usedEncoding:encoding error:err];
        return fileContent;
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
+(NSString*)contentOfFileAtPath:(NSString*)filePath withEncoding:(NSStringEncoding)encoding andError:(NSError**)err{
    @try {
        NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:encoding error:err];
        return fileContent;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get content of file at url
 * @param fileURL as NSURL
 * @param encoding as NSStringEncoding
 * @param err as NSError
 * @return fileContent as NSString
 */
+(NSString*)contentOfFileAtURL:(NSURL*)fileURL withEncoding:(NSStringEncoding)encoding andError:(NSError**)err{
    @try {
        NSString *fileContent = [NSString stringWithContentsOfURL:fileURL encoding:encoding error:err];
        return fileContent;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get all files with given extention
 * @param extention as NSString
 * @param filesDir as NSString
 * @return jsonDataFiles as NSArray
 */
+(NSArray*)getAllFilesWithExtention:(NSString*)extention fromDir:(NSString*)filesDir{
    @try {
        NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filesDir
                                                                            error:NULL];
        NSMutableArray *jsonDataFiles = [NSMutableArray array];
        [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *filename = (NSString *)obj;
            NSString *extension = [[filename pathExtension] lowercaseString];
            if ([extension isEqualToString:extention]) {
                [jsonDataFiles addObject:[filesDir stringByAppendingPathComponent:filename]];
            }
        }];
        return jsonDataFiles;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get all dirs inside file dic
 * @param filesDir as NSString
 * @return jsonDirs as NSArray
 */
+(NSArray*)getAllDirsInside:(NSString*)filesDir{
    @try {
        NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filesDir
                                                                            error:NULL];
        NSMutableArray *jsonDirs = [NSMutableArray array];
        [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *filename = (NSString *)obj;
            NSString *filePath = [filesDir stringByAppendingPathComponent:filename];
            BOFLogDebug(@"filePath = %@", filePath);
            BOOL isDir;
            [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir];
            //NSString *extension = [[filename pathExtension] lowercaseString];
            if (isDir) {
                [jsonDirs addObject:filePath];
            }
        }];
        return jsonDirs;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOF_DEBUG, exception);
    }
    return nil;
}

/**
 * method to get all content inside file dir
 * @param filesDir as NSString
 * @return jsonDirs as NSArray
 */
+(NSArray*)getAllContentInside:(NSString*)filesDir{
    @try {
        NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filesDir
                                                                            error:NULL];
        NSMutableArray *jsonDirs = [NSMutableArray array];
        [dirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *filename = (NSString *)obj;
            [jsonDirs addObject:[filesDir stringByAppendingPathComponent:filename]];
        }];
        return jsonDirs;
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
