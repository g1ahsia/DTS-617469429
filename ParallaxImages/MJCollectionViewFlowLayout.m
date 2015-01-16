//
//  MJCollectionViewFlowLayout.m
//  ParallaxImages
//
//  Created by Allen on 7/8/14.
//  Copyright (c) 2014 sky. All rights reserved.
//

#import "MJCollectionViewFlowLayout.h"
#import "MJRootViewController.h"

@implementation MJCollectionViewFlowLayout

-(id)init {
    if (!(self = [super init])) return nil;
    self.minimumLineSpacing = 0.0f;
    return self;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGPoint theTargetContentOffset = proposedContentOffset;
    CGFloat sensitivity;
    if (theTargetContentOffset.y > self.collectionView.contentOffset.y) sensitivity = 0.3;
    else sensitivity = -0.3;
    theTargetContentOffset.y = roundf((theTargetContentOffset.y - (self.cellSpacing - (BOUNDS_HEIGHT - self.cellSpacing)/2)) / self.cellSpacing + sensitivity) * self.cellSpacing + (self.cellSpacing - (BOUNDS_HEIGHT - self.cellSpacing)/2);
    
    theTargetContentOffset.y = MAX(theTargetContentOffset.y, self.cellSpacing - (BOUNDS_HEIGHT - self.cellSpacing)/2);
    
    theTargetContentOffset.y = MIN(theTargetContentOffset.y, ([self.collectionView numberOfItemsInSection:0] - 3) * self.cellSpacing + (self.cellSpacing - (BOUNDS_HEIGHT - self.cellSpacing)/2));
    
    return(theTargetContentOffset);
}
@end
