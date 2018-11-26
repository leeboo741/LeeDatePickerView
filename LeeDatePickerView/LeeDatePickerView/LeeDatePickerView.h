//
//  LeeDatePickerView.h
//  LeeDatePickerView
//
//  Created by mac on 2018/9/13.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

// 回调Block
typedef void(^LeeDatePickerViewSelectTimeBlock)(NSArray<NSDate *> * dateArray);

// 回调block中的时间下标
typedef enum : NSUInteger {
    LeeDatePickerViewSelectTimeArrayIndex_Start = 0,
    LeeDatePickerViewSelectTimeArrayIndex_End = 1,
    LeeDatePickerViewSelectTimeArrayIndex_Single = 0,
} LeeDatePickerViewSelectTimeArrayIndex; // 时间下标

// 显示样式
typedef enum : NSUInteger {
    LeeDatePickerViewStyle_StartAndEnd = 0, // 获取开始时间和结束时间
    LeeDatePickerViewStyle_Single = 1, // 获取单个时间
} LeeDatePickerViewStyle; // 样式

// 时间格式样式 @"yyyy-MM-dd HH:mm:ss"
typedef enum : NSUInteger {
    LeeDatePickerViewDateFormatterStyle_yMd = 0, // 年-月-日
    LeeDatePickerViewDateFormatterStyle_yMdHms = 1, // 年-月-日 时:分:秒
    LeeDatePickerViewDateFormatterStyle_yMdHm = 2, // 年-月-日 时:分
    LeeDatePickerViewDateFormatterStyle_Default = 0, // 默认
} LeeDatePickerViewDateFormatterStyle; // 时间格式样式

@interface LeeDatePickerView : UIView

// Init
/**
 调用方法

 @param style 展示样式，时间区间还是单个时间
 @param formatterStyle 时间格式样式
 @param block 数据回调
 */
+(void)showLeeDatePickerViewWithStyle:(LeeDatePickerViewStyle)style
                       formatterStyle:(LeeDatePickerViewDateFormatterStyle)formatterStyle
                                block:(LeeDatePickerViewSelectTimeBlock)block;

@end
