//
//  ViewController.m
//  IOSCalender
//
//  Created by 于磊 on 16/5/6.
//  Copyright © 2016年 于磊. All rights reserved.
//

#import "ViewController.h"
#import "UICalender.h"

@interface ViewController ()
@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UICalender * calender = [[UICalender alloc]initWithCurrentDate:[NSDate date]];
    CGRect frame = calender.frame;
    frame.origin.y = 20;
    calender.frame = frame;
    [self.view addSubview:calender];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
