//
//  TKJsonCompany.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 6/2/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKJsonCompany.h"
#import "TKJsonEmployee.h"


@implementation TKJsonCompany

@synthesize name;

@synthesize employees;

+ (void)setUpEntityDescription:(TKRemoteEntityDescription *)entityDescription {
    [super setUpEntityDescription:entityDescription];
    
    [entityDescription addPropertyTransformersByLocalKey:@{@"name": @"title"}];
    
    [entityDescription addSubEntityDescriptionsByLocalKey:@{@"employees": [TKJsonEmployee entityDescription]}];
}

@end
