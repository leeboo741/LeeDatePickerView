//
//  LeeDatePickerView.h
//  LeeDatePickerView
//
//  Created by mac on 2018/9/13.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectTimeBlock)(NSDate * startDate, NSDate * endDate);

@interface LeeDatePickerView : UIView
@property (nonatomic, copy) SelectTimeBlock selectTimeBlock;
+(void)showLeeDatePickerViewWithBlock:(SelectTimeBlock)block;
@end
