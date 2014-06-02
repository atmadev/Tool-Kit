//
//  TKPropertyTransformer.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 6/1/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKPropertyTransformer.h"


@interface TKPropertyTransformer ()

@property (nonatomic, strong) NSArray *remoteKeyPath;

@end


@implementation TKPropertyTransformer

+ (id)propertyTransformerWithRemoteKey:(NSString *)remoteKey {
    return [[self alloc] initWithRemoteKey:remoteKey];
}

- (id)initWithRemoteKey:(NSString *)remoteKey {
    self = [self init];
    if (self) {
        self.remoteKey = remoteKey;
    }
    return self;
}

- (void)setRemoteKey:(NSString *)remoteKey {
    _remoteKey = remoteKey;
    self.remoteKeyPath = [remoteKey componentsSeparatedByString:@"."];
}

- (Class)inputRemoteValueClass {
    return nil;
}

- (id)localFromRemoteValue:(id)value {
    return value;
}

- (id)remoteFromLocalValue:(id)value {
    return value;
}

@end

id TKTransformerCreate(NSString *remoteKey) {
    return [[TKPropertyTransformer alloc] initWithRemoteKey:remoteKey];
}



@implementation TKIntegerTransformer

- (NSNumber *)localFromRemoteValue:(NSString *)value {
    NSInteger integerValue = value.integerValue;
    return integerValue ? @(integerValue) : nil;
}

- (NSString *)remoteFromLocalValue:(NSNumber *)value {
    return value ? value.stringValue : nil;
}

@end

id TKIntegerTransformerCreate(NSString *remoteKey) {
    return [[TKIntegerTransformer alloc] initWithRemoteKey:remoteKey];
}



@implementation TKDecimalTransformer

- (NSDecimalNumber *)localFromRemoteValue:(NSString *)value {
    return [NSDecimalNumber decimalNumberWithString:value];
}

- (NSString *)remoteFromLocalValue:(NSDecimalNumber *)value {
    return [value stringValue];
}

@end

id TKDecimalTransformerCreate(NSString *remoteKey) {
    return [TKDecimalTransformer propertyTransformerWithRemoteKey:remoteKey];
}



@implementation TKTimestampTransformer

- (NSDate *)localFromRemoteValue:(NSString *)value {
    return [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
}

- (NSNumber *)remoteFromLocalValue:(NSDate *)value {
    return @([value timeIntervalSince1970]);
}

@end

id TKTimestampTransformerCreate(NSString *remoteKey) {
    return [TKTimestampTransformer propertyTransformerWithRemoteKey:remoteKey];
}



#import "TKDateUtilities.h"

@implementation TKSqlDateTimeTransformer

- (NSDate *)localFromRemoteValue:(NSString *)value {
    return [TKDateUtilities dateFromSqlDateTimeString:value];
}

- (NSString *)remoteFromLocalValue:(NSDate *)value {
    return [TKDateUtilities stringSqlDateTimeFromDate:value];
}

@end

id TKSqlDateTimeTransformerCreate(NSString *remoteKey) {
    return [TKSqlDateTimeTransformer propertyTransformerWithRemoteKey:remoteKey];
}


@implementation TKSqlDateTransformer

- (NSDate *)localFromRemoteValue:(NSString *)value {
    return [TKDateUtilities dateFromSqlDateString:value];
}

- (NSString *)remoteFromLocalValue:(NSDate *)value {
    return [TKDateUtilities stringSqlDateFromDate:value];
}

@end

id TKSqlDateTransformerCreate(NSString *remoteKey) {
    return [TKSqlDateTransformer propertyTransformerWithRemoteKey:remoteKey];
}



@implementation TKFloatTransformer

- (NSNumber *)localFromRemoteValue:(NSString *)value {
    return value ? @(value.floatValue) : nil;
}

- (NSString *)remoteFromLocalValue:(NSNumber *)value {
    return value ? value.stringValue : nil;
}


@end

id TKFloatTransformerCreate(NSString *remoteKey) {
    return [TKFloatTransformer propertyTransformerWithRemoteKey:remoteKey];
}


@implementation TKBoolTransformer

- (NSNumber *)localFromRemoteValue:(NSString *)value {
    return value ? @(value.boolValue) : nil;
}

- (NSString *)remoteFromLocalValue:(NSNumber *)value {
    return value ? value.stringValue : nil;
}

@end


id TKBoolTransformerCreate(NSString *remoteKey) {
    return [TKBoolTransformer propertyTransformerWithRemoteKey:remoteKey];
}
