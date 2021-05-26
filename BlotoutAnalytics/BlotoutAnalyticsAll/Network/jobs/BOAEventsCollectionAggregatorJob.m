//
//  BOAEventsCollectionAggregatorJob.m
//  BlotoutAnalytics
//
//  Created by Blotout on 12/10/19.
//  Copyright © 2019 Blotout. All rights reserved.
//

#import "BOAEventsCollectionAggregatorJob.h"
#import <BlotoutFoundation/BOFFileSystemManager.h>
#import "BOAUtilities.h"
#import "BOAEvents.h"
#import <BlotoutFoundation/BOFLogs.h>
#import "BOAConstants.h"

@interface BOAEventsCollectionAggregatorJob () {
    
}

@property (atomic, assign) BOOL _executing;
@property (atomic, assign) BOOL _finished;
@end

@implementation BOAEventsCollectionAggregatorJob

- (instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) start {
    @try {
        if ([self isCancelled])
        {
            // Move the operation to the finished state if it is canceled.
            [self willChangeValueForKey:@"isFinished"];
            self._finished = YES;
            [self didChangeValueForKey:@"isFinished"];
            return;
        }
        
        // If the operation is not canceled, begin executing the task.
        [self willChangeValueForKey:@"isExecuting"];
        [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
        self._executing = YES;
        [self didChangeValueForKey:@"isExecuting"];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (void) main {
    @try {
        if ([self isCancelled]) {
            return;
        }
        [self collectInformation];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

-(void)collectInformation {
    @try {
        //        //[BOAEvents getSyncedDirectoryPath]
        //        NSString *syncDirPath = [BOAEvents getSyncedDirectoryPath];
        //        NSArray *dirFiles = [BOFFileSystemManager getAllFilesWithExtention:@"txt" fromDir:syncDirPath];
        //        
        //        for (NSString*fileName in dirFiles) {
        //            //launch operations to collect data from each files and data will be available on singleton instance for further operation
        //            
        //            //__block NSString *blockFileName =  fileName;
        //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //                // do your background work
        //                //NSString *fileContent = [BOFFileSystemManager contentOfFileAtPath:blockFileName withEncoding:NSUTF8StringEncoding andError:nil];
        //                
        //                dispatch_async(dispatch_get_main_queue(), ^{
        //                    // update UI, etc.
        //                    
        //                });
        //
        //            });
        //            
        //        }
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

- (BOOL) isAsynchronous {
    return YES;
}

- (BOOL)isExecuting {
    return self._executing;
}

- (BOOL)isFinished {
    return self._finished;
}

- (void)completeOperation {
    @try {
        [self willChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"isExecuting"];
        
        self._executing = NO;
        self._finished = YES;
        
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
    } @catch (NSException *exception) {
        BOFLogDebug(@"%@:%@", BOA_DEBUG, exception);
    }
}

@end
