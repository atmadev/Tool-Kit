//
//  TKCoreDataMapper.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/4/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKCoreData.h"
#import "TKCoreDataBaseEntityGateway.h"
#import "TKConstants.h"


NSString *const kExceptRelationshipKey = @"ExceptRelationship";
NSString *const kCDMapperShouldSkipKey = @"shouldSkip";


@implementation TKCoreDataMapper

static TKCoreDataMapper *_mapper = nil;

+ (TKCoreDataMapper *)mapper {
    if (_mapper == nil) {
        _mapper = [self new];
    }
    return _mapper;
}

- (NSManagedObject *)createManagedObjectFromObject:(id)inputObject
                                        entityName:(NSString *)entityName
                                          userInfo:(NSDictionary *)userInfo {
    
    return [self createManagedObjectFromObject:inputObject
                            exceptRelationship:nil
                                    entityName:entityName
                                      userInfo:userInfo];
}

- (NSManagedObject *)createManagedObjectFromObject:(id)inputObject
                                exceptRelationship:(NSRelationshipDescription *)relationship
                                        entityName:(NSString *)entityName
                                          userInfo:(NSDictionary *)userInfo {
    
    NSManagedObject *managedObject = [CoreDataGateway.registeredEntityGatewaysByEntityName[entityName] createObject];
                                      
    [self parseObject:inputObject exceptRelationship:relationship mergeChanges:NO userInfo:userInfo toManagedObject:managedObject];
    
    return managedObject;
}

- (void)parseObject:(id)inputObject
       mergeChanges:(BOOL)mergeChanges
           userInfo:(NSDictionary *)userInfo
    toManagedObject:(NSManagedObject *)nativeObject {
    
    [self parseObject:inputObject
   exceptRelationship:nil
         mergeChanges:mergeChanges
             userInfo:userInfo
      toManagedObject:nativeObject];
}

- (void)parseObject:(id)inputObject
 exceptRelationship:(NSRelationshipDescription *)relationship
       mergeChanges:(BOOL)mergeChanges
           userInfo:(NSDictionary *)userInfo
    toManagedObject:(NSManagedObject *)nativeObject {
    
    [self parseAttributesFromObject:inputObject
                           userInfo:userInfo
                    toManagedObject:nativeObject];
    
    [self parseRelationshipsFromObject:inputObject
                    exceptRelationship:relationship
                          mergeChanges:mergeChanges
                              userInfo:userInfo
                       toManagedObject:nativeObject];
}

- (void)parseAttributesFromObject:(id)inputObject
                         userInfo:(NSDictionary *)userInfo
                  toManagedObject:(NSManagedObject *)nativeObject {
    
    id dictionaryValue = nil;
    NSString *key = nil;
    
    for (NSAttributeDescription *attribute in nativeObject.entity.attributesByName.allValues) {
        key = attribute.name;
        
        if ([[attribute.userInfo valueForKey:kCDMapperShouldSkipKey] boolValue]) {
            continue;
        }
        
        dictionaryValue = [inputObject valueForKey:key];
        
        if (!dictionaryValue && attribute.defaultValue) {
            dictionaryValue = attribute.defaultValue;
        }
        
        [nativeObject setValue:dictionaryValue forKey:key];
    }
}


- (void)parseRelationshipsFromObject:(id)inputObject
                  exceptRelationship:(NSRelationshipDescription *)exceptRelationship
                        mergeChanges:(BOOL)mergeChanges
                            userInfo:(NSDictionary *)userInfo
                     toManagedObject:(NSManagedObject *)nativeObject {
    
    NSEntityDescription *entity = nativeObject.entity;
    
    id dictionaryValue = nil;
    id nativeValue = nil;
    NSString *key = nil;
    
    if (!exceptRelationship) {
        exceptRelationship = [userInfo objectForKey:kExceptRelationshipKey];
    }
    
    
    for (NSRelationshipDescription *relationship in entity.relationshipsByName.allValues) {
        
        key = relationship.name;
        
        if ([relationship isEqual:exceptRelationship]) { continue; }
        
        nativeValue = nil;
        
        dictionaryValue = [inputObject valueForKey:key];
        
        if (dictionaryValue != nil && ![dictionaryValue isEqual:[NSNull null]]) {
            
            TKAbstractCoreDataEntityGateway *gateway = relationship.destinationEntity.gateway;
            
            if (relationship.isToMany) {
                if ([[dictionaryValue class] isCollection]) {
                    if ([(NSObject <TKCollection> *)dictionaryValue count]) {
                        NSArray *newObjects = [gateway insertObjectsWithoutSaving:dictionaryValue
                                                                    isFirstInsert:!mergeChanges
                                                                         userInfo:@{kExceptRelationshipKey : relationship.inverseRelationship}
                                                                            error:nil];
                        if (relationship.isOrdered) {
                            //ordered retationships works without delta
                            nativeValue = [newObjects orderedSet];
                        }
                        else {
                            if ([[nativeObject valueForKey:key] count] == 0) {
                                nativeValue = [newObjects set];
                            }
                            else {
                                NSMutableSet *mutableSet = [nativeObject mutableSetValueForKey:key];
                                [mutableSet addObjectsFromArray:newObjects];
                            }
                        }
                    }
                }
                else {
                    DLog(@"ERROR: Wrong type \"%@\" for key \"%@\"; Must be a Collection", [dictionaryValue class], key);
                }
            }
            else {
                id existingObject = [nativeObject valueForKey:key];
                if (existingObject) {
                    nativeValue = [gateway insertObjectWithoutSaving:dictionaryValue
                                                       isFirstInsert:NO
                                                            userInfo:@{kExceptRelationshipKey : relationship.inverseRelationship}
                                                mergeChangesToObject:existingObject
                                                               error:nil];
                }
                else {
                    nativeValue = [gateway insertObjectWithoutSaving:dictionaryValue
                                                       isFirstInsert:NO
                                                            userInfo:@{kExceptRelationshipKey : relationship.inverseRelationship}
                                                               error:nil];
                }
            }
            if (nativeValue) {
                [nativeObject setValue:nativeValue forKey:key];
            }
        }
        else {
            //DLog(@"WARNING: Object for key \"%@\" is absent in the %@ structure", key, entity.name);
        }
    }
}

#pragma mark - Relationships Mapping

- (void)mapRelationshipsWithSortedParents:(NSArray *)parents
                       primaryParentIDKey:(NSString *)primaryParentIDKey
                           sortedChildren:(NSArray *)children
                     secondaryParentIDKey:(NSString *)secondaryParentIDKey
                       secondaryParentKey:(NSString *)secondaryParentKey {
    
    if (parents.count == 0 || children.count == 0) {
        return;
    }
    
    NSAssert(primaryParentIDKey, @"primaryParentIDKey can't be nil");
    NSAssert(secondaryParentIDKey, @"secondaryParentIDKey can't be nil");
    NSAssert(secondaryParentKey, @"secondaryParentKey can't be nil");
    
    NSEnumerator *parentEnumerator = [parents objectEnumerator];
    id parent = [parentEnumerator nextObject];
    
    NSEnumerator *childEnumerator = [children objectEnumerator];
    id child = [childEnumerator nextObject];
    
    NSNumber *primaryParentID = [parent valueForKey:primaryParentIDKey];
    NSNumber *secondaryParentID = [child valueForKey:secondaryParentIDKey];
    
    while (child && parent) {
        switch ([secondaryParentID compare:primaryParentID]) {
                
            case NSOrderedSame: {
                [child setValue:parent forKey:secondaryParentKey];
                child = [childEnumerator nextObject];
                secondaryParentID = [child valueForKey:secondaryParentIDKey];
            }
                break;
                
            case NSOrderedDescending: {
                //Skip parent because current child has greater id, so next parent can be parent of current child
                parent = [parentEnumerator nextObject];
                primaryParentID = [parent valueForKey:primaryParentIDKey];
            }
                break;
                
            case NSOrderedAscending: {
                //else just go to the next child because current parrent has greater id, so next child can be a child of the current parent
                child = [childEnumerator nextObject];
                secondaryParentID = [child valueForKey:secondaryParentIDKey];
            }
                break;
        }
    }
}

- (void)mapOneToManyRelationship:(NSRelationshipDescription *)relationship
            secondaryParentIDKey:(NSString *)secondaryParentIDKey {
    
    NSString * secondaryParentKey = relationship.inverseRelationship.name;
    
    
    TKBaseCoreDataEntityGateway * childrenGateway = relationship.destinationEntity.gateway;
    NSArray *children = [childrenGateway objectsWithPredicateString:@"%K == nil && %K != nil"
                                                          arguments:@[secondaryParentKey, secondaryParentIDKey]
                                                           sortKeys:@[secondaryParentIDKey]];
    
    TKBaseCoreDataEntityGateway * parentGateway = relationship.entity.gateway;
    
    NSArray * parentIDs = [children valueForKey:secondaryParentIDKey];
    
    NSArray * parents = [parentGateway objectsSortedByIDs:parentIDs
                    withRelationshipKeyPathsForPrefetching:@[relationship.name]];
    
    
    [self mapRelationshipsWithSortedParents:parents
                       primaryParentIDKey:@"id"
                           sortedChildren:children
                     secondaryParentIDKey:secondaryParentIDKey
                       secondaryParentKey:secondaryParentKey];
}


//Optimize, improve Code readability

- (void)mapRelationship:(NSRelationshipDescription *)relationship
         inverseObjects:(NSArray *)inverseObjects
 usingDestinationIDsKey:(NSString *)destinationIDsKey {
    
    if (!inverseObjects.count) { return; }
    
    TKBaseCoreDataEntityGateway *gateway = relationship.destinationEntity.gateway;
    if (!gateway.objectsCount) { return; }
    
    NSMutableSet *allDestinationIDs = [NSMutableSet set];
    
    for (id object in inverseObjects) {
        [allDestinationIDs unionSet:[object valueForKey:destinationIDsKey]];
        NSSet *mappedObjects = [object valueForKey:relationship.name];
        if (mappedObjects.count) {
            [allDestinationIDs unionSet:[mappedObjects valueForKey:kIDKey]];
        }
    }
    
    [self mapRelationship:relationship
           inverseObjects:inverseObjects
   usingDestinationIDsKey:destinationIDsKey
       destinationObjects:[gateway objectsWithIDs:allDestinationIDs
           withRelationshipKeyPathsForPrefetching:@[relationship.inverseRelationship.name]]];
}

- (void)mapRelationship:(NSRelationshipDescription *)relationship
         inverseObjects:(NSArray *)inverseObjects
 usingDestinationIDsKey:(NSString *)destinationIDsKey
     destinationObjects:(NSArray *)destinationObjects {
    
    if (!inverseObjects.count || !destinationObjects.count) { return; }
    NSAssert(relationship, @"relationship can't be nil");
    NSAssert(destinationIDsKey, @"destinationIDsKey can't be nil");
    
    NSString *destinationRelationKey = relationship.name;
    
    NSDictionary *destinationObjectsByID = [NSDictionary dictionaryWithObjects:destinationObjects forKeys:[destinationObjects valueForKey:kIDKey]];
    for (id inverseObject in inverseObjects) {
        
        NSSet *existingDestinationObjectIDs = [[inverseObject valueForKey:relationship.name] valueForKey:kIDKey];
        NSSet *destinationObjectIDsToMap = [inverseObject valueForKey:destinationIDsKey];
        
        //Delete unmapped fromObjects
        NSMutableSet *destinationObjectIDsToRemove = [existingDestinationObjectIDs mutableSet];
        [destinationObjectIDsToRemove minusSet:destinationObjectIDsToMap];
        
        NSMutableSet *destinationObjectsToMap = [inverseObject mutableSetValueForKey:destinationRelationKey];
        for (NSNumber *objectID in destinationObjectIDsToRemove) {
            id destinationObject = destinationObjectsByID[objectID];
            if (destinationObject) {
                [destinationObjectsToMap removeObject:destinationObject];
            }
        }
        
        NSMutableSet *destinationObjectIDsToAdd = [destinationObjectIDsToMap mutableSet];
        [destinationObjectIDsToAdd minusSet:existingDestinationObjectIDs];
        
        //Map new fromObjects
        for (NSNumber *objectID in destinationObjectIDsToAdd) {
            id destinationObject = destinationObjectsByID[objectID];
            if (destinationObject) {
                [destinationObjectsToMap addObject:destinationObject];
            }
        }
    }
}

@end
