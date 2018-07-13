//
//  THNXLineFormatter.m
//  mixcash
//
//  Created by RHP on 2018/6/8.
//  Copyright © 2018年 taihuoniao. All rights reserved.
//

#import "THNXLineFormatter.h"

@implementation THNXLineFormatter

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis{
    return [self.times objectAtIndex:value];
}

@end
