//
//  NSDictionary+Extensions.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/13/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "NSDictionary+Extensions.h"


@implementation NSDictionary (Extensions)

+ (NSDictionary *)dictionaryWithURLEncodedString:(NSString *)URLEncodedString {
    NSMutableDictionary *queryComponents = [NSMutableDictionary dictionary];
    for (NSString *keyValuePairString in [URLEncodedString componentsSeparatedByString:@"&"]) {
        
        NSArray *keyValuePairArray = [keyValuePairString componentsSeparatedByString:@"="];
        
        if ([keyValuePairArray count] < 2) continue;
        
        NSString *key = [[keyValuePairArray objectAtIndex:0] stringByReplacingURLEncoding];
        NSString *value = [[keyValuePairArray objectAtIndex:1] stringByReplacingURLEncoding];
        
        id results = [queryComponents objectForKey:key];
        
        if (results) {
            if ([results isKindOfClass:[NSMutableArray class]]) {
                [(NSMutableArray *)results addObject:value];
            } else {
                
                NSMutableArray *values = [NSMutableArray arrayWithObjects:results, value, nil];
                [queryComponents setObject:values forKey:key];
                
            }
        } else {
            [queryComponents setObject:value forKey:key];
        }
        [results addObject:value];
    }
    return queryComponents;
}

- (void)URLEncodePart:(NSMutableArray *)parts path:(NSString *)path value:(id)value {
    NSString *encodedPart = [[value description] stringByAddingURLEncoding];
    [parts addObject:[NSString stringWithFormat:@"%@=%@", path, encodedPart]];
}

- (void)URLEncodeParts:(NSMutableArray *)parts path:(NSString *)inPath {
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *encodedKey = [[key description] stringByAddingURLEncoding];
        NSString *path = inPath ? [inPath stringByAppendingFormat:@"[%@]", encodedKey] : encodedKey;
        
        if ([value isKindOfClass:[NSArray class]]) {
            for (id item in value) {
                if ([item isKindOfClass:[NSDictionary class]] || [item isKindOfClass:[NSMutableDictionary class]]) {
                    [item URLEncodeParts:parts path:[path stringByAppendingString:@"[]"]];
                } else {
                    [self URLEncodePart:parts path:[path stringByAppendingString:@"[]"] value:item];
                }
                
            }
        } else if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSMutableDictionary class]]) {
            [value URLEncodeParts:parts path:path];
        }
        else {
            [self URLEncodePart:parts path:path value:value];
        }
    }];
}

- (NSString *)stringWithURLEncodedEntries {
    NSMutableArray *parts = [NSMutableArray array];
    [self URLEncodeParts:parts path:nil];
    return [parts componentsJoinedByString:@"&"];
}

- (NSString *)URLEncodedString {
    return [self stringWithURLEncodedEntries];
}


@end
