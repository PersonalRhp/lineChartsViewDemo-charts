//
//  ViewController.m
//  lineCharsViewDemo
//
//  Created by HongpingRao on 2018/7/11.
//  Copyright © 2018年 Hongping Rao. All rights reserved.
//

#import "ViewController.h"
#import "THNStatisticsChartView.h"
#import <Charts/Charts-Swift.h>
#import "THNStatisticsChartView.h"

@interface ViewController ()

@property (nonatomic, strong) THNStatisticsChartView *chartView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.chartView.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:self.chartView];

    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (THNStatisticsChartView *)chartView {
    if (!_chartView) {
        _chartView = [[THNStatisticsChartView alloc]init];
    }
    return _chartView;
}

@end
