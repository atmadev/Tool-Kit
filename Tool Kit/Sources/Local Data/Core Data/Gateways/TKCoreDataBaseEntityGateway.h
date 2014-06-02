//
//  TKBaseCoreDataEntityGateway.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/4/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKAbstractCoreDataEntityGateway.h"


@class NSRelationshipDescription;


@interface TKBaseCoreDataEntityGateway : TKAbstractCoreDataEntityGateway

- (NSArray *)objectsWithID:(NSNumber *)ID;

- (NSArray *)insertObjectsWithoutSaving:(NSArray *)sortedNewObjects
                  sortedExistingObjects:(NSArray *)existingObjects
                          isFirstInsert:(BOOL)isFirstInsert
                                  error:(NSError *__autoreleasing *)anError;

- (NSSet *)existingObjectIDsAmongIDs:(NSSet *)IDs;

- (NSArray *)objectsSortedByIDs:(id <TKCollection>)IDs
withRelationshipKeyPathsForPrefetching:(NSArray *)relationshipKeyPathsForPrefetching;

- (NSArray *)objectsWithIDs:(id <TKCollection>)IDs
withRelationshipKeyPathsForPrefetching:(NSArray *)relationshipKeyPathsForPrefetching;

- (void)mapRelationships;

- (NSRelationshipDescription *)relationshipForKey:(NSString *)key;
- (NSRelationshipDescription *)inverseRelationshipForKey:(NSString *)key;

@end
