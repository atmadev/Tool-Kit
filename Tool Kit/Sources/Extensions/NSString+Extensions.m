//
//  NSString+Extensions.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/6/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "NSString+Extensions.h"
#import "TKDateUtilities.h"


@implementation NSString (Extensions)

- (NSString *)normalizedString {
    return [[self stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]] lowercaseString];
}

- (NSMutableAttributedString *)attributedString {
    return [[NSMutableAttributedString alloc] initWithString:self];
}

- (NSUInteger)integerValueFromHex {
	int result = 0;
	sscanf([self UTF8String], "%x", &result);
	return result;
}

+ (NSString *)uniqueString
{
    NSString* dateString = [TKDateUtilities fullDateFileSystemStringFromCurrentDate];
    NSString* hashString = [NSString randomStringWithLength:12];
    return [NSString stringWithFormat:@"%@_%@", dateString, hashString];
}

+ (NSString *)randomString
{
    return [NSString randomStringWithLength:32];
}


+ (NSString *)randomStringWithLength:(NSUInteger)length
{
    static char const possibleChars[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    unichar characters[length];
    for( int index = 0; index < length; ++index )
    {
        characters[ index ] = possibleChars[arc4random_uniform(sizeof(possibleChars)-1)];
    }
    return [NSString stringWithCharacters:characters length:length] ;
}


@end


#import "NSDictionary+Extensions.h"


@implementation NSString (URLEncoding)

- (NSString *)stringByStrippingHTML {
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

- (NSString *)stringByAppendingQueryParameters:(NSDictionary *)queryParameters {
    if ([queryParameters count] > 0) {
        return [NSString stringWithFormat:@"%@?%@", self, [queryParameters stringWithURLEncodedEntries]];
    }
    return [NSString stringWithString:self];
}

- (NSDictionary *)queryParameters {
    return [NSDictionary dictionaryWithURLEncodedString:self];
}



- (NSString *)stringByAddingURLEncoding {
    CFStringRef legalURLCharactersToBeEscaped = CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`\n\r");
    CFStringRef encodedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                        (CFStringRef)self,
                                                                        NULL,
                                                                        legalURLCharactersToBeEscaped,
                                                                        kCFStringEncodingUTF8);
    if (encodedString) {
        return (__bridge_transfer NSString *)encodedString;
    }
    
    return @"";
}

- (NSString *)stringByReplacingURLEncoding {
    return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)stringByDecodingHTMLEntitiesInString {
    
    NSMutableString *results = [NSMutableString string];
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    while (![scanner isAtEnd]) {
        NSString *temp;
        if ([scanner scanUpToString:@"&" intoString:&temp]) {
            [results appendString:temp];
        }
        if ([scanner scanString:@"&" intoString:NULL]) {
            BOOL valid = YES;
            unsigned c = 0;
            NSUInteger savedLocation = [scanner scanLocation];
            if ([scanner scanString:@"#" intoString:NULL]) {
                // it's a numeric entity
                if ([scanner scanString:@"x" intoString:NULL]) {
                    // hexadecimal
                    unsigned int value;
                    if ([scanner scanHexInt:&value]) {
                        c = value;
                    } else {
                        valid = NO;
                    }
                } else {
                    // decimal
                    int value;
                    if ([scanner scanInt:&value] && value >= 0) {
                        c = value;
                    } else {
                        valid = NO;
                    }
                }
                if (![scanner scanString:@";" intoString:NULL]) {
                    // not ;-terminated, bail out and emit the whole entity
                    valid = NO;
                }
            } else {
                if (![scanner scanUpToString:@";" intoString:&temp]) {
                    // &; is not a valid entity
                    valid = NO;
                } else if (![scanner scanString:@";" intoString:NULL]) {
                    // there was no trailing ;
                    valid = NO;
                } else if ([temp isEqualToString:@"amp"]) {
                    c = '&';
                } else if ([temp isEqualToString:@"quot"]) {
                    c = '"';
                } else if ([temp isEqualToString:@"lt"]) {
                    c = '<';
                } else if ([temp isEqualToString:@"gt"]) {
                    c = '>';
                } else {
                    // unknown entity
                    valid = NO;
                }
            }
            if (!valid) {
                // we errored, just emit the whole thing raw
                [results appendString:[self substringWithRange:NSMakeRange(savedLocation, [scanner scanLocation]-savedLocation)]];
            } else {
                [results appendFormat:@"%c", c];
            }
        }
    }
    
    return results;
}

- (NSString*) stringByDecodingURLFormat {
    NSString* result = [(NSString*)self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return result;
}

@end