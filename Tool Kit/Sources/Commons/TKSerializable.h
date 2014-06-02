//
//  TKSerializable.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/7/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TKSerializable : NSObject <NSCoding, NSCopying>

- (void)enumerateIvarListUsingBlock:(void (^)(NSString *key))block;

- (NSMutableDictionary *)dictionaryRepresentation;

@end
