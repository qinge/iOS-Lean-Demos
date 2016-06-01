//
//  ViewController.m
//  VideoRecord
//
//  Created by qinge on 16/6/1.
//  Copyright © 2016年 qin. All rights reserved.
//  https://github.com/piemonte/PBJVision

#import "ViewController.h"
#import <PBJVision/PBJVision.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()<PBJVisionDelegate>
@property (weak, nonatomic) IBOutlet UIView *preview;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) PBJVision *vision;

@property (nonatomic, assign) BOOL recording;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupPreviewLayer];
    [self setupPBJVision];
    [self.vision startPreview];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestureRecognizer:)];
    [self.preview addGestureRecognizer:longPressGesture];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


-(void)setupPreviewLayer{
    AVCaptureVideoPreviewLayer *previewLayer = [[PBJVision sharedInstance] previewLayer];
    previewLayer.frame = self.preview.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.preview.layer addSublayer:previewLayer];
}

-(void)setupPBJVision{
    self.vision = [PBJVision sharedInstance];
    self.vision.delegate = self;
    self.vision.cameraMode = PBJCameraModeVideo;
    self.vision.cameraOrientation = PBJCameraOrientationPortrait;
    self.vision.focusMode = PBJFocusModeContinuousAutoFocus;
    self.vision.outputFormat = PBJOutputFormatSquare;
//    self.vision.additionalCompressionProperties = @{AVVideoProfileLevelKey : AVVideoProfileLevelH264Baseline30};
}



- (IBAction)recordAction:(UIButton *)sender {
    [_recordButton setTitle:@"...ing" forState:UIControlStateNormal];
        [self.vision startVideoCapture];
    self.timer = [NSTimer timerWithTimeInterval:10.0 target:self selector:@selector(timerEnded:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];

}


-(void)handleLongPressGestureRecognizer:(UILongPressGestureRecognizer *)gesture{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            if (!_recording) {
                [self.vision startVideoCapture];
                self.timer.fireDate = [NSDate distantPast];
                [_recordButton setTitle:@"...ing" forState:UIControlStateNormal];
            }else{
//                [self.vision resumeVideoCapture];
            }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
//            [self.vision pauseVideoCapture];
            [self.vision endVideoCapture];
            break;
            
        default:
            break;
    }
}


-(void)timerEnded:(NSTimer *)timer{
    NSLog(@"once circle");
    [_recordButton setTitle:@"action" forState:UIControlStateNormal];
    [self.vision endVideoCapture];
    self.timer = nil;
}

#pragma mark - PBJVisionDelegate

- (void)vision:(PBJVision *)vision capturedVideo:(nullable NSDictionary *)videoDict error:(nullable NSError *)error{
    if (error && [error.domain isEqual:PBJVisionErrorDomain] && error.code == PBJVisionErrorCancelled) {
        NSLog(@"recording session cancelled");
        return;
    } else if (error) {
        NSLog(@"encounted an error in video capture (%@)", error);
        return;
    }
    NSString *currentVideo = [videoDict objectForKey:PBJVisionVideoPathKey];
    NSURL *videoURL = [NSURL fileURLWithPath:currentVideo];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:^(NSURL *assetURL, NSError *error1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Video Saved!" message: @"Saved to the camera roll."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }];

}



@end
