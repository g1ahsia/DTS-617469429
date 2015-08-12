//
//  MJCollectionViewCell.h
//  RCCPeakableImageSample
//
//  Created by Mayur on 4/1/14.
//  Copyright (c) 2014 RCCBox. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSInteger IMAGE_HEIGHT;

#define IMAGE_OFFSET_SPEED 50

@interface MJCollectionViewCell : UICollectionViewCell

/*
 image used in the cell which will be having the parallax effect
 
 */
@property (nonatomic, strong, readwrite) UIImage *image;
@property (nonatomic, assign, readwrite) CGPoint imageOffset;
@property (nonatomic, strong, readwrite) UIImageView *MJImageView;


@end
