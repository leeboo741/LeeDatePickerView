//
//  LeeDatePickerView.m
//  LeeDatePickerView
//
//  Created by mac on 2018/9/13.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "LeeDatePickerView.h"
#import "LeeDatePickerHeadView.h"
#import "LeeDatePickerSingleHeadView.h"

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
UIPickerViewDataSource,
LeeDatePickerHeadViewDelegate
>

/*---------View---------*/
@property (nonatomic, strong) UIView * contentView; // 内容区
@property (nonatomic, strong) UIView<LeeDatePickerHeadViewProtocol>* contentHeadView;
@property (nonatomic, strong) UIPickerView * datePickerView; // 时间选择器
@property (nonatomic, strong) UIView * contentBottomView; // 内容区底部

/*---------Data---------*/
@property (nonatomic, assign) NSInteger startYear;
@property (nonatomic, assign) NSInteger endYear;

@property (nonatomic, strong) NSMutableArray * yearArray; // 年份 list
@property (nonatomic, strong) NSMutableArray * monthArray; // 月份 list
@property (nonatomic, strong) NSMutableArray * dayArray; // 日期 list
@property (nonatomic, strong) NSMutableArray * hourArray; // 小时 list
@property (nonatomic, strong) NSMutableArray * minArray; // 分钟 list
@property (nonatomic, strong) NSMutableArray * secArray; // 秒 list

@property (nonatomic, assign) NSInteger yearIndex; // 选中年份标记
@property (nonatomic, assign) NSInteger monthIndex; // 选中月份标记
@property (nonatomic, assign) NSInteger dayIndex; // 选中日期标记
@property (nonatomic, assign) NSInteger hourIndex; // 选中小时标记
@property (nonatomic, assign) NSInteger minIndex; // 选中分钟标记
@property (nonatomic, assign) NSInteger secIndex; // 选中秒标记

@property (nonatomic, assign) DatePickerView_SelectedTimeZone selectedTimeZone; // 时间选择区域
@property (nonatomic, copy) NSString * startDateStr; // 开始时间
@property (nonatomic, copy) NSString * endDateStr; // 结束时间
@property (nonatomic, strong) NSDate * startDate; // 开始时间
@property (nonatomic, strong) NSDate * endDate; // 结束时间
@property (nonatomic, strong) NSDateFormatter * formatter; // 时间格式

@property (nonatomic, strong) NSTimer * selectPickerTimer; // pickerview 滚动 timer

// Block
@property (nonatomic, copy) LeeDatePickerViewSelectTimeBlock lDatePickerSelectTimeBlock;
// Formatter Style
@property (nonatomic, assign) LeeDatePickerViewDateFormatterStyle formatterStyle; // 时间格式样式
// Style
@property (nonatomic, assign) LeeDatePickerViewStyle style;

@end

static NSString * ymdFormatterStr = @"yyyy.MM.dd"; // yMd时间格式
static NSString * ymdhmsFormatterStr = @"yyyy.MM.dd HH:mm:ss"; // ymdhms时间格式
static NSString * ymdhmFormatterStr = @"yyyy.MM.dd HH:mm"; // ymdhm时间格式

static CGFloat sContentHeight = 300.0f; // 内容显示区 高度
static CGFloat sContentHeadHeight = 50.0f; // 内容显示区 头部高度
static CGFloat sContentCenterHeight = 200.0f; // 内容显示区 中心区高度
static CGFloat sContentBottomHeight = 50.0f; // 内容显示区 底部高度

static NSInteger sYearCountAfterNow = 20; // 从现在往后数多少年
static NSInteger sYearCountBeforeNow = 10; // 从现在往前数多少年

static CGFloat selectPickerTimerInterval = 0.1; // pickerview 滚动 timer 时间间隔

@implementation LeeDatePickerView
#pragma mark -
#pragma mark Super
// 销毁，顺便把定时器销毁
-(void)dealloc{
    if (self.selectPickerTimer) {
        [self.selectPickerTimer invalidate];
        self.selectPickerTimer = nil;
    }
}
#pragma mark -
#pragma mark Init
// 对外开放的初始方法
+(void)showLeeDatePickerViewWithStyle:(LeeDatePickerViewStyle)style
                       formatterStyle:(LeeDatePickerViewDateFormatterStyle)formatterStyle
                                block:(LeeDatePickerViewSelectTimeBlock)block{
    LeeDatePickerView * pickerView = [[LeeDatePickerView alloc]init];
    pickerView.style = style;
    pickerView.formatterStyle = formatterStyle;
    pickerView.lDatePickerSelectTimeBlock = ^(NSArray<NSDate *> *dateArray) {
        block(dateArray);
    };
    [pickerView showContentView:YES];
}
// 重写init方法，顺便初始化一些初始数据
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
// 初始化页面
-(void)setUpView{
#pragma mark 头部内容显示区
    self.contentView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, sContentHeight)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.contentView];
    // 头部内容显示区域显示什么需要根据style来，所以在setStyle方法里进行设置
#pragma mark 时间选择区
    self.datePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, sContentHeadHeight, [UIScreen mainScreen].bounds.size.width, sContentCenterHeight)];
    self.datePickerView.dataSource = self;
    self.datePickerView.delegate = self;
    self.datePickerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.datePickerView];
    
#pragma mark 内容页底部
    self.contentBottomView = [[UIView alloc]initWithFrame:CGRectMake(0, sContentHeadHeight + sContentCenterHeight, self.bounds.size.width, sContentBottomHeight)];
    [self.contentView addSubview:self.contentBottomView];
    [self setUpBottomView];
    
}
// 设置底部区域页面
-(void)setUpBottomView{
    UIButton * cancelButton = [[UIButton alloc]initWithFrame:CGRectMake(0, -10, self.bounds.size.width/2, 50)];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithRed:146/255.0f green:146/255.0f blue:146/255.0f alpha:1] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentBottomView addSubview:cancelButton];
    
    UIButton * commitButton = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width/2, -10, self.bounds.size.width/2, 50)];
    commitButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [commitButton setTitle:@"确定" forState:UIControlStateNormal];
    [commitButton setTitleColor:[UIColor colorWithRed:146/255.0f green:146/255.0f blue:146/255.0f alpha:1] forState:UIControlStateNormal];
    [commitButton addTarget:self action:@selector(commitAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentBottomView addSubview:commitButton];
}
#pragma mark -
#pragma mark Set/Get
-(void)setFormatterStyle:(LeeDatePickerViewDateFormatterStyle)formatterStyle{
    _formatterStyle = formatterStyle;
    [self.datePickerView reloadAllComponents];
    self.startDateStr = [self.formatter stringFromDate:[NSDate date]];
    self.endDateStr = [self.formatter stringFromDate:[NSDate date]];
    [self selectPickerDate:[NSDate date]];
}
// Set 页面样式
-(void)setStyle:(LeeDatePickerViewStyle)style{
    _style = style;
    #pragma mark 内容显示区头部
    if (self.contentHeadView) {
        [self.contentHeadView removeFromSuperview];
    }
    if (style == LeeDatePickerViewStyle_StartAndEnd) {
        self.contentHeadView = [[LeeDatePickerHeadView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, sContentHeadHeight)];
        self.contentHeadView.delegate = self;
    }else{
        self.contentHeadView = [[LeeDatePickerSingleHeadView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, sContentHeadHeight)];
        self.contentHeadView.delegate = self;
    }
    [self.contentView addSubview:self.contentHeadView];
}
// GET 显示的时间格式
-(NSDateFormatter *)formatter{
    // 判断外部是否提供时间格式
    if (!_formatter)// 没有提供
    {
        _formatter = [[NSDateFormatter alloc]init];
        // 根据时间格式字符串样式 提供 时间格式
        switch (self.formatterStyle) {
            case LeeDatePickerViewDateFormatterStyle_yMd:
                [_formatter setDateFormat:ymdFormatterStr];
                break;
            case LeeDatePickerViewDateFormatterStyle_yMdHm:
                [_formatter setDateFormat:ymdhmFormatterStr];
                break;
            case LeeDatePickerViewDateFormatterStyle_yMdHms:
                [_formatter setDateFormat:ymdhmsFormatterStr];
                break;
            default:
                [_formatter setDateFormat:ymdFormatterStr];
                break;
        }
    }// 没有提供时间格式判断结束
    return _formatter;
}
// GET 开始时间
-(NSDate *)startDate{
    NSDate * date = [self.formatter dateFromString:self.startDateStr];
    return date;
}
// GET 结束时间
-(NSDate *)endDate{
    NSDate * date = [self.formatter dateFromString:self.endDateStr];
    return date;
}
// SET 开始时间 字符串
// 设置头部页面显示
-(void)setStartDateStr:(NSString *)startDateStr{
    _startDateStr = startDateStr;
    self.contentHeadView.startTimeStr = startDateStr;
}
// SET 结束时间 字符串
// 设置头部页面显示
-(void)setEndDateStr:(NSString *)endDateStr{
    _endDateStr = endDateStr;
    self.contentHeadView.endTimeStr = endDateStr;
}
// GET 开始年份，如果为0, 则默认从1970年开始
-(NSInteger)startYear{
    if (_startYear == 0) {
        _startYear = 1970;
    }
    return _startYear;
}
// GET 结束年份, 如果为0, 则默认为从现在开始+sYearCountAfterNow
-(NSInteger)endYear{
    if (_endYear == 0){
        NSDateFormatter * formater = [[NSDateFormatter alloc]init];
        [formater setDateFormat:@"yyyy"];
        NSString * yearStr = [formater stringFromDate:[NSDate date]];
        _endYear = [yearStr integerValue] + sYearCountAfterNow;
    }
    return _endYear;
}
// GET 年份列表，从开始年份到结束年份
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
// GET 月份列表，12个月
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
// GET 日期列表，取最大值 31 天
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
// GET 小时列表，24 小时
-(NSMutableArray *)hourArray{
    if (_hourArray == nil) {
        _hourArray = [NSMutableArray array];
        for (int hour = 1; hour < 24; hour++) {
            NSString * str = [NSString stringWithFormat:@"%02d", hour];
            [_hourArray addObject:str];
        }
    }
    return _hourArray;
}
// GET 分钟列表，60 分钟
-(NSMutableArray *)minArray{
    if (_minArray == nil) {
        _minArray = [NSMutableArray array];
        for (int min = 1; min < 60; min++) {
            NSString * str = [NSString stringWithFormat:@"%02d", min];
            [_minArray addObject:str];
        }
    }
    return _minArray;
}
// GET 秒钟列表，60 秒
-(NSMutableArray *)secArray{
    if (_secArray == nil) {
        _secArray = [NSMutableArray array];
        for (int sec = 1; sec < 60; sec++) {
            NSString * str = [NSString stringWithFormat:@"%02d", sec];
            [_secArray addObject:str];
        }
    }
    return _secArray;
}
-(void)setMinIndex:(NSInteger)minIndex{
    if (minIndex >= 59) {
        minIndex = 58;
    }
    if (minIndex < 0) {
        minIndex = 0;
    }
    _minIndex = minIndex;
}
-(void)setSecIndex:(NSInteger)secIndex{
    if (secIndex >= 59) {
        secIndex = 58;
    }
    if (secIndex < 0) {
        secIndex = 0;
    }
    _secIndex = secIndex;
}
#pragma mark -
#pragma mark ContentHead Delegate
-(void)leeDatePickerHeadView:(id<LeeDatePickerHeadViewDelegate>)headView select:(LeeDatePickerHeadViewSelectIndex)index{
    if ([headView isKindOfClass:[LeeDatePickerHeadView class]]) {
        if (index == LeeDatePickerHeadViewSelectIndex_Start) {
            self.selectedTimeZone = DatePickerView_SelectedTimeZone_Start;
            [self selectPickerDate:self.startDate];
        }else if (index == LeeDatePickerHeadViewSelectIndex_End) {
            self.selectedTimeZone = DatePickerView_SelectedTimeZone_End;
            [self selectPickerDate:self.endDate];
        }
    }else{
        self.selectedTimeZone = DatePickerView_SelectedTimeZone_Start;
        [self selectPickerDate:self.startDate];
    }
}
#pragma mark -
#pragma mark Action
// 选中日期
-(void)selectPickerDate:(NSDate *)date{
    NSCalendar * calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    // 定义一个时间字段的旗标，指定将会获取指定年、月、日、时、分、秒的信息
    unsigned unitFlags = NSCalendarUnitYear |
    NSCalendarUnitMonth |  NSCalendarUnitDay |
    NSCalendarUnitHour |  NSCalendarUnitMinute |
    NSCalendarUnitSecond | NSCalendarUnitWeekday;
    // 获取不同时间字段的信息
    NSDateComponents *comp = [calendar components: unitFlags fromDate:date];
    self.yearIndex = [self.yearArray indexOfObject:[NSString stringWithFormat:@"%ld", comp.year]];
    self.monthIndex = [self.monthArray indexOfObject:[NSString stringWithFormat:@"%02ld", comp.month]];
    self.dayIndex = [self.dayArray indexOfObject:[NSString stringWithFormat:@"%02ld", comp.day]];
    self.hourIndex = [self.hourArray indexOfObject:[NSString stringWithFormat:@"%02ld",comp.hour]];
    self.minIndex = [self.minArray indexOfObject:[NSString stringWithFormat:@"%02ld",comp.minute]];
    self.secIndex = [self.secArray indexOfObject:[NSString stringWithFormat:@"%02ld",comp.second]];
    
    switch (self.formatterStyle) {
        case LeeDatePickerViewDateFormatterStyle_yMdHms:
            [self.datePickerView selectRow:self.secIndex inComponent:5 animated:YES];
            [self pickerView:self.datePickerView didSelectRow:self.secIndex inComponent:5];
        case LeeDatePickerViewDateFormatterStyle_yMdHm:
            [self.datePickerView selectRow:self.hourIndex inComponent:3 animated:YES];
            [self.datePickerView selectRow:self.minIndex inComponent:4 animated:YES];
            [self pickerView:self.datePickerView didSelectRow:self.hourIndex inComponent:3];
            [self pickerView:self.datePickerView didSelectRow:self.minIndex inComponent:4];
        case LeeDatePickerViewDateFormatterStyle_yMd:
            [self.datePickerView selectRow:self.yearIndex inComponent:0 animated:YES];
            [self.datePickerView selectRow:self.monthIndex inComponent:1 animated:YES];
            [self.datePickerView selectRow:self.dayIndex inComponent:2 animated:YES];
            [self pickerView:self.datePickerView didSelectRow:self.yearIndex inComponent:0];
            [self pickerView:self.datePickerView didSelectRow:self.monthIndex inComponent:1];
            [self pickerView:self.datePickerView didSelectRow:self.dayIndex inComponent:2];
            break;
        default:
            break;
    }
}
// 取消操作
-(void)cancelAction{
    [self showContentView:NO];
}
// 确认操作
-(void)commitAction{
    if (self.lDatePickerSelectTimeBlock) {
        self.lDatePickerSelectTimeBlock(@[self.startDate,self.endDate]);
    }
    [self showContentView:NO];
}
// 页面的展示/隐藏
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
// 点击当前页面 隐藏并移除 时间选择器
-(void)tapView{
    [self showContentView:NO];
}
// 时间校验检查
-(CheckDateState)checkDateStartDate:(NSDate * )startDate endDate:(NSDate *)endDate{
    if ([startDate compare:endDate] == NSOrderedDescending) {
        return CheckDateState_EndTimeEarly;
    }
    return CheckDateState_Safe;
}
// 展示信息
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
    label.textAlignment = NSTextAlignmentCenter;
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
// 判断是否是闰年
-(BOOL)isLeapYear:(NSInteger)year{
    // 1. 能被4整除
    // 2. 如果能被100整除则必须也能被400整除
    // ==》
    // 1. 不能被100整除，但是能被4整除的年份是闰年
    // 2. 能被100整除，同时也能被400整除的年份也是闰年
    if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
        return YES;
    }else{
        return NO;
    }
}
#pragma mark -
#pragma mark Picker View Delegate/DataSource
// 展示列数
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    switch (self.formatterStyle) {
        case LeeDatePickerViewDateFormatterStyle_yMd: // 年月日 3列
            return 3;
            break;
        case LeeDatePickerViewDateFormatterStyle_yMdHm: // 年月日时分 5列
            return 5;
            break;
        case LeeDatePickerViewDateFormatterStyle_yMdHms:// 年月日时分秒 6列
            return 6;
            break;
        default:
            return 3;
            break;
    }
}
// 每一列展示的行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) { // 年
        return self.yearArray.count;
    }else if (component == 1){ // 月
        return self.monthArray.count;
    }else if (component == 2){ // 日 根据月份不同，展示行数不同
        switch (self.monthIndex) {
            case 0:
            case 2:
            case 4:
            case 6:
            case 7:
            case 9:
            case 11:
            {
                return 31;
            }
                break;
            case 3:
            case 5:
            case 8:
            case 10:
            {
                return 30;
            }
                break;
                
            default:
            {
                if ([self isLeapYear:[[self.yearArray objectAtIndex:self.yearIndex] integerValue]]){
                    return 29;
                }else{
                    return 28;
                }
            }
                break;
        }
    }else if (component == 3){ // 时
        return self.hourArray.count;
    }else if (component == 4){ // 分
        return self.minArray.count;
    }else if (component == 5){ // 秒
        return self.secArray.count;
    }else{
        return 0;
    }
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    NSInteger yearRowIndex;
    NSInteger monthRowIndex;
    NSInteger dayRowIndex;
    NSString * yearStr;
    NSString * monthStr;
    NSString * dayStr;
    
    NSInteger hourRowIndex;
    NSInteger minRowIndex;
    NSString * hourStr;
    NSString * minStr;
    
    NSInteger secRowIndex;
    NSString * secStr;
    
    switch (self.formatterStyle) {
        case LeeDatePickerViewDateFormatterStyle_yMdHms:
            secRowIndex = [_datePickerView selectedRowInComponent:5];
            secStr = [self.secArray objectAtIndex:secRowIndex];
        case LeeDatePickerViewDateFormatterStyle_yMdHm:
            hourRowIndex = [_datePickerView selectedRowInComponent:3];
            minRowIndex = [_datePickerView selectedRowInComponent:4];
            hourStr = [self.hourArray objectAtIndex:hourRowIndex];
            minStr = [self.minArray objectAtIndex:minRowIndex];
        case LeeDatePickerViewDateFormatterStyle_yMd:
            yearRowIndex = [_datePickerView selectedRowInComponent:0];
            monthRowIndex = [_datePickerView selectedRowInComponent:1];
            dayRowIndex = [_datePickerView selectedRowInComponent:2];
            yearStr = [self.yearArray objectAtIndex:yearRowIndex];
            monthStr = [self.monthArray objectAtIndex:monthRowIndex];
            dayStr = [self.dayArray objectAtIndex:dayRowIndex];
        default:
            break;
    }
    NSString * selectedDateStr;
    if (self.formatterStyle == LeeDatePickerViewDateFormatterStyle_yMd) {
        selectedDateStr = [NSString stringWithFormat:@"%@.%@.%@",yearStr,monthStr,dayStr];
    }else if (self.formatterStyle == LeeDatePickerViewDateFormatterStyle_yMdHm){
        selectedDateStr = [NSString stringWithFormat:@"%@.%@.%@ %@:%@",yearStr,monthStr,dayStr,hourStr,minStr];
    }else{
        selectedDateStr = [NSString stringWithFormat:@"%@.%@.%@ %@:%@:%@",yearStr,monthStr,dayStr,hourStr,minStr,secStr];
    }
    
    
    if (component == 0) {
        self.yearIndex = row;
    }else if (component == 1){
        self.monthIndex = row;
        [pickerView reloadComponent:2];
        if (self.monthIndex == 3 || self.monthIndex == 5 || self.monthIndex == 8 || self.monthIndex == 10) {
            if (self.dayIndex + 1 == 31) {
                self.dayIndex = 30;
            }
        }else if (self.monthIndex == 1) {
            if (self.dayIndex + 1 > 28) {
                self.dayIndex = 27;
            }
        }
        [pickerView selectRow:self.dayIndex inComponent:2 animated:YES];
    }else if(component == 2){
        self.dayIndex = row;
    }else if (component == 3){
        self.hourIndex = row;
    }else if (component == 4){
        self.minIndex = row;
    }else if (component == 5){
        self.secIndex = row;
    }
    
    if (self.style == LeeDatePickerViewStyle_Single) {
        self.startDateStr = selectedDateStr;
    }else{
        if (self.selectedTimeZone == DatePickerView_SelectedTimeZone_Start) {
            self.startDateStr = selectedDateStr;
        }else if (self.selectedTimeZone == DatePickerView_SelectedTimeZone_End){
            self.endDateStr = selectedDateStr;
        }
        // 会引起 selectPickerDate 方法中 index 越界  要想想怎么解决
//        CheckDateState checkTimeState = [self checkDateStartDate:self.startDate endDate:self.endDate];
//        if (checkTimeState == CheckDateState_EndTimeEarly) {
//            [self selectPickerDate:[NSDate date]];
//            [self showMessage:@"结束时间不能早于开始时间"];
//        }
    }
    
//    if (_selectPickerTimer) {
//        [_selectPickerTimer invalidate];
//    }
    [self reloadPicker:nil];
//    _selectPickerTimer = [NSTimer scheduledTimerWithTimeInterval:selectPickerTimerInterval target:self selector:@selector(reloadPicker:) userInfo:@(component) repeats:NO];
}
-(void)reloadPicker:(NSTimer *)timer{
    [self.datePickerView reloadAllComponents];
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40.0f;
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel * label = (UILabel *)view;
    if (!label) {
        label = [[UILabel alloc]init];
        label.textAlignment = NSTextAlignmentCenter;
        [label setBackgroundColor:[UIColor clearColor]];
    }
    label.attributedText = [self pickerView:pickerView attributedTitleForRow:row forComponent:component];
    return label;
}
-(NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString * string;
    BOOL isSelected;
    if (component == 0) {
        string = [NSString stringWithFormat:@"%@年",self.yearArray[row]];
        isSelected = (row == self.yearIndex);
    }else if (component == 1) {
        string = [NSString stringWithFormat:@"%@月",self.monthArray[row]];
        isSelected = (row == self.monthIndex);
    }else if (component == 2){
        string = [NSString stringWithFormat:@"%@日",self.dayArray[row]];
        isSelected = (row == self.dayIndex);
    }else if (component == 3){
        string = [NSString stringWithFormat:@"%@时",self.hourArray[row]];
        isSelected = (row == self.hourIndex);
    }else if (component == 4){
        string = [NSString stringWithFormat:@"%@分",self.minArray[row]];
        isSelected = (row == self.minIndex);
    }else{
        string = [NSString stringWithFormat:@"%@秒",self.secArray[row]];
        isSelected = (row == self.secIndex);
    }
    return [self getAttributeStringWithString:string isSelected:isSelected];
}
-(NSAttributedString *)getAttributeStringWithString:(NSString *)string isSelected:(BOOL)isSelected{
    NSMutableAttributedString * attributeString = [[NSMutableAttributedString alloc]initWithString:string];
    NSRange range = NSMakeRange(0, string.length);
    CGFloat selectFontSize = 0.0f;
    CGFloat unSelectFontSize = 0.0f;
    
    UIFont * font;
    UIColor * color;
    switch (self.formatterStyle) {
        case LeeDatePickerViewDateFormatterStyle_yMd:
            selectFontSize = 21.0f;
            unSelectFontSize = 21.0f;
            break;
        case LeeDatePickerViewDateFormatterStyle_yMdHm:
            selectFontSize = 19.0f;
            unSelectFontSize = 19.0f;
            break;
        case LeeDatePickerViewDateFormatterStyle_yMdHms:
            selectFontSize = 17.0f;
            unSelectFontSize = 17.0f;
            break;
            
        default:
            selectFontSize = 19.0f;
            unSelectFontSize = 19.0f;
            break;
    }
    if (isSelected) {
        font = [UIFont systemFontOfSize:selectFontSize];
        color = [UIColor colorWithRed:100/255.0 green:147/255.0 blue:237/255.0 alpha:1];
    }else{
        font = [UIFont systemFontOfSize:unSelectFontSize];
        color = [UIColor colorWithRed:104/255.0 green:104/255.0 blue:104/255.0 alpha:1];
    }
    [attributeString addAttribute:NSFontAttributeName value:font range:range];
    [attributeString addAttribute:NSForegroundColorAttributeName value:color range:range];
    return [[NSAttributedString alloc]initWithAttributedString:attributeString];
}

@end
