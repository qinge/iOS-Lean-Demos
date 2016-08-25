//
//  ViewController.m
//  ScrollItemJumpAnimation
//
//  Created by snqu-ios on 16/8/23.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//  web.goshipster.com

#import "ViewController.h"
#import "ScrollJumpView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet ScrollJumpView *scrollJumpView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    for (int i = 0; i < 30; i++) {
        [_dataArray addObject:@(i)];
    }
    _scrollJumpView.itemsArray = _dataArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
