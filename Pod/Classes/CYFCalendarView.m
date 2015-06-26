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
static const int SECONDS_IN_HOUR = SECONDS_IN_MINUTE*60;

@interface CYFCalendarView () {
    NSDate *_day;
}

@property (nonatomic, strong, readonly) NSArray *timelines;
@property (nonatomic, strong) NSArray *eventViews;
@property (nonatomic) CGFloat timelineHeight;
@property (nonatomic) CGFloat timelineLeadingToSuperView;
@property (nonatomic) CGFloat hourGapHeight;
@property (nonatomic) CGFloat minVerticalStep;
@property (nonatomic, strong) NSDate *beginOfDay;
@end

@implementation CYFCalendarView

@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat timelineHeight = 1;
        CGFloat timelineLeadingToSuperView = 80;
        UIColor *timelineColor = [UIColor blackColor];
        CGFloat hourGapHeight = 59;
        CGFloat timeLabelTrailingSpace = 0;
        _timelineHeight = timelineHeight;
        _timelineLeadingToSuperView = timelineLeadingToSuperView;
        _hourGapHeight = hourGapHeight;
        _minVerticalStep = (self.timelineHeight + self.hourGapHeight) / 4; // 15mins
        
        CGFloat halfGap = (hourGapHeight + timelineHeight) / 2;
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
    return self;
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
                    }
                }];
            UIEdgeInsets insets = UIEdgeInsetsMake(-draggableView.contentViewInsets.top, -draggableView.contentViewInsets.left, -draggableView.contentViewInsets.bottom, -draggableView.contentViewInsets.right);
            draggableView.frame = UIEdgeInsetsInsetRect(frame, insets);
            [self addSubview:draggableView];
            [eventViews addObject:draggableView];
        }
        else {
            eventView.frame = frame;
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
    return minutes / 60.0 * (self.timelineHeight+self.hourGapHeight);
}

- (NSDate *)_beginOfDay:(NSDate *)day {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnit)( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:day];
    components.second = 0;
    components.minute = 0;
    components.hour = 0;
    return [cal dateFromComponents:components];
}

@end
