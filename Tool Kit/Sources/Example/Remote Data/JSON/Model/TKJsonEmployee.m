//
//  TKJsonEmployee.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 6/2/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKJsonEmployee.h"
#import "TKPropertyTransformer.h"



@implementation TKJsonEmployee

@synthesize name;
@synthesize dateOfBirth;

@synthesize company;

+ (void)setUpEntityDescription:(TKRemoteEntityDescription *)entityDescription {
    [super setUpEntityDescription:entityDescription];
    
    [entityDescription addPropertyTransformersByLocalKey:@{@"dateOfBirth": TKSqlDateTransformerCreate(@"birthday")}];
    
    [entityDescription addExceptionKeys:[NSSet setWithObject:@"company"]];
}

@end
