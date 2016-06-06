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
#import "CaptureSessionAssetWriterCoordinator.h"
#import "IDFileManager.h"

@interface RecodingViewController ()<UINavigationBarDelegate, CaptureSessionCoordinatorDelegate>

@property (weak, nonatomic) IBOutlet UIView *preview;
@property (weak, nonatomic) IBOutlet StartRecoderButton *startRecoderButton;
@property (nonatomic, strong) RecorderManager *recorderManager;
@property (nonatomic, strong) CaptureSessionAssetWriterCoordinator *captureSessionCoordinator;


@end

@implementation RecodingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSString *titleString = nil;
    if (self.mode == PiplelineModeMoveFileOutput) {
        titleString = @"PiplelineModeMoveFileOutput";
        [self setupRecorderManager];
        
    }else{
        titleString = @"PipelineModeAssetWriter";
        [self setupWritterRecorderManager];
    }
    self.navigationBarTitle.title = titleString;
    
    
    
}

-(void)setupWritterRecorderManager{
    _captureSessionCoordinator = [[CaptureSessionAssetWriterCoordinator alloc] init];
    [_captureSessionCoordinator setDeledate:self callbackQueue:dispatch_get_main_queue()];
    
    AVCaptureVideoPreviewLayer *previewLayer = [_captureSessionCoordinator previewLayer];
    previewLayer.frame = self.preview.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.preview.layer insertSublayer:previewLayer atIndex:0];
    self.preview.clipsToBounds = YES;
    [_captureSessionCoordinator startRunning];
    
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
    if (self.mode == PiplelineModeMoveFileOutput) {
        [self.recorderManager startPreview];
    }else{
    
    }
    
}

#pragma mark - UINavigationBarDelegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}



// 需要将手动添加到 xib 中的 NavigationBar 的 delegate 设置为 self
- (IBAction)goBack:(id)sender {
    
    if (self.mode == PiplelineModeMoveFileOutput) {
        [self.recorderManager stopPreview];
    }else{
        [self.captureSessionCoordinator stopRunning];
        [self.captureSessionCoordinator stopRecording];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)transferCameraPosition:(id)sender {
    [self.recorderManager transferCameraPosition];
}

int i = 0;
- (IBAction)startRecoderAction:(StartRecoderButton *)sender {
    if (self.mode == PiplelineModeMoveFileOutput ) {
        if ([self.recorderManager isRecording]) {
            [self.recorderManager stopPreview];
            [self.recorderManager stopRecord];
        }else{
            [self.recorderManager startPreview];
            [self.recorderManager startRecord];
        }
    }else{
        if (i == 0) {
            i++;
            [self.captureSessionCoordinator startRunning];
            [self.captureSessionCoordinator startRecording];
        }else{
            i--;
            [self.captureSessionCoordinator stopRunning];
            [self.captureSessionCoordinator stopRecording];
        }
    }
    
}

#pragma mark - CaptureSessionCoordinatorDelegate
-(void)coordinatorDidBeginRecording:(CaptureSessionCoordinator *)coordinator{
    
}
-(void)coordinator:(CaptureSessionCoordinator *)coordinator didFinishRecordingToOutputFileURL:(NSURL *)outputFileURL error:(NSError *)error{
//    IDFileManager *fm = [IDFileManager new];
//    [fm copyFileToDocuments:outputFileURL];
//    [fm copyFileToCameraRoll:outputFileURL];
    
    [self copyFileToCacheDirFromURL:outputFileURL];
    
}


-(void)copyFileToCacheDirFromURL:(NSURL *)srcURL {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"srcURL = %@", srcURL);
        NSString *destURL = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        destURL = [destURL stringByAppendingPathComponent:@"test01.mov"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:destURL]) {
            [fileManager removeItemAtPath:destURL error:nil];
        }
        NSError *error = nil;
        NSString *srcURL = [NSString stringWithFormat:@"%@output%d.mov", NSTemporaryDirectory(), 0];
        [fileManager copyItemAtPath:srcURL toPath:destURL error:&error];
        if (error) {
            NSLog(@"保存失败 = %@", error);
        }else{
            NSLog(@"保存成功");
        }
        // 删除 temp 目录下临时文件
        if ([fileManager fileExistsAtPath:srcURL]) {
            [fileManager removeItemAtPath:srcURL error:nil];
            NSLog(@"删除缓存成功");
        }else{
            NSLog(@"删除缓存失败");
        }
        
    });
}

@end
