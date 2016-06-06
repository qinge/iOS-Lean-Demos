//
//  AssertWriterCoordinator.m
//  视频录制
//
//  Created by snqu-ios on 16/5/31.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import "AssertWriterCoordinator.h"

typedef NS_ENUM(NSInteger, WriterStatus){
    WriterStatusIdle = 0,
    WriterStatusPreparingToRecord,
    WriterStatusRecording,
    WriterStatusFinishingRecordingPart1, // waiting for inflight buffers to be appended
    WriterStatusFinishingRecordingPart2, // calling finish writing on the asset writer
    WriterStatusFinished,	// terminal state
    WriterStatusFailed		// terminal state
}; // internal state machine


@interface AssertWriterCoordinator()

@property (nonatomic, weak)id <AssetWriterCoordinatorDelegate>delegate;

@property (nonatomic, assign) WriterStatus status;

@property (nonatomic) dispatch_queue_t writingQueue;
@property (nonatomic) dispatch_queue_t delegateCallbackQueue;

@property (nonatomic) NSURL *URL;

@property (nonatomic) AVAssetWriter *assetWriter;
@property (nonatomic) BOOL haveStartedSession;

@property (nonatomic) CMFormatDescriptionRef audioTrackSourceFormatDescription;
@property (nonatomic) NSDictionary *audioTrackSettings;
@property (nonatomic) AVAssetWriterInput *audioInput;

@property (nonatomic) CMFormatDescriptionRef videoTrackSourceFormatDescription;
@property (nonatomic) CGAffineTransform videoTrackTransform;
@property (nonatomic) NSDictionary *videoTrackSettings;
@property (nonatomic) AVAssetWriterInput *videoInput;

@end

@implementation AssertWriterCoordinator

-(instancetype)initWithURL:(NSURL *)url{
    if (!url) {
        return nil;
    }
    self = [super init];
    if (self) {
        _writingQueue = dispatch_queue_create("com.example.assetwriter.writing", DISPATCH_QUEUE_SERIAL);
        _videoTrackTransform = CGAffineTransformMakeRotation(M_PI_2);
        _URL = url;
    }
    return self;
}



-(void)addVideoTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formateDescription settings:(NSDictionary *)videoSettings{
    if (formateDescription == NULL) {
        NSLog(@"NULL format description");
        return ;
    }
    @synchronized(self) {
        if (_status != WriterStatusIdle) {
            NSLog(@"Cannot add tracks while not idle");
            return;
        }
        if (_videoTrackSourceFormatDescription) {
            NSLog(@"Cannot add more than one video track");
            return;
        }
        _videoTrackSourceFormatDescription = (CMFormatDescriptionRef)CFRetain(formateDescription);
        _videoTrackSettings = [videoSettings copy];
    }
}


-(void)addAudioTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formateDescription settings:(NSDictionary *)audioSettings{
    if (formateDescription == NULL) {
        NSLog(@"NULL format description");
        return;
    }
    
    @synchronized(self) {
        if (_status != WriterStatusIdle) {
            NSLog(@"Cannot add tracks while not idle");
            return;
        }
        if (_audioTrackSourceFormatDescription) {
            NSLog(@"Cannot add more than one audio track");
            return;
        }
        _audioTrackSourceFormatDescription = (CMFormatDescriptionRef)CFRetain(formateDescription);
        _audioTrackSettings = [audioSettings copy];
    }
}


-(void)setDelegate:(id<AssetWriterCoordinatorDelegate>)delegate callbackQueue:(dispatch_queue_t)delegateCallbackQueue{
    if (delegate && delegateCallbackQueue == NULL) {
        NSLog(@"delegateCallbackQueue == null");
        return;
    }
    @synchronized(self) {
        _delegate = delegate;
        if (delegateCallbackQueue != _delegateCallbackQueue) {
            _delegateCallbackQueue = delegateCallbackQueue;
        }
    }
}


/**
 *  准备录制
 */
-(void)prepareToRecord{
    @synchronized(self) {
        if (_status != WriterStatusIdle) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Already prepared, cannot prepare again" userInfo:nil];
            return;
        }
        [self transitionToStatus:WriterStatusPreparingToRecord error:nil];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtURL:_URL error:NULL];
        _assetWriter = [[AVAssetWriter alloc] initWithURL:_URL fileType:AVFileTypeQuickTimeMovie error:&error];
        
        // Create and add inputs
        if (!error) {
            [self setupAssetWriterVideoInputWithSourceFormatDescription:_videoTrackSourceFormatDescription transform:_videoTrackTransform settings:_videoTrackSettings error:&error];
        }
        if (!error && _audioTrackSourceFormatDescription) {
            [self setupAssetWriterAudioInputWithSourceFormatDescription:_audioTrackSourceFormatDescription settings:_audioTrackSettings error:&error];
        }
        if (!error) {
            BOOL success = [_assetWriter startWriting];
            if (!success) {
                error = _assetWriter.error;
            }
        }
        
        @synchronized(self) {
            if (error) {
                [self transitionToStatus:WriterStatusFailed error:error];
            }else{
                [self transitionToStatus:WriterStatusRecording error:nil];
            }
        }
        
    });
}




-(void)appendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeVideo];
}


-(void)appendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeAudio];
}


-(void)finishRecording{
    @synchronized(self) {
        BOOL shouldFinishRecording = NO;
        switch (_status) {
            case WriterStatusIdle:
            case WriterStatusPreparingToRecord:
            case WriterStatusFinishingRecordingPart1:
            case WriterStatusFinishingRecordingPart2:
            case WriterStatusFinished:
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not recording" userInfo:nil];
                break;
            case WriterStatusFailed:
                NSLog(@"Recording has failed, nothing to do");
                break;
                
            case WriterStatusRecording:
                shouldFinishRecording = YES;
                break;
            default:
                break;
        }
        if (shouldFinishRecording) {
            [self transitionToStatus:WriterStatusFinishingRecordingPart1 error:nil];
        }else{
            return;
        }
    }
    
    
    dispatch_async(_writingQueue, ^{
        @autoreleasepool {
            @synchronized(self) {
                if (_status != WriterStatusFinishingRecordingPart1) {
                    return ;
                }
                [self transitionToStatus:WriterStatusFinishingRecordingPart2 error:nil];
            }
            [_assetWriter finishWritingWithCompletionHandler:^{
                @synchronized(self) {
                    NSError *error = _assetWriter.error;
                    if (error) {
                        [self transitionToStatus:WriterStatusFailed error:error];
                    }else{
                        [self transitionToStatus:WriterStatusFinished error:nil];
                    }
                }
            }];
        }
    });
}


-(void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer ofMediaType:(NSString *)mediaType{
    if (sampleBuffer == NULL) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"NULL sample buffer" userInfo:nil];
        return ;
    }
    @synchronized(self) {
        if (_status < WriterStatusRecording) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not ready to record yet" userInfo:nil];
            return;
        }
    }
    
    CFRetain(sampleBuffer);
    dispatch_async(_writingQueue, ^{
        @autoreleasepool {
            if (_status > WriterStatusFinishingRecordingPart1) {
                CFRelease(sampleBuffer);
                return ;
            }
        }
       
        if (!_haveStartedSession && mediaType == AVMediaTypeVideo) {
            [_assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
            _haveStartedSession = YES;
        }
        
        AVAssetWriterInput *input = (mediaType == AVMediaTypeVideo) ? _videoInput : _audioInput;
        if (input.readyForMoreMediaData) {
            BOOL success = [input appendSampleBuffer:sampleBuffer];
            if (!success) {
                NSError *error = _assetWriter.error;
                @synchronized(self) {
                    [self transitionToStatus:WriterStatusFailed error:error];
                }
            }
        }else{
            NSLog(@"%@ input not ready for more media data, dropping buffer", mediaType);
        }
        CFRelease(sampleBuffer);
        
    });
    
}



#pragma mark - 设置 asset writer 视频 参数 设置
- (BOOL)setupAssetWriterVideoInputWithSourceFormatDescription:(CMFormatDescriptionRef)videoFormatDescription transform:(CGAffineTransform)transform settings:(NSDictionary *)videoSettings error:(NSError **)errorOut{
    
//    if (!videoSettings) {
//        videoSettings = [self fallbackVideoSettingsForSourceFormatDescription:videoFormatDescription];
//    }
//    videoSettings = [self fallbackVideoSettingsForSourceFormatDescription:videoFormatDescription];
    
    if ([_assetWriter canApplyOutputSettings:videoSettings forMediaType:AVMediaTypeVideo]) {
        _videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoSettings sourceFormatHint:videoFormatDescription];
        _videoInput.expectsMediaDataInRealTime = YES; // 不加这个好像要掉帧
        _videoInput.transform = transform;
        if ([_assetWriter canAddInput:_videoInput]) {
            [_assetWriter addInput:_videoInput];
        }else{
            if (errorOut) {
                *errorOut = [self cannotSetupInputError];
                return NO;
            }
        }
    }else{
        if (errorOut) {
            *errorOut = [self cannotSetupInputError];
        }
        return NO;
    }
    return YES;
}

#pragma mark - 设置 asset writer 音频 参数 设置
- (BOOL)setupAssetWriterAudioInputWithSourceFormatDescription:(CMFormatDescriptionRef)audioFormatDescription settings:(NSDictionary *)audioSettings error:(NSError **)errorOut{
    if (!audioSettings) {
        audioSettings = @{AVFormatIDKey : @(kAudioFormatMPEG4AAC)};
    }
    if ([_assetWriter canApplyOutputSettings:audioSettings forMediaType:AVMediaTypeAudio]) {
        _audioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:audioSettings sourceFormatHint:audioFormatDescription];
        _audioInput.expectsMediaDataInRealTime = YES;
        if ([_assetWriter canAddInput:_audioInput]) {
            [_assetWriter addInput:_audioInput];
        }else{
            if (errorOut) {
                *errorOut = [self cannotSetupInputError];
            }
            return NO;
        }
    }else{
        if (errorOut) {
            *errorOut = [self cannotSetupInputError];
        }
        return NO;
    }
    return YES;
}


- (NSDictionary *)fallbackVideoSettingsForSourceFormatDescription:(CMFormatDescriptionRef)videoFormatDescription{
    float bitsPerPixel;
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(videoFormatDescription);
    int numPixels = dimensions.width * dimensions.height;
    int bitsPerSecond;
    
    NSLog(@"No video settings provided, using default settings");
    if (numPixels < (640 * 480)) {
        bitsPerPixel = 4.05;
    }else{
        bitsPerPixel = 10.1;
    }
    bitsPerSecond = numPixels * bitsPerPixel;
    
    NSDictionary *compressionProperties = @{AVVideoAverageBitRateKey : @(bitsPerSecond),
                                            AVVideoExpectedSourceFrameRateKey: @(30),
                                            AVVideoMaxKeyFrameIntervalKey: @(30)};
    
    CMVideoDimensions videoDimensions = CMVideoFormatDescriptionGetDimensions(videoFormatDescription);
    videoDimensions.width = 100;
    videoDimensions.height = 100;
    NSDictionary *dic = @{ AVVideoCodecKey : AVVideoCodecH264,
                           AVVideoCompressionPropertiesKey : compressionProperties,
                           AVVideoWidthKey: @(videoDimensions.width),
                           AVVideoHeightKey : @(videoDimensions.height)
                           };
    return dic;
    
}

-(void)transitionToStatus:(WriterStatus)newStatus error:(NSError*)error{
    BOOL shouldNotifyDelegate = NO;
    if (newStatus != _status) {
        if (newStatus == WriterStatusFinished || newStatus == WriterStatusFailed) {
            shouldNotifyDelegate = YES;
            dispatch_async(_writingQueue, ^{
                _assetWriter = nil;
                _videoInput = nil;
                _audioInput = nil;
                if (newStatus == WriterStatusFailed) {
                    [[NSFileManager defaultManager] removeItemAtURL:_URL error:NULL];
                }
            });
        }else if (newStatus == WriterStatusRecording){
            shouldNotifyDelegate = YES;
        }
        _status = newStatus;
    }
    
    if (shouldNotifyDelegate && self.delegate) {
        dispatch_async(_delegateCallbackQueue, ^{
            @autoreleasepool {
                switch (newStatus) {
                    case WriterStatusRecording:
                        [self.delegate writerCoordinatorDidFinishPreparing:self];
                        break;
                    case WriterStatusFinished:
                        [self.delegate writerCoordinatorDidFinishRecording:self];
                        break;
                        
                    case WriterStatusFailed:
                        [self.delegate writerCoordinator:self didFailWithError:error];
                        break;
                        
                    default:
                        break;
                }
            }
        });
        
    }
}

-(NSError *)cannotSetupInputError{
    NSDictionary *errorDic = @{
                               NSLocalizedDescriptionKey : @"错误了",
                               NSLocalizedFailureReasonErrorKey : @"不能设置输入"
                               
                               };
    return [NSError errorWithDomain:@"com.example" code:0 userInfo:errorDic];
}

@end
