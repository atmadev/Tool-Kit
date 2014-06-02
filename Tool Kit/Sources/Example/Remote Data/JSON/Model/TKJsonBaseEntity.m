//
//  TKJsonBaseEntity.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 6/2/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKJsonBaseEntity.h"
#import "TKPropertyTransformer.h"


@implementation TKJsonBaseEntity

@synthesize id;

+ (void)setUpEntityDescription:(TKRemoteEntityDescription *)entityDescription {
    [super setUpEntityDescription:entityDescription];
    
    [entityDescription addPropertyTransformersByLocalKey:@{@"id": TKIntegerTransformerCreate(@"uid")}];
}

@end
