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

@interface MJRootViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *parallaxCollectionView;
@property (nonatomic, strong) NSMutableArray* images;

@end

@implementation MJRootViewController {
    
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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blurViewTapped)];
    [self.view addGestureRecognizer:tap];
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



@end
