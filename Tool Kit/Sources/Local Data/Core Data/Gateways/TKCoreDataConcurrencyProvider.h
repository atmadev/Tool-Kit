//
//  TKCoreDataConcurrencyProvider.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/4/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//@class CDPrivateManagedObjectContextContainer;


@interface TKCoreDataConcurrencyProvider : NSObject

- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator;

- (NSManagedObjectContext *)managedObjectContext;

- (BOOL)isProvidedContextForCurrentThread;

- (NSManagedObjectContext *)createAndRegisterManagedObjectContextWithType:(NSManagedObjectContextConcurrencyType)type;
- (void)unregisterManagedObjectContext:(NSManagedObjectContext *)context;

- (BOOL)save:(NSError **)error;

- (BOOL)openTransaction;
- (void)closeTransaction;

@end