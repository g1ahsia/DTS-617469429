//
//  PageViewController.m
//  ParallaxImages
//
//  Created by Allen Hsiao on 8/12/15.
//  Copyright (c) 2015 sky. All rights reserved.
//

#import "PageViewController.h"
#import "MJRootViewController.h"
#import "ZoomInOutTransitioner.h"
#import "MJAppDelegate.h"


@implementation PageViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withPresentation:(BOOL)isPresentation {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if (isPresentation)
            [self setModalPresentationStyle:UIModalPresentationCustom];
        //        else {
        UIScreenEdgePanGestureRecognizer *screenEdgePanGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(presentedViewEdgePanned:)];
        screenEdgePanGestureRecognizer.edges = UIRectEdgeLeft;
        [self.view addGestureRecognizer:screenEdgePanGestureRecognizer];
        
        [self configureView];

    }
    return self;
}


- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BOUNDS_WIDTH, BOUNDS_WIDTH)];
        [_imageView setBackgroundColor:[UIColor clearColor]];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (void)setImage:(UIImage *)image {
    if (![_image isEqual:image]) {
        _image = [image copy];
        self.imageView.image = image;
    }
}


- (void)viewDidLoad {
    
}

- (void)configureView {
    [self.view addSubview:self.imageView];
    //    [self.contentScrollView addSubview:self.imageView];
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(9, (44 - 22)/2, 22, 22)];
    [cancel setBackgroundImage:[UIImage imageNamed:@"cancel_w.png"] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:cancel];

}

- (void)presentedViewEdgePanned:(UIScreenEdgePanGestureRecognizer*)gesture {
    CGPoint velocity = [gesture velocityInView:self.view];
    CGFloat progress = [gesture translationInView:self.view].x / (self.view.bounds.size.width * 1.0);
    progress = MIN(1.0, MAX(0.0, progress));
    
    ZoomInOutTransitioningDelegate *myTransitioningDelegate = self.transitioningDelegate;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        myTransitioningDelegate.interactionController = [[UIPercentDrivenInteractiveTransition alloc] init];
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        [myTransitioningDelegate.interactionController updateInteractiveTransition:progress];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded) {
        // Finish or cancel the interactive transition
        if (progress > 0.3 || velocity.x > 1000.0) {
            myTransitioningDelegate.interactionController.completionSpeed = 0.8;
            [myTransitioningDelegate.interactionController finishInteractiveTransition];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
            
        }
        else {
            myTransitioningDelegate.interactionController.completionSpeed = 0.2;
            [myTransitioningDelegate.interactionController cancelInteractiveTransition];
            //            [self cancelInteraction:myTransitioningDelegate.interactionController];
        }
        
        myTransitioningDelegate.interactionController = nil;
    }
}


- (void)cancelButtonTapped {
    
//    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
