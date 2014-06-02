//
//  TKDateUtilities.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/30/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TKDateUtilities : NSObject

+ (NSString *)stringFromCurrentDate;
+ (NSString *)fileSystemStringFromCurrentDate;
+ (NSString *)fullDateFileSystemStringFromCurrentDate;
+ (NSString *)stringGMTFromCurrentDate;
+ (NSString *)stringGMTFromCurrentDateYMD;

+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)stringGMTFromDate:(NSDate *)date;

+ (NSString *)stringWithDateAndTimeFromDate:(NSDate *)date;
+ (NSString *)stringWithTimeFromDate:(NSDate *)date;
+ (NSString *)stringWithTimeGMTFromDate:(NSDate *)date;


+ (NSString *)stringSqlDateTimeFromDate:(NSDate *)date;
+ (NSDate *)dateFromSqlDateTimeString:(NSString *)string;

+ (NSString *)stringSqlDateFromDate:(NSDate *)date;
+ (NSDate *)dateFromSqlDateString:(NSString *)string;


+ (NSDate *)dateFromString:(NSString *)stringDate;
+ (NSDate *)dateFromStringGMT:(NSString *)stringDate;

+ (NSDate *)dateWithTimeFromStringGMT:(NSString *)stringDate;

+ (NSDate *)dateFromStringGMT:(NSString *)string format:(NSString *)dateFormat locale:(NSLocale *)locale;
+ (NSString *)stringGMTFromDate:(NSDate *)date format:(NSString *)dateFormat locale:(NSLocale *)locale;

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)dateFormat;

+ (NSNumber *)timestampFromCurrentDate;
+ (NSNumber *)timestampFromDate:(NSDate *)date;

+ (NSDate *)dateFromTimestamp:(NSNumber *)timestamp;

+ (BOOL)isSameDayWithDate1:(NSDate*)date1 date2:(NSDate*)date2;

@end
