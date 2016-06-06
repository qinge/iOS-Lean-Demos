//
//  ViewController.m
//  视频录制
//
//  Created by snqu-ios on 16/5/27.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import "ViewController.h"
#import "RecodingViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    RecodingViewController *rvc = (RecodingViewController *)segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"MovieFileOutput"]) {
        rvc.mode = PiplelineModeMoveFileOutput;
    }else if ([segue.identifier isEqualToString:@"AssetWriter"]){
        rvc.mode = PipelineModeAssetWriter;
    }
}



@end
