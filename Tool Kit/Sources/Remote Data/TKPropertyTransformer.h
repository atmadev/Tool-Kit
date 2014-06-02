//
//  TKPropertyTransformer.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 6/1/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TKPropertyTransformer : NSObject

@property (nonatomic, strong) NSString *remoteKey;
@property (nonatomic, strong, readonly) NSArray *remoteKeyPath;

+ (id)propertyTransformerWithRemoteKey:(NSString *)remoteKey;
- (id)initWithRemoteKey:(NSString *)remoteKey;

- (Class)inputRemoteValueClass;

- (id)localFromRemoteValue:(id)value;
- (id)remoteFromLocalValue:(id)value;

@end

id TKTransformerCreate(NSString *remoteKey);


@interface TKIntegerTransformer : TKPropertyTransformer
@end

id TKIntegerTransformerCreate(NSString *remoteKey);



@interface TKDecimalTransformer : TKPropertyTransformer
@end

id TKDecimalTransformerCreate(NSString *remoteKey);



@interface TKTimestampTransformer : TKPropertyTransformer
@end

id TKTimestampTransformerCreate(NSString *remoteKey);



@interface TKSqlDateTimeTransformer : TKPropertyTransformer
@end

id TKSqlDateTimeTransformerCreate(NSString *remoteKey);



@interface TKSqlDateTransformer : TKPropertyTransformer
@end

id TKSqlDateTransformerCreate(NSString *remoteKey);



@interface TKFloatTransformer : TKPropertyTransformer

@end

id TKFloatTransformerCreate(NSString *remoteKey);


@interface TKBoolTransformer : TKPropertyTransformer

@end

id TKBoolTransformerCreate(NSString *remoteKey);
