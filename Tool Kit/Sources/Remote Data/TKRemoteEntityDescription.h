//
//  TKRemoteEntityDescription.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/7/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKEntityDescription.h"


@interface TKRemoteEntityDescription : NSObject <TKEntityDescription, NSCopying>

@property (nonatomic) Class defaultModelClass;

- (void)addPropertyTransformersByLocalKey:(NSDictionary *)propertyTransformers;

- (void)addSubEntityDescriptionsByLocalKey:(NSDictionary *)subEntityDescriptions;

- (void)addExceptionKeys:(NSSet *)exceptionKeys;
- (void)addRequiredKeys:(NSSet *)requiredKeys;

- (void)setDefaultPropertyTransformerClass:(Class)class;

@end
