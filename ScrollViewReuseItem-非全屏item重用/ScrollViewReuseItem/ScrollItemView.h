//
//  ScrollItemView.h
//  ScrollViewReuseItem
//
//  Created by snqu-ios on 16/8/26.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollItemView : UIView
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (assign, nonatomic) NSNumber *userId;
@property (assign, nonatomic) NSInteger numberOfInstance;

@end
