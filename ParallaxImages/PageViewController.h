//
//  PageViewController.h
//  ParallaxImages
//
//  Created by Allen Hsiao on 8/12/15.
//  Copyright (c) 2015 sky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageViewController : UIViewController <UIScrollViewDelegate>

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withPresentation:(BOOL)isPresentation;

@property (nonatomic, strong, readwrite) UIScrollView *contentScrollView;

@property (nonatomic, strong, readwrite) UIImage *image;

@property (nonatomic, strong, readwrite) UIImageView *imageView;

@end
