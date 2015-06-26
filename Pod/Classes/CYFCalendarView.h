//
//  CYFCalendarView.h
//  Pods
//
//  Created by Victor on 6/24/15.
//
//

#import <UIKit/UIKit.h>
#import "CYFCalendarEvent.h"
@class CYFCalendarView;

@protocol CYFCalendarViewDelegate <UIScrollViewDelegate>
@required
- (UIView *)calendarView:(CYFCalendarView *)calendarView viewForEvent:(id<CYFCalendarEvent>)event;
@optional
- (void)calendarView:(CYFCalendarView *)calendarView didChangeStartTime:(NSDate *)startTime ofEvent:(id<CYFCalendarEvent>)event atIndex:(NSInteger)index;
- (void)calendarView:(CYFCalendarView *)calendarView didChangeEndTime:(NSDate *)endTime ofEvent:(id<CYFCalendarEvent>)event atIndex:(NSInteger)index;
- (void)calendarView:(CYFCalendarView *)calendarView didChangeStartTime:(NSDate *)startTime endTime:(NSDate *)endTime ofEvent:(id<CYFCalendarEvent>)event atIndex:(NSInteger)index;
@end

@interface CYFCalendarView : UIScrollView

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSDate *day;
@property (nonatomic, weak) id<CYFCalendarViewDelegate> delegate;
@property (nonatomic, readonly) BOOL hasEventConflict;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)reloadData;

@end
