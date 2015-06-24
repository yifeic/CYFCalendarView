//
//  CYFCalendarEvent.h
//  Pods
//
//  Created by Victor on 6/24/15.
//
//

#import <Foundation/Foundation.h>

@protocol CYFCalendarEvent <NSObject>

- (NSString *)title;
- (NSDate *)startAt;
- (NSDate *)endAt;
- (BOOL)editable;

@end
