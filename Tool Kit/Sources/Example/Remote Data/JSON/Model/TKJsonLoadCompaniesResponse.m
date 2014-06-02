//
//  TKJsonLoadCompaniesResponse.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 6/2/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKJsonLoadCompaniesResponse.h"
#import "TKJsonCompany.h"


@implementation TKJsonLoadCompaniesResponse

@synthesize companies;

+ (void)setUpEntityDescription:(TKRemoteEntityDescription *)entityDescription {
    [super setUpEntityDescription:entityDescription];
    
    [entityDescription addSubEntityDescriptionsByLocalKey:@{@"companies": [TKJsonCompany entityDescription]}];
}

@end
