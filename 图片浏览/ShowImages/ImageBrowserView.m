//
//  ImageBrowserView.m
//  ShowImages
//
//  Created by snqu-ios on 16/6/8.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import "ImageBrowserView.h"
#import "UIImageView+WebCache.h"
#import "ViewController.h"


@interface ImageBrowserView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIWindow *keyWindow;

@end

@implementation ImageBrowserView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self configScrollView];
    }
    return self;
}


-(void)configScrollView{
    _keyWindow = [UIApplication sharedApplication].keyWindow;
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
            _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor blackColor];
            _scrollView.maximumZoomScale = 2.0;
            _scrollView.minimumZoomScale = 0.5;
    _scrollView.userInteractionEnabled = YES;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollEnabled = YES;
    _scrollView.multipleTouchEnabled = YES;
    [self addSubview:_scrollView];
    [_keyWindow addSubview:self];
    
    //        // 双击放大视图
    //        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomInScrollview:)];
    //        doubleTap.numberOfTapsRequired = 2;
    //        [_scrollView addGestureRecognizer:doubleTap];
    
    // 单击关闭视图
    //        UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    //        [_scrollView addGestureRecognizer: singleTap];
    
    //        [singleTap requireGestureRecognizerToFail:doubleTap];
}



-(void)setImageURLs:(NSArray *)imURLs{
    _imageURLs = imURLs;
    for (int i = 0; i < _imageURLs.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(i * _scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        [imageView sd_setImageWithURL:_imageURLs[i]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = i;
        imageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
        [imageView addGestureRecognizer: singleTap];
        
        [_scrollView addSubview:imageView];
    }
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * [_imageURLs count], _scrollView.frame.size.height);
    _scrollView.alpha = 0.0;
}

-(void)browserImageFromImageView:(UIImageView *)startImageView atURLIndex:(NSInteger)urlIndex {
    //    UIWindow *_keyWindow = [UIApplication sharedApplication].keyWindow;
    _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width * urlIndex, 0);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:startImageView.image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGRect startFrame = [startImageView convertRect:startImageView.bounds toView:_keyWindow];
    CGRect endFrame = [[_scrollView viewWithTag:urlIndex] convertRect:[_scrollView viewWithTag:urlIndex].bounds toView:_keyWindow];
    imageView.frame = startFrame;
    imageView.backgroundColor = [UIColor clearColor];
    [_keyWindow addSubview:imageView];
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = endFrame;
        imageView.backgroundColor = [UIColor blackColor];
    } completion:^(BOOL finished) {
        _scrollView.alpha = 1.0;
        [imageView removeFromSuperview];
    }];
}

/**
 *  隐藏ImageView
 *
 *  @param tap 单击手势
 */
- (void)hideImage:(UITapGestureRecognizer*)gesture{
    // 添加渐变缩小的 view
    UIImage *image = ((UIImageView *)gesture.view).image;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = [gesture.view convertRect:_scrollView.frame toView:_keyWindow];
    [_keyWindow addSubview:imageView];
    gesture.view.alpha = 0.0;
    
    
    // 获取缩小后的 frame
    ViewController *vc = (ViewController *) _keyWindow.rootViewController;
    UIImageView *destImageView = [vc imageViewForIndex:gesture.view.tag];
    CGRect finalFrame = [destImageView.superview convertRect:destImageView.frame toView:_keyWindow];
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = finalFrame;
        _scrollView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
        [self removeFromSuperview];
    }];
    
}

/**
 *  放大ImageView
 *
 *  @param tapGestureRecognizer 双击手势
 */
- (void)zoomInScrollview:(UITapGestureRecognizer *)tapGestureRecognizer{
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

}

@end
