//
//  TKRemoteEntity.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/7/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKRemoteEntityDescription.h"
#import "TKEntityImp.h"


@interface TKRemoteEntity : TKEntityImp

+ (void)setUpEntityDescription:(TKRemoteEntityDescription *)entityDescription;

- (void)awakeFromMapping;

+ (Class)entityDescriptionClass;

@end
