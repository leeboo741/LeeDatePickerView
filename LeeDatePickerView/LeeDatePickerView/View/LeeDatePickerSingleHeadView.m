//
//  LeeDatePickerSingleHeadView.m
//  LeeDatePickerView
//
//  Created by mac on 2018/11/23.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "LeeDatePickerSingleHeadView.h"

@interface LeeDatePickerSingleHeadView()
@property (nonatomic, strong) UILabel * timeTitleLabel;
@property (nonatomic, strong) UILabel * timeValueLabel;
@property (nonatomic, strong) UIView * lineView;
@end

@implementation LeeDatePickerSingleHeadView

@synthesize startTimeStr = _startTimeStr;
@synthesize endTimeStr = _endTimeStr;
@synthesize delegate = _delegate;

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        [self setFrame:frame];
    }
    return self;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    
    [self.timeTitleLabel setFrame:CGRectMake(20, 5, (self.bounds.size.width-40) / 2, self.bounds.size.height - 10)];
    [self.timeValueLabel setFrame:CGRectMake(self.bounds.size.width / 2, 5, (self.bounds.size.width-40) / 2, self.bounds.size.height - 10)];
    [self.lineView setFrame:CGRectMake(0, self.bounds.size.height - 5, self.bounds.size.width, 5)];
}
-(void)initView{
    self.timeTitleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    self.timeTitleLabel.text = @"选择时间";
    self.timeTitleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    self.timeTitleLabel.textColor = [UIColor colorWithRed:146/255.0f green:146/255.0f blue:146/255.0f alpha:1];
    self.timeTitleLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.timeTitleLabel];
    self.timeValueLabel = [[UILabel alloc] init];
    self.timeValueLabel.font = [UIFont systemFontOfSize:15.0f];
    self.timeValueLabel.textColor = [UIColor colorWithRed:70/255.0f green:70/255.0f blue:70/255.0f alpha:1];
    self.timeValueLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.timeValueLabel];
    self.lineView = [[UIView alloc]init];
    self.lineView.backgroundColor = [UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1];
    [self addSubview:self.lineView];
    
}
-(void)setStartTimeStr:(NSString *)startTimeStr{
    _startTimeStr = startTimeStr;
    self.timeValueLabel.text = startTimeStr;
}

@end
