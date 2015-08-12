
@import UIKit;

typedef NS_ENUM(NSInteger, TransitionType) {
    RightToLeft      = 0, //default transition
    BottomToTop     = 1,
    StretchInOut    = 2,
    FadeInOut        = 3,
    FormSheet       = 4
};

@interface ZoomInOutAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic) BOOL isPresentation;
@property (nonatomic) NSInteger transitionType;
@property (nonatomic) CGRect initFrame;
@end

@interface DragToDismissTransitioning : NSObject <UIViewControllerInteractiveTransitioning>

- (id)initWithReferenceImageView:(UIImageView *)referenceImageView;

@end

@interface ZoomInOutTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate> {
    ZoomInOutAnimatedTransitioning *animationController;
}

@property (nonatomic, strong, readwrite) UIImageView *referenceImageView;

@property (nonatomic, strong, readwrite) UIImageView *referenceImageViewTop;

@property (nonatomic, strong, readwrite) UIImageView *referenceImageViewBottom;

@property UIPercentDrivenInteractiveTransition *interactionController;

@property DragToDismissTransitioning *dragToDismissTransitioning;


//@property (weak, nonatomic, readonly) UIScrollView *referenceImageScrollViewTop;
//
//@property (weak, nonatomic, readonly) UIScrollView *referenceImageScrollViewBottom;



// Initializes the receiver with the specified reference image views.
- (id)initWithReferenceImageScrollView:(UIImageView *)referenceImageView imageViewTop:(UIImageView *)referenceImageViewTop imageViewBottom:(UIImageView *)referenceImageViewBottom;

- (id)initWithReferenceImageView:(UIImageView *)referenceImageView;

- (id)initWithFrame:(CGRect)frame;

@end
