//
//  NSCollection+Extensions.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 6/1/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "NSCollection+Extensions.h"

@implementation NSObject (Collection)

+ (BOOL)isCollection {
    return NO;
}

@end


@implementation NSArray (OrderedCollection)

+ (BOOL)isCollection {
    return YES;
}

+ (BOOL)isMutable {
    return NO;
}

+ (BOOL)isOrdered {
    return YES;
}

- (id)firstObject {
    return self.count ? [self objectAtIndex:0] : nil;
}

- (id)anyObject {
    return [self lastObject];
}

- (NSArray *)array {
    return self;
}

- (NSMutableArray *)mutableArray {
    return [NSMutableArray arrayWithArray:self];
}

- (NSSet *)set {
    return [NSSet setWithArray:self];
}

- (NSMutableSet *)mutableSet {
    return [NSMutableSet setWithArray:self];
}

- (NSOrderedSet *)orderedSet {
    return [NSOrderedSet orderedSetWithArray:self];
}

- (NSMutableOrderedSet *)mutableOrderedSet {
    return [NSMutableOrderedSet orderedSetWithArray:self];
}

- (id <TKCollection>)convertToCollectionWithClass:(Class)collecitonClass {
    
    NSAssert([collecitonClass isCollection], @"Given class is not collection class");
    
    if ([collecitonClass isSubclassOfClass:[NSMutableArray class]]) {
        return [self mutableArray];
    }
    else if ([collecitonClass isSubclassOfClass:[NSArray class]]) {
        return [self array];
    }
    else if ([collecitonClass isSubclassOfClass:[NSMutableSet class]]) {
        return [self mutableSet];
    }
    else if ([collecitonClass isSubclassOfClass:[NSSet class]]) {
        return [self set];
    }
    else if ([collecitonClass isSubclassOfClass:[NSMutableOrderedSet class]]) {
        return [self mutableOrderedSet];
    }
    else if ([collecitonClass isSubclassOfClass:[NSOrderedSet class]]) {
        return [self orderedSet];
    }
    else {
        @throw [NSException exceptionWithName:@"Collection exception" reason:@"Unknown collectionClass" userInfo:nil];
    }
}

- (id)collectionByAddingObject:(id)object {
    return [self arrayByAddingObject:object];
}

- (NSArray *)sortedArrayUsingDescriptorKeys:(NSArray *)sortDescriptorKeys {
    return [self sortedArrayUsingDescriptors:[sortDescriptorKeys sortDescriptorsFromSortKeys]];
}

- (id)objectContainer {
    return [self valueForKey:@"objectContainer"];
}

- (id)originalObject {
    return [self valueForKey:@"originalObject"];
}

@end


static NSString * const minusString = @"-";


@implementation NSArray (Extensions)

- (NSArray *)sortDescriptorsFromSortKeys {
    BOOL ascending = YES;
    NSMutableArray *mutableSortDescriptors = [NSMutableArray arrayWithCapacity:self.count];
    for (NSString *sortKey in self) {
        NSString *originalSortKey = sortKey;
        if (sortKey.length > 1 && [[sortKey substringToIndex:1] isEqualToString:minusString]) {
            originalSortKey = [sortKey substringFromIndex:1];
            ascending = NO;
        }
        else {
            ascending = YES;
        }
        
        [mutableSortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:originalSortKey ascending:ascending]];
    }
    
    return [NSArray arrayWithArray:mutableSortDescriptors];
}

//TODO: optimize algoritm
- (NSMutableArray *)groupSortedArrayByKeys:(NSArray *)sortingKeys {
    
    if (!sortingKeys.count) {
        return [self mutableArray];
    }
    
    NSMutableArray *rootArray = [NSMutableArray array];
    
    NSString *sortingKey = sortingKeys.firstObject;
    NSArray *leftSortingKeys = nil;
    if (sortingKeys.count > 1) {
        leftSortingKeys = [sortingKeys subarrayWithRange:NSMakeRange(1, sortingKeys.count - 1)];
    }
    
    if ([sortingKey isEqualToString:@""]) {
        //Insert array with 1 object, because empty key for grouping, so it is one big group:)
        [rootArray addObject:@[ leftSortingKeys ? [self groupSortedArrayByKeys:leftSortingKeys] : self ]];
        return rootArray;
    }
    
    NSMutableArray *group = [NSMutableArray array];
    id lastSortingValue = nil;
    id currentSortingValue = nil;
    
    for (id object in self) {
        currentSortingValue = [object valueForKeyPath:sortingKey];
        if (lastSortingValue && [currentSortingValue compare:lastSortingValue] != NSOrderedSame) {
            [rootArray addObject:leftSortingKeys ? [group groupSortedArrayByKeys:leftSortingKeys] : group];
            group = [NSMutableArray array];
        }
        
        [group addObject:object];
        lastSortingValue = currentSortingValue;
    }
    
    if (group.count) {
        [rootArray addObject:leftSortingKeys ? [group groupSortedArrayByKeys:leftSortingKeys] : group];
    }
    
    return rootArray;
}

- (void)enumerateSubArraysWithPageSize:(NSUInteger)pageSize usingBlock:(void (^)(NSArray *subArray, NSUInteger location, BOOL *stop))block {
    NSUInteger page = 0;
    NSUInteger location = 0;
    NSUInteger length = pageSize;
    __block BOOL stop = NO;
    
    do {
        location = page > 0 ? page*pageSize : 0;
        length = location + pageSize > self.count ? (self.count - location) : pageSize;
        
        block([self subarrayWithRange:NSMakeRange(location, length)], length, &stop);
        
        if (stop) {
            return;
        }
        page++;
        
    } while (location + pageSize < self.count);
}

@end


@implementation NSMutableArray (OrderedCollection)

+ (BOOL)isMutable {
    return YES;
}

- (NSArray *)array {
    return [NSArray arrayWithArray:self];
}

@end

@implementation NSMutableArray (Extensions)

- (void)addNullableObject:(id)object {
    if (object) {
        [self addObject:object];
    }
}

@end





@implementation NSSet (Collection)

+ (BOOL)isCollection {
    return YES;
}

+ (BOOL)isMutable {
    return NO;
}

+ (BOOL)isOrdered {
    return NO;
}

- (NSArray *)sortedArrayUsingSelector:(SEL)comparator {
    return [[self allObjects] sortedArrayUsingSelector:comparator];
}

- (NSArray *)sortedArrayUsingDescriptorKeys:(NSArray *)sortDescriptorKeys {
    return [self sortedArrayUsingDescriptors:[sortDescriptorKeys sortDescriptorsFromSortKeys]];
}

- (id)objectContainer {
    return [self valueForKey:@"objectContainer"];
}

- (id)originalObject {
    return [self valueForKey:@"originalObject"];
}

- (NSArray *)array {
    return [self allObjects];
}

- (NSMutableArray *)mutableArray {
    return [NSMutableArray arrayWithArray:[self allObjects]];
}

- (NSSet *)set {
    return self;
}

- (NSMutableSet *)mutableSet {
    return [NSMutableSet setWithSet:self];
}

- (NSOrderedSet *)orderedSet {
    return [NSOrderedSet orderedSetWithSet:self];
}

- (NSMutableOrderedSet *)mutableOrderedSet {
    return [NSMutableOrderedSet orderedSetWithSet:self];
}

- (id <TKCollection>)convertToCollectionWithClass:(Class)collecitonClass {
    
    NSAssert([collecitonClass isCollection], @"Given class is not collection class");
    
    if ([collecitonClass isSubclassOfClass:[NSMutableArray class]]) {
        return [self mutableArray];
    }
    else if ([collecitonClass isSubclassOfClass:[NSArray class]]) {
        return [self array];
    }
    else if ([collecitonClass isSubclassOfClass:[NSMutableSet class]]) {
        return [self mutableSet];
    }
    else if ([collecitonClass isSubclassOfClass:[NSSet class]]) {
        return [self set];
    }
    else if ([collecitonClass isSubclassOfClass:[NSMutableOrderedSet class]]) {
        return [self mutableOrderedSet];
    }
    else if ([collecitonClass isSubclassOfClass:[NSOrderedSet class]]) {
        return [self orderedSet];
    }
    else {
        @throw [NSException exceptionWithName:@"Collection exception" reason:@"Unknown collectionClass" userInfo:nil];
    }
}

- (id)collectionByAddingObject:(id)object {
    return [self setByAddingObject:object];
}

@end


@implementation NSMutableSet (Collection)

+ (BOOL)isMutable {
    return YES;
}

@end


@implementation NSOrderedSet (OrderedCollection)

+ (BOOL)isCollection {
    return YES;
}

+ (BOOL)isMutable {
    return NO;
}

+ (BOOL)isOrdered {
    return YES;
}

- (id)anyObject {
    return [self lastObject];
}

- (NSArray *)sortedArrayUsingSelector:(SEL)comparator {
    return [[self array] sortedArrayUsingSelector:comparator];
}

- (NSArray *)sortedArrayUsingDescriptorKeys:(NSArray *)sortDescriptorKeys {
    return [[self array] sortedArrayUsingDescriptorKeys:sortDescriptorKeys];
}

- (id)objectContainer {
    return [self valueForKey:@"objectContainer"];
}

- (id)originalObject {
    return [self valueForKey:@"originalObject"];
}

- (NSMutableArray *)mutableArray {
    return [NSMutableArray arrayWithArray:[self array]];
}

- (NSMutableSet *)mutableSet {
    return [NSMutableSet setWithSet:[self set]];
}

- (NSOrderedSet *)orderedSet {
    return self;
}

- (NSMutableOrderedSet *)mutableOrderedSet {
    return [NSMutableOrderedSet orderedSetWithOrderedSet:self];
}

- (id <TKCollection>)convertToCollectionWithClass:(Class)collecitonClass {
    
    NSAssert([collecitonClass isCollection], @"Given class is not collection class");
    
    if ([collecitonClass isSubclassOfClass:[NSMutableArray class]]) {
        return [self mutableArray];
    }
    else if ([collecitonClass isSubclassOfClass:[NSArray class]]) {
        return [self array];
    }
    else if ([collecitonClass isSubclassOfClass:[NSMutableSet class]]) {
        return [self mutableSet];
    }
    else if ([collecitonClass isSubclassOfClass:[NSSet class]]) {
        return [self set];
    }
    else if ([collecitonClass isSubclassOfClass:[NSMutableOrderedSet class]]) {
        return [self mutableOrderedSet];
    }
    else if ([collecitonClass isSubclassOfClass:[NSOrderedSet class]]) {
        return [self orderedSet];
    }
    else {
        @throw [NSException exceptionWithName:@"Collection exception" reason:@"Unknown collectionClass" userInfo:nil];
    }
}

- (id)collectionByAddingObject:(id)object {
    NSMutableOrderedSet *mutableOrderedSet = [self mutableOrderedSet];
    [mutableOrderedSet addObject:object];
    return [mutableOrderedSet orderedSet];
}

@end


@implementation NSMutableOrderedSet (Collection)

+ (BOOL)isMutable {
    return YES;
}

@end
