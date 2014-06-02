//
//  TKEntityDescription.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/7/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TKPropertyTransformer;


@protocol TKEntityDescription <NSObject>

- (TKPropertyTransformer *)propertyTransformerForLocalKey:(NSString *)localKey;
- (id <TKEntityDescription>)subEntityDescriptionForKey:(NSString *)localKey;

- (NSSet *)exceptionKeys;
- (NSSet *)requiredKeys;

- (Class)defaultModelClass;

- (void)objectDidParse:(id)object toDictionary:(NSMutableDictionary *)dictionary;

@end
