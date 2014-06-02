//
//  TKCoreDataConcurrencyProvider.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/4/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKCoreDataConcurrencyProvider.h"
#import <CoreData/CoreData.h>


@interface TKCoreDataConcurrencyProvider ()

@property (nonatomic, retain) NSMutableDictionary *managedObjectsContextsByQueueKey;
@property (nonatomic, retain) NSManagedObjectContext *mainManagedObjectContext;

@property (nonatomic, retain) NSCountedSet *openedTransactions;

@property (nonatomic, strong) NSMutableArray *registeredContexts;

- (void)addObserverOfContext:(NSManagedObjectContext *)context;
- (void)removeObserverOfContext:(NSManagedObjectContext *)context;

- (id)currentQueueKey;
- (id)currentThreadKey;
- (id)keyOfPointer:(void *)pointer;

@end


@implementation TKCoreDataConcurrencyProvider

- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator {
    self = [super init];
    if (self) {
        
        self.openedTransactions = [NSCountedSet set];
        
        NSManagedObjectContext *mainManagedObjectContext = [NSManagedObjectContext new];
        
        mainManagedObjectContext.persistentStoreCoordinator = coordinator;
        mainManagedObjectContext.undoManager = nil;
        mainManagedObjectContext.retainsRegisteredObjects = NO;
        mainManagedObjectContext.mergePolicy = [[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicyType];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mergeChangesFromContextDidSaveNotification:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:mainManagedObjectContext];
        
        self.mainManagedObjectContext = mainManagedObjectContext;
        
        self.managedObjectsContextsByQueueKey = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                 mainManagedObjectContext, [self keyOfPointer:(__bridge void *)dispatch_get_main_queue()],
                                                 mainManagedObjectContext, [self keyOfPointer:(__bridge void *)([NSThread mainThread])], nil];
        
        self.registeredContexts = [NSMutableArray array];
    }
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.managedObjectsContextsByQueueKey = nil;
    self.mainManagedObjectContext = nil;
    self.openedTransactions = nil;
}

#pragma mark;

- (NSManagedObjectContext *)managedObjectContext {
    
    id primaryKey = nil;
    id secondaryKey = nil;
    
    if ([NSThread isMainThread]) {
        primaryKey = self.currentQueueKey;
        secondaryKey = self.currentThreadKey;
    }
    else {
        primaryKey = self.currentThreadKey;
        secondaryKey = self.currentQueueKey;
    }
    
    NSManagedObjectContext *context = [self.managedObjectsContextsByQueueKey objectForKey:primaryKey] ?:
    [self.managedObjectsContextsByQueueKey objectForKey:secondaryKey];
    
    if (!context) {
        @throw [NSException exceptionWithName:@"Core Data Concurrency Exception"
                                       reason:@"Managed Object Context is absent for current queue/thread"
                                     userInfo:@{@"Current thread key"   : [self currentThreadKey],
                                                @"Current queue key"    : [self currentQueueKey],
                                                @"Contexts"             : self.managedObjectsContextsByQueueKey.description}];
    }
    
    return context;
}

- (BOOL)isProvidedContextForCurrentThread {
    return [self.managedObjectsContextsByQueueKey objectForKey:[self currentQueueKey]] != nil ||
    [self.managedObjectsContextsByQueueKey objectForKey:[self currentThreadKey]] != nil;
}

- (id)currentQueueKey {
    return [self keyOfPointer:(__bridge void *)(dispatch_get_current_queue())];
}

- (id)currentThreadKey {
    return [self keyOfPointer:(__bridge void *)([NSThread currentThread])];
}

- (id)keyOfPointer:(void *)pointer {
    return [NSValue valueWithPointer:pointer];
}

#pragma mark -

- (void)addObserverOfContext:(NSManagedObjectContext *)context {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeChangesFromContextDidSaveNotification:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:context];
}

- (void)removeObserverOfContext:(NSManagedObjectContext *)context {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:context];
}

- (void)mergeChangesFromContextDidSaveNotification:(NSNotification *)notification {
    [self mergeChangesToMainContext:notification];
    [self mergeChangesToPrivateContexts:notification];
}

- (void)mergeChangesToMainContext:(NSNotification *)notification {
    if ([notification object] != self.mainManagedObjectContext) {
        dispatch_block_t block = ^{
            [self.mainManagedObjectContext mergeChangesFromContextDidSaveNotification:notification];
        };
        
        if ([NSThread isMainThread]) {
            block();
        }
        else {
            dispatch_sync(dispatch_get_main_queue(), block);
        }
    }
}

//Only for registered managed object contexts. It's not implemented for transaction contexts.
- (void)mergeChangesToPrivateContexts:(NSNotification *)notification {
    for (NSManagedObjectContext *context in self.registeredContexts) {
        if (context != [notification object]) {
            [context performBlockAndWait:^{
                [context mergeChangesFromContextDidSaveNotification:notification];
            }];
        }
    }
}

#pragma mark -

- (NSManagedObjectContext *)createAndRegisterManagedObjectContextWithType:(NSManagedObjectContextConcurrencyType)type; {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
    context.persistentStoreCoordinator = self.managedObjectContext.persistentStoreCoordinator;
    context.mergePolicy = [[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicyType];
    [context performBlockAndWait:^{
        [self.managedObjectsContextsByQueueKey setObject:context forKey:[self currentQueueKey]];
    }];
    
    [self.registeredContexts addObject:context];
    [self addObserverOfContext:context];
    
    return context;
}

- (void)unregisterManagedObjectContext:(NSManagedObjectContext *)context {
    [self removeObserverOfContext:context];
    [self.registeredContexts removeObject:context];
    
    [context performBlockAndWait:^{
        [self.managedObjectsContextsByQueueKey removeObjectForKey:[self currentQueueKey]];
    }];
}

#pragma mark -

- (BOOL)save:(NSError *__autoreleasing *)error {
    return [self.managedObjectContext save:error];
}

- (BOOL)openTransaction {
    [self.openedTransactions addObject:[self currentThreadKey]];
    
    NSManagedObjectContext *context = [self.managedObjectsContextsByQueueKey objectForKey:[self currentThreadKey]];
    
    if (!context) {
        context = [NSManagedObjectContext new];
        context.persistentStoreCoordinator = self.mainManagedObjectContext.persistentStoreCoordinator;
        context.mergePolicy = [[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicyType];
        [self.managedObjectsContextsByQueueKey setObject:context forKey:[self currentThreadKey]];
        
        [self addObserverOfContext:context];
    }
    
    return context != nil;
}

- (void)closeTransaction {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error = nil;
    
    [context save:&error];
    if (error) {
        DLog(@"CORE DATA SAVE ERROR: %@", error);
    }
    
    if ([self.openedTransactions countForObject:[self currentThreadKey]] == 0 && context) {
        
        [self removeObserverOfContext:context];
        [context reset];
        [self.managedObjectsContextsByQueueKey removeObjectForKey:[self currentThreadKey]];
    }
    
    [self.openedTransactions removeObject:[self currentThreadKey]];
}

@end
