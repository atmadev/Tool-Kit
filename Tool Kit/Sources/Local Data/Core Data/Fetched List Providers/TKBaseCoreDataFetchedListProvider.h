//
//  TKBaseCoreDataFetchedListProvider.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/6/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKCoreData.h"
#import "TKFetchedListProvider.h"


@interface TKBaseCoreDataFetchedListProvider : NSObject <TKFetchedListProvider, NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *_currentController;
    NSNumber * _limit;
}

@property (nonatomic, strong) NSArray *searchKeys;

@property (nonatomic, strong) NSFetchedResultsController *currentController;

@property (nonatomic, copy) NSString *groupKeyPath;
@property (nonatomic, strong) NSString *sectionNameKeyPath;

@property (nonatomic) NSString *lastSearchString;
@property (nonatomic, copy) NSArray *lastSortKeys;
@property (nonatomic, copy) NSObject <TKCollection> * lastExceptObjects;

@property (nonatomic, strong) NSManagedObjectContext *privateContext;
@property (nonatomic, strong) NSManagedObjectContext *publicContext;

@property (nonatomic, copy) NSArray *sortKeys;
@property (nonatomic, copy) NSArray *originalSortKeys;

@property (nonatomic) NSNumber * limit;

- (void)setUpDelegate;

- (NSPredicate *)createPredicateBasedOnString:(NSString *)aPredicateString
                                    arguments:(NSArray *)aPredicateArguments
                          forSearchWithString:(NSString *)searchString
                                exceptObjects:(NSObject <TKCollection> *)exceptObjects;

- (id)objectAtIndexPathInternal:(NSIndexPath *)indexPath;

@end


@interface TKBaseCoreDataFetchedListProvider (Abstract)

- (void)prepareProviderForSearchWithString:(NSString *)searchString
                                  sortKeys:(NSArray *)sortKeys
                             exceptObjects:(NSObject <TKCollection> *)exceptObjects;

- (void)performFetchInternal;

@end