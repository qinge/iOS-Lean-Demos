//
//  ScrollJumpView.m
//  ScrollItemJumpAnimation
//
//  Created by snqu-ios on 16/8/25.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import "ScrollJumpView.h"
#import "ScrollItemView.h"
#import <Masonry.h>


#define ITEM_WIDTH 60.0
#define SCREEN_WIDTH    [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT    [[UIScreen mainScreen] bounds].size.height

static const int ItemBaseTag = 1000;

@interface ScrollJumpView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray<ScrollItemView *> *itemViewArray;
@end

@implementation ScrollJumpView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addScrollView];
    }
    return self;
}


-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addScrollView];
    }
    return self;
}

-(void)addScrollView{
    _scrollView = [[UIScrollView alloc] init];
    [self addSubview:_scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.mas_equalTo(self.mas_leading);
//        make.top.mas_equalTo(self.mas_top);
//        make.trailing.mas_equalTo(self.mas_trailing);
//        make.bottom.mas_equalTo(self.mas_bottom);
        make.edges.equalTo(self);
    }];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.bounces = NO;
}

-(void)setItemsArray:(NSArray *)itemsArray{
    _itemsArray = itemsArray;
    _itemViewArray = [NSMutableArray array];
    int  tempCount = (int)(SCREEN_WIDTH) / (int)(ITEM_WIDTH) - 1;
    _scrollView.contentSize = CGSizeMake(ITEM_WIDTH * (_itemsArray.count + tempCount), ITEM_WIDTH);
    [self setupItemView];
}

-(void)setupItemView{
    __weak typeof(self) weakSelf = self;
    int  tempCount = (int)(SCREEN_WIDTH) / (int)(ITEM_WIDTH) - 1 ;
    for (int i = 0; i < (self.itemsArray.count + tempCount); i++) {
        NSArray* nibView = [[NSBundle mainBundle] loadNibNamed:@"ScrollItemView" owner:nil options:nil];
        ScrollItemView *itemView = [nibView firstObject];
        [self.itemViewArray addObject:itemView];
        itemView.tag = ItemBaseTag + i;
        itemView.indexLabel.text = [NSString stringWithFormat:@"item: %d", i];
        if (i < self.itemsArray.count) {
            itemView.contentContainerView.backgroundColor = [self randomColor];
        }else{
            itemView.contentContainerView.backgroundColor = [UIColor clearColor];
        }
        
        [_scrollView addSubview:itemView];
        
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(ITEM_WIDTH);
            make.height.mas_equalTo(ITEM_WIDTH);
            if (i == 0) {
                // 第一项
                make.left.mas_equalTo(itemView.superview.mas_left);
                make.bottom.mas_equalTo(itemView.superview.mas_bottom).mas_offset(60);
//                make.bottom.mas_equalTo(itemView.superview.mas_bottom).offset(60);
                make.height.mas_equalTo(self.mas_height);
            }else if (i == _itemsArray.count + tempCount - 1){
                // 最后一项
                make.left.mas_equalTo([weakSelf viewWithTag:(ItemBaseTag + i - 1)].mas_right);
                make.right.mas_equalTo(itemView.superview.mas_right);
                make.bottom.mas_equalTo(itemView.superview.mas_bottom).mas_offset(110);
            }else{
                // 中间项
                make.left.mas_equalTo([weakSelf viewWithTag:(ItemBaseTag + i - 1)].mas_right);
                make.bottom.mas_equalTo(itemView.superview.mas_bottom).mas_offset(110);
            }
        }];
    }
    
}



-(UIColor *)randomColor{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    double offseX = [scrollView contentOffset].x;
    NSInteger currentIndex = offseX / ITEM_WIDTH;
    if (currentIndex > self.itemViewArray.count - 2 || currentIndex < 0) {
        return;
    }
//    NSInteger preIndex = currentIndex - 1;
    NSInteger nextIndex = currentIndex + 1;
    
//    CGFloat rate = (offseX - (currentIndex * ITEM_WIDTH)) / ITEM_WIDTH;
    CGFloat scale = (_scrollView.contentOffset.x - currentIndex * ITEM_WIDTH) / ITEM_WIDTH;
    
    
//    ScrollItemView *preItemView = preIndex > 0 ? [self.itemViewArray objectAtIndex:preIndex] : nil;
    ScrollItemView *currentItemView = [self.itemViewArray objectAtIndex:currentIndex];
    ScrollItemView *nextItemView = [self.itemViewArray objectAtIndex:nextIndex];
    
//    CATransform3D currentTransform = CATransform3DIdentity;
//    CATransform3D nextTransform = CATransform3DIdentity;
//    currentItemView.layer.transform = CATransform3DTranslate(currentTransform, 0, -scale * ITEM_WIDTH , 0);
//    nextItemView.layer.transform = CATransform3DTranslate(nextTransform, 0, scale* ITEM_WIDTH, 0);
    
    NSLog(@"transform = %f", scale* ITEM_WIDTH);
    NSLog(@"currentIndex = %d", currentIndex);
    
//    if (preItemView) {
//        [preItemView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.bottom.equalTo(preItemView.superview.mas_bottom).mas_offset(110 - scale* ITEM_WIDTH);
//        }];
//    }
    
    [currentItemView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(currentItemView.superview.mas_bottom).mas_offset(MIN(scale* ITEM_WIDTH + 60, 110));
    }];
    
    [nextItemView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(nextItemView.superview.mas_bottom).mas_offset(MIN(120 - scale* ITEM_WIDTH, 110));
    }];
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        NSInteger currentIndex = roundf(scrollView.contentOffset.x / ITEM_WIDTH);
        ScrollItemView *currentItemView = [self.itemViewArray objectAtIndex:currentIndex];
        CGFloat offsetX = (CGRectGetMidX(currentItemView.frame) - ITEM_WIDTH / 2);
        [_scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }
   
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger currentIndex = roundf(scrollView.contentOffset.x / ITEM_WIDTH);
    ScrollItemView *currentItemView = [self.itemViewArray objectAtIndex:currentIndex];
    CGFloat offsetX = (CGRectGetMidX(currentItemView.frame) - ITEM_WIDTH / 2) ;
//    [_scrollView scrollRectToVisible:CGRectMake(offsetX, 0, ITEM_WIDTH, ITEM_WIDTH) animated:YES];
    [_scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

@end
