//
//  TKDemo.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 6/2/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKDemo.h"
#import "TKJsonLoadCompaniesResponse.h"
#import "TKJsonMapper.h"
#import "TKCoreDataCompanyGateway.h"


@implementation TKDemo

- (void)demo {
    
    NSError * error = nil;
    
    TKJsonLoadCompaniesResponse * response = [TKJsonLoadCompaniesResponse remoteObjectFromJSONData:[self remoteJSONObject] error:&error];
    
    if (error) {
        DLog(@"%@", error);
        return;
    }
    
    NSArray * companies = [[TKCoreDataCompanyGateway gateway] insertObjects:response.companies error:&error];
    
    if (error) {
        DLog(@"%@", error);
        return;
    }
    
    DLog(@"inserted companies %@", [companies valueForKey:@"_dict"]);
}

- (NSData *)remoteJSONObject {
    NSArray * companies = @[ @{@"uid": @"1",
                               @"title": @"SoftwareGiant",
                               @"employees": @[ @{@"uid": @"1",
                                                  @"name": @"Valera",
                                                  @"birthday": @"1989-05-02"},
                                                @{@"uid": @"2",
                                                  @"name": @"Vasya",
                                                  @"birthday": @"1990-06-03"},
                                                @{@"uid": @"3",
                                                  @"name": @"Alex",
                                                  @"birthday": @"1991-04-30"}
                                                ]
                               },
                             @{@"uid": @"2",
                               @"title": @"MilleniumDevelopment",
                               @"employees": @[ @{@"uid": @"4",
                                                  @"name": @"Petro",
                                                  @"birthday": @"1992-04-14"},
                                                @{@"uid": @"5",
                                                  @"name": @"Afonya",
                                                  @"birthday": @"1985-06-09"}
                                                ]
                               }
                            ];
    NSError * error = nil;
    
    NSData * data = [NSJSONSerialization dataWithJSONObject:@{@"companies": companies} options:0 error:&error];
    
    if (error) {
        DLog(@"%@", error);
        return nil;
    }
    
    return data;
}

@end
