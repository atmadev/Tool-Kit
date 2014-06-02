//
//  TKBaseCoreDataEntityGateway.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/4/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKCoreDataBaseEntityGateway.h"
#import "TKAbstractCoreDataEntityGatewayProtected.h"
#import "TKBaseEntity.h"


@implementation TKBaseCoreDataEntityGateway

- (NSArray *)objectsSortedByID {
    return [self objectsWithPredicateString:nil
                                  arguments:nil
                                   sortKeys:@[@"id"]
                                     ofType:NSManagedObjectResultType];
}


- (NSArray *)objectsWithIDs:(id <TKCollection>)IDs {
    NSAssert(IDs, @"IDs can't be nil");
    return [self objectsWithPredicateString:@"id IN %@"
                                  arguments:@[IDs]];
}

- (NSArray *)objectsWithIDs:(id <TKCollection>)IDs  withRelationshipKeyPathsForPrefetching:(NSArray *)relationshipKeyPathsForPrefetching {
    NSAssert(IDs, @"IDs can't be nil");
    NSAssert(relationshipKeyPathsForPrefetching, @"relationshipKeyPathsForPrefetching can't be nil");
    NSFetchRequest *request = [CoreDataGateway fetchRequestForObjectsWithEntityName:self.entityName
                                                                      predicateString:@"id IN %@"
                                                                            arguments:@[ IDs ]
                                                                             sortKeys:nil
                                                                                limit:0
                                                                               ofType:NSManagedObjectResultType];
    request.returnsObjectsAsFaults = NO;
    request.relationshipKeyPathsForPrefetching = relationshipKeyPathsForPrefetching;
    
    return [CoreDataGateway performRequest:request];
}


- (NSArray *)sortedObjectsWithIDs:(id <TKCollection>)IDs {
    NSAssert(IDs, @"IDs can't be nil");
    return [self objectsWithPredicateString:@"id IN %@"
                                  arguments:@[ IDs ]
                                   sortKeys:@[ @"id" ]];
}

- (NSArray *)objectsSortedByIDs:(id <TKCollection>)IDs withRelationshipKeyPathsForPrefetching:(NSArray *)relationshipKeyPathsForPrefetching {
    NSAssert(IDs, @"IDs can't be nil");
    NSAssert(relationshipKeyPathsForPrefetching, @"relationshipKeyPathsForPrefetching can't be nil");
    NSFetchRequest *request = [CoreDataGateway fetchRequestForObjectsWithEntityName:self.entityName
                                                                      predicateString:@"id IN %@"
                                                                            arguments:@[ IDs ]
                                                                             sortKeys:@[ @"id" ]
                                                                                limit:0
                                                                               ofType:NSManagedObjectResultType];
    request.returnsObjectsAsFaults = NO;
    request.relationshipKeyPathsForPrefetching = relationshipKeyPathsForPrefetching;
    
    return [CoreDataGateway performRequest:request];
}

#pragma mark -

- (id)insertObjectWithoutSaving:(id)object
                  isFirstInsert:(BOOL)isFirstInsert
                       userInfo:(NSDictionary *)userInfo
                          error:(NSError *__autoreleasing *)anError {
    
    id existingObject = isFirstInsert ? nil : [self objectWithID:[object valueForKey:@"id"]];
    
    return [self insertObjectWithoutSaving:object
                             isFirstInsert:isFirstInsert
                                  userInfo:nil
                      mergeChangesToObject:existingObject
                                     error:anError];
}

- (NSArray *)insertObjectsWithoutSaving:(id <TKCollection>)objects
                          isFirstInsert:(BOOL)isFirstInsert
                               userInfo:(NSDictionary *)userInfo
                                  error:(NSError *__autoreleasing *)anError {
    
    NSArray * returningObjects = nil;
    
    if (!isFirstInsert) {
        NSArray *sortedNewObjects = [objects sortedArrayUsingDescriptorKeys:@[@"id"]];
        NSArray *newIDs = [sortedNewObjects valueForKey:@"id"];
        
        NSMutableArray * mutableIDs = [NSMutableArray array];
        
        for (id newID in newIDs) {
            if ([newID respondsToSelector:@selector(intValue)]) {
                [mutableIDs addObject:newID];
            }
        }
        
        newIDs = mutableIDs;
        
        /*
#ifdef DEBUG
        for (id newID in newIDs) {
            NSAssert([newID respondsToSelector:@selector(intValue)], @"%@. Invalid id value class '%@'. Must support intValue", [self class], [newIDs class]);
        }
#endif*/
        
        NSArray *existingObjects = [self objectsWithPredicateString:@"id IN %@"
                                                          arguments:@[newIDs]
                                                           sortKeys:@[@"id"]
                                                             ofType:NSManagedObjectResultType];
        
        returningObjects = [self insertObjectsWithoutSaving:sortedNewObjects
                                      sortedExistingObjects:existingObjects
                                              isFirstInsert:isFirstInsert
                                                      error:anError];
    }
    else {
        returningObjects = [super insertObjectsWithoutSaving:objects
                                               isFirstInsert:isFirstInsert
                                                    userInfo:userInfo
                                                       error:anError];
    }
    
    [self mapRelationships];
    
    return returningObjects;
}

- (void)mapRelationships {
    
}

- (NSRelationshipDescription *)relationshipForKey:(NSString *)key {
    return self.entityDescription.relationshipsByName[key];
}

- (NSRelationshipDescription *)inverseRelationshipForKey:(NSString *)key {
    return [[self relationshipForKey:key] inverseRelationship];
}

/*
 * Very cool algoritm for checking existing objects
 * https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/CoreData/Articles/cdImporting.html#//apple_ref/doc/id/TP40003174-SW4
 */
- (NSArray *)insertObjectsWithoutSaving:(NSArray *)sortedNewObjects
                  sortedExistingObjects:(NSArray *)existingObjects
                          isFirstInsert:(BOOL)isFirstInsert
                                  error:(NSError *__autoreleasing *)anError {
    
    NSEnumerator *existingObjectEnumerator = [existingObjects objectEnumerator];
    NSObject <TKBaseEntity> * existingObject = [existingObjectEnumerator nextObject];
    
    NSError *error = nil;
    NSMutableArray *returningObjects = [NSMutableArray arrayWithCapacity:sortedNewObjects.count];
    
    id insertedObject = nil;
    
    for (NSObject <TKBaseEntity> * newObject in sortedNewObjects) {
        
        if (!newObject.id) {
            continue;
        }
        
        BOOL isUpdate = [existingObject.id isEqualToNumber:newObject.id];
        
        insertedObject = [self insertObjectWithoutSaving:newObject
                                           isFirstInsert:!isUpdate
                                                userInfo:nil
                                    mergeChangesToObject:isUpdate ? existingObject : nil
                                                   error:&error];
        if (insertedObject) {//Object can be deleted, so insert metod will not return it in this case
            [returningObjects addObject:insertedObject];
        }
        
        CheckErrorAndReturn(error, anError, nil)
        
        if (isUpdate) { // If we did update currrent existing object, then we don't need it any more.
            existingObject = [existingObjectEnumerator nextObject];
        }
    }
    
    return returningObjects;
}

- (id)objectWithID:(NSNumber *)ID {
    return [self objectWithID:ID ofType:NSManagedObjectResultType];
}

- (id)objectWithID:(NSNumber *)ID ofType:(NSFetchRequestResultType)type {
    NSAssert(ID, @"id can't be nil");
    return [self objectWithPredicateString:@"id == %@"
                                 arguments:@[ID]
                                    ofType:type];
}

- (NSArray *)objectsWithID:(NSNumber *)ID {
    return [self objectsWithPredicateString:@"id == %@"
                                  arguments:@[ID]
                                     ofType:NSManagedObjectResultType];
}

- (NSSet *)existingObjectIDsAmongIDs:(NSSet *)IDs {
    NSAssert(IDs, @"IDs can't be nil");
    NSFetchRequest *fetchRequest = [CoreDataGateway fetchRequestForObjectsWithEntityName:self.entityName
                                                                           predicateString:@"id IN %@"
                                                                                 arguments:@[IDs]
                                                                                  sortKeys:nil
                                                                                     limit:0
                                                                                    ofType:NSDictionaryResultType];
    fetchRequest.returnsDistinctResults = YES;
    fetchRequest.propertiesToFetch = @[@"id"];
    
    return [(id<TKCollection>)[[CoreDataGateway performRequest:fetchRequest] valueForKey:@"id"] set];
}

- (BOOL)containsObjectWithID:(NSNumber *)ID  {
    return [[self objectWithPredicateString:@"id == %@" arguments:@[ID] ofType:NSCountResultType] boolValue];
}

- (NSArray *)objectIDs {
    NSFetchRequest *request = [CoreDataGateway fetchRequestForObjectsWithEntityName:self.entityName
                                                                      predicateString:nil
                                                                            arguments:nil
                                                                             sortKeys:nil
                                                                                limit:0
                                                                               ofType:NSDictionaryResultType];
    request.returnsDistinctResults = YES;
    request.propertiesToFetch = @[@"id"];
    
    NSArray *result = [CoreDataGateway performRequest:request];
    result = [result valueForKey:@"id"];
    
    return result;
}

@end
