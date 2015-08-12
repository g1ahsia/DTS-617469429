/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 
  AAPLCoolAnimatedTransitioning and AAPLCoolTransitioningDelegate implementations.
  
 */

#import "ZoomInOutTransitioner.h"
#import "PageViewPresentationController.h"
#import "PageViewController.h"
#import "MJRootViewController.h"

@implementation ZoomInOutTransitioningDelegate

// Strech in and out animation
- (id)initWithReferenceImageScrollView:(UIImageView *)referenceImageView imageViewTop:(UIImageView *)referenceImageViewTop imageViewBottom:(UIImageView *)referenceImageViewBottom {
    if (self = [super init]) {
//        NSAssert(referenceImageScrollView.contentMode == UIViewContentModeScaleAspectFill, @"*** referenceImageView must have a UIViewContentModeScaleAspectFill contentMode!");
        _referenceImageView = referenceImageView;
        _referenceImageViewTop = referenceImageViewTop;
        _referenceImageViewBottom = referenceImageViewBottom;
        
         NSLog(@"page view presentation initiated");
    }
    return self;
}

- (id)initWithReferenceImageView:(UIImageView *)referenceImageView {
    if (self = [super init]) {
        NSAssert(referenceImageView.contentMode == UIViewContentModeScaleAspectFill, @"*** referenceImageView must have a UIViewContentModeScaleAspectFill contentMode!");
        _referenceImageView = referenceImageView;
        NSLog(@"page view presentation initiated");
    }
    return self;
}

// Swing in and out animation
- (id)initWithFrame:(CGRect)frame {
    if (self = [super init]) {
        animationController = [self animationController];
        [animationController setInitFrame:frame];
        NSLog(@"frame %f %f", frame.size.width, frame.size.height);
    }
    return  self;
}

- (ZoomInOutAnimatedTransitioning *)animationController
{
    if (!animationController) {
        animationController = [[ZoomInOutAnimatedTransitioning alloc] init];
        NSLog(@"animationController initialized");
    }
    return animationController;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    animationController = [self animationController];
    NSLog(@"presentation prepared");
    PageViewPresentationController *pagePC = [[PageViewPresentationController alloc] initWithPresentingViewController:presenting presentedViewController:presented referenceImageView:_referenceImageView imageViewTop:_referenceImageViewTop imageViewBottom:_referenceImageViewBottom];
    return pagePC;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    
    animationController = [self animationController];
    [animationController setIsPresentation:YES];
    [animationController setTransitionType:StretchInOut];

    return animationController;
}

//#pragma mark UINavigationControllerDelegate methods
//
//- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
//                                  animationControllerForOperation:(UINavigationControllerOperation)operation
//                                               fromViewController:(UIViewController *)fromVC
//                                                 toViewController:(UIViewController *)toVC
//{
//    animationController = [self animationController];
//    [animationController setIsPresentation:YES];
//
//    return animationController;
//}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    animationController = [self animationController];
    [animationController setIsPresentation:NO];
    NSLog(@"animationController dismissed");
    
    return animationController;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
{
    NSLog(@"return interaction controller for presentation");
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    NSLog(@"return interaction controller for dismissal");
    return self.interactionController;
}

@end

@implementation ZoomInOutAnimatedTransitioning


- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    if ([self transitionType] == RightToLeft) {
        if ([self isPresentation])
            return 0.4;
        else
            return 0.4;
    }
    else {
        if ([self isPresentation])
            return 0.6;
        else
            return 0.9;
    }
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    // Right to Left transition
    if ([self transitionType] == RightToLeft) {
        [self animateRightToLeftTransition:transitionContext];
    }
    // Bottom to Top transition
    else if ([self transitionType] == BottomToTop) {
        [self animateBottomToTopTransition:transitionContext];
    }
    // Page view stretch in out effect
    else if ([self transitionType] == StretchInOut) {
        [self animateStrechTransition:transitionContext];
    }
    else if ([self transitionType] == FadeInOut) {
        [self animateFadeInOutTransition:transitionContext];
    }
    else if ([self transitionType] == FormSheet) {
        [self animateFormSheetTransition:transitionContext];
    }
}

#pragma helper transition methods

- (void)animateStrechTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    BOOL isPresentation = [self isPresentation];
    
    UIViewController *animatingVC = isPresentation? toVC : fromVC;
    UIView *animatingView = [animatingVC view];
    
    // add the transitionView to the transition
    
    if ([self isPresentation]) {
        animatingView.alpha = 0.0;
        [containerView addSubview:animatingView];
    }
    else {
        animatingView.alpha = 0.0; // for dismisal, hide the fromVC
    }
        
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:1.0
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
//                         if (![self isPresentation])
//                             [((PageViewController *)animatingVC).contentScrollView setContentOffset:CGPointMake(0, 0)];
                     }
                     completion:^(BOOL finished){
                         if ([self isPresentation]) {
////                            toVC.view.alpha = 0; // fade in effect
                            [UIView animateWithDuration:0.3f animations:^{
                                animatingView.alpha = 1.0;
//                            }
//                            completion:^(BOOL finished){
                                [transitionContext completeTransition:YES];
                            }];
                         }
                         else if (!transitionContext.transitionWasCancelled) {
                             [transitionContext completeTransition:YES];
                         }
                         else {
                             [UIView animateWithDuration:0.3f animations:^{
                                 animatingView.alpha = 1.0;
                                 [transitionContext completeTransition:NO];
                             }];
                         }
                     }];
    
}

//- (void)animateSwingTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
//    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    
//    UIView *containerView = [transitionContext containerView];
//    
//    BOOL isPresentation = [self isPresentation];
//    
//    UIViewController *animatingVC = isPresentation? toVC : fromVC;
//    UIView *animatingView = [animatingVC view];
//    CGAffineTransform presentedTransform = CGAffineTransformIdentity;
//    CGAffineTransform dismissedTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.1, 0.1), CGAffineTransformMakeRotation(8 * M_PI));
//    CGRect presentedFrame = [transitionContext finalFrameForViewController:animatingVC];
////    CGRect presentedFrame = CGRectMake(0, 0, 90, 90);
//    CGRect dismissedFrame = [self initFrame];
//    [animatingView setTransform:isPresentation ? dismissedTransform : presentedTransform];
//    [animatingView setFrame:isPresentation ? dismissedFrame : presentedFrame];
//    [animatingView setAlpha:isPresentation ? 0 : 1];
//    
//    if([self isPresentation])
//        [containerView addSubview:animatingView];
//    else {
//        // To overwrite the blank chrome view
//        [containerView addSubview:toVC.view];
//        [containerView sendSubviewToBack:toVC.view];
//    }
//    
//    [UIView animateWithDuration:[self transitionDuration:transitionContext]
//                          delay:0
//         usingSpringWithDamping:0.7
//          initialSpringVelocity:0.0
//                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
//                     animations:^{
//                        [animatingView setTransform:isPresentation ? presentedTransform : dismissedTransform];
//                        [animatingView setFrame:isPresentation ? presentedFrame : dismissedFrame];
//                        [animatingView setAlpha:isPresentation ? 1 : 0];
//                     }
//                     completion:^(BOOL finished){
//                        if(!isPresentation)
//                            [fromVC.view removeFromSuperview];
//                         
//                         [transitionContext completeTransition:YES];
//                     }];
//}

- (void)animateFadeInOutTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    
    BOOL isPresentation = [self isPresentation];
    
    UIViewController *animatingVC = isPresentation? toVC : fromVC;
    UIView *animatingView = [animatingVC view];
    if ([self isPresentation])
        [containerView addSubview:toVC.view];
    else
        [animatingView removeFromSuperview];
    
    [animatingView setAlpha:isPresentation ? 0 : 1];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:1.0
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [animatingView setAlpha:isPresentation ? 1 : 0];
                     }
                     completion:^(BOOL finished){
                         if (![self isPresentation])
                             [animatingView removeFromSuperview];
                         [transitionContext completeTransition:YES];
                     }];
}

- (void)animateRightToLeftTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    BOOL isPresentation = [self isPresentation];
    
    UIViewController *animatingVC = isPresentation? toVC : fromVC;
    UIViewController *dismissingVC = isPresentation? fromVC : toVC;
    UIView *animatingView = [animatingVC view];
    UIView *dismissingView = [dismissingVC view];
    
    CGAffineTransform presentedTransform = CGAffineTransformIdentity;
    CGAffineTransform dismissedTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.9, 0.9), CGAffineTransformMakeRotation(8 * M_PI));
    CGRect presentedFrame = [transitionContext finalFrameForViewController:animatingVC];
//    CGRect presentedFrame = CGRectMake(0, 0, BOUNDS_WIDTH, BOUNDS_HEIGHT);
    CGRect dismissedFrame = CGRectMake(BOUNDS_WIDTH, 0, BOUNDS_WIDTH, BOUNDS_HEIGHT);
    [animatingView setFrame:isPresentation ? dismissedFrame : presentedFrame];
    [animatingView setAlpha:isPresentation ? 0 : 1];
    
    [dismissingView setTransform:isPresentation ? presentedTransform : dismissedTransform];
    [dismissingView setAlpha:isPresentation ? 1 : 0.5];

    if([self isPresentation]) {
        [containerView addSubview:animatingView];
    }
    else {
        // To overwrite the blank chrome view
        [containerView addSubview:toVC.view];
        [containerView sendSubviewToBack:toVC.view];
        
        UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:dismissingView];
        
        UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[dismissingView]];
        gravity.gravityDirection = CGVectorMake(1.0, 0);
        [animator addBehavior:gravity];
    }
    
//    [UIView animateWithDuration:[self transitionDuration:transitionContext]
//                          delay:0
//         usingSpringWithDamping:1.0
//          initialSpringVelocity:0.0
//                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
//                     animations:^{
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
//                         [animatingView setTransform:isPresentation ? presentedTransform : dismissedTransform];
                         [animatingView setFrame:isPresentation ? presentedFrame : dismissedFrame];
                         [animatingView setAlpha:isPresentation ? 1 : 0];
                         [dismissingView setTransform:isPresentation ? dismissedTransform : presentedTransform];
                         [dismissingView setAlpha:isPresentation ? 0.5 : 1];
                     }
                     completion:^(BOOL finished){
                         if ([self isPresentation]) {
                             [transitionContext completeTransition:YES];
                         }
                         else if (!transitionContext.transitionWasCancelled) {
                             [transitionContext completeTransition:YES];
                         }
                         else {
                             [transitionContext completeTransition:NO];
                         }
    }];
}

- (void)animateBottomToTopTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    BOOL isPresentation = [self isPresentation];
    
    UIViewController *animatingVC = isPresentation? toVC : fromVC;
    UIViewController *dismissingVC = isPresentation? fromVC : toVC;
    UIView *animatingView = [animatingVC view];
    UIView *dismissingView = [dismissingVC view];
    
    CGAffineTransform presentedTransform = CGAffineTransformIdentity;
    CGAffineTransform dismissedTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.9, 0.9), CGAffineTransformMakeRotation(8 * M_PI));
    CGRect presentedFrame = [transitionContext finalFrameForViewController:animatingVC];
    CGRect dismissedFrame = CGRectMake(0, BOUNDS_HEIGHT, BOUNDS_WIDTH, BOUNDS_HEIGHT);
    //    [animatingView setTransform:isPresentation ? dismissedTransform : presentedTransform];
    [animatingView setFrame:isPresentation ? dismissedFrame : presentedFrame];
    [animatingView setAlpha:isPresentation ? 0 : 1];
    
    [dismissingView setTransform:isPresentation ? presentedTransform : dismissedTransform];
    [dismissingView setAlpha:isPresentation ? 1 : 0.5];
    
    if([self isPresentation]) {
        [containerView addSubview:animatingView];
    }
    else {
        // To overwrite the blank chrome view
//        [containerView addSubview:toVC.view];
//        [containerView sendSubviewToBack:toVC.view];
        
        UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:dismissingView];
        
        UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[dismissingView]];
        gravity.gravityDirection = CGVectorMake(1.0, 0);
        [animator addBehavior:gravity];
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:1.0
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         //                         [animatingView setTransform:isPresentation ? presentedTransform : dismissedTransform];
                         [animatingView setFrame:isPresentation ? presentedFrame : dismissedFrame];
                         [animatingView setAlpha:isPresentation ? 1 : 0];
                         [dismissingView setTransform:isPresentation ? dismissedTransform : presentedTransform];
                         [dismissingView setAlpha:isPresentation ? 0.5 : 1];
                         
                     }
                     completion:^(BOOL finished){
                         if ([self isPresentation]) {
                             [transitionContext completeTransition:YES];
                         }
                         else if (!transitionContext.transitionWasCancelled) {
                             [transitionContext completeTransition:YES];
                         }
                         else {
                             [transitionContext completeTransition:NO];
                         }
                     }];
}

- (void)animateFormSheetTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    BOOL isPresentation = [self isPresentation];
    
    UIViewController *animatingVC = isPresentation? toVC : fromVC;
    UIViewController *dismissingVC = isPresentation? fromVC : toVC;
    UIView *animatingView = [animatingVC view];
    UIView *dismissingView = [dismissingVC view];
    
//    CGAffineTransform presentedTransform = CGAffineTransformIdentity;
//    CGAffineTransform dismissedTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.9, 0.9), CGAffineTransformMakeRotation(8 * M_PI));
    CGRect presentedFrame = [transitionContext finalFrameForViewController:animatingVC];
    CGRect dismissedFrame = CGRectOffset(presentedFrame, 0, BOUNDS_HEIGHT);
    //    [animatingView setTransform:isPresentation ? dismissedTransform : presentedTransform];
    [animatingView setFrame:isPresentation ? dismissedFrame : presentedFrame];
    [animatingView setAlpha:isPresentation ? 0 : 1];
    
//    [dismissingView setTransform:isPresentation ? presentedTransform : dismissedTransform];
//    [dismissingView setAlpha:isPresentation ? 1 : 0.5];
    
    if([self isPresentation]) {
        [containerView addSubview:animatingView];
    }
    else {
        UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:dismissingView];
        
        UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[dismissingView]];
        gravity.gravityDirection = CGVectorMake(1.0, 0);
        [animator addBehavior:gravity];
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:1.0
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         //                         [animatingView setTransform:isPresentation ? presentedTransform : dismissedTransform];
                         [animatingView setFrame:isPresentation ? presentedFrame : dismissedFrame];
                         [animatingView setAlpha:isPresentation ? 1 : 0];
//                         [dismissingView setTransform:isPresentation ? dismissedTransform : presentedTransform];
//                         [dismissingView setAlpha:isPresentation ? 0.5 : 1];
                     }
                     completion:^(BOOL finished){
                         if ([self isPresentation]) {
                             [transitionContext completeTransition:YES];
                         }
                         else if (!transitionContext.transitionWasCancelled) {
                             [transitionContext completeTransition:YES];
                         }
                         else {
                             [transitionContext completeTransition:NO];
                         }
                     }];
}


@end
