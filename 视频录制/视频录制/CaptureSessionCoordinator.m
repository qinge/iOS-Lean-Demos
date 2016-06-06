//
//  CaptureSessionCoordinator.m
//  视频录制
//
//  Created by snqu-ios on 16/5/31.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import "CaptureSessionCoordinator.h"

@interface CaptureSessionCoordinator()

@property (nonatomic, strong) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation CaptureSessionCoordinator

-(instancetype)init {
    self = [super init];
    if (self) {
        _sessionQueue = dispatch_queue_create("com.qin.capturepipeline.session", DISPATCH_QUEUE_SERIAL);
        _captureSession = [self setupCaptureSession];
    }
    return self;
}

-(void)setDeledate:(id<CaptureSessionCoordinatorDelegate>)delegate callbackQueue:(dispatch_queue_t)delegateCallbackQueue{
    if(delegate && ( delegateCallbackQueue == NULL)){
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Caller must provide a delegateCallbackQueue" userInfo:nil];
    }
    @synchronized(self) {
        self.delegate = delegate;
        if (delegateCallbackQueue != _delegateCallbackQueue) {
            _delegateCallbackQueue = delegateCallbackQueue;
        }
    }
}

-(AVCaptureVideoPreviewLayer *)previewLayer{
    if (!_previewLayer && _captureSession) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    }
    return _previewLayer;
}


-(void)startRunning{
    dispatch_async(_sessionQueue, ^{
        [self.captureSession startRunning];
    });
}

-(void)stopRunning{
    dispatch_async(_sessionQueue, ^{
        [self stopRecording]; // does nothing if we aren't currently recording
        [self.captureSession stopRunning];
    });
}

-(void)startRecording{
    //overwritten by subclass
}

-(void)stopRecording{
    //overwritten by subclass
}

-(AVCaptureSession *)setupCaptureSession{
    AVCaptureSession *captureSession = [AVCaptureSession new];
    
    [self addDefaultCameraInputToCaptureSession:captureSession];
    [self addDefaultMicInputToCaptureSession:captureSession];
    
    return captureSession;
}

#pragma mark - 添加视频输入

-(BOOL)addDefaultCameraInputToCaptureSession:(AVCaptureSession *)captureSession{
    NSError *error;
    AVCaptureDeviceInput *cameraDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:&error];
    if (error) {
        NSLog(@"error configuring camera input: %@", [error localizedDescription]);
        return NO;
    }else{
        BOOL success = [self addInput:cameraDeviceInput toCaptureSession:captureSession];
        return success;
    }
}

#pragma mark - 添加音频输入
- (BOOL)addDefaultMicInputToCaptureSession:(AVCaptureSession *)captureSession{
    NSError *error;
    AVCaptureDeviceInput *micDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:&error];
    if (error) {
        NSLog(@"error configuring mic input: %@", [error localizedDescription]);
        return NO;
    }else{
        BOOL success = [self addInput:micDeviceInput toCaptureSession:captureSession];
        return success;
    }
}

- (BOOL)addInput:(AVCaptureDeviceInput *)input toCaptureSession:(AVCaptureSession *)captureSession{
    if ([captureSession canAddInput:input]) {
        [captureSession addInput:input];
        return YES;
    }else{
        NSLog(@"can't add input: %@", [input description]);
        return NO;
    }
}


#pragma mark - 选择相机位置
- (BOOL)addCameraAtPosition:(AVCaptureDevicePosition)position toCaptureSession:(AVCaptureSession *)captureSession{
    NSError *error;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *cameraDeviceInput;
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            cameraDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
            break;
        }
    }
    if (!cameraDeviceInput) {
        NSLog(@"No capture device found for requested position");
        return NO;
    }
    
    if (error) {
        NSLog(@"error configuring camera input: %@", [error localizedDescription]);
        return NO;
    }else{
        BOOL success = [self addInput:cameraDeviceInput toCaptureSession:captureSession];
        _cameraDevice = cameraDeviceInput.device;
        return success;
    }
    
}

#pragma mark - 添加输出

-(BOOL)addOutput:(AVCaptureOutput *)output toCaptureSession:(AVCaptureSession *)captureSession{
    if ([captureSession canAddOutput:output]) {
        [captureSession addOutput:output];
        return YES;
    }else{
        NSLog(@"can't add output: %@", [output description]);
        return NO;
    }
}

/**
 *  设置 录制时长
 *
 *  @param frameDuration
 *  @param device
 */

-(void)setFrameRateWithDuration:(CMTime)frameDuration OnCaptureDevice:(AVCaptureDevice *)device{
    NSError *error;
    NSArray *supportedFrameRateRanges = [device.activeFormat videoSupportedFrameRateRanges];
    BOOL frameRateSupported = NO;
    for (AVFrameRateRange *range in supportedFrameRateRanges) {
        if (CMTIME_COMPARE_INLINE(frameDuration, >=, range.minFrameDuration) && CMTIME_COMPARE_INLINE(frameDuration, <=, range.maxFrameDuration)) {
            frameRateSupported = YES;
            break;  // 需要验证是否应该 终止
        }
    }
    
    if (frameRateSupported && [device lockForConfiguration:&error]) {
        [device setActiveVideoMaxFrameDuration:frameDuration];
        [device setActiveVideoMinFrameDuration:frameDuration];
        [device unlockForConfiguration];
    }
    
}

-(void)listCamerasAndMics{
    NSLog(@"%@", [[AVCaptureDevice devices] description]);
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        NSLog(@"error = %@", [error localizedDescription]);
    }
    
    [audioSession setActive:YES error:&error];
    
    NSArray *availableAudioInputs = [audioSession availableInputs];
    for (AVAudioSessionPortDescription *portDescription in  availableAudioInputs) {
        NSLog(@" data source: %@", [[portDescription dataSources] description]);
    }
    
    if ([availableAudioInputs count] > 0) {
        AVAudioSessionPortDescription *poreDescription = [availableAudioInputs firstObject];
        if ([[poreDescription dataSources] count] > 0) {
            NSError *error;
            AVAudioSessionDataSourceDescription *dataSource = [[poreDescription dataSources] lastObject];
            [poreDescription setPreferredDataSource:dataSource error:&error];
            [self logError:error];
            
            [audioSession setPreferredInput:poreDescription error:&error];
            [self logError:error];
            
            NSArray *availableAudioInputs = [audioSession availableInputs];
            NSLog(@"auudio inputs : %@", [availableAudioInputs description]);
        }
    }
}

- (void)logError:(NSError *)error
{
    if(error){
        NSLog(@"%@", [error localizedDescription]);
    }
}

-(void)configureFrontMic{
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [audioSession setActive:YES error:&error];
    
    NSArray *inputs = [audioSession availableInputs];
    AVAudioSessionPortDescription *builtInMic = nil;
    for (AVAudioSessionPortDescription *port in  inputs) {
        if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic]) {
            builtInMic = port;
            break;
        }
    }
    
    for (AVAudioSessionDataSourceDescription *source in builtInMic.dataSources) {
        if ([source.orientation isEqual:AVAudioSessionOrientationFront]) {
            [builtInMic setPreferredDataSource:source error:nil];
            [audioSession setPreferredInput:builtInMic error:&error];
            break;
        }
    }
    
}


@end
