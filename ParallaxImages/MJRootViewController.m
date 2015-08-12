//
//  MJViewController.m
//  ParallaxImages
//
//  Created by Mayur on 4/1/14.
//  Copyright (c) 2014 sky. All rights reserved.
//

#import "MJRootViewController.h"
#import "MJCollectionViewCell.h"
#import "MJCollectionViewFlowLayout.h"
#import "PageViewController.h"
#import "ZoomInOutTransitioner.h"

@interface MJRootViewController ()

@property (nonatomic, strong) UICollectionView *parallaxCollectionView;
@property (nonatomic, strong) NSMutableArray* images;

@end

@implementation MJRootViewController {
    id<UIViewControllerTransitioningDelegate> transitioningDelegate;

}
NSInteger BOUNDS_WIDTH;
NSInteger BOUNDS_HEIGHT;

- (UICollectionView *)parallaxCollectionView {
    if (!_parallaxCollectionView) {
        MJCollectionViewFlowLayout *layout = [[MJCollectionViewFlowLayout alloc] init];
        layout.cellSpacing = IMAGE_HEIGHT;
        _parallaxCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:layout];
        _parallaxCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _parallaxCollectionView.dataSource = self;
        _parallaxCollectionView.delegate = self;
        [_parallaxCollectionView registerClass:[MJCollectionViewCell class]
                    forCellWithReuseIdentifier:@"MJCell"];
        
        _parallaxCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
        [_parallaxCollectionView setContentOffset:CGPointMake(0, IMAGE_HEIGHT - (BOUNDS_HEIGHT - IMAGE_HEIGHT)/2)];
    }
    return _parallaxCollectionView;
}

- (void)viewDidLoad
{
    //    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blurViewTapped)];
    //    [self.view addGestureRecognizer:tap];
    BOUNDS_WIDTH = self.view.bounds.size.width;
    BOUNDS_HEIGHT = self.view.bounds.size.height;
    [super viewDidLoad];
    
    // Fill image array with images
    NSUInteger index;
    for (index = 0; index < 13; ++index) {
        // Setup image name
        
        NSString *name = [NSString stringWithFormat:@"image%03ld.jpg", (unsigned long)index];
        if(!self.images) {
            self.images = [NSMutableArray arrayWithCapacity:0];
        }
        [self.images addObject:name];
    }
    [self.view addSubview:self.parallaxCollectionView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDatasource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count + 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MJCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MJCell" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        cell.image = nil;
        return cell;
    }
    
    else if (indexPath.row == [self.images count] + 1) {
        cell.image = nil;
        return cell;
    }
    //get image name and assign
    NSString* imageName = [self.images objectAtIndex:indexPath.row - 1];
    
    cell.image = [UIImage imageNamed:imageName];
    
    return cell;
}

#pragma mark - UIScrollViewdelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    for(MJCollectionViewCell *view in self.parallaxCollectionView.visibleCells) {
//
//    }
//}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    for(MJCollectionViewCell *view in self.parallaxCollectionView.visibleCells) {
//        // Only display the quote of the center cell
//        if (self.parallaxCollectionView.contentOffset.y -  view.frame.origin.y + (BOUNDS_HEIGHT - IMAGE_HEIGHT)/2 == 0.0) {
//            [UIView animateWithDuration:0.8f animations:^{ view.textTransparency = 1; } completion:nil];
//        }
//    }
//}
//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
//    for(MJCollectionViewCell *view in self.parallaxCollectionView.visibleCells) {
//
////        view.textTransparency = 0;
//    }
//}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MJCollectionViewCell *cell = (MJCollectionViewCell*)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    
    UIImage *topCellImage = [self captureTransitionTopView];
    //    UIImage *bottomCellImage = [self captureCellView:bottomCell];
    UIImage *bottomCellImage = [self captureTransitionBottomView];
    
    CGRect topRect = CGRectMake(0, 0, BOUNDS_WIDTH, (BOUNDS_HEIGHT - IMAGE_HEIGHT)/2);
    CGRect bottomRect = CGRectMake(0, (BOUNDS_HEIGHT - IMAGE_HEIGHT)/2 + IMAGE_HEIGHT, BOUNDS_WIDTH, (BOUNDS_HEIGHT - IMAGE_HEIGHT)/2);
    
    UIImageView *referenceImageViewTop= [[UIImageView alloc] initWithImage:topCellImage];
    UIImageView *referenceImageViewBottom= [[UIImageView alloc] initWithImage:bottomCellImage];
    [referenceImageViewTop setFrame:topRect];
    [referenceImageViewBottom setFrame:bottomRect];

    
    
    //    if (collectionView.contentOffset.y - cell.frame.origin.y + (BOUNDS_HEIGHT - IMAGE_HEIGHT)/2 == 0) {
    PageViewController *pageVC = [[PageViewController alloc] initWithNibName:nil bundle:nil withPresentation:YES];
    pageVC.image = cell.image;
    
    transitioningDelegate = [[ZoomInOutTransitioningDelegate alloc] initWithReferenceImageScrollView:cell.MJImageView imageViewTop:referenceImageViewTop imageViewBottom:referenceImageViewBottom];
//    [pageVC setTransitioningDelegate:transitioningDelegate];
//    [self presentViewController:pageVC animated:YES completion:NULL];
    self.navigationController.delegate = self;
    [self.navigationController pushViewController:pageVC animated:YES];
    
    //    }
    
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    ZoomInOutAnimatedTransitioning *transition = [[ZoomInOutAnimatedTransitioning alloc] init];
    [transition setTransitionType:StretchInOut];
    if ([fromVC isKindOfClass:[self class]])
        [transition setIsPresentation:YES];
    else
        [transition setIsPresentation:NO];
    return transition;
}


#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(self.view.frame.size.width, IMAGE_HEIGHT);
}

- (void)blurViewTapped {
    [self.images addObject:@"panoramic.jpg"];
    NSInteger numOfCollections = (unsigned long)[self.images count];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numOfCollections inSection:0];
    [_parallaxCollectionView insertItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - Helper methods

- (UIImage *)captureTransitionTopView {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(BOUNDS_WIDTH, (BOUNDS_HEIGHT - IMAGE_HEIGHT)/2), YES, 2.0);
        } else {
            UIGraphicsBeginImageContext(CGSizeMake(BOUNDS_WIDTH, (BOUNDS_HEIGHT - IMAGE_HEIGHT)/2));
        }
    } else {
        UIGraphicsBeginImageContext(CGSizeMake(BOUNDS_WIDTH, (BOUNDS_HEIGHT - IMAGE_HEIGHT)/2));
    }
    [self.view drawViewHierarchyInRect:CGRectMake(0, 0, BOUNDS_WIDTH, BOUNDS_HEIGHT) afterScreenUpdates:YES];
    return UIGraphicsGetImageFromCurrentImageContext();
}

- (UIImage *)captureTransitionBottomView {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(BOUNDS_WIDTH, (BOUNDS_HEIGHT - IMAGE_HEIGHT)/2), YES, 2.0);
        } else {
            UIGraphicsBeginImageContext(CGSizeMake(BOUNDS_WIDTH, (BOUNDS_HEIGHT - IMAGE_HEIGHT)/2));
        }
    } else {
        UIGraphicsBeginImageContext(CGSizeMake(BOUNDS_WIDTH, (BOUNDS_HEIGHT - IMAGE_HEIGHT)/2));
    }
    [self.view drawViewHierarchyInRect:CGRectMake(0, -(BOUNDS_HEIGHT - IMAGE_HEIGHT)/2 - IMAGE_HEIGHT, BOUNDS_WIDTH, BOUNDS_HEIGHT) afterScreenUpdates:YES];
    return UIGraphicsGetImageFromCurrentImageContext();
}


@end
