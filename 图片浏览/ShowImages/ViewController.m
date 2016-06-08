//
//  ViewController.m
//  ShowImages
//
//  Created by snqu-ios on 16/6/7.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+WebCache.h"
#import "ImageBrowserView.h"



@interface ViewController (){
    NSInteger selectedIndex;
}

@property (nonatomic, weak) IBOutlet UIView *imageContainer;

@property (nonatomic, strong) NSArray *imageURLs;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageURLs = @[@"http://ww4.sinaimg.cn/thumbnail/7f8c1087gw1e9g06pc68ug20ag05y4qq.gif",
                   @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr0nly5j20pf0gygo6.jpg",
                   @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1d0vyj20pf0gytcj.jpg",
                   @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1xydcj20gy0o9q6s.jpg",
                   @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr2n1jjj20gy0o9tcc.jpg",
                   @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr39ht9j20gy0o6q74.jpg",
                   @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr3xvtlj20gy0obadv.jpg",
                   @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg",
                   @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg"];
    int index = 0;
    for (int i = 0;  i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            CGRect imageViewFrame = CGRectMake(5 * (j+1) + 100 * j, 5 * (i+1) + 100 * i, 100, 100);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.userInteractionEnabled = YES;
            imageView.tag = index;
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
            [imageView sd_setImageWithURL:_imageURLs[index]];
            imageView.clipsToBounds = YES;
            [_imageContainer addSubview:imageView];
            index ++;
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tapImage:(UITapGestureRecognizer *)gesture{
    ImageBrowserView *broserManger = [[ImageBrowserView alloc] initWithFrame:self.view.frame];
    [broserManger setImageURLs:self.imageURLs];
    [broserManger browserImageFromImageView:(UIImageView *)[gesture view] atURLIndex:gesture.view.tag];
}

-(UIImageView *)imageViewForIndex:(NSInteger)index{
    for (UIImageView *imageView in self.imageContainer.subviews) {
        if (imageView.tag == index) {
            return imageView;
        }
    }
    return nil;
//    return [self.imageContainer viewWithTag:index];
}

@end
