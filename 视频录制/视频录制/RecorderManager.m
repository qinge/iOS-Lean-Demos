//
//  RecorderManager.m
//  视频录制
//
//  Created by snqu-ios on 16/5/27.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import "RecorderManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface RecorderManager()<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *cameraDeviceInput;
@property (nonatomic, strong) AVCaptureDeviceInput *micDeviceInput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;

@property (nonatomic, strong) dispatch_queue_t sessionQueue;

@end


@implementation RecorderManager


-(instancetype)init{
    self = [super init];
    if (self) {
        [self configRecord];
    }
    return self;
}


// 授权

-(void)authorizationPermissionWithBlock:(authorizationResult) block {
    //    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (block) {
            block(granted);
        }
    }];
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
    
    
    self.sessionQueue = dispatch_queue_create("com.example.capture.session", DISPATCH_QUEUE_SERIAL);
}

-(void)startPreview{
    dispatch_async(self.sessionQueue, ^{
        [self.captureSession startRunning];
    });
}

-(void)stopPreview{
    dispatch_async(self.sessionQueue, ^{
        [self.captureSession stopRunning];
    });
}


- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if(!_previewLayer && _captureSession){
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    }
    return _previewLayer;
}


-(void)startRecord{
    self.isRecording = YES;
    NSURL *outputUrl = [self tempFileURL];
    [self.movieFileOutput startRecordingToOutputFileURL:outputUrl recordingDelegate:self];
}

-(void)stopRecord{
    self.isRecording = NO;
    [self.movieFileOutput stopRecording];
}

- (NSURL *)tempFileURL
{
    NSString *path = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSInteger i = 0;
    while(path == nil || [fm fileExistsAtPath:path]){
        path = [NSString stringWithFormat:@"%@output%ld.mov", NSTemporaryDirectory(), (long)i];
        i++;
    }
    return [NSURL fileURLWithPath:path];
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    
}


- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    [self copyFileToCameraRoll:outputFileURL];
}


- (void)copyFileToCameraRoll:(NSURL *)fileURL
{
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    if(![library videoAtPathIsCompatibleWithSavedPhotosAlbum:fileURL]){
//        NSLog(@"video incompatible with camera roll");
//    }
//    [library writeVideoAtPathToSavedPhotosAlbum:fileURL completionBlock:^(NSURL *assetURL, NSError *error) {
//        
//        if(error){
//            NSLog(@"Error: Domain = %@, Code = %@", [error domain], [error localizedDescription]);
//        } else if(assetURL == nil){
//            
//            //It's possible for writing to camera roll to fail, without receiving an error message, but assetURL will be nil
//            //Happens when disk is (almost) full
//            NSLog(@"Error saving to camera roll: no error message, but no url returned");
//            
//        } else {
//            //remove temp file
//            NSError *error;
//            [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
//            if(error){
//                NSLog(@"error: %@", [error localizedDescription]);
//            }
//            
//        }
//    }];
    
    
    NSString *destUrl = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    destUrl = [destUrl stringByAppendingPathComponent:@"test01.mov"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager isExecutableFileAtPath:destUrl]) {
        [fileManager removeItemAtPath:destUrl error:nil];
    }
    NSError *error = nil;
    NSString *src = [NSString stringWithFormat:@"%@output%d.mov", NSTemporaryDirectory(), 0];
    [fileManager copyItemAtPath:src toPath:destUrl error:&error];
    if (error) {
        NSLog(@"保存失败 = %@", error);
    }else{
        NSLog(@"保存成功");
    }
    
}

@end
