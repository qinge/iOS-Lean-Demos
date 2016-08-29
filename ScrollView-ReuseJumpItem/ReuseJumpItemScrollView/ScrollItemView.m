//
//  ScrollItemView.m
//  ScrollItemJumpAnimation
//
//  Created by snqu-ios on 16/8/23.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import "ScrollItemView.h"

@implementation ScrollItemView

-(void)awakeFromNib{
    [super awakeFromNib];
    self.contentContainerView.backgroundColor = [self randomColor];
}


-(UIColor *)randomColor{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}

@end
