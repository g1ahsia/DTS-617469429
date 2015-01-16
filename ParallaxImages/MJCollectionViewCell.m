//
//  MJCollectionViewCell.m
//  RCCPeakableImageSample
//
//  Created by Mayur on 4/1/14.
//  Copyright (c) 2014 RCCBox. All rights reserved.
//

#import "MJCollectionViewCell.h"
#import "UIImage+ImageEffects.h"

@interface MJCollectionViewCell() {
}
@property (nonatomic, strong, readwrite) UIImageView *MJImageView;

@property (nonatomic, strong, readwrite) UIView *overlapView;

@end

@implementation MJCollectionViewCell

NSInteger IMAGE_HEIGHT = 260;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self setupImageView];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) [self setupImageView];
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Setup Method
- (void)setupImageView
{
    // Clip subviews
    self.clipsToBounds = NO;
    
    // Add image subview
    self.MJImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, IMAGE_HEIGHT)];
    self.MJImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.MJImageView.clipsToBounds = YES;
    [self addSubview:self.MJImageView];
    
    self.overlapView = [[UIView alloc] initWithFrame:CGRectMake(0, IMAGE_HEIGHT, 30, 30)];
    [self.overlapView setBackgroundColor:[UIColor redColor]];
    
    [self addSubview:self.overlapView];
}

# pragma mark - Setters

- (void)setImage:(UIImage *)image
{
    self.MJImageView.image = image;
}

- (void)setImageOffset:(CGPoint)imageOffset
{
    // Store padding value
    _imageOffset = imageOffset;
    
    // Grow image view
    CGRect frame = self.MJImageView.bounds;
    CGRect offsetFrame = CGRectOffset(frame, _imageOffset.x, _imageOffset.y);
    self.MJImageView.frame = offsetFrame;
}

- (void)setTransparency:(CGFloat)transparency
{
    _transparency = transparency;
}

- (void)setTextTransparency:(CGFloat)textTransparency
{
}

@end
