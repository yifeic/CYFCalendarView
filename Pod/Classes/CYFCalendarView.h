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
- (UIView *)calendarView:(CYFCalendarView *)calendarView viewForEvent:(id<CYFCalendarEvent>)event atIndex:(NSInteger)index;
- (UIView *)calendarView:(CYFCalendarView *)calendarView viewForEditableEvent:(id<CYFCalendarEvent>)event;

@optional
/// If startTime or endTime is nil, it's unchanged.
- (void)calendarView:(CYFCalendarView *)calendarView didChangeEventStartTime:(NSDate *)startTime endTime:(NSDate *)endTime;
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
@property (nonatomic) CGFloat eventViewTrailing;
@property (nonatomic) CGFloat eventViewLeading;
@property (nonatomic) CGFloat eventViewHandleSize;
@property (nonatomic, strong) UIFont *timeLabelFont;
@property (nonatomic, strong) UIColor *timeLabelColor;
@property (nonatomic, strong) UIColor *currentTimelineColor;

/// Array of CYFCalendarEvent.
@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSDate *day;
@property (nonatomic, strong) id<CYFCalendarEvent> editableEvent;

/// Event views properties. Set up these before calling reloadData.
@property (nonatomic, strong) UIColor *eventBackgroundColor;
@property (nonatomic, strong) UIColor *editableEventBackgroundColor;
@property (nonatomic, strong) UIColor *conflictEventBackgroundColor;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)scrollToEditableEventView;
- (void)reloadTimelines;
- (void)reloadEventViews;
- (void)reloadEditableEventView;
@end
