//
//  MTLJSONAdapter+Categories.m
//  MantleExtension
//
//  Created by 徐林峰 on 16/5/31.
//  Copyright © 2016年 Marike Jave. All rights reserved.
//
#import "MTLJSONAdapter+Categories.h"

NSString * const MTLNumberValueTransformerName = @"MTLNumberValueTransformerName";

NSString * const MTLStringValueTransformerName = @"MTLStringValueTransformerName";

@implementation NSValueTransformer (MTLTransformerAdditions)

#pragma mark Category Loading

+ (void)load {
    @autoreleasepool {
        MTLValueTransformer *stringValueTransformer = [MTLValueTransformer transformerUsingReversibleBlock:^ id (id value, BOOL *success, NSError **error) {
            if (value == nil) return nil;
            return [NSString stringWithFormat:@"%@", value];
        }];
        [NSValueTransformer setValueTransformer:stringValueTransformer forName:MTLStringValueTransformerName];
        
        MTLValueTransformer *numberValueTransformer = [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
            if (value == nil) return nil;
            if ([value isKindOfClass:[NSNumber class]]) return value;
            if ([value isKindOfClass:[NSString class]]) {
                NSString *stringValue = value;
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                value = [numberFormatter numberFromString:stringValue];
                if (!value) {
                    if (error != NULL) {
                        NSDictionary *userInfo = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert object to number", @""),
                                                   NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an string, got: %@.", @""), value],
                                                   MTLTransformerErrorHandlingInputValueErrorKey : value
                                                   };
                        
                        *error = [NSError errorWithDomain:MTLTransformerErrorHandlingErrorDomain code:MTLTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
                    }
                    *success = NO;
                    return nil;
                }
                return value;
            }
            else {
                if (error != NULL) {
                    NSDictionary *userInfo = @{
                                               NSLocalizedDescriptionKey: NSLocalizedString(@"Could not convert object to number", @""),
                                               NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:NSLocalizedString(@"Expected an string or number, got: %@.", @""), value],
                                               MTLTransformerErrorHandlingInputValueErrorKey : value
                                               };
                    
                    *error = [NSError errorWithDomain:MTLTransformerErrorHandlingErrorDomain code:MTLTransformerErrorHandlingErrorInvalidInput userInfo:userInfo];
                }
                *success = NO;
                return nil;
            }
        }];
        [NSValueTransformer setValueTransformer:numberValueTransformer forName:MTLNumberValueTransformerName];
    }
}

@end

@implementation MTLJSONAdapter (Categories)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

+ (NSValueTransformer *)transformerForModelPropertiesOfObjCType:(const char *)objCType {
    NSParameterAssert(objCType != NULL);
    if (strcmp(objCType, @encode(BOOL)) == 0) {
        return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
    }
//    char *typeValue = @encode(NSString);
    if (strcmp(objCType, "@\"NSString\"") == 0) {
        return [NSValueTransformer valueTransformerForName:MTLStringValueTransformerName];
    }
    if (strcmp(objCType, @encode(unsigned char)) == 0 || strcmp(objCType, @encode(char)) == 0 ||
        strcmp(objCType, @encode(unsigned short)) == 0 || strcmp(objCType, @encode(short)) == 0 ||
        strcmp(objCType, @encode(unsigned int)) == 0 || strcmp(objCType, @encode(int)) == 0 ||
        strcmp(objCType, @encode(unsigned long)) == 0 || strcmp(objCType, @encode(long)) == 0 ||
        strcmp(objCType, @encode(long long)) == 0 || strcmp(objCType, @encode(unsigned long long)) == 0 ||
        strcmp(objCType, @encode(float)) == 0 || strcmp(objCType, @encode(double)) == 0) {
        return [NSValueTransformer valueTransformerForName:MTLNumberValueTransformerName];
    }
    return nil;
}
#pragma clang diagnostic pop

@end
