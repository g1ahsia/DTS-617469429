
#import "PageViewPresentationController.h"
#import "MJRootViewController.h"
#import "MJAppDelegate.h"


@implementation PageViewPresentationController

- (instancetype)initWithPresentingViewController:(UIViewController *)presentingViewController presentedViewController:(UIViewController *)presentedViewController referenceImageView:(UIImageView *)referenceImageView imageViewTop:(UIImageView *)referenceImageViewTop imageViewBottom:(UIImageView *)referenceImageViewBottom
{
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        _referenceImageView = referenceImageView;
        _referenceImageViewTop = referenceImageViewTop;
        _referenceImageViewBottom = referenceImageViewBottom;
        pageVC = (PageViewController *)presentedViewController;
        
    }
    NSLog(@"presentation controller initiated");
    return self;
}

- (void)presentationTransitionWillBegin
{
    NSLog(@"Presentation transition will begin zoom in");
    [super presentationTransitionWillBegin];
    
    // Copying the image view
    
//    transitionImageContainerView = [[UIView alloc] initWithFrame:pageVC]
    
    transitionImageView = [[UIImageView alloc] initWithImage:_referenceImageView.image];
    transitionImageView.contentMode = UIViewContentModeScaleAspectFill;
    transitionImageView.layer.contentsRect = _referenceImageView.layer.contentsRect;
    [transitionImageView setClipsToBounds:YES];
    
    
//    transitionEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
//    transitionEffectView.alpha = 0;
    
    originalImageFrame = [[self containerView] convertRect:self.referenceImageView.bounds
                                             fromView:self.referenceImageView];
    
    // If presenting VC is MainView VC
//        _referenceTransformView = [self.referenceImageView subviews][1];
    [transitionImageView setFrame:originalImageFrame];
    transitionImageViewTop = [[UIImageView alloc] initWithImage:_referenceImageViewTop.image];
    transitionImageViewBottom = [[UIImageView alloc] initWithImage:_referenceImageViewBottom.image];
    [transitionImageViewTop setFrame:_referenceImageViewTop.frame];
    [transitionImageViewBottom setFrame:_referenceImageViewBottom.frame];
    
    pageVCImageHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? BOUNDS_WIDTH : BOUNDS_HEIGHT;
        
        /* Capturing the whole of content scrollview of pageVC */
        
//        UIGraphicsBeginImageContext(pageVC.contentScrollView.contentSize);
    
        // Reset the saved contentscrollview offset and frame
    
    [self addViewsToTransitionView];
    
    finalImageFrame = pageVC.imageView.frame;

    [[[self presentedViewController] transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
            [transitionImageView setFrame:finalImageFrame];
        
            [transitionImageViewTop setFrame:CGRectMake(0, -transitionImageViewTop.frame.size.height, [[self containerView] bounds].size.width,transitionImageViewTop.frame.size.height)];
            [transitionImageViewBottom setFrame:CGRectMake(0, [[self containerView] bounds].size.height, [[self containerView] bounds].size.width, transitionImageViewBottom.frame.size.height)];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context){

    }];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    // delay 1 second to avoid flash sympton
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (!isDismissing)
            [UIView animateWithDuration:0.4 animations:^{
                transitionImageView.alpha = 0;
            }];
    });
}

- (void)containerViewWillLayoutSubviews
{
    
    NSLog(@"container view will layout subviews");

}

- (void)containerViewDidLayoutSubviews
{
    NSLog(@"container view did layout subviews");
}

- (void)dismissalTransitionWillBegin
{
    [super dismissalTransitionWillBegin];
    
    isDismissing = YES;
    
    yOffSet = (pageVC.contentScrollView.contentOffset.y / 260) * 0.3;
    [self addViewsToTransitionView];
    
    finalImageFrame = pageVC.imageView.frame;
    
    transitionImageView.frame = CGRectOffset(pageVC.imageView.frame, 0, - pageVC.contentScrollView.contentOffset.y);
    //    [transitionImageView setFrame:CGRectOffset(finalImageFrame, 0, - pageVC.contentScrollView.contentOffset.y)];
    transitionImageView.layer.contentsRect = CGRectMake(0, - yOffSet, 1, 1);
    
    transitionImageView.alpha = 1;
//    transitionEffectView.alpha = pageVC.blurView.alpha;
    
    transitionImageView.image = pageVC.image;
    
    [[[self presentedViewController] transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            [transitionImageView setFrame:originalImageFrame];
//            [transitionEffectView setFrame:originalImageFrame];

            transitionImageView.layer.contentsRect = CGRectMake(0, 0, 1, 1);
            [transitionImageViewTop setFrame:_referenceImageViewTop.frame];
            [transitionImageViewBottom setFrame:_referenceImageViewBottom.frame];
        } completion:^(id<UIViewControllerTransitionCoordinatorContext> context){
            transitionImageView.alpha = 0;
    }];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
    isDismissing = NO;
}

- (void)addViewsToTransitionView
{
    [[self containerView] setBackgroundColor:[UIColor blackColor]];
    [[self containerView] addSubview:transitionImageView];
    [[self containerView] addSubview:transitionImageViewTop];
    [[self containerView] addSubview:transitionImageViewBottom];
}

#pragma mark - UIScrollViewdelegate methods

// Must return the content of the scroll view to zoom
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return transitionImageView;
}

- (ZoomInOutTransitioningDelegate *)transitioningDelegate
{
    return self.presentedViewController.transitioningDelegate;
}

#pragma mark - UIGestureRecognizers

- (void)presentedViewTapped:(UITapGestureRecognizer *)gesture
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
