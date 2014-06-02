//
//  TKBaseEntity.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 6/1/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKEntity.h"


@protocol TKBaseEntity <TKEntity>

@property (nonatomic, strong) NSNumber * id;

@end
