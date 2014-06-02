//
//  TKCoreDataContext.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 4/7/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKCoreDataContext.h"
#import "TKCoreData.h"
#import "TKAbstractCoreDataEntityGateway.h"


@implementation TKAbstractCoreDataContext

- (id)createObjectWithEntityName:(NSString *)entityName {
    
    id object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.context];
    
    TKAbstractCoreDataEntityGateway * gateway = CoreDataGateway.registeredEntityGatewaysByEntityName[entityName];
    [gateway applyDefaultSettingsForObject:object];
    
    return object;
}

- (id)insertObject:(id)object forEntityName:(NSString *)entityName {
    if ([object isKindOfClass:[NSManagedObject class]]) {
        return object;
    }
    
    id insertedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.context];
    
    NSError *error = nil;
    
    TKAbstractCoreDataEntityGateway * gateway = CoreDataGateway.registeredEntityGatewaysByEntityName[entityName];
    [gateway mapObject:object
         isFirstInsert:NO
              userInfo:nil
  mergeChangesToObject:insertedObject
                 error:&error];
    if (error) {
        DLog(@"ERROR: %@", error);
        return nil;
    }
    
    return insertedObject;
}

- (void)deleteObject:(id)object {
    [self.context deleteObject:object];
}

- (id)internalObjectFromContainer:(id)objectContainer {
    if (objectContainer == nil) return nil;
    return [self.context objectWithID:objectContainer];
}

- (BOOL)save:(NSError **)anError {
    return [self.context save:anError];
}

- (void)rollback {
    [self.context rollback];
}

- (BOOL)hasChanges {
    return [self.context hasChanges];
}

- (NSSet *)registeredObjects {
    return [self.context registeredObjects];
}

@end


@implementation TKBaseCoreDataContext

- (id)init {
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (NSManagedObjectContext *)context {
    if (!_context) {
        _context = [CoreDataGateway createAndRegisterManagedObjectContextWithType:NSMainQueueConcurrencyType];
    }
    
    return _context;
}

- (void)dealloc {
    [CoreDataGateway unregisterManagedObjectContext:self.context];
}

@end


@implementation TKCoreDataNestedContext

- (NSManagedObjectContext *)context {
    if (!_context) {
        _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    }
    
    return _context;
}

- (void)setParentDataContext:(TKAbstractCoreDataContext *)dataContext {
    _parentDataContext = dataContext;
    self.context.parentContext = [dataContext context];
}

@end


@implementation TKCoreDataCurrentContext

static TKCoreDataCurrentContext * _currentContext = nil;

+ (TKCoreDataCurrentContext *)currentContext {
    if (!_currentContext) {
        _currentContext = [self new];
    }
    return _currentContext;
}

- (NSManagedObjectContext *)context {
    return [CoreDataGateway managedObjectContext];
}

@end
