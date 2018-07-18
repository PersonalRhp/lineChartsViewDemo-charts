//
//  THNLineChartView.h
//  lineCharsViewDemo
//
//  Created by HongpingRao on 2018/7/17.
//  Copyright © 2018年 Hongping Rao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Charts/Charts-Swift.h>
#import <UIKit/UIKit.h>

@interface THNLineChartView : NSObject

@property (nonatomic, assign) BOOL isShowSalesTrend;
@property (nonatomic, strong) UILabel *chartsDesLabel;
- (LineChartView *)lineChartView:(NSArray *)dataArray;
- (void)layoutChartViewData:(NSArray *)dataArray;

@end
