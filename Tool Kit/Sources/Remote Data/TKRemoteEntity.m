//
//  TKRemoteEntity.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/7/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKRemoteEntity.h"
#import "TKPropertyTransformer.h"


@implementation TKRemoteEntity

static NSMutableDictionary *_entityDescriptionsByClassName = nil;

+ (NSMutableDictionary *)entityDescriptionsByClassName {
    if (!_entityDescriptionsByClassName) {
        _entityDescriptionsByClassName = [NSMutableDictionary dictionary];
    }
    
    return _entityDescriptionsByClassName;
}

+ (TKRemoteEntityDescription *)entityDescription {
    
    NSString *classString = NSStringFromClass([self class]);
    
    TKRemoteEntityDescription *entityDescription = self.entityDescriptionsByClassName[classString];
    
    if (!entityDescription) {
        entityDescription = [[self entityDescriptionClass] new];
        [self setUpEntityDescription:entityDescription];
        self.entityDescriptionsByClassName[classString] = entityDescription;
    }
    
    return entityDescription;
}

- (TKRemoteEntityDescription *)entityDescription {
    return [[self class] entityDescription];
}

+ (void)setUpEntityDescription:(TKRemoteEntityDescription *)entityDescription {
    entityDescription.defaultModelClass = [self class];
}


- (void)awakeFromMapping {
    
}

+ (Class)entityDescriptionClass {
    return [TKRemoteEntityDescription class];
}

- (NSString *)debugDescription {
    return self.localDictionaryRepresentation.description;
}

@end
