//
//  CollectionTestViewController.m
//  ScrollItemJumpAnimation
//
//  Created by snqu-ios on 16/8/24.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import "CollectionTestViewController.h"
#import "HeadCollectionReusableView.h"

#define offset_HeaderStop (40.0)

@interface CollectionTestViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *segmentView;
@property (nonatomic, strong) HeadCollectionReusableView *reusableHeadView;

@end

@implementation CollectionTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _collectionView.contentInset = UIEdgeInsetsMake(_headView.frame.size.height, 0, 0, 0);
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 10;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    return cell;
}




#pragma mark - UICollectionViewDelegate

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader) {
        _reusableHeadView = (HeadCollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"TestSectionHead" forIndexPath:indexPath];
        return _reusableHeadView;
    }
    return nil;
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat  offset = scrollView.contentOffset.y + _headView.bounds.size.height;
//    CATransform3D avatarTransform = CATransform3DIdentity;
//    CATransform3D headerTransform = CATransform3DIdentity;
//    
//    if (offset < 0) {
//        
//    }else{
//        
//    }
    
    CGFloat segmentViewOffset = _reusableHeadView.frame.size.height - _segmentView.frame.size.height - offset;
    CATransform3D segmentTransform = CATransform3DIdentity;
    segmentTransform = CATransform3DTranslate(segmentTransform, 0, MAX(segmentViewOffset, -offset_HeaderStop), 0);
    _segmentView.layer.transform = segmentTransform;
    _collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(CGRectGetMaxY(_segmentView.frame), 0, 0, 0);
}



@end
