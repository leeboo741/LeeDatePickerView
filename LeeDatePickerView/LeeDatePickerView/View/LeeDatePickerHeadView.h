//
//  LeeDatePickerHeadView.h
//  LeeDatePickerView
//
//  Created by mac on 2018/9/14.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LeeDatePickerHeadView;
@protocol LeeDatePickerHeadViewDelegate<NSObject>
-(void)leeDatePickerHeadViewSelectedStartTimeView:(LeeDatePickerHeadView *)headView;
-(void)leeDatePickerHeadViewSelectedEndTimeView:(LeeDatePickerHeadView *)headView;
@end

@interface LeeDatePickerHeadView : UIView

@property (nonatomic, copy) NSString * startDateStr;
@property (nonatomic, copy) NSString * endDateStr;

@property (nonatomic, weak) id<LeeDatePickerHeadViewDelegate>delegate;

@end
