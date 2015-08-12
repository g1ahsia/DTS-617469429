
@import UIKit;
#import "ZoomInOutTransitioner.h"
#import "PageViewController.h"

@interface PageViewPresentationController : UIPresentationController <UIScrollViewDelegate>
{
    
    UIImageView *transitionImageView;
    UIImageView *transitionImageViewTop;
    UIImageView *transitionImageViewBottom;
    PageViewController *pageVC;
    
    CGRect originalImageFrame;
    CGRect finalImageFrame;
    CGRect finalTransformFrame;
    CGFloat pageVCImageHeight;
    CGFloat yOffSet;
    
    BOOL isDismissing;
}

@property (weak, nonatomic, readwrite) UIImageView *referenceImageView;

@property (weak, nonatomic, readwrite) UIImageView *referenceImageViewTop;

@property (weak, nonatomic, readwrite) UIImageView *referenceImageViewBottom;


@property (weak, readonly) ZoomInOutTransitioningDelegate *transitioningDelegate;

- (instancetype)initWithPresentingViewController:(UIViewController *)presentingViewController presentedViewController:(UIViewController *)presentedViewController referenceImageView:(UIImageView *)referenceImageView imageViewTop:(UIImageView *)referenceImageViewTop imageViewBottom:(UIImageView *)referenceImageViewBottom;

@end
