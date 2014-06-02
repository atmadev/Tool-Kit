//
//  TKRemoteEntityDescription.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/7/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKRemoteEntityDescription.h"
#import "TKPropertyTransformer.h"


@interface TKRemoteEntityDescription ()

@property (nonatomic, strong) NSMutableDictionary *propertyTransformersByLocalName;
@property (nonatomic, strong) NSMutableDictionary *subEntityDescriptionsByLocalName;
@property (nonatomic, strong) NSMutableSet *exceptionKeys;
@property (nonatomic, strong) NSMutableSet *requiredKeys;

@property (nonatomic) Class defaultPropertyTransformerClass;

@end


@implementation TKRemoteEntityDescription

- (id)init {
    self = [super init];
    if (self) {
        self.propertyTransformersByLocalName = [NSMutableDictionary dictionary];
        self.subEntityDescriptionsByLocalName = [NSMutableDictionary dictionary];
        self.exceptionKeys = [NSMutableSet set];
        self.requiredKeys = [NSMutableSet set];
    }
    return self;
}

- (void)addPropertyTransformersByLocalKey:(NSDictionary *)propertyTransformers {
    [self.propertyTransformersByLocalName addEntriesFromDictionary:propertyTransformers];
}

- (void)addSubEntityDescriptionsByLocalKey:(NSDictionary *)subEntityDescriptions {
    [self.subEntityDescriptionsByLocalName addEntriesFromDictionary:subEntityDescriptions];
}

- (void)addExceptionKeys:(NSSet *)exceptionKeys {
    [self.exceptionKeys unionSet:exceptionKeys];
}

- (void)addRequiredKeys:(NSSet *)requiredKeys {
    [self.requiredKeys unionSet:requiredKeys];
}

#pragma mark - Entity Description

- (TKPropertyTransformer *)propertyTransformerForLocalKey:(NSString *)localKey fromDictionary:(NSMutableDictionary *)dictionary {
    id transformer = dictionary[localKey];
    if (transformer) {
        if ([transformer isKindOfClass:[NSString class]]) {
            transformer = TKTransformerCreate(transformer);
            dictionary[localKey] = transformer;
        }
    }
    else {
        transformer = TKTransformerCreate(localKey);
        if (transformer) {
            dictionary[localKey] = transformer;
        }
    }
    
    return transformer;
}

- (TKPropertyTransformer *)propertyTransformerForLocalKey:(NSString *)localKey {
    return [self propertyTransformerForLocalKey:localKey fromDictionary:self.propertyTransformersByLocalName];
}

- (id <TKEntityDescription>)subEntityDescriptionForKey:(NSString *)localKey {
    return self.subEntityDescriptionsByLocalName[localKey];
}

- (void)objectDidParse:(id)object toDictionary:(NSMutableDictionary *)dictionary {
    
}

#pragma mark - Copying

- (id)copyWithZone:(NSZone *)zone {
    TKRemoteEntityDescription * object = [[self class] allocWithZone:zone];
    
    object.propertyTransformersByLocalName = self.propertyTransformersByLocalName.mutableCopy;
    object.subEntityDescriptionsByLocalName = self.subEntityDescriptionsByLocalName.mutableCopy;
    object.exceptionKeys = self.exceptionKeys.mutableCopy;
    object.requiredKeys = self.requiredKeys.mutableCopy;
    object.defaultPropertyTransformerClass = self.defaultPropertyTransformerClass;
    object.defaultModelClass = self.defaultModelClass;
    
    return object;
}

@end
