//
//  NSValueTransformer+MTLTPredefinedTransformerAdditions.m
//  MantleExtension
//
//  Created by Marke Jave on 16/6/13.
//  Copyright © 2016年 Marike Jave. All rights reserved.
//

#import <objc/runtime.h>

#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"
#import "MTLJSONAdapter+Categories.h"

NSString * const MTLDateTimeValueTransformerName = @"MTLDateTimeValueTransformerName";
NSString * const MTLDateValueTransformerName = @"MTLDateValueTransformerName";
NSString * const MTLTimeValueTransformerName = @"MTLTimeValueTransformerName";

NSString * const MTLAnyValueInSetTransformerName = @"MTLAnyValueInSetTransformerName";

@implementation NSArray (AnyValue)

- (id)anyObject{
    for (id objcet in self) {
        if (objcet != [NSNull null]) {
            return objcet;
        }
    }
    return nil;
}

@end

@interface MTLAnyValueTransformer : MTLValueTransformer
@end

@implementation MTLAnyValueTransformer
@end

@implementation NSValueTransformer (MTLPredefinedTransformerAdditions)

#pragma mark Category Loading

+ (void)load {
    @autoreleasepool {
        NSValueTransformer *dateTimeValueTransformer = [NSValueTransformer mtl_dateTransformerWithDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSValueTransformer *dateValueTransformer = [NSValueTransformer mtl_dateTransformerWithDateFormat:@"yyyy-MM-dd"];
        NSValueTransformer *timeValueTransformer = [NSValueTransformer mtl_dateTransformerWithDateFormat:@"HH:mm:ss"];
        NSValueTransformer *anyValueInSetTransformer = [NSValueTransformer mtl_anyValueInSetTransformer];
        
        [NSValueTransformer setValueTransformer:dateTimeValueTransformer forName:MTLDateTimeValueTransformerName];
        [NSValueTransformer setValueTransformer:dateValueTransformer forName:MTLDateValueTransformerName];
        [NSValueTransformer setValueTransformer:timeValueTransformer forName:MTLTimeValueTransformerName];
        [NSValueTransformer setValueTransformer:anyValueInSetTransformer forName:MTLAnyValueInSetTransformerName];
    }
}

+ (NSValueTransformer<MTLTransformerErrorHandling> *)mtl_dateTransformerWithDateFormat:(NSString *)dateFormat;{
    return [self mtl_dateTransformerWithDateFormat:dateFormat locale:[NSLocale currentLocale]];
}

+ (NSValueTransformer<MTLTransformerErrorHandling> *)mtl_anyValueInSetTransformer;{
    return [MTLAnyValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        NSArray *allValues = nil;
        if ([value isKindOfClass:[NSDictionary class]]) {
            allValues = [value allValues];
        } else if ([value isKindOfClass:[NSSet class]]){
            allValues = [value allValues];
        }
        if ([allValues isKindOfClass:[NSArray class]]) {
            for (id itemValue in allValues) {
                if ([itemValue isKindOfClass:[NSNull class]] || ([itemValue isKindOfClass:[NSString class]] && ![itemValue length])) {
                    continue;
                }
                return itemValue;
            }
            return nil;
        }
        return value;
    }];
}

+ (NSValueTransformer<MTLTransformerErrorHandling> *)mtl_validatingTransformerForClass:(Class)modelClass {
    NSParameterAssert(modelClass != nil);
    
    return [MTLValueTransformer transformerUsingForwardBlock:^ id (id value, BOOL *success, NSError **error) {
        if (value != nil && ![value isKindOfClass:modelClass]) {
            if ([modelClass isSubclassOfClass:[NSNumber class]]) {
                return [[NSValueTransformer valueTransformerForName:MTLNumberValueTransformerName] transformedValue:value];
            }
            if ([modelClass isSubclassOfClass:[NSString class]]) {
                return [[NSValueTransformer valueTransformerForName:MTLStringValueTransformerName] transformedValue:value];
            }
            if (error != NULL) {
                NSDictionary *userInfo = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Value did not match expected type", @""),
                                           NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected %@ to be of class %@ but got %@", @""), value, modelClass, [value class]],
                                           MTLTransformerErrorHandlingInputValueErrorKey : value
                                           };
                
                *error = [NSError errorWithDomain:MTLTransformerErrorHandlingErrorDomain code:MTLTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
            }
            *success = NO;
            return nil;
        }
        return value;
    }];
}

@end

