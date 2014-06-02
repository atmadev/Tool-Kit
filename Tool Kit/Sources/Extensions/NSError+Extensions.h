//
//  NSError+TKAdditions.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 2/25/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>


#define SetErrorAndReturn(__Error__, __ExternError__, __ReturnValue__) \
if (__ExternError__ != NULL) { \
*__ExternError__ = __Error__; \
} \
return __ReturnValue__;


#define CheckErrorAndReturn(__Error__, __ExternError__, __ReturnValue__) if (__Error__ != nil) { \
SetErrorAndReturn(__Error__, __ExternError__, __ReturnValue__); \
}

#define TKErrorDomainDefault NSStringFromClass(self.class)

@interface NSError (Extesnions)

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message;

+ (id)errorWithCode:(NSInteger)code message:(NSString *)errorMessage userInfo:(NSDictionary *)userInfo;

+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code message:(NSString *)errorMessage userInfo:(NSDictionary *)userInfo;
+ (id)errorWithDomain:(NSString *)domain code:(NSInteger)code message:(NSString *)errorMessage;

+ (id)errorWithException:(NSException *)exception;

- (NSString *)message;

- (BOOL)isNetworkProblem;
- (BOOL)isInvalidSession;

- (TKErrorCode)errorCode;

@end
