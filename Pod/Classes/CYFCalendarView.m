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

@interface CYFCalendarView () {
    NSDate *_day;
    id<CYFCalendarEvent> _editableEvent;
    NSArray *_events;
}

@property (nonatomic, strong, readonly) NSArray *timelines;
@property (nonatomic, strong) NSArray *eventViews;
@property (nonatomic, strong) CYFCalendarDraggableView *draggableEventView;
@property (nonatomic) CGFloat minVerticalStep;
@property (nonatomic, strong) NSDate *beginOfDay;
@property (nonatomic, readwrite) BOOL hasEventConflict;
@property (nonatomic, readonly) UIView *currentTimeline;
@property (nonatomic, strong) NSTimer *timer;
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
        _eventViewLeading = 0;
        _eventViewTrailing = 0;
        _currentTimelineColor = [UIColor redColor];
        _eventViewHandleSize = 10;
        
        // current timeline
        _currentTimeline = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_currentTimeline];
        self.currentTimeline.backgroundColor = self.currentTimelineColor;
        self.currentTimeline.hidden = YES;
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

- (void)startUpdatingCurrentTimeline {
    self.currentTimeline.hidden = NO;
    [self.timer invalidate];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    self.timer = timer;
    [self onTimer:timer];
}

- (void)stopUpdatingCurrentTimeline {
    self.currentTimeline.hidden = YES;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)onTimer:(NSTimer *)timer {
    CGFloat y = [self _yFromDate:[NSDate date]];
    self.currentTimeline.frame = CGRectMake(self.timelineLeadingToSuperView, y, self.frame.size.width-self.timelineLeadingToSuperView, self.timelineHeight);
}

- (void)reloadEventViews {
    NSAssert(self.events != nil, @"events property cannot be nil");
    NSAssert(self.day != nil, @"day property cannot be nil");
    
    for (UIView *view in self.eventViews) {
        [view removeFromSuperview];
    }
    self.eventViews = @[];
    
    if ([[NSCalendar currentCalendar] isDateInToday:self.day]) {
        [self startUpdatingCurrentTimeline];
    }
    else {
        [self stopUpdatingCurrentTimeline];
    }
    
    // non-editable events view
    NSMutableArray *eventViews = [NSMutableArray arrayWithCapacity:self.events.count];
    for (NSInteger i = 0; i < self.events.count; i++) {
        id<CYFCalendarEvent> event = self.events[i];
        
        CGFloat top = [self _yFromDate:event.startAt];
        CGFloat bottom = [self _yFromDate:event.endAt];
        
        UIView *eventView = [self.delegate calendarView:self viewForEvent:event atIndex:i];
        
        CGRect frame = CGRectMake(self.timelineLeadingToSuperView+self.eventViewLeading, top, 1, bottom-top);
        eventView.frame = frame;
        eventView.backgroundColor = self.eventBackgroundColor;
        [self addSubview:eventView];
        [eventViews addObject:eventView];
    }
    self.eventViews = eventViews;

    [self checkDraggableEventViewConflict];
}

- (void)setDay:(NSDate *)day {
    _day = day;
    self.beginOfDay = [self _beginOfDay:day];
}

- (NSDate *)day {
    return _day;
}

- (void)reloadEditableEventView {
    if (!self.editableEvent) {
        return;
    }
    
    [self.draggableEventView removeFromSuperview];
    self.draggableEventView = nil;
    
    CGFloat top = [self _yFromDate:self.editableEvent.startAt];
    CGFloat bottom = [self _yFromDate:self.editableEvent.endAt];
    
    UIView *eventView = [self.delegate calendarView:self viewForEditableEvent:self.editableEvent];
    
    CGRect frame = CGRectMake(self.timelineLeadingToSuperView+self.eventViewLeading, top, 1, bottom-top);

    @weakify(self)
    CYFCalendarDraggableView *draggableView =
    [[CYFCalendarDraggableView alloc]
        initWithContentView:eventView
        onDrag:^(CYFCalendarDraggableView *draggableView, UIGestureRecognizer *gesture) {
            @strongify(self)
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
                
                [self checkDraggableEventViewConflict];
                
                if ([self.delegate respondsToSelector:@selector(calendarView:didChangeEventStartTime:endTime:)]) {
                    CGFloat bottom = CGRectGetMaxY(draggableView.frame)-draggableView.contentViewInsets.bottom;
                    NSDate *startTime = [self _dateFromY:destTop];
                    NSDate *endTime = [self _dateFromY:bottom];
                    [self.delegate calendarView:self didChangeEventStartTime:startTime endTime:endTime];
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
                
                [self checkDraggableEventViewConflict];
                
                if ([self.delegate respondsToSelector:@selector(calendarView:didChangeEventStartTime:endTime:)]) {
                    NSDate *startTime = [self _dateFromY:destTop];
                    [self.delegate calendarView:self didChangeEventStartTime:startTime endTime:nil];
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
                
                [self checkDraggableEventViewConflict];
                
                if ([self.delegate respondsToSelector:@selector(calendarView:didChangeEventStartTime:endTime:)]) {
                    NSDate *endTime = [self _dateFromY:destBottom];
                    [self.delegate calendarView:self didChangeEventStartTime:nil endTime:endTime];
                }
            }
        }];
    UIEdgeInsets insets = UIEdgeInsetsMake(-draggableView.contentViewInsets.top, -draggableView.contentViewInsets.left, -draggableView.contentViewInsets.bottom, -draggableView.contentViewInsets.right);
    draggableView.frame = UIEdgeInsetsInsetRect(frame, insets);
    draggableView.contentView.backgroundColor = self.editableEventBackgroundColor;
    [self addSubview:draggableView];
    [self bringSubviewToFront:draggableView];
    self.draggableEventView = draggableView;
    self.draggableEventView.handleSize = self.eventViewHandleSize;
    
    [self checkDraggableEventViewConflict];
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

- (void)checkDraggableEventViewConflict {
    BOOL hasConflict = NO;
    if (self.draggableEventView && self.eventViews.count > 0) {
        CGRect thisFrame = self.draggableEventView.contentFrame;
        for (UIView *view in self.eventViews) {
            CGRect thatFrame = view.frame;
            if (CGRectIntersectsRect(thisFrame, thatFrame)) {
                hasConflict = YES;
                break;
            }
        }
        
        if (!self.currentTimeline.hidden && CGRectGetMinY(thisFrame) < CGRectGetMinY(self.currentTimeline.frame)) {
            hasConflict = YES;
        }
    }
    self.hasEventConflict = hasConflict;
    self.draggableEventView.contentView.backgroundColor = hasConflict ? self.conflictEventBackgroundColor : self.editableEventBackgroundColor;
}

- (void)scrollToEditableEventView {
    CGFloat top = CGRectGetMinY(self.draggableEventView.frame);
    CGFloat y = MAX(top - 50, -self.contentInset.top);
    y = MIN(y, self.contentSize.height-CGRectGetHeight(self.frame)+self.contentInset.bottom);
    self.contentOffset = CGPointMake(0, y);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSArray *subviews = self.eventViews;
    if (self.draggableEventView) {
        subviews = [subviews arrayByAddingObject:self.draggableEventView];
    }
    
    for (UIView *v in subviews) {
        CGRect frame = v.frame;
        CGFloat width = self.frame.size.width - frame.origin.x - self.eventViewTrailing;
        frame.size.width = width;
        v.frame = frame;
    }
}

@end
