//
//  TKCompanyMO.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 6/2/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TKCompany.h"


@class TKEmployeeMO;

@interface TKCompanyMO : NSManagedObject <TKCompany>

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSSet *employees;
@end

@interface TKCompanyMO (CoreDataGeneratedAccessors)

- (void)addEmployeesObject:(TKEmployeeMO *)value;
- (void)removeEmployeesObject:(TKEmployeeMO *)value;
- (void)addEmployees:(NSSet *)values;
- (void)removeEmployees:(NSSet *)values;

@end
