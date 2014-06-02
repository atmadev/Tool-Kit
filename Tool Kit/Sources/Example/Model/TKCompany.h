//
//  TKCompany.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 6/2/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKBaseEntity.h"


@protocol TKCompany <TKBaseEntity>

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSSet * employees;

@end
