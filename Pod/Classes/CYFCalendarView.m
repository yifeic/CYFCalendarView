//
//  CYFCalendarView.m
//  Pods
//
//  Created by Victor on 6/24/15.
//
//

#import "CYFCalendarView.h"

@interface CYFCalendarView ()
@property (nonatomic, strong, readonly) NSArray *timelines;
@end

@implementation CYFCalendarView

- (instancetype)initWithEvents:(NSArray *)events day:(NSDate *)day {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        CGFloat timelineHeight = 1;
        CGFloat timelineLeadingToSuperView = 80;
        UIColor *timelineColor = [UIColor blackColor];
        CGFloat gapHeight = 59;
        CGFloat timeLabelTrailingSpace = 0;
        
        CGFloat halfGap = (gapHeight + timelineHeight) / 2;
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = @"h:mma";
        
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:(NSCalendarUnit)( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:day];
        components.second = 0;
        components.minute = 0;
        components.hour = 0;
        NSDate *beginOfDay = [cal dateFromComponents:components];
        
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
                timeLabel.text = [timeFormatter stringFromDate:[beginOfDay dateByAddingTimeInterval:i*60*15]].lowercaseString;
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
@end
