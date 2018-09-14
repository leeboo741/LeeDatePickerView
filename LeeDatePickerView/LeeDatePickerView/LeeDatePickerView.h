//
//  LeeDatePickerView.h
//  LeeDatePickerView
//
//  Created by mac on 2018/9/13.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeeDatePickerView : UIView
@property (nonatomic, copy) void(^selectTimeBlock)(NSDate * startDate, NSDate * endDate);
@end
