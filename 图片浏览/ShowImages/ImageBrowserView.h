//
//  ImageBrowserView.h
//  ShowImages
//
//  Created by snqu-ios on 16/6/8.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageBrowserView : UIView

@property (nonatomic, copy) NSArray *imageURLs;

-(void)browserImageFromImageView:(UIImageView *)startImageView atURLIndex:(NSInteger)urlIndex;

@end
