//
//  TKDualCoreDataFetchedListProvider.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/6/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKDualCoreDataFetchedListProvider.h"


@interface TKDualCoreDataFetchedListProvider ()

@property (nonatomic, strong) NSFetchedResultsController *exchangeableController;

@property (nonatomic, copy) NSFetchRequest *request;
@property (nonatomic, copy) NSString *originalPredicateFormat;
@property (nonatomic, copy) NSArray *originalPredicateArguments;

@end


@implementation TKDualCoreDataFetchedListProvider

- (id)initWithPredicateFormat:(NSString *)originalPredicateFormat
                    arguments:(NSArray *)arguments
                     sortKeys:(NSArray *)sortKeys
                   entityName:(NSString *)entityName {
    
    self = [self init];
    if (self) {
        self.originalPredicateFormat = originalPredicateFormat;
        self.originalPredicateArguments = arguments;
        self.sortKeys = sortKeys;
        
        self.request = [CoreDataGateway fetchRequestForObjectsWithEntityName:entityName
                                                             predicateString:originalPredicateFormat
                                                                   arguments:arguments
                                                                    sortKeys:sortKeys
                                                                       limit:0
                                                                      ofType:NSManagedObjectIDResultType];
    }
    return self;
}

- (id)initWithGroupingPredicateFormat:(NSString *)anOriginalPredicateFormat
                            arguments:(NSArray *)arguments
                             sortKeys:(NSArray *)sortKeys
                           entityName:(NSString *)entityName
                   customGroupKeyPath:(NSString *)customGroupKeyPath
             customSectionNameKeyPath:(NSString *)customSectionNameKeyPath {
    
    self = [self initWithPredicateFormat:anOriginalPredicateFormat
                               arguments:arguments
                                sortKeys:sortKeys
                              entityName:entityName];
    if (self) {
        self.groupKeyPath = customGroupKeyPath.length ? customGroupKeyPath : sortKeys.firstObject;
        self.sectionNameKeyPath = customSectionNameKeyPath.length ? customSectionNameKeyPath : self.groupKeyPath;
    }
    return self;
}

- (void)setLimit:(NSNumber *)limit {
    _limit = limit;
    self.request.fetchLimit = limit.unsignedIntegerValue;
}

- (NSFetchedResultsController *)createController {
    return [[NSFetchedResultsController alloc] initWithFetchRequest:self.request.copy
                                               managedObjectContext:self.privateContext
                                                 sectionNameKeyPath:self.groupKeyPath
                                                          cacheName:nil];
}

- (NSFetchedResultsController *)currentController {
    if (!_currentController) {
        _currentController = [self createController];
        [self setUpDelegate];
    }
    return _currentController;
}

- (NSFetchedResultsController *)exchangeableController {
    if (!_exchangeableController) {
        _exchangeableController = [self createController];
    }
    return _exchangeableController;
}

- (void)exchangeControllers {
    NSFetchedResultsController *controller = self.exchangeableController;
    self.exchangeableController = self.currentController;
    self.currentController = controller;
    [self setUpDelegate];
}

- (void)prepareProviderForSearchWithString:(NSString *)searchString sortKeys:(NSArray *)sortKeys exceptObjects:(NSObject <TKCollection> *)exceptObjects {
    
    self.lastSortKeys = sortKeys;
    
    self.exchangeableController.fetchRequest.predicate = [self createPredicateBasedOnString:self.originalPredicateFormat
                                                                                  arguments:self.originalPredicateArguments
                                                                        forSearchWithString:searchString
                                                                              exceptObjects:exceptObjects];
    self.exchangeableController.fetchRequest.sortDescriptors = [CoreDataGateway sortDescriptorsFromSortkeys:sortKeys ? sortKeys : self.sortKeys];
}

- (void)search:(NSString *)searchString
      sortKeys:(NSArray *)sortKeys
 exceptObjects:(NSObject <TKCollection> *)exceptObjects
    completion:(dispatch_block_t)completion {
    
    [self.privateContext performBlock:^{
        [self prepareProviderForSearchWithString:searchString sortKeys:sortKeys exceptObjects:exceptObjects];
        [self performFetchInternal];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self exchangeControllers];
            if (completion) {
                completion();
            }
        });
    }];
}

- (void)performFetchInternal {
    NSError *error = nil;
    [self.exchangeableController performFetch:&error];
    if (error) { DLog(@"%@", error); }
}

- (void)performFetchSync {
    [self.privateContext performBlockAndWait:^{
        [self prepareProviderForSearchWithString:self.lastSearchString sortKeys:self.lastSortKeys exceptObjects:self.lastExceptObjects];
        [self performFetchInternal];
    }];
    [self exchangeControllers];
}

@end
