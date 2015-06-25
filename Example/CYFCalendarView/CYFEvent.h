//
//  CYFEvent.h
//  CYFCalendarView
//
//  Created by Victor on 6/25/15.
//  Copyright (c) 2015 yifeic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYFCalendarEvent.h"

@interface CYFEvent : NSObject <CYFCalendarEvent>

@property (nonatomic, strong) NSDate *startAt;
@property (nonatomic, strong) NSDate *endAt;
@property (nonatomic) BOOL editable;

@end
