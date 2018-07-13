//
//  UIColor+Extension.h
//  mixcash
//
//  Created by FLYang on 2018/5/21.
//  Copyright © 2018年 taihuoniao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Extension)

/**
 转换 HEX 格式的颜色值

 @param color 颜色值(#000000)
 @return 颜色
 */
+ (UIColor *)colorWithHexString:(NSString *)color;

/**
 转换 HEX 格式的颜色值，设置透明度

 @param color 颜色值(#000000)
 @param alpha 透明度
 @return 颜色
 */
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

@end
