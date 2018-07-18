//
//  THNLineChartView.m
//  lineCharsViewDemo
//
//  Created by HongpingRao on 2018/7/17.
//  Copyright © 2018年 Hongping Rao. All rights reserved.
//

#import "THNLineChartView.h"
#import <Charts/Charts-Swift.h>
#import <UIKit/UIKit.h>
#import "THNXLineFormatter.h"

@interface THNLineChartView()<ChartViewDelegate>

@property (nonatomic, strong) LineChartView *lineView;
@property (nonatomic, strong) NSMutableArray *times;
@property (nonatomic, strong) UILabel *dateDesLabel;
@property (nonatomic, strong) UILabel *salesDesLabel;
@property (nonatomic, strong) LineChartDataSet *chartDataSet;

@end

@implementation THNLineChartView


- (LineChartView *)lineChartView:(NSArray *)dataArray {
    self.lineView  = [[LineChartView alloc]init];
    [self layoutChartViewStyle];
    [self layoutChartViewData:dataArray];
    [self.lineView addSubview:self.chartsDesLabel];
    return self.lineView;
}

// 设置ChartView数据
- (void)layoutChartViewData:(NSArray *)dataArray {
    NSMutableArray *entrys = [NSMutableArray array];
    double salesDataMax = 0;
    double salesDataMin = 0;
    double saleAmount = 0;
    
    for (int i = 0 ; i < dataArray.count; i++) {
        NSDictionary *dict = dataArray[i];
        
        self.isShowSalesTrend ? (saleAmount = [dict[@"sale_amount"] doubleValue]) : (saleAmount = [dict[@"order_quantity"] doubleValue]);
        
        NSString *time = [self timeConversion:dict[@"time"]];
        [self.times addObject:time];
        
        ChartDataEntry *entry = [[ChartDataEntry alloc]initWithX:i y:saleAmount];
        [entrys addObject:entry];
        
        if (saleAmount > salesDataMax) {
            salesDataMax = saleAmount;
        }
        if (saleAmount < salesDataMin) {
            salesDataMin = saleAmount;
        }
    }
    
    // 设置Y轴最大能显示的数据, 为了解决 Marker顶部遮盖的问题
    self.lineView.leftAxis.axisMaximum = (salesDataMax + (salesDataMax - salesDataMin) * 0.2);
    // 设置X轴最大和最小显示的数据，为了解决 Marker左边和右边遮盖的问题
    self.lineView.xAxis.axisMinimum = -(dataArray.count *0.04);
    self.lineView.xAxis.axisMaximum = dataArray.count - 1 + (dataArray.count *0.04);
    LineChartDataSet *chartDataSet = [[LineChartDataSet alloc]initWithValues:entrys];
    [self layoutChartDataSet:chartDataSet];
    LineChartData *data = [[LineChartData alloc]initWithDataSets:@[chartDataSet]];
    self.lineView.data = data;
}

// 设置linceChartView样式
- (void)layoutChartViewStyle {
    self.lineView.delegate = self;
    self.lineView.legend.enabled = NO;//不显示图例说明
    self.lineView.chartDescription.text = @"";
    self.lineView.doubleTapToZoomEnabled = NO;//取消双击缩放
    //数据显示是不完整，因为数据超出整个 LineChartView，就不显示了,这个时候通过设置下面属性使数据可以完全显示
    self.lineView.minOffset = 20;
    self.lineView.backgroundColor = [UIColor clearColor];
    
    // 设置X轴样式
    self.lineView.xAxis.labelCount = 100; // 设置X轴总数量
    self.lineView.xAxis.labelPosition = XAxisLabelPositionBottom;// X轴的位置
    self.lineView.xAxis.granularity = 1;// 间隔为1
    self.lineView.xAxis.drawGridLinesEnabled = NO;//不绘制网络线
    self.lineView.xAxis.labelTextColor = [UIColor blackColor];
    THNXLineFormatter *matter = [[THNXLineFormatter alloc]init];
    matter.times = self.times;
    self.lineView.xAxis.valueFormatter = matter;
    
    // 设置Y轴样式
    self.lineView.leftAxis.gridColor = [UIColor blackColor];//网格线颜色
    self.lineView.leftAxis.axisLineColor = [UIColor blackColor];//Y轴颜色
    self.lineView.leftAxis.labelTextColor = [UIColor blackColor];//Y轴文字颜色
    self.lineView.rightAxis.enabled = NO;//不绘制右边轴的信息
    
    
    // 设置点击样式
    ChartMarkerView *marker = [[ChartMarkerView alloc] init];
    marker.backgroundColor = [UIColor blackColor];
    UIImageView *markerBottomImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"spot"]];
    markerBottomImageView.frame = CGRectMake(0, 0, 15, 15);
    markerBottomImageView.center = marker.center;
    [marker addSubview:markerBottomImageView];
    //创建一个黑色的View，将这个View添加在maker上
    UIView *markView = [[UIView alloc] initWithFrame:CGRectMake(-50, -70, 100, 60)];
    UIImageView *markTopImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 60)];
    markTopImageView.image = [UIImage imageNamed:@"promptBox"];
    [markView addSubview:markTopImageView];
    [marker addSubview:markView];
    [markView addSubview:self.dateDesLabel];
    [markView addSubview:self.salesDesLabel];
    self.lineView.marker = marker;
}

// 设置折线样式
- (void)layoutChartDataSet:(LineChartDataSet *)chartDataSet{
    chartDataSet.axisDependency = AxisDependencyLeft;
    chartDataSet.lineWidth = 1.0f;//折线宽度
    chartDataSet.drawValuesEnabled = NO;//是否在拐点处显示数据
    chartDataSet.drawCirclesEnabled = NO;//是否绘制拐点
    chartDataSet.circleRadius = 7.0f;//拐点半径
    chartDataSet.drawCircleHoleEnabled = YES;//是否绘制中间的空心
    chartDataSet.circleColors = @[[UIColor blueColor]];//拐点颜色
    chartDataSet.circleHoleRadius = 5.5f;//空心的半径
    chartDataSet.circleHoleColor = [UIColor whiteColor];//空心的颜色
    chartDataSet.highlightEnabled = YES;//选中拐点,是否开启高亮效果(显示十字线)
    chartDataSet.highlightColor = [UIColor redColor];
    chartDataSet.highlightLineWidth = 1.0/[UIScreen mainScreen].scale;//十字线宽度
    chartDataSet.highlightLineDashLengths = @[@5, @5];
    chartDataSet.valueFont = [UIFont systemFontOfSize:12];
    chartDataSet.mode = LineChartModeCubicBezier;// 模式为曲线模式
    chartDataSet.cubicIntensity = 0.2;// 曲线弧度
    chartDataSet.drawValuesEnabled = NO;//线上面不显示文字
    chartDataSet.drawFilledEnabled = YES;//是否填充颜色
    NSArray *gradientColors = @[
                                (id)[ChartColorTemplates colorFromString:@"#4CE49E"].CGColor,
                                (id)[ChartColorTemplates colorFromString:@"#38D6B8"].CGColor
                                ];
    CGGradientRef gradient = CGGradientCreateWithColors(nil, (CFArrayRef)gradientColors, nil);
    chartDataSet.fillAlpha = 0.50f;//透明度
    chartDataSet.fill = [ChartFill fillWithLinearGradient:gradient angle:90.0f];//赋值填充颜色对象
    CGGradientRelease(gradient);//释放gradientRef
    [chartDataSet setColor:[UIColor orangeColor]];//折线颜色
}

// 时间戳转换
- (NSString *)timeConversion:(NSString *)timeStampString {
    NSTimeInterval interval = [timeStampString doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM"];
    NSString *dateString = [formatter stringFromDate: date];
    return dateString;
}

- (NSMutableArray *)times {
    if (!_times) {
        _times = [NSMutableArray array];
    }
    return _times;
}

- (UILabel *)dateDesLabel {
    if (!_dateDesLabel) {
        _dateDesLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 30, 100, 20)];
        _dateDesLabel.font = [UIFont systemFontOfSize:11];
        _dateDesLabel.textColor = [UIColor purpleColor];
    }
    return _dateDesLabel;
}

- (UILabel *)salesDesLabel {
    if (!_salesDesLabel) {
        _salesDesLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 8, 100, 20)];
        _salesDesLabel.font = [UIFont systemFontOfSize:11];
        _salesDesLabel.textColor = [UIColor purpleColor];
    }
    return _salesDesLabel;
}

// 设置Y轴描述
- (UILabel *)chartsDesLabel {
    if (!_chartsDesLabel) {
        _chartsDesLabel = [[UILabel alloc]init];
        _chartsDesLabel.text = @"单位/元";
        _chartsDesLabel.font = [UIFont systemFontOfSize:14];
        _chartsDesLabel.textColor = [UIColor blackColor];
        _chartsDesLabel.frame = CGRectMake(20, -10, 100, 40);
    }
    return _chartsDesLabel;
}

#pragma mark - ChartViewDelegate的实现
- (void)chartValueSelected:(ChartViewBase *)chartView entry:(ChartDataEntry *)entry highlight:(ChartHighlight *)highlight {
    NSInteger dateIndex = entry.x;
    NSInteger salesIndex = entry.y;
    
    if (self.isShowSalesTrend) {
        self.salesDesLabel.text = [NSString stringWithFormat:@"销售额: ¥%ld",salesIndex];
    } else {
        self.salesDesLabel.text = [NSString stringWithFormat:@"订单数: %ld个",salesIndex];
    }
    
    self.dateDesLabel.text = [NSString stringWithFormat:@"时间:%@",self.times[dateIndex]];
}

@end
