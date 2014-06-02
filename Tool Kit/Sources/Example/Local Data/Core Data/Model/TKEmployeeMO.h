//
//  TKEmployeeMO.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 6/2/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TKEmployee.h"
#import "TKCompanyMO.h"


@interface TKEmployeeMO : NSManagedObject <TKEmployee>

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * dateOfBirth;
@property (nonatomic, retain) TKCompanyMO *company;

@end
