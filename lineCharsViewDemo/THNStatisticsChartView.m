//
//  THNStatisticsChartView.m
//  mixcash
//
//  Created by HongpingRao on 2018/6/11.
//  Copyright © 2018年 taihuoniao. All rights reserved.
//

#import "THNStatisticsChartView.h"
#import <Charts/Charts-Swift.h>
#import "THNXLineFormatter.h"
#import <Masonry/Masonry.h>
#import "UIColor+Extension.h"
#import <MJExtension/MJExtension.h>

static NSString *const kUrlSaleAmountTrend = @"/stats/sale_amount_trend";

@interface THNStatisticsChartView ()<ChartViewDelegate>

@property (nonatomic, strong) LineChartView *lineView;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) NSMutableArray *times;
@property (nonatomic, strong) UILabel *chartsDesLabel;
@property (nonatomic, strong) UIButton *dateListButton;
@property (nonatomic, strong) UILabel *dateDesLabel;
@property (nonatomic, strong) UILabel *salesDesLabel;
@property (nonatomic, assign) BOOL isShowSalesTrend;

@end

@implementation THNStatisticsChartView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadSalesTrendData];
        self.layer.cornerRadius = 5;
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.segmentedControl];
        [self addSubview:self.chartsDesLabel];
        [self addSubview:self.lineView];
    //  [self addSubview:self.dateListButton];
        [self layoutChartViewPosition];
        [self layoutChartView];
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

    [self.chartsDesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.segmentedControl);
        make.top.equalTo(self.segmentedControl.mas_bottom).with.offset(15);
    }];

//    [self.dateListButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.mas_right).with.offset(-26);
//        make.top.equalTo(self.mas_top).with.offset(15);
//        make.height.equalTo(@25);
//    }];
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

//加载销售趋势图的数据
- (void)loadSalesTrendData {
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    params[@"start_time"] = @"2018-05-19";
    params[@"end_time"] = @"2018-05-27";
//    THNRequest *request = [THNAPI  postWithUrlString:kUrlSaleAmountTrend requestDictionary:params signVerify:YES delegate:self];
//    [request startRequestSuccess:^(THNRequest *request, id result) {
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"charts" ofType:@"json"]];
    NSDictionary *result = [data mj_JSONObject];
        NSArray *array = result[@"data"][@"sale_amount_data"];
        NSMutableArray *entrys = [NSMutableArray array];
        double salesDataMax = 0;
        double salesDataMin = 0;
        for (int i = 0 ; i < array.count; i++) {
            NSDictionary *dict = array[i];
            double saleAmount = [dict[@"sale_amount"] doubleValue];
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
        self.lineView.xAxis.axisMinimum = -(array.count *0.04);
        self.lineView.xAxis.axisMaximum = array.count - 1 + (array.count *0.04);
    
        LineChartDataSet *chartDataSet = [[LineChartDataSet alloc]initWithValues:entrys];
        [self layoutChartDataSet:chartDataSet];
        self.isShowSalesTrend = YES;
//    } failure:^(THNRequest *request, NSError *error) {
//
//    }];
  
}

- (void)changeData:(UISegmentedControl *)sender {
    sender.selected = !sender.selected;
    // 清除LineView(Marker)
    [self.lineView clear];
    
    if (sender.selected) {
        self.chartsDesLabel.text = @"单位/个";
        [self loadOrderTrendData];
    } else {
         self.chartsDesLabel.text = @"单位/元";
        [self loadSalesTrendData];
    }
    
}

//加载订单趋势图的数据
- (void)loadOrderTrendData {
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"statisOrder" ofType:@"json"]];
    NSDictionary *result = [data mj_JSONObject];
    NSArray *array = result[@"data"][@"order_quantity_data"];
    NSMutableArray *entrys = [NSMutableArray array];
    double orderDataMax = 0;
    double orderDataMin = 0;
    for (int i = 0 ; i < array.count; i++) {
        NSDictionary *dict = array[i];
        double orderQuantity = [dict[@"order_quantity"] doubleValue];
        NSString *time = [self timeConversion:dict[@"time"]];
        [self.times addObject:time];
        ChartDataEntry *entry = [[ChartDataEntry alloc]initWithX:i y:orderQuantity];
        [entrys addObject:entry];
        
        if (orderQuantity > orderDataMax) {
            orderDataMax = orderQuantity;
        }
        if (orderQuantity < orderDataMin) {
            orderDataMin = orderQuantity;
        }
        
    }
    // 设置Y轴最大能显示的数据, 为了解决 Marker顶部遮盖的问题
    self.lineView.leftAxis.axisMaximum = (orderDataMax + (orderDataMax - orderDataMin) * 0.2);
    // 设置X轴最大和最小显示的数据，为了解决 Marker左边和右边遮盖的问题
    self.lineView.xAxis.axisMaximum = array.count - 1 + (array.count *0.04);
    self.lineView.xAxis.axisMinimum =  -(array.count *0.04);
    
    LineChartDataSet *chartDataSet = [[LineChartDataSet alloc]initWithValues:entrys];
    [self layoutChartDataSet:chartDataSet];
    self.isShowSalesTrend = NO;
}

// 设置折线样式
- (void)layoutChartDataSet:(LineChartDataSet *)chartDataSet {
    chartDataSet.axisDependency = AxisDependencyLeft;
    chartDataSet.lineWidth = 1.0f;//折线宽度
    chartDataSet.drawValuesEnabled = NO;//是否在拐点处显示数据
    chartDataSet.drawCirclesEnabled = NO;//是否绘制拐点
    chartDataSet.circleRadius = 7.0f;//拐点半径
    chartDataSet.drawCircleHoleEnabled = YES;//是否绘制中间的空心
    chartDataSet.circleColors = @[[UIColor colorWithHexString:@"02A65A"]];//拐点颜色
    chartDataSet.circleHoleRadius = 5.5f;//空心的半径
    chartDataSet.circleHoleColor = [UIColor whiteColor];//空心的颜色
    chartDataSet.highlightEnabled = YES;//选中拐点,是否开启高亮效果(显示十字线)
    chartDataSet.highlightColor = [UIColor colorWithHexString:@"4CE49E"];
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
    [chartDataSet setColor:[UIColor colorWithHexString:@"02A65A"]];//折线颜色
    LineChartData *data = [[LineChartData alloc]initWithDataSets:@[chartDataSet]];
    self.lineView.data = data;
    self.lineView.backgroundColor = [UIColor clearColor];
}

- (void)layoutChartView {
    self.lineView.legend.enabled = NO;//不显示图例说明
    self.lineView.chartDescription.text = @"";
    self.lineView.doubleTapToZoomEnabled = NO;//取消双击缩放
    
    // 设置X轴样式
    self.lineView.xAxis.labelCount = 100; // 设置X轴总数量
    self.lineView.xAxis.labelPosition = XAxisLabelPositionBottom;// X轴的位置
    self.lineView.xAxis.granularity = 1;// 间隔为1
    self.lineView.xAxis.drawGridLinesEnabled = NO;//不绘制网络线
    //数据显示是不完整，因为数据超出整个 LineChartView，就不显示了,这个时候通过设置下面属性使数据可以完全显示
    self.lineView.minOffset = 20;
    self.lineView.xAxis.labelTextColor = [UIColor colorWithHexString:@"6C6C6C"];
    
    // 设置Y轴样式
    self.lineView.leftAxis.gridColor = [UIColor colorWithHexString:@"EBEBEC"];//网格线颜色
    self.lineView.leftAxis.axisLineColor = [UIColor colorWithHexString:@"E5E5E5"];//Y轴颜色
    self.lineView.leftAxis.labelTextColor = [UIColor colorWithHexString:@"6C6C6C"];//Y轴文字颜色
    self.lineView.rightAxis.enabled = NO;//不绘制右边轴的信息
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
    
    THNXLineFormatter *matter = [[THNXLineFormatter alloc]init];
    matter.times = self.times;
    self.lineView.xAxis.valueFormatter = matter;
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
        _segmentedControl.tintColor = [UIColor colorWithHexString:@"28AA5A"];
        _segmentedControl.layer.borderColor = [UIColor colorWithHexString:@"28AA5A"].CGColor; //     边框颜色
        [_segmentedControl addTarget:self action:@selector(changeData:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
}

- (UIButton *)dateListButton {
    if (!_dateListButton) {
        _dateListButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dateListButton setImage:[UIImage imageNamed:@"order_info_down"] forState:UIControlStateNormal];
        [_dateListButton setTitle:@"2015.09 - 2018.09" forState:UIControlStateNormal];
        [_dateListButton setTintColor:[UIColor colorWithHexString:@"666666"]];
        _dateListButton.backgroundColor = [UIColor colorWithHexString:@"FAFAFA"];
        _dateListButton.imageEdgeInsets = UIEdgeInsetsMake(0, 120, 0, 0);
        //设置边框宽度
        _dateListButton.layer.borderWidth = 1.0f;
        //给按钮设置角的弧度
        _dateListButton.layer.cornerRadius = 12.5f;
        _dateListButton.layer.borderColor = [[UIColor colorWithHexString:@"D2D2D2"]CGColor];
        _dateListButton.layer.masksToBounds = YES;
        
    }
    return _dateListButton;
}

- (UILabel *)chartsDesLabel {
    if (!_chartsDesLabel) {
        _chartsDesLabel = [[UILabel alloc]init];
        _chartsDesLabel.text = @"单位/元";
        _chartsDesLabel.font = [UIFont systemFontOfSize:14];
        _chartsDesLabel.textColor = [UIColor colorWithHexString:@"666666"];
    }
    return _chartsDesLabel;
}

- (NSMutableArray *)times {
    if (!_times) {
        _times = [NSMutableArray array];
    }
    return _times;
}

- (LineChartView *)lineView {
    if (!_lineView) {
        _lineView = [[LineChartView alloc]init];
        _lineView.delegate = self;
    }
    return _lineView;
}

- (UILabel *)dateDesLabel {
    if (!_dateDesLabel) {
        _dateDesLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 30, 100, 20)];
        _dateDesLabel.font = [UIFont systemFontOfSize:11];
        _dateDesLabel.textColor = [UIColor colorWithHexString:@"D8D8D8"];
    }
    return _dateDesLabel;
}
- (UILabel *)salesDesLabel {
    if (!_salesDesLabel) {
        _salesDesLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 8, 100, 20)];
        _salesDesLabel.font = [UIFont systemFontOfSize:11];
        _salesDesLabel.textColor = [UIColor colorWithHexString:@"D8D8D8"];
    }
    return _salesDesLabel;
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
