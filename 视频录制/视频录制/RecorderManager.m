//
//  RecorderManager.m
//  视频录制
//
//  Created by snqu-ios on 16/5/27.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import "RecorderManager.h"
#import <AVFoundation/AVFoundation.h>

@interface RecorderManager()<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *cameraDeviceInput;
@property (nonatomic, strong) AVCaptureDeviceInput *micDeviceInput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;

@property (nonatomic, strong) dispatch_queue_t sessionQueue;

@end


@implementation RecorderManager

+(instancetype)sharedInstance{
    static RecorderManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[RecorderManager alloc] init];
        [instance configRecord];
    });
    return instance;
}


-(void)configRecord{
    self.captureSession = [AVCaptureSession new];
    
    // 视频输入
    AVCaptureDevice *cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    self.cameraDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:cameraDevice error:&error];
    if ([self.captureSession canAddInput:self.cameraDeviceInput]) {
        [self.captureSession addInput:self.cameraDeviceInput];
    }
    
    // 贞率设置
    CMTime frameDuration = CMTimeMake(1, 60);
    NSArray *supportedFrameRateRanges = [cameraDevice.activeFormat videoSupportedFrameRateRanges];
    BOOL frameRateSupported = NO;
    for (AVFrameRateRange *range in supportedFrameRateRanges) {
        if (CMTIME_COMPARE_INLINE(frameDuration, >=, range.minFrameDuration) && CMTIME_COMPARE_INLINE(frameDuration, <=, range.maxFrameDuration)) {
            frameRateSupported = YES;
        }
    }
    
    // 配置之前需要先锁定
    if (frameRateSupported && [cameraDevice lockForConfiguration:&error]) {
        [cameraDevice setActiveVideoMaxFrameDuration:frameDuration];
        [cameraDevice setActiveVideoMinFrameDuration:frameDuration];
        [cameraDevice unlockForConfiguration];
    }
    
    // 视频防抖
//    AVCaptureConnection *connection = [[AVCaptureConnection alloc] init];
//    AVCaptureVideoStabilizationMode stabilizationMode = AVCaptureVideoStabilizationModeCinematic;
//    if ([cameraDevice.activeFormat isVideoStabilizationModeSupported:stabilizationMode]) {
//        [connection setPreferredVideoStabilizationMode:stabilizationMode];
//    }
    
    
    // 音频输入
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    
    // 寻找期望的输入端口
    NSArray *inputs = [audioSession availableInputs];
    AVAudioSessionPortDescription *builtInMic = nil;
    for (AVAudioSessionPortDescription *port in inputs) {
        if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
            builtInMic = port;
            break;
        }
    }
    
    // 寻找期望的麦克风
    for (AVAudioSessionDataSourceDescription *source in builtInMic.dataSources) {
        if ([source.orientation isEqual:AVAudioSessionOrientationFront]) {
            [builtInMic setPreferredDataSource:source error:nil];
            [audioSession setPreferredInput:builtInMic error:&error];
            break;
        }
    }
    
    // 输出
    self.movieFileOutput = [AVCaptureMovieFileOutput new];
    if ([self.captureSession canAddOutput:self.movieFileOutput]) {
        [self.captureSession addOutput:self.movieFileOutput];
    }
    
    // 实时预览
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    
    
    self.sessionQueue = dispatch_queue_create("com.example.capture.session", DISPATCH_QUEUE_SERIAL);
}


-(void)startRecord{
    NSLog(@"%s", __FUNCTION__);
    self.isRecording = YES;
    NSString *fileUrl = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    fileUrl = [fileUrl stringByAppendingPathComponent:@"test01.mov"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if (![fileManager isExecutableFileAtPath:fileUrl]) {
//        [fileManager delete:fileUrl];
//    }
    NSURL *outputUrl = [NSURL fileURLWithPath:fileUrl];
    
    [self.movieFileOutput startRecordingToOutputFileURL:outputUrl recordingDelegate:self];
    
    dispatch_async(self.sessionQueue, ^{
        [self.captureSession startRunning];
    });
    
    
    
    
}

-(void)stopRecord{
    NSLog(@"%s", __FUNCTION__);
    self.isRecording = NO;
    
    dispatch_async(self.sessionQueue, ^{
        [self.captureSession stopRunning];
    });
}


#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    
}

@end
