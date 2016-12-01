//
//  MTLModel+Categories.m
//  MantleExtension
//
//  Created by Marike Jave on 16/6/11.
//  Copyright © 2016年 Marike Jave. All rights reserved.
//

#import "MTLModel+Categories.h"
#import <objc/runtime.h>
#import <Mantle/NSError+MTLModelException.h>

static BOOL _MTLValidateAndSetValue(id obj, NSString *key, id value, BOOL forceUpdate, NSError **error) {
    // Mark this as being autoreleased, because validateValue may return
    // a new object to be stored in this variable (and we don't want ARC to
    // double-free or leak the old or new values).
    __autoreleasing id validatedValue = value;
    
    @try {
        if (![obj validateValue:&validatedValue forKey:key error:error]) return NO;
        
        if (forceUpdate || value != validatedValue) {
            [obj setValue:validatedValue forKey:key];
        }
        
        return YES;
    } @catch (NSException *ex) {
        NSLog(@"*** Caught exception setting key \"%@\" : %@", key, ex);
        
        // Fail fast in Debug builds.
#if DEBUG
        @throw ex;
#else
        if (error != NULL) {
            *error = [NSError mtl_modelErrorWithException:ex];
        }
        
        return NO;
#endif
    }
}

@implementation MTLModel (ClearPropertyValue)

- (void)clear{
    NSSet *propertyKeys = [[self class] propertyKeys];
    [propertyKeys enumerateObjectsUsingBlock:^(NSString *propertyKey, BOOL *stop) {
        Class objectClass = nil;
        objc_property_t property = class_getProperty([self class], [propertyKey UTF8String]);
        const char * const attrString = property_getAttributes(property);
        const char *typeString = attrString + 1;
        const char *next = NSGetSizeAndAlignment(typeString, NULL, NULL);
        // if this is an object type, and immediately followed by a quoted string...
        if (typeString[0] == *(@encode(id)) && typeString[1] == '"') {
            // we should be able to extract a class name
            const char *className = typeString + 2;
            next = strchr(className, '"');
            
            if (!next) {
                fprintf(stderr, "ERROR: Could not read class name in attribute string \"%s\" for property %s\n", attrString, property_getName(property));
            } else if (className != next) {
                size_t classNameLength = next - className;
                char trimmedName[classNameLength + 1];
                
                strncpy(trimmedName, className, classNameLength);
                trimmedName[classNameLength] = '\0';
                
                // attempt to look up the class in the runtime
                objectClass = objc_getClass(trimmedName);
            }
        }
        NSError *error = nil;
        BOOL success = _MTLValidateAndSetValue(self, propertyKey, objectClass ? nil : @0, YES, &error);
        if (!success) NSLog([error description]);
    }];
}

@end

@implementation MTLModel (KVC_keyedValues)

- (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues;{
    for (NSString *key in keyedValues) {
        // Mark this as being autoreleased, because validateValue may return
        // a new object to be stored in this variable (and we don't want ARC to
        // double-free or leak the old or new values).
        __autoreleasing id value = [keyedValues objectForKey:key];
        if ([value isEqual:NSNull.null]) value = nil;
        NSError *error = nil;
        BOOL success = _MTLValidateAndSetValue(self, key, value, YES, &error);
        if (!success) NSLog([error description]);
    }
}

@end
