//
//  TKEntityImp.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/17/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKSerializable.h"
#import "TKEntity.h"
#import "TKDictionaryRepresentation.h"

@class TKRemoteEntityDescription;


@interface TKEntityImp : TKSerializable <TKDictionaryRepresentation>

+ (TKRemoteEntityDescription *)entityDescription;
- (TKRemoteEntityDescription *)entityDescription;

@end
