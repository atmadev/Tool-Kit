//
//  TKAbstractCoreDataEntityGatewayProtected.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/4/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKAbstractCoreDataEntityGateway.h"
#import <Foundation/Foundation.h>
#import "TKCoreData.h"

#define EntityName(__Name__) NSStringFromProtocol(@protocol(__Name__))

#define TK_ENTITY_GATEWAY_SINGLETON_INIT(__protocol__) \
\
static id _gateway;\
\
+ (id)gateway {\
if (_gateway == nil) {\
_gateway = [self new];\
}\
return _gateway;\
}\
\
- (NSString *)entityName {\
return EntityName(__protocol__);\
}\


@interface TKAbstractCoreDataEntityGateway ()

@property (nonatomic, strong) NSMutableDictionary *cacheContainer;

- (id)mapObject:(id)object isFirstInsert:(BOOL)isFirstInsert
       userInfo:(NSDictionary *)userInfo
mergeChangesToObject:(id)existingObject
          error:(NSError **)anError;

- (void)deleteObjectWithoutSaving:(id)object;

- (NSEntityDescription *)entityDescription;

#pragma mark - Internal Fetching

- (id)objectOfType:(NSFetchRequestResultType)type;

- (id)objectWithPredicateString:(NSString *)predicateString
                      arguments:(NSArray *)arguments
                         ofType:(NSFetchRequestResultType)type;


- (NSArray *)objectsOfType:(NSFetchRequestResultType)type;

- (NSArray *)objectsWithPredicateString:(NSString *)predicateString
                              arguments:(NSArray *)arguments
                                 ofType:(NSFetchRequestResultType)type;

- (NSArray *)objectsWithPredicateString:(NSString *)predicateString
                              arguments:(NSArray *)arguments
                               sortKeys:(NSArray *)sortKeys
                                 ofType:(NSFetchRequestResultType)type;

#pragma mark - Internal Notifications

- (void)postDidChangeNotification;

@end
