//
//  TKDualCoreDataFetchedListProvider.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/6/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKBaseCoreDataFetchedListProvider.h"


@interface TKDualCoreDataFetchedListProvider : TKBaseCoreDataFetchedListProvider

- (id)initWithPredicateFormat:(NSString *)originalPredicateFormat
                    arguments:(NSArray *)arguments
                     sortKeys:(NSArray *)sortKeys
                   entityName:(NSString *)entityName;

- (id)initWithGroupingPredicateFormat:(NSString *)anOriginalPredicateFormat
                            arguments:(NSArray *)arguments
                             sortKeys:(NSArray *)sortKeys
                           entityName:(NSString *)entityName
                   customGroupKeyPath:(NSString *)customGroupKeyPath
             customSectionNameKeyPath:(NSString *)customSectionNameKeyPath;

@end
