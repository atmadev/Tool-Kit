//
//  TKJsonEntity.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/8/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKRemoteEntity.h"

@class TKJsonEntityDescription;


@interface TKJsonEntity : TKRemoteEntity

+ (TKJsonEntityDescription *)entityDescription;
- (TKJsonEntityDescription *)entityDescription;

@end
