//
//  TKJsonEntityDescription.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/8/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKJsonEntityDescription.h"
#import "TKPropertyTransformer.h"


NSString *const UnderscoreString = @"_";


@interface TKJsonEntityDescription ()

@property (nonatomic) NSMutableDictionary *propertyTransformersByLocalName;
//@property (nonatomic) NSRegularExpression *regexp;

@end


@implementation TKJsonEntityDescription
/*
- (id)init {
    self = [super init];
    if (self) {
        self.regexp = [NSRegularExpression regularExpressionWithPattern:@"([a-z])([A-Z])"
                                                                options:0
                                                                  error:NULL];
    }
    return self;
}
*/

- (NSString *)convertToRemoteKey:(NSString *)localKey {
    
    if ([[localKey substringToIndex:1] isEqualToString:UnderscoreString]) {
        return [localKey substringFromIndex:1];
    }
       /*                                                                                           //       0123456
    NSString *entityShortName = [NSStringFromClass(self.defaultModelClass) substringFromIndex:7]; //escape TKJson
    
    NSMutableString *remoteKey = [NSMutableString stringWithString:entityShortName];
    [remoteKey appendString:@"_"];
    
    NSString *key = [self.regexp
                     stringByReplacingMatchesInString:localKey
                     options:0
                     range:NSMakeRange(0, localKey.length)
                     withTemplate:@"$1_$2"];
    [remoteKey appendString:key];
    
    NSString *finalKey = [remoteKey lowercaseString];
    
    DLog(@"%@ -> %@", localKey, finalKey);
    
    return finalKey;*/
    return localKey;
}

- (TKPropertyTransformer *)propertyTransformerForLocalKey:(NSString *)localKey {
    
    id transformer = self.propertyTransformersByLocalName[localKey];
    if (transformer) {
        if ([transformer isKindOfClass:[NSString class]]) {
            transformer = TKTransformerCreate(transformer);
            self.propertyTransformersByLocalName[localKey] = transformer;
        }
        
        if (!((TKPropertyTransformer *)transformer).remoteKey.length) {
            ((TKPropertyTransformer *)transformer).remoteKey = [self convertToRemoteKey:localKey];
        }
    }
    else {
        transformer = TKTransformerCreate([self convertToRemoteKey:localKey]);
        if (transformer) {
            self.propertyTransformersByLocalName[localKey] = transformer;
        }
    }
    
    return transformer;
}

@end
