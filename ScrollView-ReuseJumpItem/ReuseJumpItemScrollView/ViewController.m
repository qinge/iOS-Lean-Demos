//
//  ViewController.m
//  ReuseJumpItemScrollView
//
//  Created by snqu-ios on 16/8/29.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import "ViewController.h"
#import "ScrollItemView.h"
#import "PureLayout.h"
#import <Masonry.h>

#define ITEM_WIDTH 60.0
#define TOTAL_PAGES 20
#define SCREEN_WIDTH    [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT    [[UIScreen mainScreen] bounds].size.height

//static const int ItemBaseTag = 1000;

@interface ViewController ()<UIScrollViewDelegate>{
    NSInteger _OnePageItemCount;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentWidthConstraint;

@property (strong, nonatomic) NSMutableArray<ScrollItemView *> *reusableViewArray;
@property (strong, nonatomic) NSMutableArray<ScrollItemView *> *visibleViewArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _reusableViewArray = [NSMutableArray array];
    _visibleViewArray = [NSMutableArray array];
    
    [self setupPages];
    
    _OnePageItemCount = ceilf(_scrollView.bounds.size.width / ITEM_WIDTH);
    for (int i = 0 ; i < _OnePageItemCount; i++) {
        [self loadPage:i];
        ScrollItemView *itemView = [_visibleViewArray objectAtIndex:i];
//        [itemView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_equalTo(ITEM_WIDTH);
//            make.height.mas_equalTo(ITEM_WIDTH);
//            if (i == 0) {
//                // 第一项
//                make.left.mas_equalTo(itemView.superview.mas_left);
//                make.bottom.mas_equalTo(itemView.superview.mas_bottom).mas_offset(60);
//            }else if (i == _OnePageItemCount - 1){
//                // 最后一项
//                make.left.mas_equalTo([_scrollView viewWithTag:(i - 1)].mas_right);
//                make.right.mas_equalTo(itemView.superview.mas_right);
//                make.bottom.mas_equalTo(itemView.superview.mas_bottom).mas_offset(110);
//            }else{
//                // 中间项
//                make.left.mas_equalTo([_scrollView viewWithTag:(i - 1)].mas_right);
//                make.bottom.mas_equalTo(itemView.superview.mas_bottom).mas_offset(110);
//            }
//        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupPages{
    [self.contentWidthConstraint autoRemove];
    CGFloat mutiplier = (TOTAL_PAGES * ITEM_WIDTH) / self.scrollView.frame.size.width ;
    self.contentWidthConstraint = [self.scrollContentView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.scrollView withMultiplier:mutiplier];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

-(void)loadPage:(NSInteger)page{
    ScrollItemView *itemView = [_reusableViewArray firstObject];
    if (itemView) {
        [_reusableViewArray removeObject:itemView];
        [itemView removeFromSuperview];
    }else{
        NSArray* nibView = [[NSBundle mainBundle] loadNibNamed:@"ScrollItemView" owner:nil options:nil];
        itemView = [nibView firstObject];
    }
    itemView.frame = CGRectMake(ITEM_WIDTH * page, 0.0, ITEM_WIDTH, self.scrollView.frame.size.height);
    itemView.tag = page;
    itemView.indexLabel.text = [NSString stringWithFormat:@"%ld", page];
    [self.scrollView addSubview:itemView];
    [self.visibleViewArray addObject:itemView];
    
//    if (page == 0 || page == [_visibleViewArray indexOfObject:[_visibleViewArray firstObject]]) {
//        [itemView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_equalTo(ITEM_WIDTH);
//            make.bottom.equalTo(itemView.superview.mas_bottom).mas_offset(MIN(ITEM_WIDTH + 60, 110));
//        }];
//
//    }else{
//        [itemView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_equalTo(ITEM_WIDTH);
//            make.bottom.equalTo(itemView.superview.mas_bottom).mas_offset(MIN(120 - ITEM_WIDTH, 110));
//        }];
//    }
}

- (void)showViewForPage:(NSInteger)page{
    
    NSInteger firstIndex = page - 1;
    NSInteger lastIndex  = page + _OnePageItemCount - 1;
    
    // 处理越界的情况
    if (firstIndex < 0) {
        firstIndex = 0;
    }
    
    if (lastIndex >= TOTAL_PAGES) {
        lastIndex = TOTAL_PAGES - 1;
    }
    
    // 回收不再显示的ImageView
    NSInteger viewIndex = 0;
    for (ScrollItemView *itemView in _visibleViewArray) {
        viewIndex = itemView.tag;
        if (viewIndex < firstIndex || viewIndex > lastIndex) {
            [_reusableViewArray addObject:itemView];
            [itemView removeFromSuperview];
        }
    }
    
    for (ScrollItemView *itemView in _reusableViewArray) {
        [itemView removeFromSuperview];
        [_visibleViewArray removeObject:itemView];
    }
    
    // 是否需要显示新的视图
    for (NSInteger index = firstIndex; index <= lastIndex; index++) {
        BOOL isShow = NO;
        
        for (ScrollItemView *itemView in _visibleViewArray) {
            if (itemView.tag == index) {
                isShow = YES;
            }
        }
        
        if (!isShow) {
            [self loadPage:index];
        }
    }
}

#pragma mark - UIScrollViewDelegate


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    double offseX = [scrollView contentOffset].x;
    NSInteger currentIndex = offseX / ITEM_WIDTH;
    if (currentIndex > TOTAL_PAGES - 2 || currentIndex < 0) {
        return;
    }
    //    NSInteger preIndex = currentIndex - 1;
//    NSInteger nextIndex = currentIndex + 1;
    
    //    CGFloat rate = (offseX - (currentIndex * ITEM_WIDTH)) / ITEM_WIDTH;
//    CGFloat scale = (_scrollView.contentOffset.x - currentIndex * ITEM_WIDTH) / ITEM_WIDTH;
    
//    
//    ScrollItemView *needReSetItemView = nil;
//    for (ScrollItemView  *itemView in _visibleViewArray) {
//        if (itemView.tag == currentIndex) {
//            needReSetItemView = itemView;
//            break;
//        }
//    }
//
//    ScrollItemView *currentItemView = needReSetItemView;
//    ScrollItemView *nextItemView = [self.visibleViewArray objectAtIndex:[_visibleViewArray indexOfObject:needReSetItemView] + 1];
    
    
    //    ScrollItemView *preItemView = preIndex > 0 ? [self.itemViewArray objectAtIndex:preIndex] : nil;
//    ScrollItemView *currentItemView = [self.itemViewArray objectAtIndex:currentIndex];
//    ScrollItemView *nextItemView = [self.itemViewArray objectAtIndex:nextIndex];
    
    //    if (preItemView) {
    //        [preItemView mas_updateConstraints:^(MASConstraintMaker *make) {
    //            make.bottom.equalTo(preItemView.superview.mas_bottom).mas_offset(110 - scale* ITEM_WIDTH);
    //        }];
    //    }
//    
//    [currentItemView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(currentItemView.superview.mas_bottom).mas_offset(MIN(scale* ITEM_WIDTH + 60, 110));
//    }];
//    
//    [nextItemView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(nextItemView.superview.mas_bottom).mas_offset(MIN(120 - scale* ITEM_WIDTH, 110));
//    }];
    
    NSInteger page = roundf(scrollView.contentOffset.x / ITEM_WIDTH);
    page = MAX(page, 0);
    page = MIN(page, TOTAL_PAGES - 1);
    [self showViewForPage:page];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        NSInteger currentIndex = roundf(scrollView.contentOffset.x / ITEM_WIDTH);
        ScrollItemView *needReSetItemView = nil;
        for (ScrollItemView  *itemView in _visibleViewArray) {
            if (itemView.tag == currentIndex) {
                needReSetItemView = itemView;
                break;
            }
        }
        CGFloat offsetX = (CGRectGetMidX(needReSetItemView.frame) - ITEM_WIDTH / 2);
        [_scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger currentIndex = roundf(scrollView.contentOffset.x / ITEM_WIDTH);
    ScrollItemView *needReSetItemView = nil;
    for (ScrollItemView  *itemView in _visibleViewArray) {
        if (itemView.tag == currentIndex) {
            needReSetItemView = itemView;
            break;
        }
    }
    CGFloat offsetX = (CGRectGetMidX(needReSetItemView.frame) - ITEM_WIDTH / 2) ;
    [_scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}


@end
