//
//  CYFCalendarDraggableView.m
//  Pods
//
//  Created by Victor on 6/25/15.
//
//

#import "CYFCalendarDraggableView.h"

@interface CYFCalendarDraggableView ()
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong, readonly) CYFCalendarDraggableViewDragBlock onDrag;
@property (nonatomic, readwrite) CGPoint dragBeginPointInSuperview;
@property (nonatomic, readwrite) CGPoint dragBeginCenter;
@end

@implementation CYFCalendarDraggableView

- (instancetype)initWithContentView:(UIView *)view onDrag:(CYFCalendarDraggableViewDragBlock)onDrag
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor greenColor];
        _onDrag = onDrag;
        _contentViewInsets = UIEdgeInsetsMake(10, 0, 0, 0);
        
        [self addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *viewDict = NSDictionaryOfVariableBindings(view);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|" options:0 metrics:nil views:viewDict]];
        NSString *contentViewVFormat = [NSString stringWithFormat:@"V:|-%f-[view]-%f-|", self.contentViewInsets.top, self.contentViewInsets.bottom];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:contentViewVFormat options:0 metrics:nil views:viewDict]];
        
        _panGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
        _panGestureRecognizer.minimumPressDuration = 0;
        [self addGestureRecognizer:self.panGestureRecognizer];
        
        [self setupResizeHandle];
    }
    return self;
}

- (void)setupResizeHandle {
    UIView *handle = [[UIView alloc] initWithFrame:CGRectZero];
    handle.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:handle];
    handle.backgroundColor = [UIColor yellowColor];
    NSDictionary *viewDict = NSDictionaryOfVariableBindings(handle);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[handle(20)]" options:0 metrics:nil views:viewDict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[handle(20)]" options:0 metrics:nil views:viewDict]];
}

- (void)drag:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.dragBeginPointInSuperview = [gesture locationInView:self.superview];
        self.dragBeginCenter = self.center;
    }
    
    self.onDrag(self, gesture);
}

@end
