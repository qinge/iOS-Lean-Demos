//
//  ViewController.m
//  ScrollViewReuseItem
//
//  Created by snqu-ios on 16/8/26.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import "ViewController.h"
#import "ScrollItemView.h"
#import "PureLayout.h"

#define TOTAL_PAGES 20
#define ITEM_WIDTH 50.0

#define SCREEN_WIDTH    [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT    [[UIScreen mainScreen] bounds].size.height

@interface ViewController ()<UIScrollViewDelegate>{
    NSInteger _needPageCount;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentWidthConstraint;

@property (strong, nonatomic) NSNumber *currentPage;

@property (strong, nonatomic) NSMutableArray<ScrollItemView *> *reusableViewArray;
@property (strong, nonatomic) NSMutableArray<ScrollItemView *> *visibleViewArray;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _reusableViewArray = [NSMutableArray array];
    _visibleViewArray = [NSMutableArray array];
    
    _scrollView.delegate = self;
    [self setupPages];
    _needPageCount = ceilf(_scrollView.bounds.size.width / ITEM_WIDTH);
    for (int i = 0 ; i < _needPageCount; i++) {
        [self loadPage:i];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setupPages{
    [self.contentWidthConstraint autoRemove];
    CGFloat mutiplier = (TOTAL_PAGES * ITEM_WIDTH) / self.scrollView.frame.size.width ;
    self.contentWidthConstraint = [self.scrollContentView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.scrollView withMultiplier:mutiplier];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
}

-(void)setCurrentPage:(NSNumber *)currentPage{
    if (_currentPage != currentPage) {
        _currentPage = currentPage;
    }
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
    [self.scrollContentView addSubview:itemView];
    [self.visibleViewArray addObject:itemView];
}




- (void)showViewForPage:(NSInteger)page{

    NSInteger firstIndex = page - 1;
    NSInteger lastIndex  = page + _needPageCount - 1;
    
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
    NSInteger page = roundf(scrollView.contentOffset.x / ITEM_WIDTH);
    page = MAX(page, 0);
    page = MIN(page, TOTAL_PAGES - 1);
    [self showViewForPage:page];
}


@end
