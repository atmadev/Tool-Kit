//
//  TKJsonMapper.m
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/7/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//

#import "TKJsonMapper.h"
#import <objc/runtime.h>
#import "TKPropertyTransformer.h"


@interface TKJsonMapper ()

@end



@implementation TKJsonMapper

static TKJsonMapper *_mapper = nil;

+ (TKJsonMapper *)mapper {
    if (!_mapper) {
        _mapper = [self new];
    }
    return _mapper;
}

#pragma mark -

- (id)parseJSONObjectWithClass:(Class)classOfObject
                  decoderBlock:(id (^)(NSError **error))decoderBlock
          jsonDescriptionBlock:(NSString *(^)())jsonDescriptionBlock
                         error:(NSError **)anError {
    
    id object = nil;
    NSString *errorMessage = nil;
    NSError *error = nil;
    NSDictionary *jsonDictionary = decoderBlock(&error);
    
    if (error == nil) {
        object = [self createObjectFromDictionary:jsonDictionary ofClass:classOfObject error:&error];
    }
    else {
        errorMessage = [NSString stringWithFormat:@"ERROR when parsing json for class %@. Error %@ ;\n json string %@", classOfObject, error, jsonDescriptionBlock()];
    }
    
    if (errorMessage != nil) {
        error = [NSError errorWithDomain:NSStringFromClass(self.class)
                                    code:0//TODO:   TKLocalErrorFailedToParseResponce
                                userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
    }
    
    if (error) {
        if (anError != NULL) {
            *anError = error;
        }
        else {
            DLog(@"UNHANDLED ERROR: %@", errorMessage);
        }
        return nil;
    }
    
    return object;
}

- (id)parseJSONData:(NSData *)jsonData withClass:(Class)classOfObject error:(NSError **)anError {
    return [self parseJSONObjectWithClass:classOfObject
                             decoderBlock:^id(NSError **error) {
                                 return [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:error];
                                 
                             } jsonDescriptionBlock:^NSString *{
                                 return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                 
                             } error:anError];
}

- (id)parseJSONString:(NSString *)jsonString withClass:(Class)classOfObject error:(NSError **)anError {
    
    return [self parseJSONObjectWithClass:classOfObject
                             decoderBlock:^id(NSError **error) {
                                 return [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:error];
                                 
                             } jsonDescriptionBlock:^NSString *{
                                 return jsonString;
                                 
                             } error:anError];
}

- (NSData *)JSONDataFromRemoteEntity:(TKRemoteEntity *)remoteEntity error:(NSError **)error {
    return [[remoteEntity remoteDictionaryRepresentation] JSONDataWithError:error];
}

- (NSData *)JSONDataFromDictionary:(NSDictionary *)dictionary error:(NSError **)error {
    return [dictionary JSONDataWithError:error];
}

#pragma mark - Dictionary Mapping

- (id)createObjectFromDictionary:(NSDictionary *)dictionaryObject ofClass:(Class)nativeClass error:(NSError **)anError; {
    
    NSError *error = nil;
    NSString *errorMessage = nil;
    
    id nativeObject = nil;
    
    if ([nativeClass isSubclassOfClass:[NSMutableDictionary class]]) {
        return [NSMutableDictionary dictionaryWithDictionary:dictionaryObject];
    }
    else if ([nativeClass isSubclassOfClass:[NSDictionary class]]) {
        return dictionaryObject;
    }
    else if ([nativeClass isSubclassOfClass:[TKRemoteEntity class]]) {
        nativeObject = [nativeClass new];
        [self parseDictionary:dictionaryObject forClass:nativeClass toObject:nativeObject error:&error];
        if (error == nil) {
            [(TKRemoteEntity *)nativeObject awakeFromMapping];
        }
    }
    else {
        errorMessage = [NSString stringWithFormat:@"Unknown class %@", NSStringFromClass(nativeClass)];
    }
    
    if (errorMessage) {
        error = [NSError errorWithDomain:NSStringFromClass([self class])
                                    code:TKLocalErrorFailedToParseResponce
                                userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey]];
    }
    
    if (error) {
        if (anError != NULL) {
            *anError = error;
        }
        return nil;
    }
    
    return nativeObject;
}


- (BOOL)parseDictionary:(NSDictionary *)dictionaryObject forClass:(Class)nativeClass toObject:(id)nativeObject error:(NSError **)anError {
    
    NSString *errorMessage = nil;
    
    unsigned int ivarCount;
    Ivar *ivarList = NULL;
    id localValue = nil;
    Class nativeValueClass = nil;
    NSError *error = nil;
    Ivar currentIvar = NULL;
    NSString *localKey = nil;
    NSArray *remoteKeyPath = nil;
    
    TKPropertyTransformer *propertyTranformer = nil;
    
    id dictionaryValue = nil;
    id <TKEntityDescription> entityDescription = [nativeClass entityDescription];
    NSAssert(entityDescription, @"Missing entity description for class %@", nativeClass);
    NSSet *exceptionKeys = [entityDescription exceptionKeys];
    
    Class currentClass = nativeClass;
    
    while ([[currentClass superclass] isSubclassOfClass:[TKRemoteEntity class]]) {
        ivarList = class_copyIvarList(currentClass, &ivarCount);
        
        for (int i = 0; i < ivarCount; i++) {
            
            currentIvar = ivarList[i];
            localKey = [NSString stringWithCString:ivar_getName(currentIvar) encoding:NSUTF8StringEncoding];
            
            if ([exceptionKeys containsObject:localKey]) { continue; }
            
            propertyTranformer = [entityDescription propertyTransformerForLocalKey:localKey];
            
            remoteKeyPath = propertyTranformer.remoteKeyPath;
            
            dictionaryValue = dictionaryObject;
            
            if (remoteKeyPath.count > 1) {
                NSEnumerator * itemEnumerator = remoteKeyPath.objectEnumerator;
                NSString * remoteKeyPathItem = [itemEnumerator nextObject];
                
                while (remoteKeyPathItem && dictionaryValue != nil && dictionaryValue != [NSNull null]) {
                    if ([dictionaryValue isKindOfClass:[NSArray class]]) {
                        dictionaryValue = [dictionaryValue firstObject];
                    }
                    else {
                        dictionaryValue = dictionaryValue[remoteKeyPathItem];
                        remoteKeyPathItem = [itemEnumerator nextObject];
                    }
                }
            }
            else {
                dictionaryValue = dictionaryValue[remoteKeyPath.firstObject];
            }
            
            localValue = dictionaryValue;
            
            if (dictionaryValue != nil && ![dictionaryValue isEqual:[NSNull null]]) {
                
                BOOL isDictionaryValueClassKindOfDictionary = [dictionaryValue isKindOfClass:[NSDictionary class]];
                BOOL isDictionaryValueIsCollection = [[dictionaryValue class] isCollection];
                
                //Custom mapping
                if (isDictionaryValueClassKindOfDictionary || isDictionaryValueIsCollection) {
                    
                    nativeValueClass = propertyTranformer.inputRemoteValueClass;
                    
                    NSString *nativeValueProtocolName = nil;
                    if (!nativeValueClass) {
                        NSString *typeString = [NSString stringWithCString:ivar_getTypeEncoding(currentIvar) encoding:NSUTF8StringEncoding];
                        nativeValueClass = [self parseTypeString:typeString forClassAndProtocolName:&nativeValueProtocolName error:&error];
                    }
                    
                    
                    if (error == nil) {
                        
                        //In case when array contains only one object
                        //Some stupid remote services return object instead of the array with that object
                        if ([nativeValueClass isCollection] && !isDictionaryValueIsCollection) {
                            dictionaryValue = @[dictionaryValue];
                            isDictionaryValueIsCollection = YES;
                        }
                        
                        if ([nativeValueClass isSubclassOfClass:[TKRemoteEntity class]] && isDictionaryValueClassKindOfDictionary) { //Custom object detected
                            localValue = [self createObjectFromDictionary:dictionaryValue ofClass:nativeValueClass error:&error];
                            if (error) {
                                errorMessage = error.localizedDescription;
                                break;
                            }
                        }
                        else if ([nativeValueClass isCollection] && isDictionaryValueIsCollection) {
                            
                            id <TKEntityDescription> subEntityDescription = [entityDescription subEntityDescriptionForKey:localKey];
                            
                            Class nativeValueCollectionItemClass = [subEntityDescription defaultModelClass];
                            
                            if (!nativeValueCollectionItemClass && nativeValueProtocolName != nil) { //nativeValueCollectionItemClass declared in the model as protocol
                                NSString *subNativeValueClassName = [nativeValueProtocolName substringToIndex:[nativeValueProtocolName rangeOfString:@"Protocol"].location];
                                nativeValueCollectionItemClass = NSClassFromString(subNativeValueClassName);
                            }
                            
                            if (nativeValueCollectionItemClass) { //Collection with custom objects detected
                                
                                Class collectionClass = [nativeValueClass isMutable] ? nativeValueClass : [NSMutableArray class];
                                id array = [[collectionClass alloc] initWithCapacity:[dictionaryValue count]];
                                
                                BOOL success = YES;
                                
                                id subNativeValue = nil;
                                for (id subDictionaryValue in dictionaryValue) {
                                    subNativeValue = [self createObjectFromDictionary:subDictionaryValue ofClass:nativeValueCollectionItemClass error:&error];
                                    
                                    if (subNativeValue) {
                                        [array addObject:subNativeValue];
                                    }
                                    else {
                                        success = NO;
                                        break; //Error handling is outside of the loop
                                    }
                                }
                                
                                if (!success) { break; }
                                
                                if ([nativeValueClass isMutable]) {
                                    localValue = array;
                                }
                                else {
                                    localValue = [[nativeValueClass alloc] initWithArray:array];
                                }
                            }
                            else {
                                localValue = [(id <TKCollection>)dictionaryValue convertToCollectionWithClass:nativeValueClass];
                            }
                        }
                        else if ([nativeClass isSubclassOfClass:[NSObject class]] && [dictionaryValue isKindOfClass:[NSObject class]]) {
                            localValue = dictionaryValue;
                        }
                        else if ((![nativeValueClass isSubclassOfClass:[NSDictionary class]] && isDictionaryValueClassKindOfDictionary) ||
                                 (![nativeValueClass isCollection]  && isDictionaryValueIsCollection)) {
                            
                            errorMessage = [NSString stringWithFormat:@"Incompatible types of native value (%@) and dictionary value (%@) for key '%@' in the %@ strucutre", [nativeValueClass class], [dictionaryValue class], localKey, nativeClass];
                        }
                    }
                }
                
                if (errorMessage == nil && error == nil) {
                    
                    if (propertyTranformer) {
                        localValue = [propertyTranformer localFromRemoteValue:localValue];
                    }
                    
                    @try {
                        [nativeObject setValue:localValue forKey:localKey];
                    }
                    @catch (NSException *exception) {
                        DLog(@"%@", exception);
                        errorMessage = [NSString stringWithFormat:@"%@ %@", exception.name, exception.reason];
                        break;
                    }
                }
                else {
                    break;
                }
            }
            else if ([[entityDescription requiredKeys] containsObject:localKey]) {
                DLog(@"Object for key \"%@\" is absent in the %@ structure", remoteKeyPath, [nativeObject class]);
            }
        } // <-- End of the "for" loop by ivars
        
        free(ivarList);
        
        if (errorMessage) {
            error = [NSError errorWithDomain:NSStringFromClass(self.class)
                                        code:TKLocalErrorFailedToParseResponce
                                    userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
        }
        
        if (error) {
            if (anError != nil) {
                *anError = error;
            }
            return NO;
        }
        
        currentClass = [currentClass superclass];
    } // <-- End of the "while" loop by classes
    
    return YES;
}



- (Class)parseTypeString:(NSString *)typeString forClassAndProtocolName:(NSString **)protocolName error:(NSError **)error {
    NSString *className = nil;
    if ([typeString rangeOfString:@"@"].location != NSNotFound) { //typeString: { @ }
        if ([typeString rangeOfString:@"\""].location != NSNotFound) { //typeString:  { @"class" }
            NSArray *components = [typeString componentsSeparatedByString:@"\""]; //components: [ @ | class | nil ]
            NSString *classProtocolName = [components objectAtIndex:1];
            
            if ([classProtocolName rangeOfString:@"<"].location != NSNotFound) { //classProtocolName: { class<protocol> }
                NSArray *classProtocolComponents = [classProtocolName componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]; // components: [ class | protocol | nil ]
                className = [classProtocolComponents objectAtIndex:0];
                if ([className isEqualToString:@""]) {
                    className = NSStringFromClass([NSObject class]);
                }
                if (protocolName != nil) {
                    *protocolName = [classProtocolComponents objectAtIndex:1];
                }
            }
            else { //classProtocolName: { class }
                className = classProtocolName;
            }
        }
        else {
            className = NSStringFromClass([NSObject class]);
        }
    }
    else if (error != nil) {
        *error = [NSError errorWithDomain:@"non-object types not supproted yet..."
                                     code:-1
                                 userInfo:nil];
        return nil;
    }
    
    return NSClassFromString(className);
}

@end


#pragma mark - Categories

@implementation NSData (JSONMapperDeserializing)

- (id)remoteObjectWithClass:(Class)classOfObject error:(NSError **)error {
    return [JSONMapper parseJSONData:self withClass:classOfObject error:error];
}

@end


@implementation NSDictionary (JSONMapperDeserializing)

- (id)remoteObjectWithClass:(Class)classOfObject error:(NSError **)error {
    return [JSONMapper createObjectFromDictionary:self ofClass:classOfObject error:error];
}

@end


@implementation NSString (JSONMapperDeserializing)

- (id)remoteObjectWithClass:(Class)classOfObject error:(NSError **)error {
    return [JSONMapper parseJSONString:self withClass:classOfObject error:error];
}

- (id)objectFromJSONWithError:(NSError **)anError {
    return [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                           options:0
                                             error:anError];
}

@end


@implementation TKRemoteEntity (JSONMapperDeserializing)

+ (id)remoteObjectFromJSONData:(NSData *)jsonData error:(NSError **)error {
    return [JSONMapper parseJSONData:jsonData withClass:[self class] error:error];
}

@end


@implementation TKRemoteEntity (JSONMapperSerializing)

- (NSData *)JSONDataWithError:(NSError **)error {
    return [JSONMapper JSONDataFromRemoteEntity:self error:error];
}

@end


@implementation NSDictionary (JSONMapperSerializing)

- (NSData *)JSONDataWithError:(NSError **)error {
    return [NSJSONSerialization dataWithJSONObject:self options:0
                                             error:error];
}

- (NSString *)JSONStringWithError:(NSError *__autoreleasing *)anError {
    NSError * error = nil;
    NSData * jsonData = [self JSONDataWithError:&error];
    CheckErrorAndReturn(error, anError, nil);
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end


@implementation NSArray (JSONMapperSerializing)

- (NSData *)JSONDataWithError:(NSError **)error {
    return [NSJSONSerialization dataWithJSONObject:self options:0 error:error];
}

@end
