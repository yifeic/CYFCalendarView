//
//  CYFCalendarView.m
//  Pods
//
//  Created by Victor on 6/24/15.
//
//

#import "CYFCalendarView.h"
#import "CYFCalendarDraggableView.h"
#import "EXTScope.h"

static const int SECONDS_IN_MINUTE = 60;
static const int MINUTES_IN_HOUR = 60;
static const int SECONDS_IN_HOUR = SECONDS_IN_MINUTE*60;

@interface CYFCalendarView () {
    NSDate *_day;
}

@property (nonatomic, strong, readonly) NSArray *timelines;
@property (nonatomic, strong) NSArray *eventViews;
@property (nonatomic) CGFloat minVerticalStep;
@property (nonatomic, strong) NSDate *beginOfDay;
@property (nonatomic, readwrite) BOOL hasEventConflict;
@end

@implementation CYFCalendarView

@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _timelineHeight = 1;
        _timelineLeadingToSuperView = 80;
        _hourGapHeight = 59;
        _timelineColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1.0];
        _eventBackgroundColor = [UIColor whiteColor];
        _editableEventBackgroundColor =[UIColor colorWithRed:0.37f green:0.75f blue:1.00f alpha:1.00f];
        _conflictEventBackgroundColor = [UIColor redColor];
        _timeLabelTrailingSpace = 0;
    }
    return self;
}

- (void)reloadTimelines {
    CGFloat timelineHeight = self.timelineHeight;
    CGFloat timelineLeadingToSuperView = self.timelineLeadingToSuperView;
    UIColor *timelineColor = self.timelineColor;
    CGFloat hourGapHeight = self.hourGapHeight;
    self.minVerticalStep = (self.timelineHeight + self.hourGapHeight) / 4; // 15mins
    CGFloat timeLabelTrailingSpace = self.timeLabelTrailingSpace;
    CGFloat halfGap = (hourGapHeight + timelineHeight) / 2;
    
    for (UIView *v in self.timelines) {
        [v removeFromSuperview];
    }
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"h:mma";
    NSDate *beginOfDay = [self _beginOfDay:[NSDate date]];
    
    NSMutableArray *timelines = [NSMutableArray arrayWithCapacity:25*2];
    for (NSInteger i = 0; i < 25*2-1; i++) {
        CGFloat lineTop = i * halfGap;
        
        // configure timeline
        UIView *timeline = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:timeline];
        timeline.backgroundColor = timelineColor;
        
        // timeline constraints
        timeline.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *timelineDict = NSDictionaryOfVariableBindings(timeline);
        [self addConstraint:[NSLayoutConstraint constraintWithItem:timeline attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-timelineLeadingToSuperView]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"|-%f-[timeline]|", timelineLeadingToSuperView] options:0 metrics:nil views:timelineDict]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[timeline(%f)]", lineTop, timelineHeight] options:0 metrics:nil views:timelineDict]];
        [timelines addObject:timeline];
        
        if (i % 2 == 0) {
            // configure timeLabel
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
            timeLabel.font = self.timeLabelFont;
            timeLabel.textColor = self.timeLabelColor;
            [self addSubview:timeLabel];
            
            // timeLabel constraints
            timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
            timeLabel.text = [timeFormatter stringFromDate:[beginOfDay dateByAddingTimeInterval:i*SECONDS_IN_MINUTE*30]].lowercaseString;
            [self addConstraint:[NSLayoutConstraint constraintWithItem:timeLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:timeline attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:timeLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:timeline attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-timeLabelTrailingSpace]];
        }
    }
    
    // bottom constraint
    UIView *lastTimeline = timelines.lastObject;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:lastTimeline attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    _timelines = timelines;
}

- (void)reloadData {
    NSAssert(self.events != nil, @"events property cannot be nil");
    NSAssert(self.day != nil, @"day property cannot be nil");
    
    for (UIView *view in self.eventViews) {
        [view removeFromSuperview];
    }
    
    @weakify(self)
    
    NSMutableArray *eventViews = [NSMutableArray arrayWithCapacity:self.events.count];
    for (NSInteger i = 0; i < self.events.count; i++) {
        id<CYFCalendarEvent> event = self.events[i];
        
        CGFloat top = [self _yFromDate:event.startAt];
        CGFloat bottom = [self _yFromDate:event.endAt];
        
        UIView *eventView = [self.delegate calendarView:self viewForEvent:event];
        
        CGRect frame = CGRectMake(self.timelineLeadingToSuperView, top, self.bounds.size.width-self.timelineLeadingToSuperView, bottom-top);
        
        if (event.editable) {
            CYFCalendarDraggableView *draggableView =
            [[CYFCalendarDraggableView alloc]
                initWithContentView:eventView
                onDrag:^(CYFCalendarDraggableView *draggableView, UIGestureRecognizer *gesture) {
                    @strongify(self)
                    [self bringSubviewToFront:draggableView];
                    CGPoint newLocation = [gesture locationInView:self];
                    CGFloat dy = newLocation.y - draggableView.dragBeginPointInSuperview.y;
                    if (gesture.state == UIGestureRecognizerStateChanged) {
                        draggableView.center = CGPointMake(draggableView.dragBeginCenter.x, draggableView.dragBeginCenter.y+dy);
                    }
                    else {
                        CGFloat top = CGRectGetMinY(draggableView.dragBeginFrame) + dy + draggableView.contentViewInsets.top;
                        CGFloat destTop = roundf(top / self.minVerticalStep) * self.minVerticalStep;
                        dy += destTop - top;
                        draggableView.center = CGPointMake(draggableView.dragBeginCenter.x, draggableView.dragBeginCenter.y+dy);
                        
                        BOOL hasConflict = [self _hasConflictWithOtherEventViews:draggableView];
                        self.hasEventConflict = hasConflict;
                        draggableView.contentView.backgroundColor = hasConflict ? self.conflictEventBackgroundColor : self.editableEventBackgroundColor;
                        
                        if ([self.delegate respondsToSelector:@selector(calendarView:didChangeStartTime:endTime:ofEvent:atIndex:)]) {
                            CGFloat bottom = CGRectGetMaxY(draggableView.frame);
                            NSDate *startTime = [self _dateFromY:top];
                            NSDate *endTime = [self _dateFromY:bottom];
                            [self.delegate calendarView:self didChangeStartTime:startTime endTime:endTime ofEvent:event atIndex:i];
                        }
                    }
                }
                onResizeTop:^(CYFCalendarDraggableView *draggableView, UIGestureRecognizer *gesture) {
                    @strongify(self)
                    CGPoint newLocation = [gesture locationInView:self];
                    CGFloat dy = newLocation.y - draggableView.dragBeginPointInSuperview.y;
                    
                    dy = MIN(dy, CGRectGetHeight(draggableView.dragBeginFrame) - self.minVerticalStep - draggableView.contentViewInsets.top - draggableView.contentViewInsets.bottom);
                    
                    if (gesture.state == UIGestureRecognizerStateChanged) {
                        draggableView.frame = UIEdgeInsetsInsetRect(draggableView.dragBeginFrame, UIEdgeInsetsMake(dy, 0, 0, 0));
                    }
                    else {
                        CGFloat top = CGRectGetMinY(draggableView.dragBeginFrame) + dy + draggableView.contentViewInsets.top;
                        CGFloat destTop = roundf(top / self.minVerticalStep) * self.minVerticalStep;
                        dy += destTop - top;
                        draggableView.frame = UIEdgeInsetsInsetRect(draggableView.dragBeginFrame, UIEdgeInsetsMake(dy, 0, 0, 0));
                        
                        BOOL hasConflict = [self _hasConflictWithOtherEventViews:draggableView];
                        self.hasEventConflict = hasConflict;
                        draggableView.contentView.backgroundColor = hasConflict ? self.conflictEventBackgroundColor : self.editableEventBackgroundColor;
                        
                        if ([self.delegate respondsToSelector:@selector(calendarView:didChangeStartTime:ofEvent:atIndex:)]) {
                            NSDate *startTime = [self _dateFromY:destTop];
                            [self.delegate calendarView:self didChangeStartTime:startTime ofEvent:event atIndex:i];
                        }
                    }
                }
                onResizeBottom:^(CYFCalendarDraggableView *draggableView, UIGestureRecognizer *gesture) {
                    @strongify(self)
                    CGPoint newLocation = [gesture locationInView:self];
                    CGFloat dy = newLocation.y - draggableView.dragBeginPointInSuperview.y;
                    
                    dy = MAX(dy, -(CGRectGetHeight(draggableView.dragBeginFrame) - self.minVerticalStep - draggableView.contentViewInsets.top - draggableView.contentViewInsets.bottom));
                    
                    if (gesture.state == UIGestureRecognizerStateChanged) {
                        draggableView.frame = UIEdgeInsetsInsetRect(draggableView.dragBeginFrame, UIEdgeInsetsMake(0, 0, -dy, 0));
                    }
                    else {
                        CGFloat bottom = CGRectGetMaxY(draggableView.dragBeginFrame) + dy - draggableView.contentViewInsets.bottom;
                        CGFloat destBottom = roundf(bottom / self.minVerticalStep) * self.minVerticalStep;
                        dy += destBottom - bottom;
                        draggableView.frame = UIEdgeInsetsInsetRect(draggableView.dragBeginFrame, UIEdgeInsetsMake(0, 0, -dy, 0));
                        
                        BOOL hasConflict = [self _hasConflictWithOtherEventViews:draggableView];
                        self.hasEventConflict = hasConflict;
                        draggableView.contentView.backgroundColor = hasConflict ? self.conflictEventBackgroundColor : self.editableEventBackgroundColor;
                        
                        if ([self.delegate respondsToSelector:@selector(calendarView:didChangeEndTime:ofEvent:atIndex:)]) {
                            NSDate *endTime = [self _dateFromY:destBottom];
                            [self.delegate calendarView:self didChangeEndTime:endTime ofEvent:event atIndex:i];
                        }
                    }
                }];
            UIEdgeInsets insets = UIEdgeInsetsMake(-draggableView.contentViewInsets.top, -draggableView.contentViewInsets.left, -draggableView.contentViewInsets.bottom, -draggableView.contentViewInsets.right);
            draggableView.frame = UIEdgeInsetsInsetRect(frame, insets);
            draggableView.contentView.backgroundColor = self.editableEventBackgroundColor;
            [self addSubview:draggableView];
            [eventViews addObject:draggableView];
        }
        else {
            eventView.frame = frame;
            eventView.backgroundColor = self.eventBackgroundColor;
            [self addSubview:eventView];
            [eventViews addObject:eventView];
        }
        
    }
    self.eventViews = eventViews;
}

- (void)setDay:(NSDate *)day {
    _day = day;
    self.beginOfDay = [self _beginOfDay:day];
}

- (NSDate *)day {
    return _day;
}

- (CGFloat)_yFromDate:(NSDate *)date {
    NSTimeInterval interval = [date timeIntervalSinceDate:self.beginOfDay];
    NSInteger minutes = interval / SECONDS_IN_MINUTE;
    return (float)minutes / MINUTES_IN_HOUR * (self.timelineHeight+self.hourGapHeight);
}

- (NSDate *)_dateFromY:(CGFloat)y {
    NSInteger minutes = y / (self.timelineHeight+self.hourGapHeight) * MINUTES_IN_HOUR;
    return [self.beginOfDay dateByAddingTimeInterval:minutes*SECONDS_IN_MINUTE];
}

- (NSDate *)_beginOfDay:(NSDate *)day {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnit)( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:day];
    components.second = 0;
    components.minute = 0;
    components.hour = 0;
    return [cal dateFromComponents:components];
}

- (BOOL)_hasConflictWithOtherEventViews:(CYFCalendarDraggableView *)draggableView {
    for (UIView *view in self.eventViews) {
        if (view != draggableView) {
            CGRect thisFrame = draggableView.contentFrame;
            CGRect thatFrame = [view isKindOfClass:[CYFCalendarDraggableView class]] ? [(CYFCalendarDraggableView *)view contentFrame] : view.frame;
            if (CGRectIntersectsRect(thisFrame, thatFrame)) {
                return YES;
            }
        }
    }
    return NO;
}

@end
