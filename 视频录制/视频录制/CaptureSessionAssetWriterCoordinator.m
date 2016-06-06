//
//  CaptureSessionAssetWriterCoordinator.m
//  视频录制
//
//  Created by snqu-ios on 16/5/31.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import "CaptureSessionAssetWriterCoordinator.h"
#import "IDFileManager.h"
#import "AssertWriterCoordinator.h"

typedef NS_ENUM(NSInteger, RecordingStatus) {
    RecordingStatusIdle = 0,
    RecordingStatusStartingRecording,
    RecordingStatusRecording,
    RecordingStatusStoppingRecording
};


@interface CaptureSessionAssetWriterCoordinator()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, AssetWriterCoordinatorDelegate>

@property (nonatomic, strong) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic, strong) dispatch_queue_t audioDataOutputQueue;

@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioDataOutput;

@property (nonatomic, strong) AVCaptureConnection *audioConnection;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;

@property (nonatomic, strong) NSDictionary *videoCompressionSettings;
@property (nonatomic, strong) NSDictionary *audioCompressionSettings;

@property (nonatomic, strong) AVAssetWriter *asstWriter;

@property (nonatomic, assign) RecordingStatus recordingStatus;
@property (nonatomic, strong) NSURL *recordingURL;

@property (nonatomic, retain) __attribute__ ((NSObject)) CMFormatDescriptionRef outputVideoFormatDescription;
@property (nonatomic, retain) __attribute__ ((NSObject)) CMFormatDescriptionRef outputAudioFormatDescription;

@property (nonatomic, retain) AssertWriterCoordinator *assetWriterCoordinator;

@end


@implementation CaptureSessionAssetWriterCoordinator

-(instancetype)init {
    self = [super init];
    if (self) {
        self.videoDataOutputQueue = dispatch_queue_create("com.qin.capturession.videodata", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_videoDataOutputQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
        self.audioDataOutputQueue = dispatch_queue_create("com.qin.capturession.audiodata", DISPATCH_QUEUE_SERIAL);
        
        [self addDataOutputsToCaptureSession:self.captureSession];
        [self setCompressionSettings];
    }
    return self;
}

#pragma mark - private methods 

- (void)addDataOutputsToCaptureSession:(AVCaptureSession *)captureSession{
    self.videoDataOutput = [AVCaptureVideoDataOutput new];
    _videoDataOutput.videoSettings = nil;
    _videoDataOutput.alwaysDiscardsLateVideoFrames = NO;
    [_videoDataOutput setSampleBufferDelegate:self queue:_videoDataOutputQueue];
    
    self.audioDataOutput = [AVCaptureAudioDataOutput new];
    [_audioDataOutput setSampleBufferDelegate:self queue:_audioDataOutputQueue];
    
    
    [self addOutput:_videoDataOutput toCaptureSession:self.captureSession];
    _videoConnection = [_videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    
    [self addOutput:_audioDataOutput toCaptureSession:self.captureSession];
    _audioConnection = [_audioDataOutput connectionWithMediaType:AVMediaTypeAudio];
    
}

-(void)setCompressionSettings{
    _videoCompressionSettings = [_videoDataOutput recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie];
    _audioCompressionSettings = [_audioDataOutput recommendedAudioSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie];
}

-(void)setupVideoPipelineWithInputFormatDescription:(CMFormatDescriptionRef)inputFormatDescription{
    self.outputVideoFormatDescription = inputFormatDescription;
}

-(void)teardownVideoPipeline{
    self.outputVideoFormatDescription = nil;
}


#pragma mark - Recording
-(void)startRecording{
    @synchronized(self) {
        if (_recordingStatus != RecordingStatusIdle) {
            NSLog(@"Already recording");
            return;
        }
        [self transitionToRecordingStatus:RecordingStatusStartingRecording error:nil];
    }
    
    IDFileManager *fm = [IDFileManager new];
    _recordingURL = [fm tempFileURL];
    
    self.assetWriterCoordinator = [[AssertWriterCoordinator alloc] initWithURL:_recordingURL];
    if (_outputAudioFormatDescription != nil) {
        [_assetWriterCoordinator addAudioTrackWithSourceFormatDescription:self.outputAudioFormatDescription settings:_audioCompressionSettings];
    }
    [_assetWriterCoordinator addVideoTrackWithSourceFormatDescription:self.outputVideoFormatDescription settings:_videoCompressionSettings];
    
    dispatch_queue_t callbackQueue = dispatch_queue_create("com.example.capturesession.writercallback", DISPATCH_QUEUE_SERIAL);
    [_assetWriterCoordinator setDelegate:self callbackQueue:callbackQueue];
    [_assetWriterCoordinator prepareToRecord];
    
}

-(void)stopRecording{
    @synchronized(self) {
        if (_recordingStatus != RecordingStatusRecording) {
            return;
        }
        [self transitionToRecordingStatus:RecordingStatusStoppingRecording error:nil];
    }
    
    [self.assetWriterCoordinator finishRecording];
}


#pragma mark - AssetWriterCoordinatorDelegate

-(void)writerCoordinatorDidFinishPreparing:(AssertWriterCoordinator *)coordinator{
    @synchronized(self) {
        if (_recordingStatus != RecordingStatusStartingRecording) {
            NSLog(@"Expected to be in StartingRecording state");
            return;
        }
        
        [self transitionToRecordingStatus:RecordingStatusRecording error:nil];
    }
}

-(void)writerCoordinator:(AssertWriterCoordinator *)coordinator didFailWithError:(NSError *)error{
    @synchronized(self) {
        self.assetWriterCoordinator = nil;
        [self transitionToRecordingStatus:RecordingStatusIdle error:nil];
    }
}

-(void)writerCoordinatorDidFinishRecording:(AssertWriterCoordinator *)coordinator{
    @synchronized(self) {
        if (_recordingStatus != RecordingStatusStoppingRecording) {
            NSLog(@"Expected to be in StoppingRecording state");
            return;
        }
    }
    
    self.assetWriterCoordinator = nil;
    
    @synchronized(self) {
        [self transitionToRecordingStatus:RecordingStatusIdle error:nil];
    }
}

#pragma mark - Recording State Machine

/**
 *  录制状态的改变 可判断 delegate 回调的方法
 *
 *  @param newStatus
 *  @param error
 */
- (void)transitionToRecordingStatus:(RecordingStatus)newStatus error:(NSError *)error{
    RecordingStatus oldStatus = _recordingStatus;
    _recordingStatus = newStatus;
    
    if (newStatus != oldStatus) {
        if (error && (newStatus == RecordingStatusIdle)) {
            dispatch_async(self.delegateCallbackQueue, ^{
                @autoreleasepool {
                    [self.delegate coordinator:self didFinishRecordingToOutputFileURL:_recordingURL error:nil];
                }
            });
        }else{
            error = nil;
            if (oldStatus == RecordingStatusStartingRecording && newStatus == RecordingStatusRecording ) {
                dispatch_async(self.delegateCallbackQueue, ^{
                    @autoreleasepool {
                        [self.delegate coordinatorDidBeginRecording:self];
                    }
                });
            }else if (oldStatus == RecordingStatusStoppingRecording && newStatus == RecordingStatusIdle){
                dispatch_async(self.delegateCallbackQueue, ^{
                    @autoreleasepool {
                        [self.delegate coordinator:self didFinishRecordingToOutputFileURL:_recordingURL error:nil];
                    }
                });
            }
        }
    }
}

#pragma mark - SampleBufferDelegate methods

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    if (connection == _videoConnection) {
        if (self.outputVideoFormatDescription == nil) {
            [self setupVideoPipelineWithInputFormatDescription:formatDescription];
        }else{
            self.outputVideoFormatDescription = formatDescription;
            @synchronized(self) {
                if (_recordingStatus == RecordingStatusRecording) {
                    [_assetWriterCoordinator appendVideoSampleBuffer:sampleBuffer];
                }
            }
        }
    }else if (connection == _audioConnection){
        self.outputAudioFormatDescription = formatDescription;
        @synchronized(self) {
            if (_recordingStatus == RecordingStatusRecording) {
                [_assetWriterCoordinator appendAudioSampleBuffer:sampleBuffer];
            }
        }
    }
}

@end
