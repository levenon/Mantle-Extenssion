//
//  NSValueTransformer+MTLCustomPredefinedTransformerAdditions.h
//  MantleExtension
//
//  Created by Marke Jave on 16/6/13.
//  Copyright © 2016年 Marike Jave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

extern NSString * const MTLDateTimeValueTransformerName; // yyyy-MM-dd HH:mm:ss

extern NSString * const MTLDateValueTransformerName; // yyyy-MM-dd

extern NSString * const MTLTimeValueTransformerName; // HH:mm:ss

extern NSString * const MTLAnyValueInSetTransformerName; // array set dictionay nsindex

@interface NSValueTransformer (MTLCustomPredefinedTransformerAdditions)

+ (NSValueTransformer<MTLTransformerErrorHandling> *)mtl_dateTransformerWithDateFormat:(NSString *)dateFormat;

+ (NSValueTransformer<MTLTransformerErrorHandling> *)mtl_anyValueInSetTransformer;

@end
