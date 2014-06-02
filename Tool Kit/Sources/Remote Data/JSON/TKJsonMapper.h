//
//  TKJsonMapper.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/7/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKRemoteEntity.h"


#define JSONMapper [TKJsonMapper mapper]


@interface TKJsonMapper : NSObject

+ (TKJsonMapper *)mapper;

- (id)parseJSONData:(NSData *)jsonData withClass:(Class)classOfObject error:(NSError **)anError;
- (id)parseJSONString:(NSString *)jsonString withClass:(Class)classOfObject error:(NSError **)anError;

- (NSData *)JSONDataFromRemoteEntity:(TKRemoteEntity *)remoteEntity error:(NSError **)error;
- (NSData *)JSONDataFromDictionary:(NSDictionary *)dictionary error:(NSError **)error;

@end


#pragma mark - Categories

@interface NSData (JSONMapperDeserializing)

- (id)remoteObjectWithClass:(Class)classOfObject error:(NSError **)error;

@end


@interface NSDictionary (JSONMapperDeserializing)

- (id)remoteObjectWithClass:(Class)classOfObject error:(NSError **)error;

@end


@interface NSString (JSONMapperDeserializing)

- (id)remoteObjectWithClass:(Class)classOfObject error:(NSError **)error;
- (id)objectFromJSONWithError:(NSError **)anError;

@end


@interface TKRemoteEntity (JSONMapperDeserializing)

+ (id)remoteObjectFromJSONData:(NSData *)jsonData error:(NSError **)error;

@end


@interface TKRemoteEntity (JSONMapperSerializing)

- (NSData *)JSONDataWithError:(NSError **)error;

@end


@interface NSDictionary (JSONMapperSerializing)

- (NSData *)JSONDataWithError:(NSError **)error;
- (NSString *)JSONStringWithError:(NSError **)error;

@end


@interface NSArray (JSONMapperSerializing)

- (NSData *)JSONDataWithError:(NSError **)error;

@end