//
//  TKBaseCoreDataFetchedListProvider.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/6/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKBaseCoreDataFetchedListProvider.h"



@implementation TKBaseCoreDataFetchedListProvider

@synthesize delegate = _delegate;

- (id)init {
    self = [super init];
    if (self) {
        self.privateContext = [CoreDataGateway createAndRegisterManagedObjectContextWithType:NSPrivateQueueConcurrencyType];
        self.publicContext = [CoreDataGateway createAndRegisterManagedObjectContextWithType:NSMainQueueConcurrencyType];
    }
    return self;
}

- (void)dealloc {
    [CoreDataGateway unregisterManagedObjectContext:self.privateContext];
    [CoreDataGateway unregisterManagedObjectContext:self.publicContext];
}

- (void)setDelegate:(id <TKFetchedListProviderDelegate>)delegate {
    _delegate = delegate;
    [self setUpDelegate];
}

- (id <TKFetchedListProviderDelegate>)delegate {
    return _delegate;
}

- (void)setUpDelegate {
    self.currentController.delegate = self.delegate ? self : nil;
}

- (NSPredicate *)createPredicateBasedOnString:(NSString *)aPredicateString
                                    arguments:(NSArray *)aPredicateArguments
                          forSearchWithString:(NSString *)searchString
                                exceptObjects:(NSObject <TKCollection> *)exceptObjects {
    
    self.lastSearchString = searchString;
    self.lastExceptObjects = exceptObjects;
    
    NSMutableString *predicateString   = aPredicateString.length ? [NSMutableString stringWithString:aPredicateString] : [NSMutableString string];
    NSMutableArray *predicateArguments = [NSMutableArray arrayWithArray:aPredicateArguments];
    
    if (searchString.length && self.searchKeys.count > 0) {
        
        [predicateString appendPredicateString:@"("];
        
        NSString *normalizedSearchString = [searchString normalizedString];
        NSString *likeString = [NSString stringWithFormat:@"*%@*", normalizedSearchString];
        for (NSString *searchKey in self.searchKeys) {
            [predicateString appendString:@"(%K LIKE %@)"];
            [predicateArguments addObject:searchKey];
            [predicateArguments addObject:likeString];
            if (searchKey != [self.searchKeys lastObject]) {
                [predicateString appendString:@" OR "];
            }
        }
        
        [predicateString appendString:@")"];
        
    }
    
    if (exceptObjects.count) {
        [predicateString appendPredicateString:@"(NOT (self IN %@))"];
        [predicateArguments addObject:exceptObjects];
    }
    
    return [NSPredicate predicateWithFormat:predicateString.length ? predicateString : nil
                              argumentArray:predicateString.length ? predicateArguments : nil];
}

- (void)performFetchInternal {
    NSError *error = nil;
    [self.currentController performFetch:&error];
    if (error) {
        DLog(@"%@", error);
    }
}

#pragma mark - TKFetchedListProvider

- (void)search:(NSString *)searchString sortKeys:(NSArray *)sortKeys exceptObjects:(NSObject<TKCollection> *)exceptObjects completion:(dispatch_block_t)completion {
    NSAssert(NO, @"Must be overriden");
}

- (void)search:(NSString*)searchString sortKeys:(NSArray *)sortKeys completion:(dispatch_block_t)completion {
    [self search:searchString sortKeys:sortKeys exceptObjects:self.lastExceptObjects completion:completion];
}

- (void)search:(NSString *)searchString completion:(dispatch_block_t)completion {
    [self search:searchString sortKeys:self.lastSortKeys completion:completion];
}

- (void)performFetchSync {
    NSAssert(NO, @"Must be overriden");
}

- (void)performFetchWithCompletion:(dispatch_block_t)completion {
    [self search:self.lastSearchString completion:completion];
}

- (id)objectWithID:(NSManagedObjectID *)objectID {
    return objectID ? [self.publicContext objectWithID:objectID] : nil;
}

- (id)objectAtIndex:(NSUInteger)index {
    return [self objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}

- (id)objectAtIndexPathInternal:(NSIndexPath *)indexPath {
    if ((int)indexPath.section > (int)((int)self.sections.count - 1)) {
        return nil;
    }
    
    if ((int)indexPath.row > (int)((int)[[(id <TKSectionInfo>)self.sections[indexPath.section] objects] count] - 1)) {
        return nil;
    }
    
    id object = nil;
    
    @try {
        object = [self.currentController objectAtIndexPath:indexPath];
    }
    @catch (NSException *exception) {
        DLog(@"exception %@", exception);
    }
    
    return object;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [self objectWithID:[self objectAtIndexPathInternal:indexPath]];
}

/* Returns the indexPath of a given object.
 */
- (NSIndexPath *)indexPathForObject:(id)object {
    return [self.currentController indexPathForObject:[object objectContainer]];
}

- (BOOL)containsObject:(id)object {
    return [[self.currentController fetchedObjects] containsObject:[object objectContainer]];
}

- (NSUInteger)count {
    return self.currentController.fetchedObjects.count;
}

- (id)firstObject {
    return [self objectWithID:self.currentController.fetchedObjects.firstObject];
}

- (NSString *)titleForSection:(NSInteger)section {
    
    if (!self.sectionNameKeyPath) {
        return nil;
    }
    
    id object = [self objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    
    return object ? [object valueForKeyPath:self.sectionNameKeyPath] : nil;
}

- (NSArray *)sections {
    return self.currentController.sections;
}

- (NSArray *)fetchedObjects {
    
    NSFetchRequest *reqest = self.currentController.fetchRequest.copy;
    reqest.resultType = NSManagedObjectResultType;
    reqest.predicate = [NSPredicate predicateWithFormat:@"self IN %@", self.currentController.fetchedObjects];
    
    return [self.publicContext executeFetchRequest:reqest error:nil];
}

- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)sectionIndex {
    return NSNotFound;
}

- (NSString *)sectionIndexTitleForSectionName:(NSString *)sectionName {
    return nil;
}

- (NSArray *)sectionIndexTitles {
    return nil;
}

- (void)rollbackChanges {
    [self.publicContext rollback];
}

- (BOOL)saveChanges:(NSError **)error {
    return [self.publicContext save:error];
}

- (BOOL)hasChanges {
    return [self.publicContext hasChanges];
}

- (void)deleteObjectsAtIndexPaths:(NSArray *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        id object = [self objectAtIndexPath:indexPath];
        if (object) {
            [self.publicContext deleteObject:object];
        }
    }
}

- (id)internalObjectFromContainer:(id)objectContainer {
    return objectContainer ? [self.publicContext objectWithID:objectContainer] : nil;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(provider:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
        [self.delegate provider:self
                didChangeObject:anObject
                    atIndexPath:indexPath
                  forChangeType:(TKFetchedListChangeType)type
                   newIndexPath:newIndexPath];
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(provider:didChangeSection:atIndex:forChangeType:)]) {
        [self.delegate provider:self didChangeSection:(id <TKSectionInfo>)sectionInfo
                        atIndex:sectionIndex
                  forChangeType:(TKFetchedListChangeType)type];
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (self.delegate && [self.delegate respondsToSelector:@selector(providerWillChangeContent:)]) {
        [self.delegate providerWillChangeContent:self];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (self.delegate && [self.delegate respondsToSelector:@selector(providerDidChangeContent:)]) {
        [self.delegate providerDidChangeContent:self];
    }
}

- (NSString *)controller:(NSFetchedResultsController *)controller
sectionIndexTitleForSectionName:(NSString *)sectionName {
    if (self.delegate && [self.delegate respondsToSelector:@selector(provider:sectionIndexTitleForSectionName:)]) {
        return [self.delegate provider:self sectionIndexTitleForSectionName:sectionName];
    }
    
    return nil;
}

@end
