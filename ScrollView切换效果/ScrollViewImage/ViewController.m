//
//  ViewController.m
//  ScrollViewImage
//
//  Created by snqu-ios on 16/6/6.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import "ViewController.h"
#import "Math.h"
#import "UIView+SetRect.h"
#import "MoreInfoView.h"

static int type    = 0;
static int viewTag = 0x11;

@interface ViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) NSArray       *picturesArray;
@property (nonatomic, weak) IBOutlet UIScrollView  *scrollView;
@property (nonatomic, strong) Math          *onceLinearEquation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)setup {
    
    MATHPoint pointA;
    MATHPoint pointB;
    
    // Type.
    if (type % 4 == 0) {
        
        pointA = MATHPointMake(0, 0);
        pointB = MATHPointMake(self.view.width, 270 - 80);
        
    } else if (type % 4 == 1) {
        
        pointA = MATHPointMake(0, 0);
        pointB = MATHPointMake(self.view.width, 270 - 20);
        
    } else if (type % 4 == 2) {
        
        pointA = MATHPointMake(0, 0);
        pointB = MATHPointMake(self.view.width, 270 + 20);
        
    } else if (type % 4 == 3) {
        
        pointA = MATHPointMake(0, 0);
        pointB = MATHPointMake(self.view.width, 270 + 80);
    }
    
    self.onceLinearEquation = [Math mathOnceLinearEquationWithPointA:pointA PointB:pointB];
    
    type++;
    
    // Init pictures data.
    self.picturesArray = @[[UIImage imageNamed:@"1"],
                           [UIImage imageNamed:@"2"],
                           [UIImage imageNamed:@"3"],
                           [UIImage imageNamed:@"4"],
                           [UIImage imageNamed:@"5"]];
    
    // Init scrollView.
    CGFloat height = self.scrollView.frame.size.height;
    CGFloat width  = self.scrollView.frame.size.width;
    
    _scrollView.delegate                       = self;
    _scrollView.pagingEnabled                  = YES;
    _scrollView.backgroundColor                = [UIColor blackColor];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.bounces                        = NO;
    _scrollView.contentSize                    = CGSizeMake(self.picturesArray.count * width, height);
    [self.view addSubview:_scrollView];
    
    // Init moreInfoViews.
    for (int i = 0; i < self.picturesArray.count; i++) {
        
        MoreInfoView *show   = [[MoreInfoView alloc] initWithFrame:CGRectMake(i * width, 0, width, height)];
        show.imageView.image = self.picturesArray[i];
        show.tag             = viewTag + i;
        
        [_scrollView addSubview:show];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat X = scrollView.contentOffset.x;
    
    for (int i = 0; i < self.picturesArray.count; i++) {
        
        MoreInfoView *show = (MoreInfoView *)[scrollView viewWithTag:viewTag + i];
        show.imageView.x = _onceLinearEquation.k * (X - i * self.view.width) + _onceLinearEquation.b;
    }
}

@end
