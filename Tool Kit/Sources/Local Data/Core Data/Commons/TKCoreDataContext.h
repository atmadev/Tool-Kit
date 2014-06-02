//
//  TKCoreDataContext.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 4/7/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TKAbstractCoreDataContext : NSObject {
    NSManagedObjectContext * _context;
}

@property (nonatomic, strong) NSManagedObjectContext * context;

- (id)createObjectWithEntityName:(NSString *)entityName;

- (id)insertObject:(id)object forEntityName:(NSString *)entityName;

- (void)deleteObject:(id)object;

- (id)internalObjectFromContainer:(id)objectContainer;

- (BOOL)save:(NSError **)anError;

- (void)rollback;

- (BOOL)hasChanges;

- (NSSet *)registeredObjects;

@end


@interface TKBaseCoreDataContext : TKAbstractCoreDataContext

@end



@interface TKCoreDataNestedContext : TKAbstractCoreDataContext

@property (nonatomic) TKAbstractCoreDataContext * parentDataContext;

@end



@interface TKCoreDataCurrentContext : TKAbstractCoreDataContext

+ (TKCoreDataCurrentContext *)currentContext;

@end
