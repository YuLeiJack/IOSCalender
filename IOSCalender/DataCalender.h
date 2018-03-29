//
//  DataCalender.h
//  IOSCalender
//
//  Created by 于磊 on 16/5/8.
//  Copyright © 2016年 于磊. All rights reserved.
//

#import <UIKit/UIKit.h>
#define DeviceWidth [UIScreen mainScreen].bounds.size.width

@protocol DataCalenderItemDelegate;

@interface DataCalender : UIView
@property (strong , nonatomic) NSDate *date;
@property (weak , nonatomic) id<DataCalenderItemDelegate> delegate;
@property (strong , nonatomic) NSString *day;
@property (strong , nonatomic) NSString *chineseWeatherDay;
- (NSDate *) nextMonthDate;
- (NSDate *) previousMonthDate;


@end
@protocol DataCalenderItemDelegate <NSObject>

- (void)calendarItem:(DataCalender *)item didSelectedDate:(NSDate *)date;

@end

