//
//  THNStatisticsChartView.m
//  mixcash
//
//  Created by HongpingRao on 2018/6/11.
//  Copyright © 2018年 taihuoniao. All rights reserved.
//

#import "THNStatisticsChartView.h"
#import <Masonry/Masonry.h>
#import <MJExtension/MJExtension.h>
#import "THNLineChartView.h"

@interface THNStatisticsChartView ()

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) LineChartView *lineView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) THNLineChartView * lineChart;

@end

@implementation THNStatisticsChartView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.lineChart = [[THNLineChartView alloc]init];
        self.lineChart.isShowSalesTrend = YES;
        [self loadSalesTrendData];
        self.layer.cornerRadius = 5;
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.segmentedControl];
        [self addSubview:self.lineView];
        [self layoutChartViewPosition];
    }
    return self;
}

- (void)layoutChartViewPosition {
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).with.offset(-30);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.top.equalTo(self.mas_top).with.offset(70);
    }];

    [self.segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(15);
        make.top.equalTo(self.mas_top).with.offset(15);
    }];

}

- (void)changeData:(UISegmentedControl *)sender {
    sender.selected = !sender.selected;
    // 清除LineView(Marker)
    [self.lineView clear];
    
    if (sender.selected) {
        self.lineChart.chartsDesLabel.text = @"单位/个";
        [self loadOrderTrendData];
    } else {
        self.lineChart.chartsDesLabel.text = @"单位/元";
        [self loadSalesTrendData];
    }
    [self.lineChart layoutChartViewData:self.dataArray];
}

//加载销售趋势图的数据
- (void)loadSalesTrendData {
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"charts" ofType:@"json"]];
    NSDictionary *result = [data mj_JSONObject];
    self.dataArray = result[@"data"][@"sale_amount_data"];
    self.lineChart.isShowSalesTrend = YES;
    
}

//加载订单趋势图的数据
- (void)loadOrderTrendData {
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"statisOrder" ofType:@"json"]];
    NSDictionary *result = [data mj_JSONObject];
    self.dataArray = result[@"data"][@"order_quantity_data"];
    self.lineChart.isShowSalesTrend = NO;
}

#pragma mark - lazy
- (UISegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        NSArray *segArray = @[@"销售额",@"订单数"];
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:segArray];
        _segmentedControl.backgroundColor = [UIColor whiteColor];  //
        _segmentedControl.layer.masksToBounds = YES;               //    默认为no，不设置则下面一句无效
        _segmentedControl.layer.cornerRadius = 12.5;               //    设置圆角大小，同UIView
        _segmentedControl.layer.borderWidth = 1;                   //    边框宽度，重新画边框，若不重新画，可能会出现圆角处无边框的情况
        _segmentedControl.selectedSegmentIndex = 0;
        _segmentedControl.tintColor = [UIColor blueColor];
        _segmentedControl.layer.borderColor = [UIColor blueColor].CGColor; //     边框颜色
        [_segmentedControl addTarget:self action:@selector(changeData:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
}

- (LineChartView *)lineView {
    if (!_lineView) {
        LineChartView *lineView = [self.lineChart lineChartView:self.dataArray];
        _lineView = lineView;
    }
    return _lineView;
}

@end
