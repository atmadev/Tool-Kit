//
//  TKAbstractCoreDataEntityGateway.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/4/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>


@class NSEntityDescription;


@interface TKAbstractCoreDataEntityGateway : NSObject

@property (nonatomic, strong, readonly) NSEntityDescription *entityDescription;


/*!
 * @method
 * anyObject
 *
 * @return
 * One of the objects in the Data Base, or nil if the Data Base contains no objects.
 * The object returned is chosen at the set’s convenience—the selection is not guaranteed to be random.
 */
- (id)anyObject;

/*!
 * @method
 * objects
 *
 * @return
 * All objects of the current entity in the Data Base
 */
- (NSArray *)objects;

/*!
 * @method
 * objectsCount
 *
 * @return
 * Count of the objects of the current entity in the Data Base
 */
- (NSNumber *)objectsCount;

/*!
 * @method
 * createObject
 *
 * @return
 * New object with applied default settings
 */
- (id)createObject;

/*!
 * @method
 * applyDefaultSettingsForObject:
 *
 * @return
 * Set default values of entitiy to the object. Can be overriden and set custom default values
 */
- (void)applyDefaultSettingsForObject:(id)object;

/*!
 * @method
 * refreshObject:
 *
 * @return
 * Updates the persistent properties of a object to use the latest values from the persistent store. Also merges changes.
 */
- (void)refreshObject:(id)object;

/*!
 * @method
 * insertObject:isFirstInsert:error:
 *
 * @abstract
 * Inserts given object to the Data Base and saves it
 *
 * @param object
 * Object for inserting to the Data Base
 *
 * @param isFirstInsert
 * If YES, gateway will not look for the same object in the Data Base for updating
 *
 * @discussion
 * Pass isFirstInsert:YES if you insert objects at first time, it increases performance
 *
 * @return
 * Inserted object. It is not the same, what passed in argument "object". It is native Data Base object.
 */
- (id)insertObject:(id)object isFirstInsert:(BOOL)isFirstInsert error:(NSError **)anError;
- (id)insertObject:(id)object error:(NSError **)anError;

/*!
 * @method
 * insertObjectWithoutSaving:isFirstInsert:error:
 *
 * @abstract
 * Inserts given object to the Data Base
 *
 * @param object
 * Object for inserting to the Data Base
 *
 * @param isFirstInsert
 * If YES, gateway will not look for the same object in the Data Base for updating
 *
 * @discussion
 * Pass isFirstInsert:YES if you insert objects at first time, it increases performance
 *
 * @return
 * Inserted object. It is not the same, what passed in argument "object". It is native Data Base object.
 */
- (id)insertObjectWithoutSaving:(id)object isFirstInsert:(BOOL)isFirstInsert error:(NSError *__autoreleasing *)anError;

/*!
 * @method
 * insertObjects:isFirstInsert:error:
 *
 * @param objects
 * Objects for inserting to the Data Base
 *
 * @param isFirstInsert
 * If YES, gateway will not look for the same objects in the Data Base for updating
 *
 * @abstract
 * Inserts given objects to the Data Base and saves it
 *
 * @discussion
 * Pass isFirstInsert:YES if you insert objects at first time, it increases performance
 *
 * @return
 * Inserted objects. It is not the same, what did passed in argument "objects". It are native Data Base objects.
 */
- (NSArray *)insertObjects:(id <TKCollection>)objects isFirstInsert:(BOOL)isFirstInsert error:(NSError **)anError;

- (NSArray *)insertObjects:(id <TKCollection>)objects error:(NSError **)anError;

/*!
 * @method
 * insertObjectsWithoutSaving:isFirstInsert:error:
 *
 * @param objects
 * Objects for inserting to the Data Base
 *
 * @param isFirstInsert
 * If YES, gateway will not look for the same objects in the Data Base for updating
 *
 * @abstract
 * Inserts given objects to the Data Base
 *
 * @discussion
 * Pass isFirstInsert:YES if you insert objects at first time, it increases performance
 *
 * @return
 * Inserted objects. It is not the same, what did passed in argument "objects". It are native Data Base objects.
 */
- (NSArray *)insertObjectsWithoutSaving:(id <TKCollection>)objects
                          isFirstInsert:(BOOL)isFirstInsert
                                  error:(NSError *__autoreleasing *)anError;

/*!
 * @method
 * saveObject:error:
 *
 * @param object
 * Must be the kind of NSManagedObject class if you use Core Data storage
 *
 * @return
 * Saved object
 */
- (id)saveObject:(id)object error:(NSError **)anError;


/*!
 * @method
 * saveObjects:
 *
 * @param objects
 * All objects must be the kind of NSManagedObject class if you use Core Data storage
 */
- (NSArray *)saveObjects:(id <TKCollection>)objects error:(NSError **)anError;

- (id)updateObject:(id)existingObject withObject:(id)newObject error:(NSError **)anError;
- (NSArray *)updateObjects:(NSArray *)existingObjects withObjects:(NSArray *)newObjects error:(NSError **)anError;

/*!
 * @method
 * deleteObject:
 *
 * @param object
 * Native Data Base object
 *
 * @discussion
 * Don't use object after deleting, and don't keep reference to it.
 */
- (void)deleteObject:(id)object;

- (void)deleteObjectWithoutSaving:(id)object;

/*!
 * @method
 * deleteObject:
 *
 * @param objects
 * Native Data Base objects
 *
 * @discussion
 * Don't use objects after deleting, and don't keep references to it.
 */
- (void)deleteObjects:(id <TKCollection>)objects;


/*!
 * @method
 * cleanUp
 *
 * @abstract
 * Deletes all not-valid objects.
 */
- (void)cleanUp;

/*!
 * @method
 * reset
 *
 * @abstract
 * Unload all objects from context
 *
 * @discussion
 * Use this method for decrease memory overhead. Don't forget to remove all references to the objects from the Data Base
 */
- (void)reset;

- (id)objectWithPredicateString:(NSString *)predicateString arguments:(NSArray *)arguments;

- (NSArray *)objectsWithPredicateString:(NSString *)predicateString arguments:(NSArray *)arguments;

- (NSArray *)objectsWithPredicateString:(NSString *)predicateString
                              arguments:(NSArray *)arguments
                               sortKeys:(NSArray *)sortKeys;

- (id)insertObjectWithoutSaving:(id)object
                  isFirstInsert:(BOOL)isFirstInsert
                       userInfo:(NSDictionary *)userInfo
           mergeChangesToObject:(id)existingObject
                          error:(NSError *__autoreleasing *)anError;

- (id)insertObjectWithoutSaving:(id)object
                  isFirstInsert:(BOOL)isFirstInsert
                       userInfo:(NSDictionary *)userInfo
                          error:(NSError *__autoreleasing *)anError;

- (NSArray *)insertObjectsWithoutSaving:(id <TKCollection>)objects
                          isFirstInsert:(BOOL)isFirstInsert
                               userInfo:(NSDictionary *)userInfo
                                  error:(NSError *__autoreleasing *)anError;

- (id)mapObject:(id)inputObject
  isFirstInsert:(BOOL)isFirstInsert
       userInfo:(NSDictionary *)userInfo
mergeChangesToObject:(id)existingObject
          error:(NSError *__autoreleasing *)anError;

@end


@interface TKAbstractCoreDataEntityGateway ( Abstract )

+ (id)gateway;

- (NSString *)entityName;

@end