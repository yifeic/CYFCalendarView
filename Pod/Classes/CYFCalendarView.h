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

@property (nonatomic, weak) id<CYFCalendarViewDelegate> delegate;

/// Yes if any event overlaps with another.
@property (nonatomic, readonly) BOOL hasEventConflict;

/// Timeline and timeLabel propertyies. Set up these before calling reloadTimelines.
@property (nonatomic, strong) UIColor *timelineColor;
@property (nonatomic) CGFloat timelineHeight;
@property (nonatomic) CGFloat hourGapHeight;
@property (nonatomic) CGFloat timeLabelTrailingSpace;
@property (nonatomic) CGFloat timelineLeadingToSuperView;
@property (nonatomic, strong) UIFont *timeLabelFont;
@property (nonatomic, strong) UIColor *timeLabelColor;

/// Array of CYFCalendarEvent.
@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSDate *day;

/// Event views properties. Set up these before calling reloadData.
@property (nonatomic, strong) UIColor *eventBackgroundColor;
@property (nonatomic, strong) UIColor *editableEventBackgroundColor;
@property (nonatomic, strong) UIColor *conflictEventBackgroundColor;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)reloadEvents;
- (void)reloadTimelines;

@end
