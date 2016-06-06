//
//  TestViewController.m
//  ScrollViewImage
//
//  Created by snqu-ios on 16/6/6.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import "TestViewController.h"
#import <CoreText/CoreText.h>

@interface TestViewController ()
@property(nonatomic, weak) IBOutlet UILabel *testLabel;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *infoString = @"March 23rd - March 30th";
    NSRange superscriptingRange = [infoString rangeOfString:@"rd"];
    NSRange subscriptingRange = [infoString rangeOfString:@"th"];

    NSMutableAttributedString *attrS = [[NSMutableAttributedString alloc] initWithString:infoString];
    // value 1 上标 -1 下标
    [attrS addAttribute:(NSString *)kCTSuperscriptAttributeName value:@1 range:superscriptingRange];
    [attrS addAttribute:(NSString *)kCTSuperscriptAttributeName value:@-1 range:subscriptingRange];
    
    _testLabel.attributedText = attrS;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
