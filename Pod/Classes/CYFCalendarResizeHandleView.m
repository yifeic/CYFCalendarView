//
//  CYFCalendarResizeHandleView.m
//  Pods
//
//  Created by Victor on 6/26/15.
//
//

#import "CYFCalendarResizeHandleView.h"

@implementation CYFCalendarResizeHandleView

- (instancetype)initWithHandleSize:(CGFloat)size
{
    self = [super initWithFrame:CGRectMake(0, 0, size, size)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIView *handle = [[UIView alloc] initWithFrame:CGRectZero];
        handle.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:handle];
        handle.backgroundColor = [UIColor whiteColor];
        handle.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
        handle.layer.cornerRadius = size/2;
        handle.layer.borderWidth = 1;
        
        NSArray *constraints = @[
            [NSLayoutConstraint constraintWithItem:handle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],
            [NSLayoutConstraint constraintWithItem:handle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0],
            [NSLayoutConstraint constraintWithItem:handle attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:size],
            [NSLayoutConstraint constraintWithItem:handle attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:size]
        ];
        
        [self addConstraints:constraints];
    }
    return self;
}

@end
