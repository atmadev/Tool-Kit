//
//  TKDateUtilities.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/30/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKDateUtilities.h"


NSString *const TKFileSystemDateFormat = @"dd-MM-yyyy";
NSString *const TKSimpleDateFormat = @"dd/MM/yyyy";
NSString *const TKDateWithTimeFormat = @"dd/MM/yyyy HH:mm:ss";
NSString *const TKTimeFormat = @"HH:mm";
NSString *const TKDateFormatYMD = @"yyyy.MM.dd";
NSString *const TKSqlDateTimeFormat = @"yyyy-MM-dd HH:mm:ss";
NSString *const TKSqlDateFormat = @"yyyy-MM-dd";
NSString *const TKFullDateFileSystemDateFormat = @"yyyy_MM_dd_HH_mm_ss";


@implementation TKDateUtilities

#pragma mark - Date formatters
#pragma mark GMT

+ (NSDateFormatter *)createPOSIXFormatter {
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    dateFormat.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    return dateFormat;
}

+ (NSDateFormatter *)formatterWithGMT {
    NSDateFormatter * dateFormat = [self createPOSIXFormatter];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    return dateFormat;
}

+ (NSDateFormatter *)formatterForSimpleDateGMT {
    NSDateFormatter * dateFormat = [self formatterWithGMT];
    [dateFormat setDateFormat:TKSimpleDateFormat];
    return dateFormat;
}

+ (NSDateFormatter *)formatterForDateWithTimeGMT {
    NSDateFormatter *dateFormat = [self formatterWithGMT];
    [dateFormat setDateFormat:TKDateWithTimeFormat];
    return dateFormat;
}

+ (NSDateFormatter *)formatterForFileSystemDateGMT {
    NSDateFormatter *dateFormat = [self formatterWithGMT];
    [dateFormat setDateFormat:TKFileSystemDateFormat];
    return dateFormat;
}

+ (NSDateFormatter *)formatterForFullDateFileSystemDateGMT {
    NSDateFormatter *dateFormat = [self formatterWithGMT];
    [dateFormat setDateFormat:TKFullDateFileSystemDateFormat];
    return dateFormat;
}

+ (NSDateFormatter *)formatterForDateYMDinGMT {
    NSDateFormatter * dateFormat = [self formatterWithGMT];
    [dateFormat setDateFormat:TKDateFormatYMD];
    return dateFormat;
}




#pragma mark Local

+ (NSDateFormatter *)formatterForSimpleDateCurrentLocale {
    NSDateFormatter * dateFormat = [NSDateFormatter new];
	[dateFormat setDateFormat:TKSimpleDateFormat];
    return dateFormat;
}

+ (NSDateFormatter *)formatterForDateWithLocalTime {
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    [dateFormat setDateFormat:TKDateWithTimeFormat];
    return dateFormat;
}

+ (NSDateFormatter *)formatterForTimeLocalTime {
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    [dateFormat setDateFormat:TKTimeFormat];
    return dateFormat;
}

#pragma mark - Dates
#pragma mark GMT

+ (NSString *)fileSystemStringFromCurrentDate {
    NSDateFormatter * dateFormat = [self formatterForFileSystemDateGMT];
    NSString * stringDate = [dateFormat stringFromDate:[NSDate date]];
    return stringDate;
}

+ (NSString *)fullDateFileSystemStringFromCurrentDate {
    NSDateFormatter * dateFormat = [self formatterForFullDateFileSystemDateGMT];
    NSString * stringDate = [dateFormat stringFromDate:[NSDate date]];
    return stringDate;
}

+ (NSString *)stringGMTFromCurrentDate {
	NSDateFormatter * dateFormat = [self formatterForSimpleDateGMT];
	NSString * stringDate = [dateFormat stringFromDate:[NSDate date]];
	return stringDate;
}


+ (NSString *)stringGMTFromCurrentDateYMD {
	NSDateFormatter * dateFormat = [self formatterForDateYMDinGMT];
	NSString * stringDate = [dateFormat stringFromDate:[NSDate date]];
	return stringDate;
}


+ (NSString *)stringGMTFromDate:(NSDate *)date {
	NSDateFormatter * dateFormat = [self formatterForSimpleDateGMT];
	NSString * stringDate = [dateFormat stringFromDate:date];
	return stringDate;
}

+ (NSString *)stringWithTimeGMTFromDate:(NSDate *)date {
	NSDateFormatter * dateFormat = [self formatterForDateWithTimeGMT];
	NSString * stringDate = [dateFormat stringFromDate:date];
	return stringDate;
}

+ (NSDate *)dateFromStringGMT:(NSString *)stringDate {
	NSDateFormatter * dateFormat = [self formatterForSimpleDateGMT];
	NSDate * date = [dateFormat dateFromString:stringDate];
	return date;
}

+ (NSDate *)dateWithTimeFromStringGMT:(NSString *)stringDate {
	NSDateFormatter * dateFormat = [self formatterForDateWithTimeGMT];
	NSDate * date = [dateFormat dateFromString:stringDate];
	return date;
}

#pragma mark Local

+ (NSString *)stringFromCurrentDate {
	NSDateFormatter * dateFormat = [self formatterForSimpleDateCurrentLocale];
	NSString * stringDate = [dateFormat stringFromDate:[NSDate date]];
	return stringDate;
}

+ (NSString *)stringFromDate:(NSDate *)date {
	NSDateFormatter * dateFormat = [self formatterForSimpleDateCurrentLocale];
	NSString * stringDate = [dateFormat stringFromDate:date];
	return stringDate;
}

+ (NSDate *)dateFromString:(NSString *)stringDate {
	NSDateFormatter * dateFormat = [self formatterForSimpleDateCurrentLocale];
	NSDate * date = [dateFormat dateFromString:stringDate];
	return date;
}

+ (NSString *)stringWithDateAndTimeFromDate:(NSDate *)date {
    NSDateFormatter *dateFormat = [self formatterForDateWithLocalTime];
    NSString *stringDate = [dateFormat stringFromDate:date];
    return stringDate;
}

+ (NSString *)stringWithTimeFromDate:(NSDate *)date {
    NSDateFormatter *dateFormat = [self formatterForTimeLocalTime];
    NSString *stringDate = [dateFormat stringFromDate:date];
    return stringDate;
}

#pragma mark - other

+ (NSDate *)dateFromStringGMT:(NSString *)string format:(NSString *)dateFormat locale:(NSLocale *)locale {
    NSDateFormatter *format = [self formatterWithGMT];
    if (locale != nil) {
        [format setLocale:locale];
    }
    [format setDateFormat:dateFormat];
    return [format dateFromString:string];
}

+ (NSString *)stringGMTFromDate:(NSDate *)date format:(NSString *)dateFormat locale:(NSLocale *)locale {
    NSDateFormatter *format = [self formatterWithGMT];
    if (locale != nil) {
        [format setLocale:locale];
    }
    [format setDateFormat:dateFormat];
    return [format stringFromDate:date];
}

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)dateFormat {
    NSDateFormatter* formatter = [NSDateFormatter new];
	[formatter setDateFormat:dateFormat];
    return [formatter stringFromDate:date];
}

+ (NSString *)stringSqlDateTimeFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [self formatterWithGMT];
    [formatter setDateFormat:TKSqlDateTimeFormat];
    return [formatter stringFromDate:date];
}

+ (NSDate *)dateFromSqlDateTimeString:(NSString *)string {
    NSDateFormatter *formatter = [self formatterWithGMT];
    [formatter setDateFormat:TKSqlDateTimeFormat];
    return [formatter dateFromString:string];
}

+ (NSString *)stringSqlDateFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [self formatterWithGMT];
    [formatter setDateFormat:TKSqlDateFormat];
    return [formatter stringFromDate:date];
}

+ (NSDate *)dateFromSqlDateString:(NSString *)string {
    NSDateFormatter *formatter = [self formatterWithGMT];
    [formatter setDateFormat:TKSqlDateFormat];
    return [formatter dateFromString:string];
}

#pragma mark -

+ (NSNumber *)timestampFromCurrentDate {
    return [self timestampFromDate:[NSDate date]];
}

+ (NSNumber *)timestampFromDate:(NSDate *)date {
    return [NSNumber numberWithDouble:[date timeIntervalSince1970]];
}

+ (NSDate *)dateFromTimestamp:(NSNumber *)timestamp {
    return [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue];
}

#pragma mark - 

+ (BOOL)isSameDayWithDate1:(NSDate*)date1 date2:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return  [comp1 day]   == [comp2 day] &&
            [comp1 month] == [comp2 month] &&
            [comp1 year]  == [comp2 year];
}

@end
