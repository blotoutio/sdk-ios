//
//  BOFLogs.m
//  BlotoutFoundation
//
//  Created by Blotout on 22/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOFLogs.h"
#import <Foundation/Foundation.h>
#import "BOFFileSystemManager.h"
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

static id sBOFLogsSharedInstance = nil;

#ifndef BOVERBOSE
//#define BOVERBOSE 1
#endif

void BOFLogVerbose(NSString *frmt, ...){
}

void BOFLogDebug(NSString *frmt, ...){
    @autoreleasepool {
    #ifdef BOVERBOSE
            va_list args;
            va_start(args,frmt);
            
            NSString * msg = [[NSString alloc] initWithFormat:frmt  arguments:args];
            va_end(args);
            NSString *logMessage = [NSString stringWithFormat:@"[File Name : %s] [File Path : %s] [Method Name: %s] [Line No: %d] %@", __FILE_NAME__ ,__FILE__, __PRETTY_FUNCTION__ , __LINE__, msg];
            NSLog(@"Error: %@",logMessage);
            [[BOFLogs sharedInstance] writeErrorLogs:logMessage];
    #endif
        }
}

void BOFLogError(NSString *frmt, ...){
    @autoreleasepool {
    #ifdef DEBUG
            va_list args;
            va_start(args,frmt);
            
            NSString * msg = [[NSString alloc] initWithFormat:frmt  arguments:args];
            va_end(args);
            NSString *logMessage = [NSString stringWithFormat:@"[File Name : %s] [File Path : %s] [Method Name: %s] [Line No: %d] %@", __FILE_NAME__ ,__FILE__, __PRETTY_FUNCTION__ , __LINE__, msg];
            NSLog(@"Error: %@",logMessage);
            [[BOFLogs sharedInstance] writeErrorLogs:logMessage];
    #endif
        }
}
void BOFLogStat(NSString *frmt, ...){}
void BOFLogWarn(NSString *frmt, ...){}
void BOFLogInfo(NSString *frmt, ...){
    if([BOFLogs sharedInstance].isSDKLogEnabled) {
        @autoreleasepool {
            va_list args;
            va_start(args,frmt);
            
            NSString * msg = [[NSString alloc] initWithFormat:frmt  arguments:args];
            va_end(args);
            NSString *logMessage = [NSString stringWithFormat:@"[Method Name: %s] [Line No: %d] %@",__PRETTY_FUNCTION__ , __LINE__, msg];
            NSLog(@"%@",logMessage);
            #ifdef BOVERBOSE
                    [[BOFLogs sharedInstance] writeInfoLogs:logMessage];
            #endif
        }
    }
}

@implementation BOFLogs

+ (nullable instancetype)sharedInstance{
    
    static dispatch_once_t bofLogsOnceToken = 0;
    dispatch_once(&bofLogsOnceToken, ^{
        sBOFLogsSharedInstance = [[[self class] alloc] init];
    });
    
    return  sBOFLogsSharedInstance;
    
}

-(NSString*)getBOSDKLogsRootPath{
#ifdef BOVERBOSE
    NSString *rootDirectory = [BOFFileSystemManager getBOSDKRootDirecoty];
    NSString *allBOLogsDir = [BOFFileSystemManager getChildDirectory:@"AllBOLogs" byCreatingInParent:rootDirectory];
    return allBOLogsDir;
#else
    return nil;
#endif
}

-(NSString*)getInfoLogsDirectoryPath{
#ifdef BOVERBOSE
    NSString *allLogsDir = [self getBOSDKLogsRootPath];
    NSString *infoLogs = [BOFFileSystemManager getChildDirectory:@"infoLogs" byCreatingInParent:allLogsDir];
    return infoLogs;
#else
    return nil;
#endif
}

-(NSString*)getErrorLogsDirectoryPath{
#ifdef BOVERBOSE
    NSString *allLogsDir = [self getBOSDKLogsRootPath];
    NSString *infoLogs = [BOFFileSystemManager getChildDirectory:@"errorLogs" byCreatingInParent:allLogsDir];
    return infoLogs;
#else
    return nil;
#endif
}

-(NSString*)writeErrorLogs:(NSString*)logs{
#ifdef BOVERBOSE
    //Logic will automatically create new log file matching date, so should be fine and no checks needed
    NSString *todayDateStr = [self convertDate:[NSDate date] inFormat:@"yyyy-MM-dd"];
    NSString *fileName = [NSString stringWithFormat:@"%@-errorlogs.txt",todayDateStr];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[self getErrorLogsDirectoryPath],fileName];
    NSError *error;
    return [BOFFileSystemManager pathAfterWritingString:logs toFilePath:filePath appendIfExist:YES writingError:&error];
#else
    return nil;
#endif
}

-(NSString*)writeInfoLogs:(NSString*)logs{
#ifdef BOVERBOSE
    //Logic will automatically create new log file matching date, so should be fine and no checks needed
    NSString *todayDateStr = [self convertDate:[NSDate date] inFormat:@"yyyy-MM-dd"];
    NSString *fileName = [NSString stringWithFormat:@"%@-infologs.txt",todayDateStr];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[self getInfoLogsDirectoryPath],fileName];
    NSError *error;
    return [BOFFileSystemManager pathAfterWritingString:logs toFilePath:filePath appendIfExist:YES writingError:&error];
#else
    return nil;
#endif
}

-(void)emailAllInfoLogsTo:(NSArray<NSString*>*)validEmails withSubject:(NSString*)mailSubject{
#ifdef BOVERBOSE
    if (!validEmails || (validEmails.count <= 0)) {
        return;
    }
    NSArray *allInfoLogFiles = [BOFFileSystemManager getAllFilesWithExtention:@"txt" fromDir:[self getInfoLogsDirectoryPath]];
    
    // From within your active view controller
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        //mailCont.mailComposeDelegate = self;
        NSString *logDate = [self convertDate:[NSDate date] inFormat:@"dd-MM-yyyy"];
        NSString *infoLogsMailSub = mailSubject ? mailSubject : [NSString stringWithFormat:@"%@-on-%@",@"All_Info_Logs",logDate];
        [mailCont setSubject:infoLogsMailSub];
        [mailCont setToRecipients:validEmails];
        
        for (NSString *filePath in allInfoLogFiles) {
            NSData *fileData = [NSData dataWithContentsOfFile:filePath];
            [mailCont addAttachmentData:fileData mimeType:@"text/plain" fileName:[filePath lastPathComponent]];
        }
        NSString * appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
        [mailCont setMessageBody:[NSString stringWithFormat:@"Info Logs of App:%@ on Date %@",appName, logDate] isHTML:NO];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:mailCont animated:YES completion:^{
            [mailCont dismissViewControllerAnimated:YES completion:nil];
        }];
    }
#endif
}

-(void)emailAllErrorLogsTo:(NSArray<NSString*>*)validEmails withSubject:(NSString*)mailSubject{
#ifdef BOVERBOSE
    if (!validEmails || (validEmails.count <= 0)) {
        return;
    }
    NSArray *allInfoLogFiles = [BOFFileSystemManager getAllFilesWithExtention:@"txt" fromDir:[self getErrorLogsDirectoryPath]];
    
    // From within your active view controller
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        //mailCont.mailComposeDelegate = self;
        NSString *logDate = [self convertDate:[NSDate date] inFormat:@"dd-MM-yyyy"];
        NSString *infoLogsMailSub = mailSubject ? mailSubject : [NSString stringWithFormat:@"%@-on-%@",@"All_Error_Logs",logDate];
        [mailCont setSubject:infoLogsMailSub];
        [mailCont setToRecipients:validEmails];
        
        for (NSString *filePath in allInfoLogFiles) {
            NSData *fileData = [NSData dataWithContentsOfFile:filePath];
            [mailCont addAttachmentData:fileData mimeType:@"text/plain" fileName:[filePath lastPathComponent]];
        }
        NSString * appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
        [mailCont setMessageBody:[NSString stringWithFormat:@"Error Logs of App:%@ on Date %@",appName, logDate] isHTML:NO];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:mailCont animated:YES completion:^{
            [mailCont dismissViewControllerAnimated:YES completion:nil];
        }];
    }
#endif
}

//-(void)emailAllInfoLogsTo:(NSString*)validEmail fromDateStr:(NSString*)fromDate toDateStr:(NSString*)toDate{
//#ifdef DEBUG
//#endif
//}
//
//-(void)emailAllInfoLogsTo:(NSString*)validEmail fromDate:(NSDate*)fromDate toDate:(NSDate*)toDate{
//#ifdef DEBUG
//#endif
//}

-(NSString*)convertDate:(nonnull NSDate*)date inFormat:(nullable NSString*)dateFormat{
    @try {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSString *dateFomratL = dateFormat ? dateFormat : @"yyyy-MM-dd";
        [dateFormatter setDateFormat:dateFomratL];
        NSString *dateString = [dateFormatter stringFromDate:date];
        return dateString;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", @"BOA_DEBUG", exception);
    }
    return nil;
}

-(NSString*)convertDateStr:(nonnull NSString*)dateStr inFormat:(nullable NSString*)dateFormat{
    @try {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSString *dateFomratL = dateFormat ? dateFormat : @"yyyy-MM-dd";
        [dateFormatter setDateFormat:dateFomratL];
        NSDate *date  = [dateFormatter dateFromString:dateStr];
        NSString *dateString = [dateFormatter stringFromDate:date];
        return dateString;
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", @"BOA_DEBUG", exception);
    }
    return nil;
}
@end
