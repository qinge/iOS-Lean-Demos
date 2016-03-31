
//
//  ViewController.m
//  CircleImageShow
//
//  Created by snqu-ios on 16/3/31.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import "ViewController.h"
#import "BannerView.h"

@interface ViewController ()<BannerViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *urls = @[
                      @"http://7xiwnz.com2.z0.glb.qiniucdn.com/element1/201601/51505010.jpg?v=1452049587",
                      @"http://7xiwnz.com2.z0.glb.qiniucdn.com/element1/201601/48975450.jpg?v=1452504384"
                      ];
    CGRect bannerFrame = CGRectMake(0, 0, 320, 150);
    BannerView *bannerView = [[BannerView alloc] initWithFrame:bannerFrame withImageUrls:urls];
    bannerView.userInteractionEnabled = YES;
    bannerView.delegate = self;
    [self.view addSubview:bannerView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)bannerViewDidScrollToIndex:(NSInteger)index{
    NSLog(@"index = %ld", index);
}

@end
