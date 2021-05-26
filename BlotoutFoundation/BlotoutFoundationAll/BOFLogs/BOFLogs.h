//
//  BOFLogs.h
//  BlotoutFoundation
//
//  Created by Blotout on 22/09/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

void BOFLogError(NSString *frmt, ...);
void BOFLogWarn(NSString *frmt, ...);
void BOFLogInfo(NSString *frmt, ...);
void BOFLogDebug(NSString *frmt, ...);
void BOFLogVerbose(NSString *frmt, ...);
void BOFLogStat(NSString *frmt, ...);

@interface BOFLogs : NSObject

+ (nullable instancetype)sharedInstance;

@property (nonatomic,readwrite) BOOL isSDKLogEnabled;

-(NSString*)getBOSDKLogsRootPath;
-(NSString*)getInfoLogsDirectoryPath;

-(NSString*)writeInfoLogs:(NSString*)logs;
-(NSString*)writeErrorLogs:(NSString*)logs;

-(void)emailAllInfoLogsTo:(NSArray<NSString*>*)validEmail withSubject:(NSString*)mailSubject;
-(void)emailAllErrorLogsTo:(NSArray<NSString*>*)validEmails withSubject:(NSString*)mailSubject;
@end

NS_ASSUME_NONNULL_END
