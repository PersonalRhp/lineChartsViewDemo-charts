//
//  THNXLineFormatter.h
//  mixcash
//
//  Created by RHP on 2018/6/8.
//  Copyright © 2018年 taihuoniao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Charts/Charts-Swift.h>

@interface THNXLineFormatter : NSObject <IChartAxisValueFormatter>

/// X轴数据的数组
@property (nonatomic, strong) NSMutableArray *times;

@end
