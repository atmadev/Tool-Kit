//
//  NSCollection+Extensions.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 6/1/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

@protocol TKCollection <NSObject, NSFastEnumeration>

@required
+ (BOOL)isMutable;
+ (BOOL)isOrdered;

- (NSUInteger)count;
- (id)anyObject;

- (BOOL)containsObject:(id)object;

- (NSArray *)sortedArrayUsingSelector:(SEL)comparator;
- (NSArray *)sortedArrayUsingDescriptorKeys:(NSArray *)sortDescriptorKeys;

- (NSArray *)array;
- (NSMutableArray *)mutableArray;

- (NSSet *)set;
- (NSMutableSet *)mutableSet;

- (NSOrderedSet *)orderedSet;
- (NSMutableOrderedSet *)mutableOrderedSet;

- (id <TKCollection>)convertToCollectionWithClass:(Class)collecitonClass;

- (id)collectionByAddingObject:(id)object;

- (id)originalObject;
- (id)objectContainer;

- (id)valueForKey:(NSString *)key;
- (id)valueForKeyPath:(NSString *)keyPath;

- (NSEnumerator *)objectEnumerator;

@end


@protocol TKOrderedCollection <TKCollection>

@required
- (id)firstObject;
- (id)objectAtIndex:(NSUInteger)index;
- (id)lastObject;

- (NSUInteger)indexOfObject:(id)object;
- (NSUInteger)indexOfObjectPassingTest:(BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;

- (NSEnumerator *)reverseObjectEnumerator;

@end


@interface NSObject (Collection)

+ (BOOL)isCollection;

@end


@interface NSArray (OrderedCollection) <TKOrderedCollection>

@end


@interface NSArray (Extensions)

- (NSArray *)sortDescriptorsFromSortKeys;

- (NSMutableArray *)groupSortedArrayByKeys:(NSArray *)sortingKeys;

- (void)enumerateSubArraysWithPageSize:(NSUInteger)pageSize usingBlock:(void (^)(NSArray *subArray, NSUInteger location, BOOL *stop))block;

@end

@interface NSMutableArray (Extensions)

- (void)addNullableObject:(id)object;

@end

@interface NSSet (Collection) <TKCollection>


@end


@interface NSOrderedSet (OrderedCollection) <TKOrderedCollection>


@end