//
//  TKDictionaryRepresentation.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/7/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TKEntityDescription;


@protocol TKDictionaryRepresentation <NSObject>

- (NSMutableDictionary *)remoteDictionaryRepresentationUsingEntityDescription:(id <TKEntityDescription>)entityDescription;
- (NSMutableDictionary *)remoteDictionaryRepresentation;
- (NSMutableDictionary *)localDictionaryRepresentation;

@end
