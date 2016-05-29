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
#import <AVFoundation/AVFoundation.h>

@interface RecodingViewController ()<UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UIView *preview;
@property (weak, nonatomic) IBOutlet StartRecoderButton *startRecoderButton;
@property (nonatomic, strong) RecorderManager *recorderManager;


@end

@implementation RecodingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupRecorderManager];
    
}


-(void)setupRecorderManager{
    self.recorderManager = [[RecorderManager alloc] init];
    [self.preview.layer addSublayer:self.recorderManager.previewLayer];
    self.preview.clipsToBounds = YES;
    
    self.recorderManager.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.recorderManager.previewLayer.frame = self.preview.bounds;
    self.recorderManager.previewLayer.position = CGPointMake(CGRectGetMidX(self.preview.bounds), CGRectGetMidY(self.preview.bounds));
    
    [self.recorderManager authorizationPermissionWithBlock:^(BOOL granted) {
        if (granted) {
            [self.recorderManager startPreview];
        }else{
            //
            self.startRecoderButton.enabled = NO;
        }
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.recorderManager startPreview];
}

#pragma mark - UINavigationBarDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}



// 需要将手动添加到 xib 中的 NavigationBar 的 delegate 设置为 self
- (IBAction)goBack:(id)sender {
    [self.recorderManager stopPreview];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)transferCameraPosition:(id)sender {
}

- (IBAction)startRecoderAction:(StartRecoderButton *)sender {
    if ([self.recorderManager isRecording]) {
        [self.recorderManager stopPreview];
        [self.recorderManager stopRecord];
    }else{
        [self.recorderManager startPreview];
        [self.recorderManager startRecord];
    }
}

@end
