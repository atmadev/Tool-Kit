//
//  TKAbstractCoreDataEntityGateway.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/4/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKAbstractCoreDataEntityGatewayProtected.h"


@implementation TKAbstractCoreDataEntityGateway

@synthesize entityDescription = _entityDescription;
@synthesize cacheContainer = _cacheContainer;

- (id)init {
    self = [super init];
    if (self) {
        self.cacheContainer = [NSMutableDictionary dictionary];
        [CoreDataGateway registerEntityGateway:self];
    }
    return self;
}

#pragma mark - Fetching

- (BOOL)containsObjects {
    return [self objectOfType:NSManagedObjectIDResultType] != nil;
}

- (id)anyObject {
    return [self objectOfType:NSManagedObjectResultType];
}

- (id)objectWithPredicateString:(NSString *)predicateString
                      arguments:(NSArray *)arguments {
    return [self objectWithPredicateString:predicateString
                                 arguments:arguments
                                    ofType:NSManagedObjectResultType];
}


- (NSNumber *)objectsCount {
    return [[self objectsOfType:NSCountResultType] lastObject];
}


- (NSArray *)objects {
	return [self objectsOfType:NSManagedObjectResultType];
}

- (NSArray *)objectsWithPredicateString:(NSString *)predicateString
                              arguments:(NSArray *)arguments {
    return [self objectsWithPredicateString:predicateString
                                  arguments:arguments
                                     ofType:NSManagedObjectResultType];
}

- (NSArray *)objectsWithPredicateString:(NSString *)predicateString
                              arguments:(NSArray *)arguments
                               sortKeys:(NSArray *)sortKeys {
    
    return [self objectsWithPredicateString:predicateString
                                  arguments:arguments
                                   sortKeys:sortKeys
                                     ofType:NSManagedObjectResultType];
}

#pragma mark - Creating

- (id)createObject {
	id object = [CoreDataGateway createObjectWithEntityName:self.entityName];
	[self applyDefaultSettingsForObject:object];
	return object;
}

- (void)applyDefaultSettingsForObject:(id)object {
    
    NSAttributeDescription *attribute = nil;
    NSDictionary *attributesByName = self.entityDescription.attributesByName;
    
    for (NSString *name in self.entityDescription.attributesByName) {
        attribute = attributesByName[name];
        if (attribute.defaultValue) {
            [object setValue:attribute.defaultValue forKey:name];
        }
    }
}

- (void)refreshObject:(id)object {
    [[CoreDataGateway managedObjectContext] refreshObject:[object originalObject] mergeChanges:YES];
}

- (NSEntityDescription *)entityDescription {
    if (!_entityDescription) {
        _entityDescription = [CoreDataGateway entityDescriptionWithName:self.entityName];
    }
    return _entityDescription;
}


#pragma mark - Inserting

- (id)mapObject:(id)inputObject
  isFirstInsert:(BOOL)isFirstInsert
       userInfo:(NSDictionary *)userInfo
mergeChangesToObject:(id)existingObject
          error:(NSError *__autoreleasing *)anError  {
    
    id returningObject = nil;
    if (inputObject) {
        if (isFirstInsert) {
            returningObject = [CoreDataMapper createManagedObjectFromObject:inputObject entityName:self.entityName userInfo:userInfo];
        }
        else {
            returningObject = existingObject;
            if (existingObject) {
                [CoreDataMapper parseObject:inputObject
                               mergeChanges:YES
                                   userInfo:userInfo
                            toManagedObject:existingObject];
            }
            else {
                //DLog(@"CORE DATA ERROR! Missing existing object for object %@", inputObject);
                returningObject = [CoreDataMapper createManagedObjectFromObject:inputObject
                                                                       entityName:self.entityName
                                                                         userInfo:userInfo];
            }
            
        }
        
        //DSimpleLog(@"Mapped object:\n%@", returningObject);
    }
    
    return returningObject;
}

- (id)insertObjectWithoutSaving:(id)object
                  isFirstInsert:(BOOL)isFirstInsert
                       userInfo:(NSDictionary *)userInfo
           mergeChangesToObject:(id)existingObject
                          error:(NSError *__autoreleasing *)anError {
    
    if ([object isKindOfClass:[NSManagedObject class]]) {
        return object;
    }
    
    NSError *error = nil;
    id returningObject = [self mapObject:object isFirstInsert:isFirstInsert userInfo:userInfo mergeChangesToObject:existingObject error:&error];
    if (error != nil) {
        
        if (anError != NULL) {
            *anError = error;
        }
        
        return nil;
    }
    
    return returningObject;
}

- (id)insertObjectWithoutSaving:(id)object
                  isFirstInsert:(BOOL)isFirstInsert
                       userInfo:(NSDictionary *)userInfo
                          error:(NSError *__autoreleasing *)anError {
    
    return [self insertObjectWithoutSaving:object
                             isFirstInsert:isFirstInsert
                                  userInfo:nil
                      mergeChangesToObject:nil
                                     error:anError] ;
}

- (id)insertObjectWithoutSaving:(id)object
                  isFirstInsert:(BOOL)isFirstInsert
                          error:(NSError *__autoreleasing *)anError {
    
    return [self insertObjectWithoutSaving:object
                             isFirstInsert:isFirstInsert
                                  userInfo:nil
                                     error:anError] ;
}

- (id)updateObject:(id)existingObject withObject:(id)newObject error:(NSError **)anError; {
    
    NSError * error = nil;
    
    id returningObject = [self insertObjectWithoutSaving:newObject
                                           isFirstInsert:NO
                                                userInfo:nil
                                    mergeChangesToObject:existingObject
                                                   error:&error];
    CheckErrorAndReturn(error, anError, nil);
    
    [CoreDataGateway saveContext:&error];
    CheckErrorAndReturn(error, anError, nil);
    
    return returningObject;
}

- (NSArray *)updateObjects:(NSArray *)existingObjects withObjects:(NSArray *)newObjects error:(NSError **)anError {
    
    NSError * error = nil;
    
    NSMutableArray * returningObjects = [NSMutableArray arrayWithCapacity:existingObjects.count];
    
    NSEnumerator * existingEnumerator = [existingObjects objectEnumerator];
    NSEnumerator * newEnumerator = [newObjects objectEnumerator];
    
    id existingObject = [existingEnumerator nextObject];
    id newObject = [newEnumerator nextObject];
    
    while (existingObject && newObject) {
        id returningObject = [self insertObjectWithoutSaving:newObject
                                               isFirstInsert:NO
                                                    userInfo:nil
                                        mergeChangesToObject:existingObject
                                                       error:&error];
        CheckErrorAndReturn(error, anError, nil);
        
        if (returningObject) {
            [returningObjects addObject:returningObject];
        }
        
        existingObject = [existingEnumerator nextObject];
        newObject = [newEnumerator nextObject];
    }
    
    
    [CoreDataGateway saveContext:&error];
    CheckErrorAndReturn(error, anError, nil);
    
    return returningObjects;
}

- (id)insertObject:(id)object isFirstInsert:(BOOL)isFirstInsert error:(NSError *__autoreleasing *)anError {
    id returningObject = [self insertObjectWithoutSaving:object isFirstInsert:isFirstInsert error:anError] ;
    
    BOOL success = [CoreDataGateway saveContext:anError];
    
    if (success) {
        [self postDidChangeNotification];
    }
    
    return success ? returningObject : nil;
}

- (id)insertObject:(id)object error:(NSError *__autoreleasing *)anError {
    return [self insertObject:object isFirstInsert:NO error:anError];
}

- (NSArray *)insertObjectsWithoutSaving:(id <TKCollection>)objects
                          isFirstInsert:(BOOL)isFirstInsert
                               userInfo:(NSDictionary *)userInfo
                                  error:(NSError *__autoreleasing *)anError {
    
    id returningCollection = [NSMutableArray arrayWithCapacity:[objects count]];
    
    id mappedObject = nil;
    NSError *error = nil;
    
    for (id object in objects) {
        mappedObject = [self insertObjectWithoutSaving:object isFirstInsert:isFirstInsert userInfo:userInfo mergeChangesToObject:nil error:&error];
        if (error == nil) {
            if (mappedObject != nil) {
                [returningCollection addObject:mappedObject];
            }
        }
        else {
            SetErrorAndReturn(error, anError, nil);
        }
    }
    
    returningCollection = [NSArray arrayWithArray:returningCollection];
    
    return returningCollection;
}

- (NSArray *)insertObjectsWithoutSaving:(id <TKCollection>)objects
                          isFirstInsert:(BOOL)isFirstInsert
                                  error:(NSError *__autoreleasing *)anError {
    return [self insertObjectsWithoutSaving:objects isFirstInsert:isFirstInsert userInfo:nil error:anError];
}

- (NSArray *)insertObjects:(id)objects isFirstInsert:(BOOL)isFirstInsert error:(NSError *__autoreleasing *)anError {
    
    NSError *error = nil;
    NSArray *returningCollection = [self insertObjectsWithoutSaving:objects isFirstInsert:isFirstInsert userInfo:nil error:&error];
    
    CheckErrorAndReturn(error, anError, nil);
    
    BOOL success = [CoreDataGateway saveContext:anError];
    
    if (success) {
        [self postDidChangeNotification];
    }
    
    return success ? returningCollection : nil;
}

- (NSArray *)insertObjects:(id)objects error:(NSError *__autoreleasing *)anError {
    return [self insertObjects:objects isFirstInsert:!self.containsObjects error:anError];
}

#pragma mark - Saving

- (id)saveObject:(id)object error:(NSError **)anError {
    
    NSError *error = nil;
    id returningObject = object;
    
    if (![object isKindOfClass:[NSManagedObject class]]) {
        returningObject = [self insertObjectWithoutSaving:object isFirstInsert:NO error:&error];
        CheckErrorAndReturn(error, anError, nil);
    }
    
    BOOL success = [CoreDataGateway saveContext:anError];
    
    if (returningObject != object && success) {
        [self postDidChangeNotification];
    }
    
    return success ? returningObject : nil;
}

- (NSArray *)saveObjects:(id <TKCollection>)objects error:(NSError **)anError {
    
    NSError *error = nil;
    
    id savedObjects = objects;
    
    if (![[objects anyObject] isKindOfClass:[NSManagedObject class]]) {
        savedObjects = [self insertObjectsWithoutSaving:objects isFirstInsert:NO userInfo:nil error:&error];
        CheckErrorAndReturn(error, anError, nil);
    }
    
    BOOL success = [CoreDataGateway saveContext:anError];
    
    if (savedObjects != objects && success) {
        [self postDidChangeNotification];
    }
    
    return success ? savedObjects : nil;
}

#pragma mark - Deleting

- (void)deleteObjectWithoutSaving:(id)object; {
    if ([object isKindOfClass:[NSManagedObject class]]) {
        [CoreDataGateway deleteObject:object];
    }
}

- (void)deleteObject:(id)object {
    if (object) {
        [self deleteObjectWithoutSaving:object];
        if ([CoreDataGateway saveContext:NULL]) {
            [self postDidChangeNotification];
        }
    }
}

- (void)deleteObjects:(id <TKCollection, NSFastEnumeration>)objects {
    if (objects.count) {
        for (id object in objects) {
            [self deleteObjectWithoutSaving:object];
        }
        if ([CoreDataGateway saveContext:NULL]) {
            [self postDidChangeNotification];
        }
    }
}

- (void)cleanUp {
    
}

- (void)reset {
    NSManagedObjectContext *context = [CoreDataGateway managedObjectContext];
    
    for (NSManagedObject *object in [context registeredObjects]) {
        [context refreshObject:object mergeChanges:NO];
    }
    [context reset];
}

- (void)postDidChangeNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kTKCoreDataEntityGatewayDidChangeNotificationKey object:self];
}

#pragma mark - Internal Fetching

- (id)objectOfType:(NSFetchRequestResultType)type {
    return [self objectWithPredicateString:nil
                                 arguments:nil
                                    ofType:type];
}

- (id)objectWithPredicateString:(NSString *)predicateString
                      arguments:(NSArray *)arguments
                         ofType:(NSFetchRequestResultType)type {
    
    return [CoreDataGateway objectWithEntityName:self.entityName
                                   predicateString:predicateString
                                         arguments:arguments
                                            ofType:type];
}

- (NSArray *)objectsOfType:(NSFetchRequestResultType)type {
    return [self objectsWithPredicateString:nil
                                  arguments:nil
                                     ofType:type];
}

- (NSArray *)objectsWithPredicateString:(NSString *)predicateString
                              arguments:(NSArray *)arguments
                                 ofType:(NSFetchRequestResultType)type {
    
    return [self objectsWithPredicateString:predicateString
                                  arguments:arguments
                                   sortKeys:nil
                                     ofType:type];
}

- (NSArray *)objectsWithPredicateString:(NSString *)predicateString
                              arguments:(NSArray *)arguments
                               sortKeys:(NSArray *)sortKeys
                                 ofType:(NSFetchRequestResultType)type {
    
    return [CoreDataGateway objectsWithEntityName:self.entityName
                                    predicateString:predicateString
                                          arguments:arguments
                                           sortKeys:sortKeys
                                             ofType:type];
}

@end
