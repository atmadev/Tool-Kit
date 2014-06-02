//
//  TKCoreDataGateway.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/4/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKCoreData.h"
#import "TKCoreDataConcurrencyProvider.h"
#import "TKAbstractCoreDataEntityGateway.h"


NSString *const SQLiteExtension = @"sqlite";
NSString *const kTKCachedModelVersionKey = @"TKCachedModelVersionKey";
float const TKActualModelVersionFloatValue = 2.0;


@interface TKCoreDataGateway ()

@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) TKCoreDataConcurrencyProvider *concurrencyProvider;
@property (nonatomic, retain) NSString *dataBasePath;
@property (nonatomic, retain) NSMutableDictionary * entityGateways;

@end


@implementation TKCoreDataGateway

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize concurrencyProvider = _concurrencyProvider;
@synthesize dataBasePath = _dataBasePath;
@synthesize dataBaseName = _dataBaseName;
@synthesize registeredEntityGatewaysByEntityName;

#pragma mark -
#pragma mark Initialization

static TKCoreDataGateway *_gateway = nil;

+ (TKCoreDataGateway *)gateway {
	if (_gateway == nil) {
		_gateway = [self new];
	}
	return _gateway;
}

- (void)releaseProperties {
    self.persistentStoreCoordinator = nil;
    self.managedObjectModel = nil;
    self.concurrencyProvider = nil;
     _dataBasePath = nil;
}

- (void)dealloc {
    [self releaseProperties];
}

#pragma mark -

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel == nil) {
		self.managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
	}
    return _managedObjectModel;
}

- (NSString *)dataBaseName {
    if (_dataBaseName == nil) {
        _dataBaseName = @"СachedData";
    }
    return _dataBaseName;
}

- (void)setDataBaseName:(NSString *)dataBaseName {
    if (_dataBaseName != dataBaseName) {
        self.dataBasePath = self.defaultDataBasePath;
    }
}

- (NSString *)defaultDataBasePath {
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:self.dataBaseName];
}

- (NSString *)dataBasePath {
    if (_dataBasePath == nil) {
        _dataBasePath = self.defaultDataBasePath;
    }
    
    return _dataBasePath;
}

- (void)setDataBasePath:(NSString *)dataBasePath {
    if (_dataBasePath != dataBasePath) {
        [self releaseProperties];
        _dataBasePath = dataBasePath;
    }
}

- (NSMutableDictionary *)entityGateways {
    if (!_entityGateways) {
        _entityGateways = [NSMutableDictionary dictionary];
    }
    
    return _entityGateways;
}

- (NSDictionary *)registeredEntityGatewaysByEntityName {
    return self.entityGateways;
}

- (void)registerEntityGateway:(TKAbstractCoreDataEntityGateway *)entityGateway {
    self.entityGateways[entityGateway.entityName] = entityGateway;
}

- (void)registerEntityGateways:(NSDictionary *)entityGatewaysByEntityName {
    [self.entityGateways addEntriesFromDictionary:entityGatewaysByEntityName];
}

- (NSNumber *)cachedModelVersion {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kTKCachedModelVersionKey];
}

- (void)setActualCachedModelVersion {
    [[NSUserDefaults standardUserDefaults] setObject:@(TKActualModelVersionFloatValue)
                                              forKey:kTKCachedModelVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 Returns the persistent store coordinator for the application.  This
 implementation will create and return a coordinator, having added the
 store for the application to it.  (The directory for the store is created,
 if necessary.)
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator == nil) {
		
		NSError *error;
		NSManagedObjectModel* mom = [self managedObjectModel];
		if (!mom) {
			NSAssert(NO, @"Managed object model is nil");
			return nil;
		}
        
        NSString *path = [[self dataBasePath] stringByAppendingPathExtension:SQLiteExtension];
        NSURL *url = [NSURL fileURLWithPath:path];
        
		self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
        
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                                  NSInferMappingModelAutomaticallyOption:       @YES};
        
        
        if ([[self cachedModelVersion] floatValue] < TKActualModelVersionFloatValue) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        
        BOOL existedFile = [[NSFileManager defaultManager] fileExistsAtPath:path];
        
		if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil
                                                                 URL:url
                                                             options:options
                                                                error:&error]) {
            if (existedFile) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                return self.persistentStoreCoordinator;
            }
            
            NSAssert(NO, [error localizedDescription]);
			self.persistentStoreCoordinator = nil;
			return nil;
		}
        
        [self setActualCachedModelVersion];
        
	}
    return _persistentStoreCoordinator;
}

/**
 Returns the managed object context for the application (which is already
 bound to the persistent store coordinator for the application.)
 */
- (NSManagedObjectContext *)managedObjectContext {
    return [self.concurrencyProvider managedObjectContext];
}

- (TKCoreDataConcurrencyProvider *)concurrencyProvider {
    if (_concurrencyProvider == nil) {
        self.concurrencyProvider = [[TKCoreDataConcurrencyProvider alloc] initWithPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return _concurrencyProvider;
}

- (BOOL)saveContext:(NSError **)anError {
    
    NSError *error = nil;
    
    [self.concurrencyProvider save:&error];
    
    if (error != nil) {
        if (anError != NULL) {
            *anError = error;
        }
        
        DLog(@"Can't save data base ERROR: %@; all keys in user info %@", error, error.userInfo.allKeys);
        return NO;
    }
    
    return YES;
}

- (void)clearDataBase {
    NSArray *stores = [self.persistentStoreCoordinator persistentStores];
    
    for(NSPersistentStore *store in stores) {
        [self.persistentStoreCoordinator removePersistentStore:store error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
    }
    
    [self releaseProperties];
}

- (NSManagedObjectContext *)createAndRegisterManagedObjectContextWithType:(NSManagedObjectContextConcurrencyType)type {
    return [self.concurrencyProvider createAndRegisterManagedObjectContextWithType:type];
}

- (void)unregisterManagedObjectContext:(NSManagedObjectContext *)context {
    [self.concurrencyProvider unregisterManagedObjectContext:context];
}

#pragma mark - Safe Working With Context (Concurrency Provider)

- (BOOL)isProvidedContextForCurrentThread {
    return [self.concurrencyProvider isProvidedContextForCurrentThread];
}

- (BOOL)openTransaction {
    return [self.concurrencyProvider openTransaction];
}

- (void)closeTransaction {
    return [self.concurrencyProvider closeTransaction];
}
/*
- (CDPrivateManagedObjectContextContainer *)createAndRegisterPrivateManagedObjectContextContainer {
    return [self.concurrencyProvider createAndRegisterPrivateManagedObjectContextContainer];
}

- (void)removeAndUnregisterPrivateManagedObjectContextContainer:(CDPrivateManagedObjectContextContainer *)container {
    [self.concurrencyProvider removeAndUnregisterPrivateManagedObjectContextContainer:container];
}
*/
@end



static NSString * const minusString = @"-";

@implementation TKCoreDataGateway (Requests)

#pragma mark - Getters For Managed Objects

- (id)objectForID:(NSManagedObjectID *)managedObjectID {
    return [[self managedObjectContext] objectWithID:managedObjectID];
}

- (id)objectWithEntityName:(NSString *)name
                    ofType:(NSFetchRequestResultType)type {
    
    return [self objectWithEntityName:name
                      predicateString:nil
                            arguments:nil
                               ofType:type];
}

- (id)objectWithEntityName:(NSString *)name
           predicateString:(NSString *)predicateString
                 arguments:(NSArray *)arguments
                    ofType:(NSFetchRequestResultType)type; {
    
    return [[self performRequest:[self fetchRequestForObjectsWithEntityName:name
                                                            predicateString:predicateString
                                                                  arguments:arguments
                                                                   sortKeys:nil
                                                                      limit:1
                                                                     ofType:type]] lastObject];
}

- (NSArray *)objectsWithEntityName:(NSString *)name
                   predicateString:(NSString *)predicateString
                         arguments:(NSArray *)arguments
                            ofType:(NSFetchRequestResultType)type {
    
    return [self objectsWithEntityName:name
                       predicateString:predicateString
                             arguments:arguments
                              sortKeys:nil
                                ofType:type];
}

- (NSArray *)objectsWithEntityName:(NSString *)name
                   predicateString:(NSString *)predicateString
                         arguments:(NSArray *)arguments
                          sortKeys:(NSArray *)sortKeys
                            ofType:(NSFetchRequestResultType)type {
    
    return [self performRequest:[self fetchRequestForObjectsWithEntityName:name
                                                           predicateString:predicateString
                                                                 arguments:arguments
                                                                  sortKeys:sortKeys
                                                                     limit:0
                                                                    ofType:type]];
}


- (NSArray *)performRequest:(NSFetchRequest *)request {
    NSError *error = nil;
    NSArray *result = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (error) {
        DLog(@"Request ERROR: %@", error);
    }
    return result;
}

#pragma mark - Creating Requests

- (NSFetchRequest *)fetchRequestForObjectsWithEntityName:(NSString *)name
                                         predicateString:(NSString *)predicateString
                                               arguments:(NSArray *)arguments
                                            firstSortKey:(NSString *)firstSortKey
                                           secondSortKey:(NSString *)secondSortKey
                                                   limit:(NSUInteger)limit
                                                  ofType:(NSFetchRequestResultType)type {
    
	
    NSArray *sortDescriptorKeys = [NSArray arrayWithObjects:firstSortKey, secondSortKey, nil];
    
    return [self fetchRequestForObjectsWithEntityName:name
                                      predicateString:predicateString
                                            arguments:arguments
                                             sortKeys:sortDescriptorKeys
                                                limit:limit
                                               ofType:type];
}

- (NSFetchRequest *)fetchRequestForObjectsWithEntityName:(NSString *)name
                                         predicateString:(NSString *)predicateString
                                               arguments:(NSArray *)arguments
                                                sortKeys:(NSArray *)sortKeys
                                                   limit:(NSUInteger)limit
                                                  ofType:(NSFetchRequestResultType)type {
    
    NSAssert(name != nil, @"You can't create fetch request without entity name");
	
	NSFetchRequest *request = [NSFetchRequest new];
	request.entity = [self entityDescriptionWithName:name];
    
    if (predicateString != nil) {
        request.predicate = [NSPredicate predicateWithFormat:predicateString argumentArray:arguments];
    }
    
	if (sortKeys) {
        request.sortDescriptors = [self sortDescriptorsFromSortkeys:sortKeys];
    }
    
    request.fetchLimit = limit;
    request.resultType = type;
    
    return request;
}


- (NSArray *)sortDescriptorsFromSortkeys:(NSArray *)sortKeys {
    if (sortKeys) {
        BOOL ascending = YES;
        NSMutableArray *mutableSortDescriptors = [NSMutableArray arrayWithCapacity:sortKeys.count];
        for (NSString *sortKey in sortKeys) {
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
    
    return nil;
}

#pragma mark - Creating Managed Objects

- (id)createObjectWithEntityName:(NSString *)entityName {
	return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[self managedObjectContext]];
}

- (NSEntityDescription *)entityDescriptionWithName:(NSString *)entityName {
	return [NSEntityDescription entityForName:entityName inManagedObjectContext:[self managedObjectContext]];
}

#pragma mark - Deleting Managed Objects

- (void)deleteObject:(NSManagedObject *)object {
    [[self managedObjectContext] deleteObject:object];
}

@end


@implementation NSMutableString (PredicateString)

- (void)appendANDIfNeed {
    if (self.length) {
        [self appendString:@" AND "];
    }
}

- (void)appendPredicateString:(NSString *)predicateString {
    [self appendANDIfNeed];
    [self appendString:predicateString];
}

@end


@implementation NSEntityDescription (Gateway)

- (id)gateway {
    return [[CoreDataGateway registeredEntityGatewaysByEntityName] objectForKey:self.name];
}

@end
