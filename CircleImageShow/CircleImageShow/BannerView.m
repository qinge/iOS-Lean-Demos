//
//  BannerView.m
//  CircleImageShow
//
//  Created by snqu-ios on 16/3/31.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import "BannerView.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface BannerView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView * bannerScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIImage *placeHolderImage;
@property (nonatomic, copy) NSArray* imageURLs;

@property (nonatomic, strong) NSTimer *timer;


@property (nonatomic, assign) NSInteger bannerWidth;
@property (nonatomic, assign) NSInteger bannerHeight;
@end

@implementation BannerView


-(instancetype)initWithFrame:(CGRect)frame withImageUrls:(NSArray*)imageURLs{

    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.imageURLs = imageURLs;
        self.bannerWidth = frame.size.width;
        self.bannerHeight = frame.size.height;
        self.clipsToBounds = NO;
        [self createBannerView];
        
        if (imageURLs.count > 1) {
            [self startTimerForAutoScroll];
        }
        
    }
    return self;
}

-(void)startAutoScroll{
    if (_imageURLs.count > 1) {
        [self startTimerForAutoScroll];
    }
}

-(void)stopAutoScroll{
    if (_imageURLs.count > 1) {
        [_timer invalidate];
    }
}

-(void)createBannerView {
    _bannerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _bannerWidth, _bannerHeight)];
    _bannerScrollView.bounces = NO;
    _bannerScrollView.delegate = self;
    _bannerScrollView.pagingEnabled = YES;
    _bannerScrollView.showsHorizontalScrollIndicator = NO;
    _bannerScrollView.showsVerticalScrollIndicator = NO;
    
       // 设置内容 利用 n + 2 实现循环滚动
    if (_imageURLs.count > 1) {
        //最后一张放到index = 0的位置
        UIImageView *lastImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _bannerWidth, _bannerHeight)];
        NSURL *lastImageURL = [_imageURLs lastObject];
        lastImageView.userInteractionEnabled = YES;
        [lastImageView sd_setImageWithURL:lastImageURL placeholderImage:_placeHolderImage];
        
        UIButton *lastImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        lastImageButton.backgroundColor = [UIColor clearColor];
        lastImageButton.frame = lastImageView.bounds;
        lastImageButton.tag = _imageURLs.count - 1;
        [lastImageView addSubview:lastImageButton];
        [lastImageButton addTarget:self action:@selector(bannerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_bannerScrollView addSubview:lastImageView];
        
        //第一张放到 index = count+1 的位置
        CGFloat xOfset = (_imageURLs.count + 1 ) * _bannerWidth;
        UIImageView *firstImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xOfset, 0, _bannerWidth, _bannerHeight)];
        [firstImageView sd_setImageWithURL:[_imageURLs firstObject] placeholderImage:_placeHolderImage];
        firstImageView.userInteractionEnabled = YES;
        
        UIButton *firstImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        firstImageButton.backgroundColor = [UIColor clearColor];
        firstImageButton.frame = lastImageView.bounds;
        firstImageButton.tag = 0;
        [lastImageView addSubview:firstImageButton];
        [firstImageButton addTarget:self action:@selector(bannerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_bannerScrollView addSubview:firstImageView];
        
        // 添加其余试图
        for (int i =0; i < _imageURLs.count; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_bannerWidth * (i + 1), 0, _bannerWidth, _bannerHeight)];
            imageView.userInteractionEnabled = YES;
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            button.frame = imageView.bounds;
            button.tag = i;
            [imageView addSubview:button];
            [button addTarget:self action:@selector(bannerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [imageView sd_setImageWithURL:_imageURLs[i] placeholderImage:_placeHolderImage];
            [_bannerScrollView addSubview:imageView];
        }
        
        _bannerScrollView.contentSize = CGSizeMake(_bannerWidth * (_imageURLs.count + 2), _bannerHeight);
        _bannerScrollView.contentOffset = CGPointMake(_bannerWidth, 0);
        
        [self addSubview:_bannerScrollView];
        
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.numberOfPages = _imageURLs.count;
        CGSize size = [_pageControl sizeForNumberOfPages:_imageURLs.count];
        _pageControl.frame = CGRectMake(0, _bannerHeight - 25, size.width, 6);
        _pageControl.center = CGPointMake(_bannerWidth / 2, _pageControl.center.y);
        _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1.0];
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:253/255.0 green:99/255.0 blue:99/255.0 alpha:1.0];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.currentPage = 0;
        
        [self addSubview:_pageControl];
        
    }else if(_imageURLs.count == 1){
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _bannerWidth, _bannerHeight)];
        [imageView sd_setImageWithURL:[_imageURLs firstObject] placeholderImage:_placeHolderImage];
        imageView.userInteractionEnabled = YES;
        [_bannerScrollView addSubview:imageView];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        button.frame = imageView.bounds;
        button.tag = 0;
        [imageView addSubview:button];
        [button addTarget:self action:@selector(bannerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        _bannerScrollView.contentSize = CGSizeMake(_bannerWidth , _bannerHeight);
        _bannerScrollView.contentOffset = CGPointMake(0, 0);
        [self addSubview:_bannerScrollView];
        
    }

}


-(void)startTimerForAutoScroll{
    _timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(autoMaticScroll) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)autoMaticScroll{
    
    _pageControl.currentPage = _pageControl.currentPage + 1;
    
    // 滑动到最后一页
    if (_bannerScrollView.contentOffset.x == ( _imageURLs.count + 1 ) * _bannerWidth) {
        _bannerScrollView.contentOffset = CGPointMake(_bannerWidth, 0);
    }
    
    if (_bannerScrollView.contentOffset.x == _imageURLs.count * _bannerWidth) {
        _pageControl.currentPage = 0;
    }
    
    if (_delegate) {
        [_delegate bannerViewDidScrollToIndex:_pageControl.currentPage];
    }
    
    [_bannerScrollView setContentOffset:CGPointMake(_bannerScrollView.contentOffset.x + _bannerWidth, 0) animated:YES];
}


#pragma mark - UIScrollViewDelegate


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (_imageURLs.count > 1) {
        [_timer invalidate];
    }
}


-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (_imageURLs.count > 1) {
        [self startTimerForAutoScroll];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat page = (_bannerScrollView.contentOffset.x - _bannerWidth) / _bannerWidth;
    _pageControl.currentPage = page;
    
    if (_bannerScrollView.contentOffset.x == 0) {
        //  // 如果当前页是第0页就跳转到真实的最后一页
        _bannerScrollView.contentOffset = CGPointMake(_imageURLs.count * _bannerWidth, 0);
        _pageControl.currentPage = _imageURLs.count - 1;
        
        if (_delegate) {
            [_delegate bannerViewDidScrollToIndex:_pageControl.currentPage];
        }
        return;
    }else if (_bannerScrollView.contentOffset.x == (_imageURLs.count + 1) * _bannerWidth) {
        // 如果是 最后一页就跳转到真实的第一页
        _bannerScrollView.contentOffset = CGPointMake(_bannerWidth, 0);
        _pageControl.currentPage = 0;
        
        if (_delegate) {
            [_delegate bannerViewDidScrollToIndex:_pageControl.currentPage];
        }
        return;
    }
    
    if (_delegate) {
        [_delegate bannerViewDidScrollToIndex:page];
    }
}

#pragma mark - bannerButtonClicked
-(void)bannerButtonClicked:(UIButton *)sender{
    NSInteger index = sender.tag;
    NSLog(@"click url = %@", _imageURLs[index]);
}



@end
