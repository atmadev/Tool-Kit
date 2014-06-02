//
//  TKKeyedTransformer.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 5/5/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKKeyedTransformer.h"


@implementation TKKeyedTransformer

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)data {
    if (data) {
        return [NSKeyedArchiver archivedDataWithRootObject:data];
    }
    return nil;
}

- (id)reverseTransformedValue:(NSData *)data {
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

@end


@implementation TKSetTransformer

+ (Class)transformedValueClass {
    return [NSSet class];
}

@end