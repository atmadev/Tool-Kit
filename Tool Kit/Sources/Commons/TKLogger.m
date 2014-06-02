//
//  TKLogger.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/1/13.
//  Copyright (c) 2013 Alexander Koryttsev. All rights reserved.
//

#import "TKLogger.h"
#import "TKDateUtilities.h"


#define TKStoringLogsDurationInSeconds 604800 //1 week

NSString *const TKLogDirectoryName = @"Logs";


@interface TKLogger ()

@property (nonatomic) dispatch_queue_t privateQueue;
@property (nonatomic, strong) NSString *logDirectoryPath;

- (void)saveMessage:(NSString *)message;
- (NSString *)logFilePath;

- (void)postLogMessage:(NSString *)message;

@end


@implementation TKLogger

@synthesize privateQueue;
@synthesize logDirectoryPath;

static TKLogger *_defaultLogger = nil;

+ (TKLogger *)defaultLogger {
    if (_defaultLogger == nil) {
        _defaultLogger = [self new];
    }
    return _defaultLogger;
}

- (id)init {
    self = [super init];
    if (self) {
        self.privateQueue = dispatch_queue_create("logger-private-queue", NULL);
        
        self.logDirectoryPath = [(__bridge NSString *)([[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                         inDomains:NSUserDomainMask] lastObject] path]) stringByAppendingPathComponent:@"Logs"];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:self.logDirectoryPath ])	{
            [[NSFileManager defaultManager] createDirectoryAtPath:self.logDirectoryPath  withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

- (void)dealloc {
    self.logDirectoryPath = nil;
}

- (void)performBlock:(void (^)())block {
    dispatch_async(self.privateQueue, block);
}

- (void)performBlockAndWait:(void (^)())block {
    if (dispatch_get_current_queue() == self.privateQueue) {
        block();
    }
    else {
        dispatch_sync(self.privateQueue, block);
    }
}

- (void)postSyncLogMessage:(NSString *)message {
    [self performBlockAndWait:^{
        [self postLogMessage:message];
    }];
}

- (void)postAsyncLogMessage:(NSString *)message {
    [self performBlock:^{
        [self postLogMessage:message];
    }];
}

- (void)postLogMessage:(NSString *)message {
    NSString *fullMessage = [NSString stringWithFormat:@"%@: %@\n", [TKDateUtilities stringWithTimeGMTFromDate:[NSDate date]], message];
    [self saveMessage:fullMessage];
#ifdef DEBUG
    NSLog(@"%@", message);
#endif
}

- (void)saveMessage:(NSString *)message {
    NSString *path = [self logFilePath];
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
	if(path) {
		if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:data];
		} else {
			[data writeToFile:path atomically:YES];
		}
	}
}

- (NSString *)logFilePath {
    return [[self.logDirectoryPath stringByAppendingPathComponent:[TKDateUtilities fileSystemStringFromCurrentDate]] stringByAppendingPathExtension:@"txt"];
}

- (void)deleteOldLogs {
    NSArray *content = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:self.logDirectoryPath error:nil];
    NSDictionary *attributes = nil;
    for (NSString *filePath in content) {
        attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        if ([[NSDate date] timeIntervalSinceDate:[attributes objectForKey:NSFileCreationDate]] > TKStoringLogsDurationInSeconds) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
}

@end
