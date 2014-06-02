//
//  NSDictionary+Extensions.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/13/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (Extensions)

+ (NSDictionary *)dictionaryWithURLEncodedString:(NSString *)URLEncodedString;
- (NSString *)stringWithURLEncodedEntries;

@end
