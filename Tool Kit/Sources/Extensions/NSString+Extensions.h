//
//  NSString+Extensions.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/6/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Extensions)

- (NSString *)normalizedString;
- (NSMutableAttributedString *)attributedString;

- (NSUInteger)integerValueFromHex;

+ (NSString *)uniqueString;
+ (NSString *)randomString;
+ (NSString *)randomStringWithLength:(NSUInteger)length;

@end


@interface NSString (URLEncoding)

- (NSString *)stringByAppendingQueryParameters:(NSDictionary *)queryParameters;

- (NSDictionary *)queryParameters;

- (NSString *)stringByAddingURLEncoding;

- (NSString *)stringByReplacingURLEncoding;

- (NSString *)stringByDecodingHTMLEntitiesInString;

- (NSString *)stringByDecodingURLFormat;

- (NSString *)stringByStrippingHTML;

@end
