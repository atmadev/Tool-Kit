//
//  NSManagedObject+TKExtensions.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/6/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "TKDictionaryRepresentation.h"


@interface NSManagedObject (TKExtensions)

- (id)originalObject;
- (id)objectContainer;

#ifdef DEBUG
- (NSMutableDictionary *)_desc;
#endif

@end


@interface NSManagedObject (TKDictionaryRepresentation) <TKDictionaryRepresentation>

#ifdef DEBUG
- (NSMutableDictionary *)_dict;
#endif

@end


@interface NSManagedObjectID (objectContainer)

- (id)originalObject;
- (id)objectContainer;

@end
