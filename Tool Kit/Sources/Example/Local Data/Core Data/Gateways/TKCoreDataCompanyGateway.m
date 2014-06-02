//
//  TKCoreDataCompanyGateway.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 6/2/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKCoreDataCompanyGateway.h"
#import "TKAbstractCoreDataEntityGatewayProtected.h"
#import "TKCompany.h"
#import "TKCoreDataEmployeeGateway.h"


@implementation TKCoreDataCompanyGateway

TK_ENTITY_GATEWAY_SINGLETON_INIT(TKCompany)

- (id)init {
    self = [super init];
    if (self) {
        [TKCoreDataEmployeeGateway gateway];
    }
    return self;
}

@end
