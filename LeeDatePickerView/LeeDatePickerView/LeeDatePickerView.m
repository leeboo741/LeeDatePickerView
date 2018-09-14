//
//  LeeDatePickerView.m
//  LeeDatePickerView
//
//  Created by mac on 2018/9/13.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "LeeDatePickerView.h"

typedef enum : NSUInteger {
    DatePickerView_SelectedTimeZone_Start = 0, // 当前选择开始时间
    DatePickerView_SelectedTimeZone_End = 1, // 当前选择结束时间
} DatePickerView_SelectedTimeZone;

typedef enum : NSUInteger {
    CheckDateState_Safe = 0, // 时间检测通过
    CheckDateState_EndTimeEarly = 1, // 结束时间早于开始时间
} CheckDateState;

@interface LeeDatePickerView()
<
UIPickerViewDelegate,
UIPickerViewDataSource
>

/*---------View---------*/
@property (nonatomic, strong) UIView * contentView; // 内容区

@property (nonatomic, strong) UIView * contentHeadView; // 内容区头部
@property (nonatomic, strong) UIView * contentHeadLineView; // 内容头部区选中线

@property (nonatomic, strong) UIView * startTimeView; // 开始时间显示区
@property (nonatomic, strong) UILabel * startTimeTitleLabel; // 开始时间显示 title
@property (nonatomic, strong) UILabel * startTimeLabel; // 开始时间显示

@property (nonatomic, strong) UIView * endTimeView; // 结束时间显示区
@property (nonatomic, strong) UILabel * endTimeTitleLabel; // 结束时间显示 title
@property (nonatomic, strong) UILabel * endTimeLabel; // 结束时间显示

@property (nonatomic, strong) UIPickerView * datePickerView; // 时间选择器

@property (nonatomic, strong) UIView * contentBottomView; // 内容区底部

/*---------Data---------*/

@property (nonatomic, assign) NSInteger startYear;
@property (nonatomic, assign) NSInteger endYear;

@property (nonatomic, strong) NSMutableArray * yearArray; // 年份 list
@property (nonatomic, strong) NSMutableArray * monthArray; // 月份 list
@property (nonatomic, strong) NSMutableArray * dayArray; // 日期 list

@property (nonatomic, assign) NSInteger yearIndex; // 选中年份标记
@property (nonatomic, assign) NSInteger monthIndex; // 选中月份标记
@property (nonatomic, assign) NSInteger dayIndex; // 选中日期标记

@property (nonatomic, assign) DatePickerView_SelectedTimeZone selectedTimeZone; // 时间选择区域

@property (nonatomic, copy) NSString * startDateStr; // 开始时间
@property (nonatomic, copy) NSString * endDateStr; // 结束时间
@property (nonatomic, strong) NSDate * startDate; // 开始时间
@property (nonatomic, strong) NSDate * endDate; // 结束时间

@end

static CGFloat sContentHeight = 300.0f; // 内容显示区 高度
static CGFloat sContentHeadHeight = 50.0f; // 内容显示区 头部高度
static CGFloat sContentCenterHeight = 200.0f; // 内容显示区 中心区高度
static CGFloat sContentBottomHeight = 50.0f; // 内容显示区 底部高度

static NSInteger sYearCountAfterNow = 20; // 从现在往后数多少年

@implementation LeeDatePickerView
#pragma mark -
#pragma mark Init
-(instancetype)init{
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.3];
    }
    self.selectedTimeZone = DatePickerView_SelectedTimeZone_Start;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [self setUpView];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView)];
    [self addGestureRecognizer:tap];
    return self;
}
-(void)setUpView{
#pragma mark 内容显示区
    self.contentView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, sContentHeight)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.contentView];
    
#pragma mark 内容显示区头部
    self.contentHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, sContentHeadHeight)];
    [self.contentView addSubview:self.contentHeadView];
    
    /*----开始时间---*/
    self.startTimeView = [[UIView alloc]initWithFrame:CGRectMake(0, 5, self.bounds.size.width / 2, sContentHeadHeight)];
    [self.contentHeadView addSubview:self.startTimeView];
    
    self.startTimeTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width / 2, 15)];
    self.startTimeTitleLabel.text = @"开始时间";
    self.startTimeTitleLabel.font = [UIFont systemFontOfSize:12.0f];
    self.startTimeTitleLabel.textColor = [UIColor colorWithRed:146/255.0f green:146/255.0f blue:146/255.0f alpha:1];
    self.startTimeTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.startTimeView addSubview:self.startTimeTitleLabel];
    
    self.startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.bounds.size.width / 2, 15)];
    NSDateFormatter * format = [[NSDateFormatter alloc]init];
    format.dateFormat = @"yyyy.MM.dd";
    self.startTimeLabel.text = [format stringFromDate:[NSDate date]];
    self.startTimeLabel.font = [UIFont systemFontOfSize:15.0f];
    self.startTimeLabel.textColor = [UIColor colorWithRed:70/255.0f green:70/255.0f blue:70/255.0f alpha:1];
    self.startTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.startTimeView addSubview:self.startTimeLabel];
    
    UITapGestureRecognizer * startTimeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startTimeTapAction)];
    [self.startTimeView addGestureRecognizer:startTimeTap];
    
    /*---结束时间---*/
    self.endTimeView = [[UIView alloc]initWithFrame:CGRectMake(self.bounds.size.width / 2, 0, self.bounds.size.width / 2, sContentHeadHeight)];
    [self.contentHeadView addSubview:self.endTimeView];
    
    self.endTimeTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width / 2, 15)];
    self.endTimeTitleLabel.text = @"开始时间";
    self.endTimeTitleLabel.font = [UIFont systemFontOfSize:12.0f];
    self.endTimeTitleLabel.textColor = [UIColor colorWithRed:146/255.0f green:146/255.0f blue:146/255.0f alpha:1];
    self.endTimeTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.endTimeView addSubview:self.endTimeTitleLabel];
    
    self.endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.bounds.size.width / 2, 15)];
    self.endTimeLabel.text = [format stringFromDate:[NSDate date]];
    self.endTimeLabel.font = [UIFont systemFontOfSize:15.0f];
    self.endTimeLabel.textColor = [UIColor colorWithRed:70/255.0f green:70/255.0f blue:70/255.0f alpha:1];
    self.endTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.endTimeView addSubview:self.endTimeLabel];
    
    UITapGestureRecognizer * endTimeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endTimeTapAction)];
    [self.endTimeView addGestureRecognizer:endTimeTap];
    
    /*---选中线---*/
    self.contentHeadLineView = [[UIView alloc]initWithFrame:CGRectMake(self.bounds.size.width/4-self.bounds.size.width/8, 40, self.bounds.size.width/4, 5)];
    self.contentHeadLineView.backgroundColor = [UIColor colorWithRed:63/255.0 green:189/255.0 blue:212/255.0 alpha:1];
    [self.contentHeadView addSubview:self.contentHeadLineView];
    
    [self showContentView:YES];
    
#pragma mark 时间选择区
    self.datePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, sContentHeadHeight, [UIScreen mainScreen].bounds.size.width, sContentCenterHeight)];
    self.datePickerView.dataSource = self;
    self.datePickerView.delegate = self;
    self.datePickerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.datePickerView];
    
    NSCalendar * calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    // 定义一个时间字段的旗标，指定将会获取指定年、月、日、时、分、秒的信息
    unsigned unitFlags = NSCalendarUnitYear |
    NSCalendarUnitMonth |  NSCalendarUnitDay |
    NSCalendarUnitHour |  NSCalendarUnitMinute |
    NSCalendarUnitSecond | NSCalendarUnitWeekday;
    // 获取不同时间字段的信息
    NSDateComponents *comp = [calendar components: unitFlags fromDate:[NSDate date]];
    self.yearIndex = [self.yearArray indexOfObject:[NSString stringWithFormat:@"%ld", comp.year]];
    self.monthIndex = [self.monthArray indexOfObject:[NSString stringWithFormat:@"%02ld", comp.month]];
    self.dayIndex = [self.dayArray indexOfObject:[NSString stringWithFormat:@"%02ld", comp.day]];
    [self pickerView:self.datePickerView didSelectRow:self.yearIndex inComponent:0];
    [self pickerView:self.datePickerView didSelectRow:self.monthIndex inComponent:1];
    [self pickerView:self.datePickerView didSelectRow:self.dayIndex inComponent:2];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UILabel *label = (UILabel *)[self.datePickerView viewForRow:self.yearIndex forComponent:0];
        label.textColor = [UIColor colorWithRed:26/255.0 green:174/255.0 blue:135/255.0 alpha:1];
        label.font =[UIFont systemFontOfSize:16];
        
        label = (UILabel *)[self.datePickerView viewForRow:self.monthIndex forComponent:1];
        label.textColor = [UIColor colorWithRed:26/255.0 green:174/255.0 blue:135/255.0 alpha:1];
        label.font = [UIFont systemFontOfSize:16];
        
        label = (UILabel *)[self.datePickerView viewForRow:self.dayIndex forComponent:2];
        label.textColor = [UIColor colorWithRed:26/255.0 green:174/255.0 blue:135/255.0 alpha:1];
        label.font = [UIFont systemFontOfSize:16];
    });
#pragma mark 内容页底部
    self.contentBottomView = [[UIView alloc]initWithFrame:CGRectMake(0, sContentHeadHeight + sContentCenterHeight, self.bounds.size.width, sContentBottomHeight)];
    [self.contentView addSubview:self.contentBottomView];
    
    UIButton * cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width/2, 50)];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithRed:146/255.0f green:146/255.0f blue:146/255.0f alpha:1] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentBottomView addSubview:cancelButton];
    
    UIButton * commitButton = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width/2, 0, self.bounds.size.width/2, 50)];
    commitButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [commitButton setTitle:@"确定" forState:UIControlStateNormal];
    [commitButton setTitleColor:[UIColor colorWithRed:146/255.0f green:146/255.0f blue:146/255.0f alpha:1] forState:UIControlStateNormal];
    [commitButton addTarget:self action:@selector(commitAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentBottomView addSubview:commitButton];
}
#pragma mark -
#pragma mark Set/Get
-(NSInteger)startYear{
    if (_startYear == 0) {
        _startYear = 1970;
    }
    return _startYear;
}
-(NSInteger)endYear{
    if (_endYear == 0){
        NSDateFormatter * formater = [[NSDateFormatter alloc]init];
        [formater setDateFormat:@"yyyy"];
        NSString * yearStr = [formater stringFromDate:[NSDate date]];
        _endYear = [yearStr integerValue] + sYearCountAfterNow;
    }
    return _endYear;
}
-(NSMutableArray *)yearArray{
    if (_yearArray == nil) {
        _yearArray = [NSMutableArray array];
        for (NSInteger year = self.startYear; year <= self.endYear; year ++) {
            NSString * str = [NSString stringWithFormat:@"%ld",year];
            [_yearArray addObject:str];
        }
    }
    return _yearArray;
}
-(NSMutableArray *)monthArray{
    if (_monthArray == nil) {
        _monthArray = [NSMutableArray array];
        for (int month = 1; month <= 12; month++) {
            NSString * str = [NSString stringWithFormat:@"%02d", month];
            [_monthArray addObject:str];
        }
    }
    return _monthArray;
}
-(NSMutableArray *)dayArray{
    if (_dayArray == nil) {
        _dayArray = [NSMutableArray array];
        for (int day = 1; day <= 31; day++) {
            NSString * str = [NSString stringWithFormat:@"%02d", day];
            [_dayArray addObject:str];
        }
    }
    return _dayArray;
}

#pragma mark -
#pragma mark Action
// 取消操作
-(void)cancelAction{
    [self showContentView:NO];
}
// 确认操作
-(void)commitAction{
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy.MM.dd"];
    NSDate * startDate = [formatter dateFromString:self.startTimeLabel.text];
    NSDate * endDate = [formatter dateFromString:self.endTimeLabel.text];
    if (self.selectTimeBlock) {
        self.selectTimeBlock(startDate, endDate);
    }
    [self showContentView:NO];
}
// 展示/隐藏
-(void)showContentView:(BOOL)show{
    if (show) {
        [UIView animateWithDuration:0.3 animations:^{
            self.contentView.frame = CGRectMake(0, self.bounds.size.height - sContentHeight, self.bounds.size.width, sContentHeight);
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self.contentView.frame=CGRectMake(0, self.bounds.size.height, self.bounds.size.width, sContentHeight);
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}
// 点击 开始时间内容区
-(void)startTimeTapAction{
    self.selectedTimeZone = DatePickerView_SelectedTimeZone_Start;
    [UIView animateWithDuration:0.3 animations:^{
        self.contentHeadLineView.frame=CGRectMake(self.bounds.size.width/4-self.bounds.size.width/8, 40, self.bounds.size.width/4, 5);
    }];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy.MM.dd";
    NSDate *date=[format dateFromString:self.startTimeLabel.text];
    NSCalendar *calendar = [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    // 定义一个时间字段的旗标，指定将会获取指定年、月、日、时、分、秒的信息
    unsigned unitFlags = NSCalendarUnitYear |
    NSCalendarUnitMonth |  NSCalendarUnitDay |
    NSCalendarUnitHour |  NSCalendarUnitMinute |
    NSCalendarUnitSecond | NSCalendarUnitWeekday;
    NSDateComponents *comp = [calendar components: unitFlags fromDate:date];
    
    self.yearIndex = [self.yearArray indexOfObject:[NSString stringWithFormat:@"%ld", comp.year]];
    self.monthIndex = [self.monthArray indexOfObject:[NSString stringWithFormat:@"%02ld", comp.month]];
    self.dayIndex = [self.dayArray indexOfObject:[NSString stringWithFormat:@"%02ld", comp.day]];
    
    [self.datePickerView selectRow:self.yearIndex inComponent:0 animated:YES];
    [self.datePickerView selectRow:self.monthIndex inComponent:1 animated:YES];
    [self.datePickerView selectRow:self.dayIndex inComponent:2 animated:YES];
    [self pickerView:self.datePickerView didSelectRow:self.yearIndex inComponent:0];
    [self pickerView:self.datePickerView didSelectRow:self.monthIndex inComponent:1];
    [self pickerView:self.datePickerView didSelectRow:self.dayIndex inComponent:2];
}
// 点击 结束时间内容区
-(void)endTimeTapAction{
    self.selectedTimeZone = DatePickerView_SelectedTimeZone_End;
    [UIView animateWithDuration:0.3 animations:^{
        self.contentHeadLineView.frame=CGRectMake(self.bounds.size.width/2+self.bounds.size.width/8, 40, self.bounds.size.width/4, 5);
    }];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy.MM.dd";
    NSDate *date=[format dateFromString:self.endTimeLabel.text];
    NSCalendar *calendar = [[NSCalendar alloc]
                            initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    // 定义一个时间字段的旗标，指定将会获取指定年、月、日、时、分、秒的信息
    unsigned unitFlags = NSCalendarUnitYear |
    NSCalendarUnitMonth |  NSCalendarUnitDay |
    NSCalendarUnitHour |  NSCalendarUnitMinute |
    NSCalendarUnitSecond | NSCalendarUnitWeekday;
    NSDateComponents *comp = [calendar components: unitFlags fromDate:date];
    
    self.yearIndex = [self.yearArray indexOfObject:[NSString stringWithFormat:@"%ld", comp.year]];
    self.monthIndex = [self.monthArray indexOfObject:[NSString stringWithFormat:@"%02ld", comp.month]];
    self.dayIndex = [self.dayArray indexOfObject:[NSString stringWithFormat:@"%02ld", comp.day]];
    
    [self.datePickerView selectRow:self.yearIndex inComponent:0 animated:YES];
    [self.datePickerView selectRow:self.monthIndex inComponent:1 animated:YES];
    [self.datePickerView selectRow:self.dayIndex inComponent:2 animated:YES];
    [self pickerView:self.datePickerView didSelectRow:self.yearIndex inComponent:0];
    [self pickerView:self.datePickerView didSelectRow:self.monthIndex inComponent:1];
    [self pickerView:self.datePickerView didSelectRow:self.dayIndex inComponent:2];
}
// 点击当前页面 隐藏并移除 时间选择器
-(void)tapView{
    [self showContentView:NO];
}
-(CheckDateState)checkDateStartDate:(NSDate * )startDate endDate:(NSDate *)endDate{
    if ([startDate compare:endDate] == NSOrderedDescending) {
        return CheckDateState_EndTimeEarly;
    }
    return CheckDateState_Safe;
}
-(void)showMessage:(NSString * )message{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIView *showview = [[UIView alloc]init];
    showview.backgroundColor = [UIColor blackColor];
    showview.frame = CGRectMake(1, 1, 1, 1);
    showview.alpha = 1.0f;
    showview.layer.cornerRadius = 5.0f;
    showview.layer.masksToBounds = YES;
    [window addSubview:showview];
    UILabel *label = [[UILabel alloc]init];
    CGSize LabelSize = [message sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(290, 9000)];
    label.frame = CGRectMake(10, 5, LabelSize.width, LabelSize.height);
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = 1;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:15];
    [showview addSubview:label];
    showview.frame = CGRectMake((UIScreen.mainScreen.bounds.size.width - LabelSize.width - 20)/2, UIScreen.mainScreen.bounds.size.height - 100, LabelSize.width+20, LabelSize.height+10);
    [UIView animateWithDuration:3 animations:^{
        showview.alpha = 0;
    } completion:^(BOOL finished) {
        [showview removeFromSuperview];
    }];
}
#pragma mark -
#pragma mark Picker View Delegate/DataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        return self.yearArray.count;
    }else if (component == 1){
        return self.monthArray.count;
    }else{
        switch (self.monthIndex + 1) {
            case 1:
            case 3:
            case 5:
            case 7:
            case 8:
            case 10:
            case 12:
            {
                return 31;
            }
                break;
            case 4:
            case 6:
            case 9:
            case 11:
            {
                return 30;
            }
                break;
                
            default:
            {
                return 28;
            }
                break;
        }
    }
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSInteger yearRowIndex = [_datePickerView selectedRowInComponent:0];
    NSInteger monthRowIndex = [_datePickerView selectedRowInComponent:1];
    NSInteger dayRowIndex = [_datePickerView selectedRowInComponent:2];
    
    NSString * yearStr = [_yearArray objectAtIndex:yearRowIndex];
    NSString * monthStr = [_monthArray objectAtIndex:monthRowIndex];
    NSString * dayStr = [_dayArray objectAtIndex:dayRowIndex];
    
    NSString * selectedDateStr = [NSString stringWithFormat:@"%@.%@.%@",yearStr,monthStr,dayStr];
    NSDateFormatter * formater = [[NSDateFormatter alloc]init];
    [formater setDateFormat:@"yyyy.MM.dd"];
    NSDate * selectedDate = [formater dateFromString:selectedDateStr];
    if (component == 0) {
        self.yearIndex = row;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UILabel *label = (UILabel *)[pickerView viewForRow:row forComponent:component];
            label.textColor = [UIColor colorWithRed:26/255.0 green:174/255.0 blue:135/255.0 alpha:1];
            label.font = [UIFont systemFontOfSize:16];
        });
    }else if (component == 1){
        self.monthIndex = row;
        [pickerView reloadComponent:2];
        if (self.monthIndex + 1 == 4 || self.monthIndex + 1 == 6 || self.monthIndex + 1 == 9 || self.monthIndex + 1 == 11) {
            if (self.dayIndex + 1 == 31) {
                self.dayIndex = 30;
            }
        }else if (self.monthIndex + 1 == 2) {
            if (self.dayIndex + 1 > 28) {
                self.dayIndex = 27;
            }
        }
        [pickerView selectRow:self.dayIndex inComponent:2 animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UILabel *label = (UILabel *)[pickerView viewForRow:row forComponent:component];
            label.textColor = [UIColor colorWithRed:26/255.0 green:174/255.0 blue:135/255.0 alpha:1];
            label.font = [UIFont systemFontOfSize:16];
            label = (UILabel *)[pickerView viewForRow:self.dayIndex forComponent:2];
            label.textColor = [UIColor colorWithRed:26/255.0 green:174/255.0 blue:135/255.0 alpha:1];
            label.font = [UIFont systemFontOfSize:16];
        });
    }else{
        self.dayIndex = row;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UILabel *label = (UILabel *)[pickerView viewForRow:row forComponent:component];
            label.textColor = [UIColor colorWithRed:26/255.0 green:174/255.0 blue:135/255.0 alpha:1];
            label.font = [UIFont systemFontOfSize:16];
        });
    }
    
    if (self.selectedTimeZone == DatePickerView_SelectedTimeZone_Start) {
        self.startTimeLabel.text = selectedDateStr;
    }else if (self.selectedTimeZone == DatePickerView_SelectedTimeZone_End){
        self.endTimeLabel.text = selectedDateStr;
    }
    
    NSDate * startDate = [formater dateFromString:self.startTimeLabel.text];
    NSDate * endDate = [formater dateFromString:self.endTimeLabel.text];
    
    CheckDateState checkTimeState = [self checkDateStartDate:startDate endDate:endDate];
    if (checkTimeState == CheckDateState_EndTimeEarly) {
        NSCalendar * calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        // 定义一个时间字段的旗标，指定将会获取指定年、月、日、时、分、秒的信息
        unsigned unitFlags = NSCalendarUnitYear |
        NSCalendarUnitMonth |  NSCalendarUnitDay |
        NSCalendarUnitHour |  NSCalendarUnitMinute |
        NSCalendarUnitSecond | NSCalendarUnitWeekday;
        // 获取不同时间字段的信息
        NSDateComponents *comp = [calendar components: unitFlags fromDate:[NSDate date]];
        self.yearIndex = [self.yearArray indexOfObject:[NSString stringWithFormat:@"%ld", comp.year]];
        self.monthIndex = [self.monthArray indexOfObject:[NSString stringWithFormat:@"%02ld", comp.month]];
        self.dayIndex = [self.dayArray indexOfObject:[NSString stringWithFormat:@"%02ld", comp.day]];
        [self.datePickerView selectRow:self.yearIndex inComponent:0 animated:YES];
        [self.datePickerView selectRow:self.monthIndex inComponent:1 animated:YES];
        [self.datePickerView selectRow:self.dayIndex inComponent:2 animated:YES];
        [self pickerView:self.datePickerView didSelectRow:self.yearIndex inComponent:0];
        [self pickerView:self.datePickerView didSelectRow:self.monthIndex inComponent:1];
        [self pickerView:self.datePickerView didSelectRow:self.dayIndex inComponent:2];
        
        [self showMessage:@"结束时间不能早于开始时间"];
    }
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40.0f;
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor =  [UIColor colorWithRed:104/255.0 green:104/255.0 blue:104/255.0 alpha:1];
    label.font = [UIFont systemFontOfSize:16];
    if (component == 0) {
        label.text = [NSString stringWithFormat:@"%@年",self.yearArray[row]];
    }else if (component == 1) {
        label.text = [NSString stringWithFormat:@"%@月",self.monthArray[row]];
    }else {
        label.text = [NSString stringWithFormat:@"%@日",self.dayArray[row]];
    }
    return label;
}

@end
