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
@property (nonatomic, readonly) CGRect dragBeginFrame;
@property (nonatomic, readonly) CGRect contentFrame;
@property (nonatomic, readonly) UIEdgeInsets contentViewInsets;
@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic) CGFloat handleSize;

- (instancetype)initWithContentView:(UIView *)view onDrag:(CYFCalendarDraggableViewDragBlock)onDrag onResizeTop:(CYFCalendarDraggableViewDragBlock)onResizeTop onResizeBottom:(CYFCalendarDraggableViewDragBlock)onResizeBottom;

@end
