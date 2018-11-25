//
//  LeeDatePickerHeadView.m
//  LeeDatePickerView
//
//  Created by mac on 2018/9/14.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "LeeDatePickerHeadView.h"

@interface LeeDatePickerHeadView()
@property (nonatomic, strong) UIView * LineView; // 内容头部区选中线

@property (nonatomic, strong) UIView * startTimeView; // 开始时间显示区
@property (nonatomic, strong) UILabel * startTimeTitleLabel; // 开始时间显示 title
@property (nonatomic, strong) UILabel * startTimeLabel; // 开始时间显示

@property (nonatomic, strong) UIView * endTimeView; // 结束时间显示区
@property (nonatomic, strong) UILabel * endTimeTitleLabel; // 结束时间显示 title
@property (nonatomic, strong) UILabel * endTimeLabel; // 结束时间显示
@end

@implementation LeeDatePickerHeadView

@synthesize startTimeStr = _startTimeStr;
@synthesize endTimeStr = _endTimeStr;
@synthesize delegate = _delegate;

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self.startTimeView setFrame:CGRectMake(0, 5, self.bounds.size.width / 2, self.bounds.size.height)];
    [self.startTimeTitleLabel setFrame:CGRectMake(0, 0, self.bounds.size.width / 2, 15)];
    [self.startTimeLabel setFrame:CGRectMake(0, 20, self.bounds.size.width / 2, 15)];
    
    [self.endTimeView setFrame:CGRectMake(self.bounds.size.width / 2, 5, self.bounds.size.width / 2, self.bounds.size.height)];
    [self.endTimeTitleLabel setFrame:CGRectMake(0, 0, self.bounds.size.width / 2, 15)];
    [self.endTimeLabel setFrame:CGRectMake(0, 20, self.bounds.size.width / 2, 15)];
    
    [self.LineView setFrame:CGRectMake(self.bounds.size.width/4-self.bounds.size.width/8, 40, self.bounds.size.width/4, 5)];
}
-(void)initView{
    /*----开始时间---*/
    self.startTimeView = [[UIView alloc]init];
    [self addSubview:self.startTimeView];
    
    self.startTimeTitleLabel = [[UILabel alloc]init];
    self.startTimeTitleLabel.text = @"开始时间";
    self.startTimeTitleLabel.font = [UIFont systemFontOfSize:12.0f];
    self.startTimeTitleLabel.textColor = [UIColor colorWithRed:146/255.0f green:146/255.0f blue:146/255.0f alpha:1];
    self.startTimeTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.startTimeView addSubview:self.startTimeTitleLabel];
    
    self.startTimeLabel = [[UILabel alloc] init];
    self.startTimeLabel.font = [UIFont systemFontOfSize:15.0f];
    self.startTimeLabel.textColor = [UIColor colorWithRed:70/255.0f green:70/255.0f blue:70/255.0f alpha:1];
    self.startTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.startTimeView addSubview:self.startTimeLabel];
    
    UITapGestureRecognizer * startTimeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startTimeTapAction)];
    [self.startTimeView addGestureRecognizer:startTimeTap];
    
    /*---结束时间---*/
    self.endTimeView = [[UIView alloc]init];
    [self addSubview:self.endTimeView];
    
    self.endTimeTitleLabel = [[UILabel alloc]init];
    self.endTimeTitleLabel.text = @"结束时间";
    self.endTimeTitleLabel.font = [UIFont systemFontOfSize:12.0f];
    self.endTimeTitleLabel.textColor = [UIColor colorWithRed:146/255.0f green:146/255.0f blue:146/255.0f alpha:1];
    self.endTimeTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.endTimeView addSubview:self.endTimeTitleLabel];
    
    self.endTimeLabel = [[UILabel alloc] init];
    self.endTimeLabel.font = [UIFont systemFontOfSize:15.0f];
    self.endTimeLabel.textColor = [UIColor colorWithRed:70/255.0f green:70/255.0f blue:70/255.0f alpha:1];
    self.endTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.endTimeView addSubview:self.endTimeLabel];
    
    UITapGestureRecognizer * endTimeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endTimeTapAction)];
    [self.endTimeView addGestureRecognizer:endTimeTap];
    
    /*---选中线---*/
    self.LineView = [[UIView alloc]init];
    self.LineView.backgroundColor = [UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1];
    [self addSubview:self.LineView];
}
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
-(void)startTimeTapAction{
    [UIView animateWithDuration:0.3 animations:^{
        self.LineView.frame=CGRectMake(self.bounds.size.width/4-self.bounds.size.width/8, 40, self.bounds.size.width/4, 5);
    }];
    if (self.delegate && [self.delegate respondsToSelector:@selector(leeDatePickerHeadView:select:)]) {
        [self.delegate leeDatePickerHeadView:self select:LeeDatePickerHeadViewSelectIndex_Start];
    }
}
-(void)endTimeTapAction{
    [UIView animateWithDuration:0.3 animations:^{
        self.LineView.frame=CGRectMake(self.bounds.size.width/2+self.bounds.size.width/8, 40, self.bounds.size.width/4, 5);
    }];
    if (self.delegate && [self.delegate respondsToSelector:@selector(leeDatePickerHeadView:select:)]) {
        [self.delegate leeDatePickerHeadView:self select:LeeDatePickerHeadViewSelectIndex_End];
    }
}
-(void)setStartTimeStr:(NSString *)startTimeStr{
    _startTimeStr = startTimeStr;
    self.startTimeLabel.text = startTimeStr;
}
-(void)setEndTimeStr:(NSString *)endTimeStr{
    _endTimeStr = endTimeStr;
    self.endTimeLabel.text = endTimeStr;
}


@end
