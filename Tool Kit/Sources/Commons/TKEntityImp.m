//
//  TKEntityImp.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/17/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKRemoteEntity.h"
#import "TKRemoteEntityDescription.h"
#import "TKPropertyTransformer.h"


@implementation TKEntityImp

+ (TKRemoteEntityDescription *)entityDescription {
    return nil;
}

- (TKRemoteEntityDescription *)entityDescription {
    return nil;
}

#pragma mark - Dictionary Representation

- (NSMutableDictionary *)dictionaryRepresentationUsingEntityDescription:(id <TKEntityDescription>)entityDescription
                                                          forRemoteData:(BOOL)forRemoteData {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    __block NSString *remoteKey = nil;
    __block TKPropertyTransformer *transformer = nil;
    __block id nativeValue = nil;
    __block id dictionaryValue = nil;
    
    id <TKEntityDescription> currentEntity = (entityDescription ?: ([self entityDescription]));
    __block NSSet *exceptionKeys = [currentEntity exceptionKeys];
    
    [self enumerateIvarListUsingBlock:^(NSString *localKey) {
        
        if ([exceptionKeys containsObject:localKey]) {
            return;
        }
        
        dictionaryValue = nativeValue = [self valueForKey:localKey];
        
        
        if (nativeValue != nil) {
            
            if (forRemoteData) {
                transformer = [currentEntity propertyTransformerForLocalKey:localKey];
                remoteKey = transformer ? transformer.remoteKey : localKey;
            }
            else {
                remoteKey = localKey;
            }
            
            if ([nativeValue isKindOfClass:[TKRemoteEntity class]]) {
                dictionaryValue = [(TKRemoteEntity *)nativeValue dictionaryRepresentationUsingEntityDescription:entityDescription forRemoteData:forRemoteData];
            }
            else if ([nativeValue conformsToProtocol:@protocol(TKDictionaryRepresentation)]) {
                dictionaryValue = [(id <TKDictionaryRepresentation>)nativeValue remoteDictionaryRepresentationUsingEntityDescription:[currentEntity subEntityDescriptionForKey:localKey]];
            }
            else if (([nativeValue isKindOfClass:[NSArray class]] && [[nativeValue lastObject] conformsToProtocol:@protocol(TKDictionaryRepresentation)]) ||
                     ([nativeValue isKindOfClass:[NSSet class]] || [nativeValue isKindOfClass:[NSOrderedSet class]])) {
                NSMutableArray *array = [NSMutableArray array];
                for (id subValue in nativeValue) {
                    //TODO: perform refactoring. Optimize.
                    if ([subValue isKindOfClass:[TKRemoteEntity class]]) {
                        [array addObject:[subValue dictionaryRepresentationUsingEntityDescription:[currentEntity subEntityDescriptionForKey:localKey]
                                                                                    forRemoteData:forRemoteData]];
                    }
                    else if ([subValue conformsToProtocol:@protocol(TKDictionaryRepresentation)]) {
                        [array addObject:[subValue remoteDictionaryRepresentationUsingEntityDescription:[currentEntity subEntityDescriptionForKey:localKey]]];
                    }
                    else {
                        [array addObject:subValue];
                    }
                    
                }
                dictionaryValue = array;
            }
            
            if (forRemoteData && transformer) {
                dictionaryValue = [transformer remoteFromLocalValue:dictionaryValue]; //TODO: check it. Do we need pass dictionaryValue... maybe nativeValue?
            }
            
            [dictionary setObject:dictionaryValue forKey:remoteKey];
        }
    }];
    
    [currentEntity objectDidParse:self toDictionary:dictionary];
    
    return dictionary;
}

- (NSMutableDictionary *)remoteDictionaryRepresentationUsingEntityDescription:(TKRemoteEntityDescription *)entityDescription {
    return [self dictionaryRepresentationUsingEntityDescription:entityDescription forRemoteData:YES];
}

- (NSMutableDictionary *)dictionaryRepresentationForRemoteData:(BOOL)forRemoteData {
    return [self dictionaryRepresentationUsingEntityDescription:nil forRemoteData:forRemoteData];
}

- (NSMutableDictionary *)remoteDictionaryRepresentation {
    return [self dictionaryRepresentationForRemoteData:YES];
}

- (NSMutableDictionary *)localDictionaryRepresentation {
    return [self dictionaryRepresentationForRemoteData:NO];
}

@end
