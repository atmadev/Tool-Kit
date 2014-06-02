//
//  TKCoreDataMapper.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/4/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObject, NSRelationshipDescription;


#define CoreDataMapper [TKCoreDataMapper mapper]


@interface TKCoreDataMapper : NSObject

+ (TKCoreDataMapper *)mapper;

- (NSManagedObject *)createManagedObjectFromObject:(id)inputObject
                                        entityName:(NSString *)entityName
                                          userInfo:(NSDictionary *)userInfo;

- (void)parseObject:(id)inputObject
       mergeChanges:(BOOL)mergeChanges
           userInfo:(NSDictionary *)userInfo
    toManagedObject:(NSManagedObject *)nativeObject;

//Relationships Mapping
//One To Many
- (void)mapRelationshipsWithSortedParents:(NSArray *)parents
                       primaryParentIDKey:(NSString *)primaryParentIDKey
                           sortedChildren:(NSArray *)children
                     secondaryParentIDKey:(NSString *)secondaryParentIDKey
                       secondaryParentKey:(NSString *)secondaryParentKey;

- (void)mapOneToManyRelationship:(NSRelationshipDescription *)relationship
            secondaryParentIDKey:(NSString *)secondaryParentIDKey;

//Many To Many
- (void)mapRelationship:(NSRelationshipDescription *)relationship
         inverseObjects:(NSArray *)inverseObjects
usingDestinationIDsKey:(NSString *)destinationIDsKey;

- (void)mapRelationship:(NSRelationshipDescription *)relationship
         inverseObjects:(NSArray *)inverseObjects
usingDestinationIDsKey:(NSString *)destinationIDsKey
     destinationObjects:(NSArray *)destinationObjects ;

@end
