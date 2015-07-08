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
    
    CYFCalendarView *calendarView = [[CYFCalendarView alloc] initWithFrame:CGRectMake(0, 20, 320, 568)];
    [self.view addSubview:calendarView];
    

    calendarView.timeLabelTrailingSpace = 10;
    calendarView.eventViewTrailing = 10;
    
    CYFEvent *e1 = [CYFEvent new];
    e1.startAt = [NSDate date];
    e1.endAt = [e1.startAt dateByAddingTimeInterval:60*60];
    e1.editable = YES;
    
    CYFEvent *e2 = [CYFEvent new];
    e2.startAt = [e1.endAt dateByAddingTimeInterval:60*60];
    e2.endAt = [e2.startAt dateByAddingTimeInterval:60*30];
//    e2.editable = YES;
    
    calendarView.events = @[e1, e2];
    calendarView.day = [NSDate date];
    
    calendarView.delegate = self;
    
    [calendarView reloadTimelines];
    [calendarView reloadEvents];
    
}

- (UIView *)calendarView:(CYFCalendarView *)calendarView viewForEvent:(id<CYFCalendarEvent>)event {
    UIView *v = [[UIView alloc] init];
    
    if ([(CYFEvent *)event editable]) {
    }
    else {
        v.layer.borderColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1.0].CGColor;
        v.layer.borderWidth = 1;
    }
    v.layer.cornerRadius = 3;
    
    return v;
}

- (void)calendarView:(CYFCalendarView *)calendarView didChangeStartTime:(NSDate *)startTime ofEvent:(id<CYFCalendarEvent>)event atIndex:(NSInteger)index {
    NSLog(@"didChangeStartTime %@ of event at index %ld", startTime, index);
}

- (BOOL)calendarView:(CYFCalendarView *)calendarView canEditEvent:(id<CYFCalendarEvent>)event atIndex:(NSInteger)index {
    return [(CYFEvent *)event editable];
}

@end
