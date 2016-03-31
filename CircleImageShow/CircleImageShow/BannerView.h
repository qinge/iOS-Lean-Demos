//
//  BannerView.h
//  CircleImageShow
//
//  Created by snqu-ios on 16/3/31.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BannerViewDelegate <NSObject>

/**
 *  监测滑动到下一页 起始位置 0 终止位置 array.count - 1
 *
 *  @param index 滑动到的位置
 */
-(void)bannerViewDidScrollToIndex:(NSInteger) index;

@end


@interface BannerView : UIView

@property (nonatomic, weak) id<BannerViewDelegate> delegate;


/**
 *  初始化循环显示控件并设置 要显示的 图片 url
 *
 *  @param frame     frame
 *  @param imageURLs 图片 url 数组
 *
 *  @return BannerView instance
 */
-(instancetype)initWithFrame:(CGRect)frame withImageUrls:(NSArray*)imageURLs;


/**
 *  开始循环滚动
 */
-(void)startAutoScroll;

/**
 *  停止循环滚动
 */
-(void) stopAutoScroll;

@end
