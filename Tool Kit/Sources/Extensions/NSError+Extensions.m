//
//  NSError+Extensions.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 2/25/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "NSError+Extensions.h"


NSString * const TKErrorDomain = @"com.toolkit";


@implementation NSError (TKAdditions)

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message {
    return [NSError errorWithDomain:TKErrorDomain
                               code:code
                           userInfo:message ? @{ NSLocalizedDescriptionKey : message } : nil
            ];
}

- (NSString *)message {
    return self.userInfo[NSLocalizedDescriptionKey];
}

- (BOOL)isNetworkProblem {
    return (self.code == TKNetworkErrorNoConnection || self.code == TKNetworkErrorServerIsUnreachable);
}

- (BOOL)isInvalidSession {
    return self.code == TKServerErrorUnauthorized;
}

- (TKErrorCode)errorCode {
    return self.code;
}

+ (id)errorWithCode:(NSInteger)code message:(NSString *)errorMessage userInfo:(NSDictionary *)userInfo {
    return [self errorWithDomain:TKErrorDomain code:code message:errorMessage userInfo:userInfo];
}

+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code message:(NSString *)errorMessage userInfo:(NSDictionary *)userInfo {
    
    NSMutableDictionary *finalDictionary = [NSMutableDictionary dictionaryWithDictionary:userInfo ?: @{}];
    if (errorMessage != nil) {
        [finalDictionary setObject:errorMessage forKey:NSLocalizedDescriptionKey];
    }
    
    return [NSError errorWithDomain:domain
                               code:code
                           userInfo:finalDictionary];
}

+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code message:(NSString *)errorMessage {
    return [NSError errorWithDomain:domain
                               code:code
                           userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorMessage, NSLocalizedDescriptionKey,nil]];
}

+ (id)errorWithException:(NSException *)exception {
    return [NSError errorWithDomain:TKErrorDomain
                               code:TKLocalErrorRaisedException
                           userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Raised Exception: %@ Reason: %@",exception.name, exception.reason], NSLocalizedDescriptionKey,nil]];
}

+ (id)errorWithURLRequestError:(NSError *)error {
    NSInteger errorCode = -1;
    NSString *errorMsg  = nil;
    
    switch (error.code) {
        case kCFURLErrorNetworkConnectionLost:
        case kCFURLErrorNotConnectedToInternet:
            errorCode = TKNetworkErrorNoConnection;
            errorMsg = [NSString stringWithFormat:@"Please check your internet connection. ErrorCode: %ld", (long)error.code];
            break;
            
        case kCFURLErrorUnknown:
        case kCFURLErrorCancelled:
        case kCFURLErrorBadURL:
        case kCFURLErrorTimedOut:
        case kCFURLErrorUnsupportedURL:
        case kCFURLErrorCannotFindHost:
        case kCFURLErrorCannotConnectToHost:
        case kCFURLErrorResourceUnavailable:
        case kCFURLErrorBadServerResponse:
        case kCFURLErrorZeroByteResource:
        case kCFURLErrorCannotDecodeRawData:
        case kCFURLErrorCannotDecodeContentData:
        case kCFURLErrorCannotParseResponse:
        case kCFURLErrorDataLengthExceedsMaximum:
        case 22: //from NSPOSIXErrorDomain
            errorMsg = [NSString stringWithFormat:@"Server is not responding. Please try again. ErrorCode: %ld", (long)error.code];
            errorCode = TKNetworkErrorServerIsUnreachable;
            break;
        default:
            errorCode = TKNetworkErrorServerIsUnreachable;
            errorMsg  = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
            break;
    }
    
    return [NSError errorWithCode:errorCode
                          message:errorMsg];
}

@end
