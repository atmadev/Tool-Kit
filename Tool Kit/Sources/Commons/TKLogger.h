//
//  TKLogger.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/1/13.
//  Copyright (c) 2013 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JSON_LOGGING_ENABLED

#ifdef DEBUG

#define DLog(fmt, ...) DSimpleLog((@"%s:%d> " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define DSimpleLog(...) [TKLoggerInstance postAsyncLogMessage:[NSString stringWithFormat:__VA_ARGS__]]

#define DSyncLog(fmt, ...) DSimpleSyncLog((@"%s:%d> " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define DSimpleSyncLog(...) [TKLoggerInstance postSyncLogMessage:[NSString stringWithFormat:__VA_ARGS__]]

#ifdef JSON_LOGGING_ENABLED
#define JSONLog(fmt, ...) DLog(fmt, ##__VA_ARGS__)
#else
#define JSONLog(fmt, ...)
#endif

#else

#define DLog(...)
#define DSimpleLog(...)

#define DSyncLog(fmt, ...)
#define DSimpleSyncLog(...) 

#define JSONLog(fmt, ...)

#endif

#define TKLoggerInstance [TKLogger defaultLogger]


@interface TKLogger : NSObject

+ (TKLogger *)defaultLogger;

- (void)postSyncLogMessage:(NSString *)message;
- (void)postAsyncLogMessage:(NSString *)message;

@end
