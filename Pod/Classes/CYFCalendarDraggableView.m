//
//  CYFCalendarDraggableView.m
//  Pods
//
//  Created by Victor on 6/25/15.
//
//

#import "CYFCalendarDraggableView.h"

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
@property (nonatomic, weak) UIView *topResizeHandle;
@property (nonatomic, weak) UIView *bottomResizeHandle;
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
        _contentViewInsets = UIEdgeInsetsMake(10, 0, 10, 0);
        
        _panGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
        _panGestureRecognizer.minimumPressDuration = 0;
        [self addGestureRecognizer:self.panGestureRecognizer];
        
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
    UIView *topHandle = [[UIView alloc] initWithFrame:CGRectZero];
    topHandle.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:topHandle];
    topHandle.backgroundColor = [UIColor yellowColor];
    NSDictionary *viewDict = NSDictionaryOfVariableBindings(topHandle);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[topHandle(20)]" options:0 metrics:nil views:viewDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topHandle(20)]" options:0 metrics:nil views:viewDict]];
    self.topResizeHandle = topHandle;
    
    UIView *bottomHandle = [[UIView alloc] initWithFrame:CGRectZero];
    bottomHandle.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:bottomHandle];
    bottomHandle.backgroundColor = [UIColor yellowColor];
    viewDict = NSDictionaryOfVariableBindings(bottomHandle);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[bottomHandle(20)]-10-|" options:0 metrics:nil views:viewDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomHandle(20)]|" options:0 metrics:nil views:viewDict]];
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

@end
