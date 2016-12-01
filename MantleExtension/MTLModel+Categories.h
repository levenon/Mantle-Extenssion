//
//  MTLModel+Categories.h
//  MantleExtension
//
//  Created by Marike Jave on 16/6/11.
//  Copyright © 2016年 Marike Jave. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface MTLModel (ClearPropertyValue)

- (void)clear;

@end

@interface MTLModel (KVC_keyedValues)

- (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues;

@end
