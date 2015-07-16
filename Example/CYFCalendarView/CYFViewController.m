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
@property (nonatomic, strong) CYFCalendarView *calView;
@end

@implementation CYFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CYFCalendarView *calendarView = [[CYFCalendarView alloc] initWithFrame:CGRectMake(0, 20, 320, 500)];
    [self.view addSubview:calendarView];
    

    calendarView.timeLabelTrailingSpace = 10;
    calendarView.eventViewTrailing = 10;
    calendarView.eventViewHandleSize = 10;
    calendarView.contentInset = UIEdgeInsetsMake(20, 0, 20, 0);
    CYFEvent *e1 = [CYFEvent new];
    e1.startAt = [NSDate date];
    e1.endAt = [e1.startAt dateByAddingTimeInterval:60*60];

    
    CYFEvent *e2 = [CYFEvent new];
    e2.startAt = [e1.endAt dateByAddingTimeInterval:60*60];
    e2.endAt = [e2.startAt dateByAddingTimeInterval:60*30];

    calendarView.delegate = self;
    
    calendarView.day = [NSDate date];
    calendarView.events = @[e2];
    calendarView.editableEvent = e1;
    
    [calendarView reloadTimelines];
    [calendarView reloadEventViews];
    [calendarView reloadEditableEventView];
    self.calView = calendarView;
}

- (UIView *)calendarView:(CYFCalendarView *)calendarView viewForEvent:(id<CYFCalendarEvent>)event atIndex:(NSInteger)index {
    UIView *v = [[UIView alloc] init];
    v.layer.cornerRadius = 3;
    v.layer.borderColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1.0].CGColor;
    v.layer.borderWidth = 1;
    return v;
}

- (UIView *)calendarView:(CYFCalendarView *)calendarView viewForEditableEvent:(id<CYFCalendarEvent>)event {
    UIView *v = [[UIView alloc] init];
    v.layer.cornerRadius = 3;
    return v;
}

- (void)calendarView:(CYFCalendarView *)calendarView didChangeEventStartTime:(NSDate *)startTime endTime:(NSDate *)endTime{
    NSLog(@"didChangeStartTime %@ of event", startTime);
    NSLog(@"didChangeEndTime %@ of event", endTime);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.calView scrollToEditableEventView];
}

@end
