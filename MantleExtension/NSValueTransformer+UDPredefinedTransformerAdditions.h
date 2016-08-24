//
//  NSValueTransformer+UDTPredefinedTransformerAdditions.h
//  UDrivingCustomer
//
//  Created by Marke Jave on 16/6/13.
//  Copyright © 2016年 Marike Jave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

extern NSString * const UDDateTimeValueTransformerName; // yyyy-MM-dd HH:mm:ss

extern NSString * const UDDateValueTransformerName; // yyyy-MM-dd

extern NSString * const UDTimeValueTransformerName; // HH:mm:ss

extern NSString * const UDAnyValueInSetTransformerName; // array set dictionay nsindex

@interface NSValueTransformer (UDPredefinedTransformerAdditions)

+ (NSValueTransformer<MTLTransformerErrorHandling> *)mtl_dateTransformerWithDateFormat:(NSString *)dateFormat;

+ (NSValueTransformer<MTLTransformerErrorHandling> *)mtl_anyValueInSetTransformer;

@end
