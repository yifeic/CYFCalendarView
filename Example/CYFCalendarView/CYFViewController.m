//
//  CYFViewController.m
//  CYFCalendarView
//
//  Created by yifeic on 06/24/2015.
//  Copyright (c) 2014 yifeic. All rights reserved.
//

#import "CYFViewController.h"
#import "CYFCalendarView.h"
#import "CYFEvent.h"

@interface CYFViewController () <CYFCalendarViewDelegate>

@end

@implementation CYFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CYFCalendarView *calendarView = [[CYFCalendarView alloc] initWithFrame:CGRectMake(0, 64, 320, 400)];
    calendarView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:calendarView];
    
    CYFEvent *e1 = [CYFEvent new];
    e1.startAt = [NSDate date];
    e1.endAt = [e1.startAt dateByAddingTimeInterval:60*60];
    e1.editable = YES;
    
    CYFEvent *e2 = [CYFEvent new];
    e2.startAt = [e1.endAt dateByAddingTimeInterval:60*60];
    e2.endAt = [e2.startAt dateByAddingTimeInterval:60*30];
    
    calendarView.events = @[e1, e2];
    calendarView.day = [NSDate date];
    
    calendarView.delegate = self;
    
    [calendarView reloadData];
    
}

- (UIView *)calendarView:(CYFCalendarView *)calendarView viewForEvent:(id<CYFCalendarEvent>)event {
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [UIColor blueColor];
    
    return v;
}

@end
