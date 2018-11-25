//
//  LeeDatePickerHeadViewDelegate.h
//  LeeDatePickerView
//
//  Created by mac on 2018/11/23.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeeDatePickerHeadViewProtocol.h"

typedef enum : NSUInteger {
    LeeDatePickerHeadViewSelectIndex_Start = 0, // 开始时间
    LeeDatePickerHeadViewSelectIndex_End = 1, // 结束时间
} LeeDatePickerHeadViewSelectIndex;

@protocol LeeDatePickerHeadViewDelegate <NSObject>

@optional
-(void)leeDatePickerHeadView:(UIView *)headView select:(LeeDatePickerHeadViewSelectIndex)index;

@end
