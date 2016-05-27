//
//  RecodingViewController.m
//  视频录制
//
//  Created by snqu-ios on 16/5/27.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import "RecodingViewController.h"
#import "StartRecoderButton.h"
#import "RecorderManager.h"

@interface RecodingViewController ()<UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UIView *preview;
@property (weak, nonatomic) IBOutlet StartRecoderButton *startRecoderButton;


@end

@implementation RecodingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [RecorderManager sharedInstance].previewLayer.frame = self.preview.bounds;
    [self.preview.layer addSublayer:[RecorderManager sharedInstance].previewLayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UINavigationBarDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}


// 需要将手动添加到 xib 中的 NavigationBar 的 delegate 设置为 self
- (IBAction)goBack:(id)sender {
    [[RecorderManager sharedInstance] stopRecord];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)transferCameraPosition:(id)sender {
}

- (IBAction)startRecoderAction:(StartRecoderButton *)sender {
    if ([[RecorderManager sharedInstance] isRecording]) {
        [[RecorderManager sharedInstance] stopRecord];
    }else{
        [[RecorderManager sharedInstance] startRecord];
    }
}

@end
