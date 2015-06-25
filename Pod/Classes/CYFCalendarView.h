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
@end

@interface CYFCalendarView : UIScrollView

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSDate *day;
@property (nonatomic, weak) id<CYFCalendarViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)reloadData;

@end
