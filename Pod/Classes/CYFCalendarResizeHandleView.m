//
//  CYFCalendarResizeHandleView.m
//  Pods
//
//  Created by Victor on 6/26/15.
//
//

#import "CYFCalendarResizeHandleView.h"

@interface CYFCalendarResizeHandleView () {
    CGFloat _handleSize;
}

@property (nonatomic, strong, readonly) UIView *handleView;
@property (nonatomic, strong, readonly) NSLayoutConstraint *widthConstraint;
@property (nonatomic, strong, readonly) NSLayoutConstraint *heightConstraint;

@end

@implementation CYFCalendarResizeHandleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _handleSize = 10;
        self.backgroundColor = [UIColor clearColor];
        UIView *handle = [[UIView alloc] initWithFrame:CGRectZero];
        handle.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:handle];
        handle.backgroundColor = [UIColor whiteColor];
        handle.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1.0].CGColor;
        handle.layer.cornerRadius = self.handleSize/2;
        handle.layer.borderWidth = 1;
        _handleView = handle;
        
        _widthConstraint = [NSLayoutConstraint constraintWithItem:handle attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.handleSize];
        _heightConstraint = [NSLayoutConstraint constraintWithItem:handle attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.handleSize];
        
        NSArray *constraints = @[
            [NSLayoutConstraint constraintWithItem:handle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0],
            [NSLayoutConstraint constraintWithItem:handle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0],
            self.widthConstraint,
            self.heightConstraint
        ];
        
        [self addConstraints:constraints];
    }
    return self;
}

- (void)setHandleSize:(CGFloat)handleSize {
    _handleSize = handleSize;
    self.handleView.layer.cornerRadius = handleSize/2;
    self.widthConstraint.constant = handleSize;
    self.heightConstraint.constant = handleSize;
}

- (CGFloat)handleSize {
    return _handleSize;
}

@end
