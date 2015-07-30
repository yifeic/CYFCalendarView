//
//  CYFCalendarDraggableView.m
//  Pods
//
//  Created by Victor on 6/25/15.
//
//

#import "CYFCalendarDraggableView.h"
#import "CYFCalendarResizeHandleView.h"

typedef NS_ENUM(NSUInteger, CYFCalendarDraggableViewTouchArea) {
    CYFCalendarDraggableViewTouchAreaContent,
    CYFCalendarDraggableViewTouchAreaBottomHandle,
};

@interface CYFCalendarDraggableView ()
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong, readonly) CYFCalendarDraggableViewDragBlock onDrag;
@property (nonatomic, strong, readonly) CYFCalendarDraggableViewDragBlock onResizeTop;
@property (nonatomic, strong, readonly) CYFCalendarDraggableViewDragBlock onResizeBottom;
@property (nonatomic, readwrite) CGPoint dragBeginPointInSuperview;
@property (nonatomic, readwrite) CGPoint dragBeginCenter;
@property (nonatomic, readwrite) CGRect dragBeginFrame;
@property (nonatomic, readonly) CGFloat handleTouchSize;
@property (nonatomic, weak) CYFCalendarResizeHandleView *topResizeHandle;
@property (nonatomic, weak) CYFCalendarResizeHandleView *bottomResizeHandle;
@property (nonatomic) CYFCalendarDraggableViewTouchArea touchBeginArea;
@end

@implementation CYFCalendarDraggableView

- (instancetype)initWithContentView:(UIView *)view onDrag:(CYFCalendarDraggableViewDragBlock)onDrag onResizeTop:(CYFCalendarDraggableViewDragBlock)onResizeTop onResizeBottom:(CYFCalendarDraggableViewDragBlock)onResizeBottom
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _onDrag = onDrag;
        _onResizeTop = onResizeTop;
        _onResizeBottom = onResizeBottom;
        _handleTouchSize = 44;
        _contentViewInsets = UIEdgeInsetsMake(0, 0, self.handleTouchSize/2, 0);
        
        _panGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
        _panGestureRecognizer.minimumPressDuration = 0;
        [self addGestureRecognizer:self.panGestureRecognizer];
        
        _contentView = view;
        [self setupContentView:view];
        [self setupResizeHandle];
    }
    return self;
}

- (void)setupContentView:(UIView *)view {
    [self addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewDict = NSDictionaryOfVariableBindings(view);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|" options:0 metrics:nil views:viewDict]];
    NSString *contentViewVFormat = [NSString stringWithFormat:@"V:|-%f-[view]-%f-|", self.contentViewInsets.top, self.contentViewInsets.bottom];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:contentViewVFormat options:0 metrics:nil views:viewDict]];
}

- (void)setupResizeHandle {
    CGFloat handleTouchSize = self.handleTouchSize;
    CGFloat handleMargin = 0;
    
//    CYFCalendarResizeHandleView *topHandle = [[CYFCalendarResizeHandleView alloc] initWithFrame:CGRectZero];
//    topHandle.translatesAutoresizingMaskIntoConstraints = NO;
//    [self addSubview:topHandle];
//    NSDictionary *viewDict = NSDictionaryOfVariableBindings(topHandle);
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"|-%f-[topHandle(%f)]", handleMargin, handleTouchSize] options:0 metrics:nil views:viewDict]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[topHandle(%f)]", handleTouchSize] options:0 metrics:nil views:viewDict]];
//    self.topResizeHandle = topHandle;
    
    CYFCalendarResizeHandleView *bottomHandle = [[CYFCalendarResizeHandleView alloc] initWithFrame:CGRectZero];
    bottomHandle.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:bottomHandle];
    NSDictionary *viewDict = NSDictionaryOfVariableBindings(bottomHandle);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"[bottomHandle(%f)]-%f-|", handleTouchSize, handleMargin] options:0 metrics:nil views:viewDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[bottomHandle(%f)]|", handleTouchSize] options:0 metrics:nil views:viewDict]];
    self.bottomResizeHandle = bottomHandle;
}

- (void)drag:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if ([self.bottomResizeHandle pointInside:[gesture locationInView:self.bottomResizeHandle] withEvent:nil]) {
            self.touchBeginArea = CYFCalendarDraggableViewTouchAreaBottomHandle;
        }
        else {
            self.touchBeginArea = CYFCalendarDraggableViewTouchAreaContent;
        }
        
        self.dragBeginPointInSuperview = [gesture locationInView:self.superview];
        self.dragBeginCenter = self.center;
        self.dragBeginFrame = self.frame;
    }
    else {
        switch (self.touchBeginArea) {
            case CYFCalendarDraggableViewTouchAreaContent:
                self.onDrag(self, gesture);
                break;
            case CYFCalendarDraggableViewTouchAreaBottomHandle:
                self.onResizeBottom(self, gesture);
                break;
        }
    }
}

- (CGRect)contentFrame {
    return UIEdgeInsetsInsetRect(self.frame, self.contentViewInsets);
}

- (void)setHandleSize:(CGFloat)handleSize {
    self.topResizeHandle.handleSize = handleSize;
    self.bottomResizeHandle.handleSize = handleSize;
}

- (CGFloat)handleSize {
    return self.topResizeHandle.handleSize;
}

@end
