//
//  TKCoreDataGateway.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/4/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKCoreData.h"


@class TKAbstractCoreDataEntityGateway;


#define CoreDataGateway [TKCoreDataGateway gateway]


@interface TKCoreDataGateway : NSObject

@property (nonatomic, retain) NSString *dataBaseName;
@property (nonatomic, retain, readonly) NSDictionary *registeredEntityGatewaysByEntityName;

+ (TKCoreDataGateway *)gateway;

- (NSManagedObjectContext *)managedObjectContext;
- (BOOL)saveContext:(NSError **)error;

- (void)clearDataBase;

- (void)registerEntityGateway:(TKAbstractCoreDataEntityGateway *)entityGateway;
- (void)registerEntityGateways:(NSDictionary *)entityGatewaysByEntityName;

#pragma mark - Safe Working With Context

- (BOOL)isProvidedContextForCurrentThread;

- (BOOL)openTransaction;
- (void)closeTransaction;

- (NSManagedObjectContext *)createAndRegisterManagedObjectContextWithType:(NSManagedObjectContextConcurrencyType)type;
- (void)unregisterManagedObjectContext:(NSManagedObjectContext *)context;

@end


@interface TKCoreDataGateway (Requests)

#pragma mark - Getters For Managed Objects

- (id)objectForID:(NSManagedObjectID *)objectID;

- (id)objectWithEntityName:(NSString *)name
                    ofType:(NSFetchRequestResultType)type;

- (id)objectWithEntityName:(NSString *)name
           predicateString:(NSString *)predicateString
                 arguments:(NSArray *)arguments
                    ofType:(NSFetchRequestResultType)type;

- (NSArray *)objectsWithEntityName:(NSString *)name
                   predicateString:(NSString *)predicateString
                         arguments:(NSArray *)arguments
                            ofType:(NSFetchRequestResultType)type;

- (NSArray *)objectsWithEntityName:(NSString *)name
                   predicateString:(NSString *)predicateString
                         arguments:(NSArray *)arguments
                          sortKeys:(NSArray *)sortKeys
                            ofType:(NSFetchRequestResultType)type;

- (NSArray *)performRequest:(NSFetchRequest *)request;

#pragma mark - Creatng Requests

- (NSFetchRequest *)fetchRequestForObjectsWithEntityName:(NSString *)name
                                         predicateString:(NSString *)predicateString
                                               arguments:(NSArray *)arguments
                                                sortKeys:(NSArray *)sortKeys
                                                   limit:(NSUInteger)limit
                                                  ofType:(NSFetchRequestResultType)type;
- (NSArray *)sortDescriptorsFromSortkeys:(NSArray *)sortKeys;

#pragma mark - Creating Managed Objects

- (id)createObjectWithEntityName:(NSString *)entityName;
- (NSEntityDescription *)entityDescriptionWithName:(NSString *)entityName;

#pragma mark - Deleting Managed Objects

- (void)deleteObject:(NSManagedObject *)object;

@end


@interface NSMutableString (PredicateString)

- (void)appendANDIfNeed;
- (void)appendPredicateString:(NSString *)predicateString;

@end


@interface NSEntityDescription (Gateway)

- (id)gateway;

@end
