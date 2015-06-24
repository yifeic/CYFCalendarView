//
//  CYFCalendarView.h
//  Pods
//
//  Created by Victor on 6/24/15.
//
//

#import <UIKit/UIKit.h>
#import "CYFCalendarEvent.h"

@interface CYFCalendarView : UIScrollView

- (instancetype)initWithEvents:(NSArray *)events day:(NSDate *)day;

@end
