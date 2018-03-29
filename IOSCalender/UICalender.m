//
//  UICalender.m
//  IOSCalender
//
//  Created by 于磊 on 16/5/8.
//  Copyright © 2016年 于磊. All rights reserved.
//

#import "UICalender.h"
#import "DataCalender.h"

#define Weekdays @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"]

static NSDateFormatter *dateForMattor;
@interface UICalender ()<UIScrollViewDelegate,DataCalenderItemDelegate>
@property(strong, nonatomic) NSDate *date;
@property(strong, nonatomic) UIButton *titleButton;
@property(strong, nonatomic) UIScrollView *scrollView;
@property(strong, nonatomic) DataCalender *leftCalenderItem;
@property(strong, nonatomic) DataCalender *centerCalendarItem;
@property(strong, nonatomic) DataCalender *rightCalenderItem;
@property(strong, nonatomic) UIView *backgroundView;
@property(strong, nonatomic) UIView *dateCheckedView;
@property(strong, nonatomic) UIDatePicker *datePicker;


@end

@implementation UICalender


- (instancetype)initWithCurrentDate:(NSDate *)date{
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithRed:236 / 255.0 green:236 / 255.0 blue:236 / 255.0 alpha:1.0];
        self.date = date;//显示当前时间
        
        [self setupTitleBar];//设置上层显示的titleBar
        [self setupWeekHeader];//设置星期的文字显示样式
        [self setupCalendarItems];//设置日历显示的三个部分
        [self setupScrollView];
        [self setFrame:CGRectMake(0, 0, DeviceWidth, CGRectGetMaxY(self.scrollView.frame))];
        [self setCurrentDate:self.date];//设置当前日期的显示
        
    }
    return self;
}


#pragma mark - UImethod
-(UIView *)backgroundView{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc]initWithFrame:self.bounds];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideDatePickerView)];
        [_backgroundView addGestureRecognizer:tapGesture];
    }
    [self addSubview:_backgroundView];
    return _backgroundView;
}
-(UIView *)dateCheckedView{
    if (!_dateCheckedView) {
        _dateCheckedView = [[UIView alloc]initWithFrame:CGRectMake(0, 44, self.frame.size.width, 0)];
        _dateCheckedView.backgroundColor = [UIColor whiteColor];
        _dateCheckedView.clipsToBounds = YES;
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, 32, 20)];
        cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [cancelButton setTitle:@"取消" forState:UIWindowLevelNormal];
        [cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelSelectCurrentData) forControlEvents:UIControlEventTouchUpInside];
        [_dateCheckedView addSubview:cancelButton];
        
        UIButton *okButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 52, 10, 32, 20)];
        okButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [okButton setTitle:@"确定" forState:UIControlStateNormal];
        
        
        [okButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [okButton addTarget:self action:@selector(selectCurrentDate) forControlEvents:UIControlEventTouchUpInside];
        [_dateCheckedView addSubview:okButton];
        [_dateCheckedView addSubview:self.datePicker];
        
    }
    [self addSubview:_dateCheckedView];
    return _dateCheckedView;
}
-(UIDatePicker *)datePicker{
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc]init];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        _datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"Chinese"];
        CGRect frame = _datePicker.frame;
        frame.origin = CGPointMake(0, 32);
        _datePicker.frame = frame;
    }
    return _datePicker;
}
#pragma mark - 设置星期
-(void)setupWeekHeader{
    NSInteger count = [Weekdays count];
    CGFloat weekHeaderSetX = 5;
    for (int i = 0; i < count; i++) {
        UILabel * weekdayLable = [[UILabel alloc]initWithFrame:CGRectMake(weekHeaderSetX, 50, (DeviceWidth - 10) / count, 20)];
        weekdayLable.textAlignment = NSTextAlignmentCenter;
        weekdayLable.text = Weekdays[i];
        if (i == 0 || i == count - 1) {
            weekdayLable.textColor = [UIColor redColor];
        }else{
            weekdayLable.textColor = [UIColor grayColor];
        }
        [self addSubview:weekdayLable];
        weekHeaderSetX += weekdayLable.frame.size.width;
    }
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(15, 74, DeviceWidth - 30, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:lineView];
}
#pragma 设置包含日期的item的scrollView
-(void)setupScrollView{
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.scrollView setFrame:CGRectMake(0, 75, DeviceWidth, self.centerCalendarItem.frame.size.height)];
    self.scrollView.contentSize = CGSizeMake(3 * self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
    [self addSubview:self.scrollView];
}
#pragma mark - 设置日历滑动显示日期
-(void)setupCalendarItems{
    self.scrollView = [[UIScrollView alloc]init];
//左边滑动日期
    self.leftCalenderItem = [[DataCalender alloc]init];
    [self.scrollView addSubview:self.leftCalenderItem];
//居中显示的日期
    CGRect itemFrame = self.leftCalenderItem.frame;
    itemFrame.origin.x = DeviceWidth;
    self.centerCalendarItem = [[DataCalender alloc]init];
    self.centerCalendarItem.frame = itemFrame;
    self.centerCalendarItem.delegate = self;
    [self.scrollView addSubview:self.centerCalendarItem];
//右边滑动的日期
    itemFrame.origin.x = DeviceWidth * 2;
    self.rightCalenderItem = [[DataCalender alloc]init];
    self.rightCalenderItem.frame = itemFrame;
    [self.scrollView addSubview:self.rightCalenderItem];
    
}

-(void)setCurrentDate:(NSDate *)date{
    self.centerCalendarItem.date = date;
    self.leftCalenderItem.date = [self.centerCalendarItem previousMonthDate];
    self.rightCalenderItem.date = [self.centerCalendarItem nextMonthDate];
    
    [self.titleButton setTitle:[self stringFromDate:self.centerCalendarItem.date] forState:UIControlStateNormal];
}


#pragma mark - Private
-(NSString *)stringFromDate:(NSDate *)date{
    if (!dateForMattor) {
        dateForMattor = [[NSDateFormatter alloc]init];
        [dateForMattor setDateFormat:@"MM-yyyy"];
    }
    return [dateForMattor stringFromDate:date];
}

#pragma mark - 月份
-(void)setupTitleBar{   //设置可以翻动月份滚动条
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DeviceWidth, 44)];
    titleView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:titleView];
   //左键选择上个月
    UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 10, 32, 24)];
    [leftButton setImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(setPreviousMonthDate) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:leftButton];
   //右键选择下个月
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(titleView.frame.size.width - 37,10,32,24)];
    [rightButton setImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(setNextMonthDate) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:rightButton];
    
    UIButton *titlebButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titlebButton.titleLabel.textColor = [UIColor whiteColor];
    titlebButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titlebButton.center = titleView.center;
    [titlebButton addTarget:self action:@selector(showDatePicker) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:titlebButton];
    self.titleButton = titlebButton;
    
}

//重新加载日历的数据
-(void)reloadCalendarItems{
    CGPoint weekSetX = self.scrollView.contentOffset;
    if (weekSetX.x > self.scrollView.frame.size.width) {
        [self setNextMonthDate];
    }else{
        [self setPreviousMonthDate];
    }
}
#pragma mark - SEL
//选择当前日期
-(void)selectCurrentDate{
    [self setCurrentDate:self.datePicker.date];
    [self hideDatePickerView];
}


//取消
-(void)cancelSelectCurrentData{
    [self hideDatePickerView];
}
-(void)hideDatePickerView{
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundView.alpha = 0;
        self.dateCheckedView.frame = CGRectMake(0, 44, self.frame.size.width, 0);
    } completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
        [self.dateCheckedView removeFromSuperview];
    }];
}


-(void)showDatePicker{
    [self showDatePickerView];
}
-(void)showDatePickerView{
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundView.alpha = 0.4;
        self.dateCheckedView.frame = CGRectMake(0, 44, self.frame.size.width, 250);
    }];
}

//跳到下个月
-(void)setNextMonthDate{
    [self setCurrentDate:[self.centerCalendarItem nextMonthDate]];
}
//跳到上个月
-(void)setPreviousMonthDate{
    [self setCurrentDate:[self.centerCalendarItem previousMonthDate]];
}

#pragma mark - 实现代理方法
//UIScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self reloadCalendarItems];
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
}

//DataCalenderItemDelegate

-(void)calendarItem:(DataCalender *)item didSelectedDate:(NSDate *)date{
    self.date = date;
    [self setCurrentDate:self.date];
}
@end
