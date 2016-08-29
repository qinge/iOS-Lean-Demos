//
//  TestViewController.m
//  ScrollViewReuseItem
//
//  Created by snqu-ios on 16/8/29.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import "TestViewController.h"
#import "HYReuseScrollView.h"
#import "MyView.h"

@interface TestViewController () <HYReuseScrollViewDataSource, HYReuseScrollViewDelegate>

@property (nonatomic, strong) HYReuseScrollView *scrollView;

@end

@implementation TestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView = [[HYReuseScrollView alloc]initWithFrame:self.view.bounds];
    self.scrollView.reuseDelegate = self;
    self.scrollView.reuseDataSource = self;
    //    self.scrollView.pagingEnabled = YES;
    
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.scrollView];
    
    [self.scrollView reloadData];
}

- (HYReuseView *)scrollView:(HYReuseScrollView *)scrollView viewForItemAtIndex:(NSInteger)index
{
    static NSString *str = @"view";
    MyView *view = [scrollView dequeueReusableViewWithIdentifier:str];
    if (!view) {
        view = [[MyView alloc]initWithReuseIdentifier:str];
    }
    
    [view setText:[NSString stringWithFormat:@"%d", index]];
    
    int color = index % 4;
    switch (color) {
        case 0:
            view.backgroundColor = [UIColor blueColor];
            break;
        case 1:
            view.backgroundColor = [UIColor greenColor];
            break;
        case 2:
            view.backgroundColor = [UIColor orangeColor];
            break;
        default:
            view.backgroundColor = [UIColor blackColor];
            break;
    }
    return view;
}

- (NSInteger)numberOfItemsInScrollView:(HYReuseScrollView *)scrollView
{
    return 100;
}

- (UIEdgeInsets)scrollView:(HYReuseScrollView *)scrollView insetForForItemAtIndex:(NSInteger)index
{
    return UIEdgeInsetsMake(20, 10, 20, 10);
}

@end

