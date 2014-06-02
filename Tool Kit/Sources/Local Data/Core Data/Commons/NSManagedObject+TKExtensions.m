//
//  NSManagedObject+TKExtensions.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/6/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "NSManagedObject+TKExtensions.h"
#import "TKCoreDataGateway.h"
#import "TKEntityDescription.h"
#import "TKPropertyTransformer.h"


@implementation NSManagedObject (TKExtensions)

- (id)originalObject {
    return self;
}

- (id)objectContainer {
    return self.objectID;
}

#ifdef DEBUG

- (NSMutableDictionary *)_desc {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObject:@"" forKey:self.entity.name];
    for (NSString *key in self.entity.attributesByName) {
        id value = [self valueForKey:key];
        if (value) {
            [dictionary setObject:value forKey:key];
        }
    }
    return dictionary;
}

#endif

@end


@implementation NSManagedObject (TKDictionaryRepresentation)

- (NSMutableDictionary *)remoteDictionaryRepresentationWithoutRelation:(NSRelationshipDescription *)exceptRelation
                                                     entityDescription:(id <TKEntityDescription>)entityDescription {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    id value = nil;
    
    TKPropertyTransformer *transformer = nil;
    
    NSString *remoteKey = nil;
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:self.entity.attributesByName];
    
    NSSet *exceptionKeys = [entityDescription exceptionKeys];
    
    for (NSString *localKey in attributes) {
        
        if ([exceptionKeys containsObject:localKey]) { continue; }
        
        value = [self valueForKey:localKey];
        
        if (entityDescription) {
            transformer = [entityDescription propertyTransformerForLocalKey:localKey];
            remoteKey = transformer.remoteKey;
        }
        else {
            remoteKey = localKey;
        }
        
        
        if (value) {
            @try {
                if (transformer) {
                    [dictionary setObject:[transformer remoteFromLocalValue:value] forKey:remoteKey];
                }
                else {
                    [dictionary setObject:value forKey:remoteKey];
                }
            }
            @catch (NSException *exception) {
                DLog(@"EXCEPTION when try set object \"%@\" for key \"%@\" in the \"%@\" structure: \"%@\"", value, localKey, [self class], exception);
            }
        }
    }
    
    NSMutableDictionary *relationships = [NSMutableDictionary dictionaryWithDictionary:self.entity.relationshipsByName];
    
    for (NSRelationshipDescription *relationship in relationships.allValues) {
        
        if ([exceptionKeys containsObject:relationship.name]) { continue; }
        
        if ([relationship isEqual:exceptRelation] || [[relationship destinationEntity] isEqual:[exceptRelation destinationEntity]]) {
            continue;
        }
        
        value = [self valueForKey:relationship.name];
        
        if (value == nil) {
            continue;
        }
        
        if (entityDescription) {
            transformer = [entityDescription propertyTransformerForLocalKey:relationship.name];
            remoteKey = transformer.remoteKey;
        }
        else {
            remoteKey = relationship.name;
        }
        
        if (!relationship.isToMany) {
            [dictionary setObject:[value remoteDictionaryRepresentationWithoutRelation:relationship.inverseRelationship
                                                                     entityDescription:[entityDescription subEntityDescriptionForKey:relationship.name]]
                           forKey:remoteKey];
            
        }
        else {
            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[value count]];
            for (NSManagedObject *managedObject in value) {
                [array addObject:[managedObject remoteDictionaryRepresentationWithoutRelation:relationship.inverseRelationship
                                                                            entityDescription:[entityDescription subEntityDescriptionForKey:relationship.name]]];
            }
            NSArray *sortedArray = [NSArray arrayWithArray:array];
            
            [dictionary setObject:sortedArray forKey:remoteKey];
        }
    }
    
    [entityDescription objectDidParse:self toDictionary:dictionary];
    
    return dictionary;
}

- (NSMutableDictionary *)dictionaryRepresentation {
    return [self remoteDictionaryRepresentationWithoutRelation:nil
                                             entityDescription:nil];
}

- (NSMutableDictionary *)remoteDictionaryRepresentationUsingEntityDescription:(id <TKEntityDescription>)entityDescription {
    return [self remoteDictionaryRepresentationWithoutRelation:nil entityDescription:entityDescription];
}

- (NSMutableDictionary *)remoteDictionaryRepresentation {
    return [self dictionaryRepresentation];
}

- (NSMutableDictionary *)localDictionaryRepresentation {
    return [self dictionaryRepresentation];
}

#ifdef DEBUG
- (NSMutableDictionary *)_dict {
    return [self dictionaryRepresentation];
}
#endif

@end


@implementation NSManagedObjectID (objectContainer)

- (id)originalObject {
    return [CoreDataGateway objectForID:self];
}

- (id)objectContainer {
    return self;
}

@end
