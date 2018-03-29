//
//  DataCalender.m
//  IOSCalender
//
//  Created by 于磊 on 16/5/8.
//  Copyright © 2016年 于磊. All rights reserved.
//

#import "DataCalender.h"
@interface DataCalendarCell : UICollectionViewCell

- (UILabel *)dayLabel;
- (UILabel *)chineseDayLabel;

@end

@implementation DataCalendarCell {
    UILabel *_dayLabel;
    UILabel *_chineseDayLabel;
    NSString *day;
}

- (UILabel *)dayLabel {
    if (!_dayLabel) {
        _dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        _dayLabel.textAlignment = NSTextAlignmentCenter;
        _dayLabel.font = [UIFont systemFontOfSize:15];
        _dayLabel.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2 - 3);
        [self addSubview:_dayLabel];
        
    }
    return _dayLabel;
}

- (UILabel *)chineseDayLabel {
    if (!_chineseDayLabel) {
        _chineseDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 10)];
        _chineseDayLabel.textAlignment = NSTextAlignmentCenter;
        _chineseDayLabel.font = [UIFont boldSystemFontOfSize:9];
        
        CGPoint point = _dayLabel.center;
        point.y += 15;
        _chineseDayLabel.center = point;
        [self addSubview:_chineseDayLabel];
        
    }
    return _chineseDayLabel;
}

@end

#define CollectionViewHorizonMargin 5
#define CollectionViewVerticalMargin 5

#define ChineseMonths @[@"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月",@"九月", @"十月", @"冬月", @"腊月"]
#define ChineseFestival @[@"除夕",@"春节",@"中秋",@"五一",@"国庆",@"儿童",@"圣诞",@"七夕",@"端午"]
#define ChineseDays @[@"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",@"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十", @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十"]
#define ChineseWeatherFestival @[@"立春",@"雨水",@"惊蛰",@"春分",@"清明",@"谷雨",@"立夏",@"小满",@"忙种",@"夏至",@"小暑",@"大暑",@"立秋",@"处暑",@"寒露",@"霜降",@"白露",@"秋分",@"立冬",@"小雪",@"大雪",@"冬至",@"小寒",@"大寒"]


typedef NS_ENUM(NSUInteger, DataCalendarMonth) {
    DataCalendarMonthPrevious = 0,
    DataCalendarMonthCurrent = 1,
    DataCalendarMonthNext = 2,
};

@interface DataCalender () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;

@end

@implementation DataCalender

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        [self setupCollectionView];
        [self setFrame:CGRectMake(0, 0, DeviceWidth, self.collectionView.frame.size.height + CollectionViewVerticalMargin * 2)];
    }
    return self;
}

#pragma mark - Custom Accessors

- (void)setDate:(NSDate *)date {
    _date = date;
    [self.collectionView reloadData];
}

#pragma mark - Public

// 获取date的下个月日期
- (NSDate *)nextMonthDate {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = 1;
    NSDate *nextMonthDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
    return nextMonthDate;
}

// 获取date的上个月日期
- (NSDate *)previousMonthDate {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = -1;
    NSDate *previousMonthDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
    return previousMonthDate;
}

#pragma mark - Private

// collectionView显示日期单元，设置其属性
- (void)setupCollectionView {
    CGFloat itemWidth = (DeviceWidth - CollectionViewHorizonMargin * 2) / 7;
    CGFloat itemHeight = itemWidth;
    
    UICollectionViewFlowLayout *flowLayot = [[UICollectionViewFlowLayout alloc] init];
    flowLayot.sectionInset = UIEdgeInsetsZero;
    flowLayot.itemSize = CGSizeMake(itemWidth, itemHeight);
    flowLayot.minimumLineSpacing = 0;
    flowLayot.minimumInteritemSpacing = 0;
    
    CGRect collectionViewFrame = CGRectMake(CollectionViewHorizonMargin, CollectionViewVerticalMargin, DeviceWidth - CollectionViewHorizonMargin * 2, itemHeight * 6);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:flowLayot];
    [self addSubview:self.collectionView];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[DataCalendarCell class] forCellWithReuseIdentifier:@"CalendarCell"];
}

// 自动获取date当前月的第一天是星期几
- (NSInteger)weekdayOfFirstDayInDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:1];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self.date];
    [components setDay:1];
    NSDate *firstDate = [calendar dateFromComponents:components];
    NSDateComponents *firstComponents = [calendar components:NSCalendarUnitWeekday fromDate:firstDate];
    return firstComponents.weekday - 1;
}

// 获取date当前月的总天数
- (NSInteger)totalDaysInMonthOfDate:(NSDate *)date {
    NSRange range = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return range.length;
}

// 获取某月day的日期
- (NSDate *)dateOfMonth:(DataCalendarMonth)calendarMonth WithDay:(NSInteger)day {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date;
    
    switch (calendarMonth) {
        case DataCalendarMonthPrevious:
            date = [self previousMonthDate];
            break;
            
        case DataCalendarMonthCurrent:
            date = self.date;
            break;
            
        case DataCalendarMonthNext:
            date = [self nextMonthDate];
            break;
        default:
            break;
    }
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    [components setDay:day];
    NSDate *dateOfDay = [calendar dateFromComponents:components];
    return dateOfDay;
}
#pragma mark - 显示节日节气信息
// 获取date当天的农历
- (NSString *)chineseCalendarOfDate:(NSDate *)date {
    
    NSCalendar *chineseCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierChinese];
    NSDateComponents *components = [chineseCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    //NSString *dayDate;
    NSCalendar *normalDate = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *Datecomponents = [normalDate components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    
    if (components.day == 1 ) {
        _day = ChineseMonths[components.month - 1];
        
    } else {
        
        _day = ChineseDays[components.day - 1];
    }
    //农历节日
   
     if (components.day == 1 && components.month == 1) {
        _day = [NSString stringWithFormat:@"%@",ChineseFestival[1]];  //春节
     } if(components.month == 8 && components.day == 15){
         _day = [NSString stringWithFormat:@"%@",ChineseFestival[2]]; //中秋
     }else if(components.day == 1 && components.month == 1){
          _day = [NSString stringWithFormat:@"%@",ChineseFestival[0]];//除夕
     }else if(components.month == 7 && components.day == 7){
         _day = [NSString stringWithFormat:@"%@",ChineseFestival[7]]; //七夕
     }else if(components.month == 5 && components.day == 5){
         _day = [NSString stringWithFormat:@"%@",ChineseFestival[8]]; //端午
     }
    //阳历节日
    if (Datecomponents.month == 6 && Datecomponents.day == 1) {       //儿童节
        _day = [NSString stringWithFormat:@"%@",ChineseFestival[5]];
    }else if(Datecomponents.month == 10 && Datecomponents.day == 1){  //国庆节
        _day = [NSString stringWithFormat:@"%@",ChineseFestival[4]];
    }else if(Datecomponents.month == 5 && Datecomponents.day == 1){   //劳动节
        _day = [NSString stringWithFormat:@"%@",ChineseFestival[3]];
    }else if(Datecomponents.month == 12 && Datecomponents.day == 25){ //圣诞节
        _day = [NSString stringWithFormat:@"%@",ChineseFestival[6]];
    }
        

    [self getLunarSpecialDate:Datecomponents.year Month:Datecomponents.month Day:Datecomponents.day];
    //除夕 另外提出放在所有节日的末尾执行，除夕是在春节前一天，即把components当天时间前移一天，放在所有节日末尾，避免其他节日全部前移一天
    NSTimeInterval timeInterval_day = 60 * 60 * 24;
    NSDate *nextDay_date = [NSDate dateWithTimeInterval:timeInterval_day sinceDate:date];
    NSCalendar *localeCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |NSDayCalendarUnit;
    components = [localeCalendar components:unitFlags fromDate:nextDay_date];
    if ( 1 == components.month && 1 == components.day ) {
        return @"除夕";
    }
    return _day;
}

//24节气 只有(1901 - 2050)之间为准确的节气
const  int START_YEAR =1901;
const  int END_YEAR   =2050;

static int32_t gLunarHolDay[]=
{
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1901
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X87, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1902
    0X96, 0XA5, 0X87, 0X96, 0X87, 0X87, 0X79, 0X69, 0X69, 0X69, 0X78, 0X78,   //1903
    0X86, 0XA5, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X78, 0X87,   //1904
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1905
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1906
    0X96, 0XA5, 0X87, 0X96, 0X87, 0X87, 0X79, 0X69, 0X69, 0X69, 0X78, 0X78,   //1907
    0X86, 0XA5, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1908
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1909
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1910
    0X96, 0XA5, 0X87, 0X96, 0X87, 0X87, 0X79, 0X69, 0X69, 0X69, 0X78, 0X78,   //1911
    0X86, 0XA5, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1912
    0X95, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1913
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1914
    0X96, 0XA5, 0X97, 0X96, 0X97, 0X87, 0X79, 0X79, 0X69, 0X69, 0X78, 0X78,   //1915
    0X96, 0XA5, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //1916
    0X95, 0XB4, 0X96, 0XA6, 0X96, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X87,   //1917
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X77,   //1918
    0X96, 0XA5, 0X97, 0X96, 0X97, 0X87, 0X79, 0X79, 0X69, 0X69, 0X78, 0X78,   //1919
    0X96, 0XA5, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //1920
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X87,   //1921
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X77,   //1922
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X87, 0X79, 0X79, 0X69, 0X69, 0X78, 0X78,   //1923
    0X96, 0XA5, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //1924
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X87,   //1925
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1926
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X87, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1927
    0X96, 0XA5, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1928
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //1929
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1930
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X87, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1931
    0X96, 0XA5, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1932
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1933
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1934
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1935
    0X96, 0XA5, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1936
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1937
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1938
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1939
    0X96, 0XA5, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1940
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1941
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1942
    0X96, 0XA4, 0X96, 0X96, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1943
    0X96, 0XA5, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1944
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //1945
    0X95, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X77,   //1946
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1947
    0X96, 0XA5, 0XA6, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //1948
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X79, 0X78, 0X79, 0X77, 0X87,   //1949
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X77,   //1950
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X79, 0X79, 0X79, 0X69, 0X78, 0X78,   //1951
    0X96, 0XA5, 0XA6, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //1952
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //1953
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X78, 0X79, 0X78, 0X68, 0X78, 0X87,   //1954
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1955
    0X96, 0XA5, 0XA5, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //1956
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //1957
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1958
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1959
    0X96, 0XA4, 0XA5, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //1960
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1961
    0X96, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1962
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1963
    0X96, 0XA4, 0XA5, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //1964
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1965
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1966
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1967
    0X96, 0XA4, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //1968
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1969
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1970
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X79, 0X69, 0X78, 0X77,   //1971
    0X96, 0XA4, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //1972
    0XA5, 0XB5, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1973
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1974
    0X96, 0XB4, 0X96, 0XA6, 0X97, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X77,   //1975
    0X96, 0XA4, 0XA5, 0XB5, 0XA6, 0XA6, 0X88, 0X89, 0X88, 0X78, 0X87, 0X87,   //1976
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //1977
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X78, 0X87,   //1978
    0X96, 0XB4, 0X96, 0XA6, 0X96, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X77,   //1979
    0X96, 0XA4, 0XA5, 0XB5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //1980
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X77, 0X87,   //1981
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //1982
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X78, 0X79, 0X78, 0X69, 0X78, 0X77,   //1983
    0X96, 0XB4, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X87,   //1984
    0XA5, 0XB4, 0XA6, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //1985
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //1986
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X79, 0X78, 0X69, 0X78, 0X87,   //1987
    0X96, 0XB4, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86,   //1988
    0XA5, 0XB4, 0XA5, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //1989
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //1990
    0X95, 0XB4, 0X96, 0XA5, 0X86, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1991
    0X96, 0XB4, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86,   //1992
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //1993
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1994
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X76, 0X78, 0X69, 0X78, 0X87,   //1995
    0X96, 0XB4, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86,   //1996
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //1997
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //1998
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //1999
    0X96, 0XB4, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86,   //2000
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //2001
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //2002
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //2003
    0X96, 0XB4, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86,   //2004
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //2005
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //2006
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X69, 0X78, 0X87,   //2007
    0X96, 0XB4, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X87, 0X78, 0X87, 0X86,   //2008
    0XA5, 0XB3, 0XA5, 0XB5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //2009
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //2010
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X78, 0X87,   //2011
    0X96, 0XB4, 0XA5, 0XB5, 0XA5, 0XA6, 0X87, 0X88, 0X87, 0X78, 0X87, 0X86,   //2012
    0XA5, 0XB3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X87,   //2013
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //2014
    0X95, 0XB4, 0X96, 0XA5, 0X96, 0X97, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //2015
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X87, 0X88, 0X87, 0X78, 0X87, 0X86,   //2016
    0XA5, 0XC3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X87,   //2017
    0XA5, 0XB4, 0XA6, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //2018
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //2019
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X78, 0X87, 0X86,   //2020
    0XA5, 0XC3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86,   //2021
    0XA5, 0XB4, 0XA5, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //2022
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X79, 0X77, 0X87,   //2023
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X78, 0X87, 0X96,   //2024
    0XA5, 0XC3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86,   //2025
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //2026
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //2027
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X78, 0X87, 0X96,   //2028
    0XA5, 0XC3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86,   //2029
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //2030
    0XA5, 0XB4, 0X96, 0XA5, 0X96, 0X96, 0X88, 0X78, 0X78, 0X78, 0X87, 0X87,   //2031
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X78, 0X87, 0X96,   //2032
    0XA5, 0XC3, 0XA5, 0XB5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X86,   //2033
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X78, 0X88, 0X78, 0X87, 0X87,   //2034
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //2035
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X78, 0X87, 0X96,   //2036
    0XA5, 0XC3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X86,   //2037
    0XA5, 0XB3, 0XA5, 0XA5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //2038
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //2039
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X78, 0X87, 0X96,   //2040
    0XA5, 0XC3, 0XA5, 0XB5, 0XA5, 0XA6, 0X87, 0X88, 0X87, 0X78, 0X87, 0X86,   //2041
    0XA5, 0XB3, 0XA5, 0XB5, 0XA6, 0XA6, 0X88, 0X88, 0X88, 0X78, 0X87, 0X87,   //2042
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //2043
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X88, 0X87, 0X96,   //2044
    0XA5, 0XC3, 0XA5, 0XB4, 0XA5, 0XA6, 0X87, 0X88, 0X87, 0X78, 0X87, 0X86,   //2045
    0XA5, 0XB3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X88, 0X78, 0X87, 0X87,   //2046
    0XA5, 0XB4, 0X96, 0XA5, 0XA6, 0X96, 0X88, 0X88, 0X78, 0X78, 0X87, 0X87,   //2047
    0X95, 0XB4, 0XA5, 0XB4, 0XA5, 0XA5, 0X97, 0X87, 0X87, 0X88, 0X86, 0X96,   //2048
    0XA4, 0XC3, 0XA5, 0XA5, 0XA5, 0XA6, 0X97, 0X87, 0X87, 0X78, 0X87, 0X86,   //2049
    0XA5, 0XC3, 0XA5, 0XB5, 0XA6, 0XA6, 0X87, 0X88, 0X78, 0X78, 0X87, 0X87    //2050
    
};
-(NSString *)getLunarSpecialDate:(NSInteger)iYear Month:(NSInteger)iMonth  Day:(NSInteger)iDay  {
    
    NSArray *chineseDays=[NSArray arrayWithObjects:
                          @"小寒", @"大寒", @"立春", @"雨水", @"惊蛰", @"春分",
                          
                          @"清明", @"谷雨", @"立夏", @"小满", @"芒种", @"夏至",
                          
                          @"小暑", @"大暑", @"立秋", @"处暑", @"白露", @"秋分",
                          
                          @"寒露", @"霜降", @"立冬", @"小雪", @"大雪", @"冬至", nil];
    
    
    long array_index = (iYear - START_YEAR)*12+iMonth -1 ;
    
    
    int64_t flag = gLunarHolDay[array_index];
    int64_t day;
    
    if(iDay <15)
        day= 15 - ((flag>>4)&0x0f);
    else
        day = ((flag)&0x0f)+15;
    
    long index = -1;
    
    if(iDay == day){
        index = (iMonth-1) *2 + (iDay>15? 1: 0);
    }
    
    if ( index >= 0  && index < [chineseDays count] ) {
         [chineseDays objectAtIndex:index];
        //NSLog(@"%@",chineseDays[index]);
        _day = chineseDays[index];
        return _day;
        
        
    } else {
        return nil;
    }
    
}
#pragma mark - UICollectionDatasource数据源协议

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 42;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CalendarCell";
    DataCalendarCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.dayLabel.textColor = [UIColor blackColor];
    cell.chineseDayLabel.textColor = [UIColor grayColor];
    NSInteger firstWeekday = [self weekdayOfFirstDayInDate];
    NSInteger totalDaysOfMonth = [self totalDaysInMonthOfDate:self.date];
    NSInteger totalDaysOfLastMonth = [self totalDaysInMonthOfDate:[self previousMonthDate]];
    //在当前月份中显示上个月天数用灰色字体填满整个月份表
    //算法：
    //月份的头 如果当前cell的下标小于当前第一个cell的数值，则把字体设置灰色
    //月份的尾 同理如果当前的cell的下标大于等于当前cell + 当月起始日期的星期几，则把字体设置灰色
    
    if (indexPath.row < firstWeekday) {    // 小于这个月的第一天
        
        NSInteger day = totalDaysOfLastMonth - firstWeekday + indexPath.row + 1;
        cell.dayLabel.text = [NSString stringWithFormat:@"%ld ", day];
        cell.dayLabel.textColor = [UIColor grayColor];
        cell.chineseDayLabel.text = [self chineseCalendarOfDate:[self dateOfMonth:DataCalendarMonthPrevious WithDay:day]];
        
    } else if (indexPath.row >= totalDaysOfMonth + firstWeekday) {    // 大于这个月的最后一天
        NSInteger day = indexPath.row - totalDaysOfMonth - firstWeekday + 1;
        
        cell.dayLabel.text = [NSString stringWithFormat:@"%ld", day];
        cell.dayLabel.textColor = [UIColor grayColor];
        cell.chineseDayLabel.text = [self chineseCalendarOfDate:[self dateOfMonth:DataCalendarMonthNext WithDay:day]];
        
        
    } else {    // 属于这个月
        NSInteger day = indexPath.row - firstWeekday + 1;
        cell.dayLabel.text= [NSString stringWithFormat:@"%ld", day];
        
        if (day == [[NSCalendar currentCalendar] component:NSCalendarUnitDay fromDate:self.date]) {
            cell.backgroundColor = [UIColor blueColor];
            cell.layer.cornerRadius = cell.frame.size.height / 5;
            cell.dayLabel.textColor = [UIColor whiteColor];
            cell.chineseDayLabel.textColor = [UIColor whiteColor];
           
            
        }
      
        
        // 如果日期和当期日期同年同月不同天, 注：第一个判断中的方法是iOS8的新API, 会比较传入单元以及比传入单元大得单元上数据是否相等，同时传入Year和Month结果错误
        if ([[NSCalendar currentCalendar] isDate:[NSDate date] equalToDate:self.date toUnitGranularity:NSCalendarUnitMonth] && ![[NSCalendar currentCalendar] isDateInToday:self.date]) {
            
            // 将当前日期的那天高亮显示
            if (day == [[NSCalendar currentCalendar] component:NSCalendarUnitDay fromDate:[NSDate date]]) {
                cell.dayLabel.textColor = [UIColor greenColor];
            }
        }
        
        cell.chineseDayLabel.text = [self chineseCalendarOfDate:[self dateOfMonth:DataCalendarMonthCurrent WithDay:day]];
    }
    //周日 周六的日期显示红色
    if (indexPath.item % 7 == 6 || indexPath.item % 7 == 0) {
        cell.dayLabel.textColor = [UIColor redColor];
    }
    
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self.date];
    NSInteger firstWeekday = [self weekdayOfFirstDayInDate];
    [components setDay:indexPath.row - firstWeekday + 1];
    NSDate *selectedDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendarItem:didSelectedDate:)]) {
        [self.delegate calendarItem:self didSelectedDate:selectedDate];
    }
}


@end
