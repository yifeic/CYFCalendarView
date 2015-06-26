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
    CYFCalendarDraggableViewTouchAreaTopHandle,
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
@property (nonatomic, readonly) CGFloat handleSize;
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
        _handleSize = 10;
        _handleTouchSize = 44;
        _contentViewInsets = UIEdgeInsetsMake(self.handleTouchSize/2, 0, self.handleTouchSize/2, 0);
        
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
    CGFloat handleSize = self.handleTouchSize;
    CGFloat handleMargin = 0;
    
    CYFCalendarResizeHandleView *topHandle = [[CYFCalendarResizeHandleView alloc] initWithHandleSize:16];
    topHandle.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:topHandle];
    NSDictionary *viewDict = NSDictionaryOfVariableBindings(topHandle);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"|-%f-[topHandle(%f)]", handleMargin, handleSize] options:0 metrics:nil views:viewDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[topHandle(%f)]", handleSize] options:0 metrics:nil views:viewDict]];
    self.topResizeHandle = topHandle;
    
    CYFCalendarResizeHandleView *bottomHandle = [[CYFCalendarResizeHandleView alloc] initWithHandleSize:16];
    bottomHandle.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:bottomHandle];
    viewDict = NSDictionaryOfVariableBindings(bottomHandle);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"[bottomHandle(%f)]-%f-|", handleSize, handleMargin] options:0 metrics:nil views:viewDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[bottomHandle(%f)]|", handleSize] options:0 metrics:nil views:viewDict]];
    self.bottomResizeHandle = bottomHandle;
}

- (void)drag:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if ([self.topResizeHandle pointInside:[gesture locationInView:self.topResizeHandle] withEvent:nil]) {
            self.touchBeginArea = CYFCalendarDraggableViewTouchAreaTopHandle;
        }
        else if ([self.bottomResizeHandle pointInside:[gesture locationInView:self.bottomResizeHandle] withEvent:nil]) {
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
            case CYFCalendarDraggableViewTouchAreaTopHandle:
                self.onResizeTop(self, gesture);
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

@end
