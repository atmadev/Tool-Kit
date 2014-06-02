//
//  TKFetchedListProvider.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/6/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TKFetchedListProviderDelegate, TKCollection;

@protocol TKFetchedListProvider <NSObject>

- (void)search:(NSString *)searchString
      sortKeys:(NSArray *)sortKeys
 exceptObjects:(NSObject <TKCollection> *)exceptObjects
    completion:(dispatch_block_t)completion;

- (void)search:(NSString *)searchString sortKeys:(NSArray *)sortKeys completion:(dispatch_block_t)completion;
- (void)search:(NSString *)searchString completion:(dispatch_block_t)completion;

- (void)performFetchWithCompletion:(dispatch_block_t)completion;
- (void)performFetchSync;

- (id)objectAtIndex:(NSUInteger)index;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;
- (BOOL)containsObject:(id)object;

- (NSUInteger)count;
- (id)firstObject;

- (NSString *)titleForSection:(NSInteger)section;

//Section indexing
- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)sectionIndex;
- (NSString *)sectionIndexTitleForSectionName:(NSString *)sectionName;
@property (nonatomic, readonly) NSArray *sectionIndexTitles;
//---


- (void)rollbackChanges;
- (BOOL)saveChanges:(NSError **)error;
- (BOOL)hasChanges;
- (void)deleteObjectsAtIndexPaths:(NSArray *)indexPaths;

- (id)internalObjectFromContainer:(id)objectContainer;

@property(nonatomic, weak) id <TKFetchedListProviderDelegate> delegate;

@property (nonatomic, readonly) NSArray *sections;

/* Returns the results of the fetch.
 Returns nil if the performFetch: hasn't been called.
 */
@property (nonatomic, readonly) NSArray *fetchedObjects;

@property (nonatomic, readonly) NSString *sectionNameKeyPath;

@property (nonatomic, strong) NSArray *searchKeys;

@end

@protocol TKSectionInfo

/* Name of the section
 */
@property (nonatomic, readonly) NSString *name;

/* Title of the section (used when displaying the index)
 */
@property (nonatomic, readonly) NSString *indexTitle;

/* Returns the array of objects in the section.
 */
@property (nonatomic, readonly) NSArray *objects;

@end



@protocol TKFetchedListProviderDelegate <NSObject>

typedef enum {
	TKFetchedListChangeInsert = 1,
	TKFetchedListChangeDelete = 2,
	TKFetchedListChangeMove = 3,
	TKFetchedListChangeUpdate = 4
}   TKFetchedListChangeType;

/* Notifies the delegate that a fetched object has been changed due to an add, remove, move, or update. Enables NSFetchedResultsController change tracking.
 controller - controller instance that noticed the change on its fetched objects
 anObject - changed object
 indexPath - indexPath of changed object (nil for inserts)
 type - indicates if the change was an insert, delete, move, or update
 newIndexPath - the destination path for inserted or moved objects, nil otherwise
 
 Changes are reported with the following heuristics:
 
 On Adds and Removes, only the Added/Removed object is reported. It's assumed that all objects that come after the affected object are also moved, but these moves are not reported.
 The Move object is reported when the changed attribute on the object is one of the sort descriptors used in the fetch request.  An update of the object is assumed in this case, but no separate update message is sent to the delegate.
 The Update object is reported when an object's state changes, and the changed attributes aren't part of the sort keys.
 */
@optional
- (void)provider:(id <TKFetchedListProvider>)provider didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(TKFetchedListChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;

/* Notifies the delegate of added or removed sections.  Enables NSFetchedResultsController change tracking.
 
 controller - controller instance that noticed the change on its sections
 sectionInfo - changed section
 index - index of changed section
 type - indicates if the change was an insert or delete
 
 Changes on section info are reported before changes on fetchedObjects.
 */
@optional
- (void)provider:(id <TKFetchedListProvider>)provider didChangeSection:(id <TKSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(TKFetchedListChangeType)type;

/* Notifies the delegate that section and object changes are about to be processed and notifications will be sent.  Enables NSFetchedResultsController change tracking.
 Clients utilizing a UITableView may prepare for a batch of updates by responding to this method with -beginUpdates
 */
@optional
- (void)providerWillChangeContent:(id <TKFetchedListProvider>)provider;

/* Notifies the delegate that all section and object changes have been sent. Enables NSFetchedResultsController change tracking.
 Providing an empty implementation will enable change tracking if you do not care about the individual callbacks.
 */
@optional
- (void)providerDidChangeContent:(id <TKFetchedListProvider>)provider;

/* Asks the delegate to return the corresponding section index entry for a given section name.	Does not enable NSFetchedResultsController change tracking.
 If this method isn't implemented by the delegate, the default implementation returns the capitalized first letter of the section name (seee NSFetchedResultsController sectionIndexTitleForSectionName:)
 Only needed if a section index is used.
 */
@optional
- (NSString *)provider:(id <TKFetchedListProvider>)provider sectionIndexTitleForSectionName:(NSString *)sectionName __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);

@end