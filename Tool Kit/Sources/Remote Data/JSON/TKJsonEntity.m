//
//  TKJsonEntity.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/8/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKJsonEntity.h"
#import "TKJsonEntityDescription.h"


@implementation TKJsonEntity

//TODO: implement handling private ivars (_ivarName)

+ (Class)entityDescriptionClass {
    return [TKJsonEntityDescription class];
}

+ (TKJsonEntityDescription *)entityDescription {
    return (TKJsonEntityDescription *)[super entityDescription];
}

- (TKJsonEntityDescription *)entityDescription {
    return (TKJsonEntityDescription *)[super entityDescription];
}

@end
