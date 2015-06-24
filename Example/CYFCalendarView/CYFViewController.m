//
//  CYFViewController.m
//  CYFCalendarView
//
//  Created by yifeic on 06/24/2015.
//  Copyright (c) 2014 yifeic. All rights reserved.
//

#import "CYFViewController.h"
#import "CYFCalendarView.h"

@interface CYFViewController ()

@end

@implementation CYFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CYFCalendarView *calendarView = [[CYFCalendarView alloc] initWithEvents:nil day:[NSDate date]];
    calendarView.frame = CGRectMake(0, 64, 320, 400);
    calendarView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:calendarView];
    
}

@end
