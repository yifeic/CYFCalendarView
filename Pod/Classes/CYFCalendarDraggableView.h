//
//  CYFCalendarDraggableView.h
//  Pods
//
//  Created by Victor on 6/25/15.
//
//

#import <UIKit/UIKit.h>
@class CYFCalendarDraggableView;

typedef void(^CYFCalendarDraggableViewDragBlock)(CYFCalendarDraggableView *draggableView, UIGestureRecognizer *gesture);

@interface CYFCalendarDraggableView : UIView

@property (nonatomic, readonly) CGPoint dragBeginPointInSuperview;
@property (nonatomic, readonly) CGPoint dragBeginCenter;
@property (nonatomic, readonly) UIEdgeInsets contentViewInsets;
- (instancetype)initWithContentView:(UIView *)view onDrag:(CYFCalendarDraggableViewDragBlock)onDrag;

@end
