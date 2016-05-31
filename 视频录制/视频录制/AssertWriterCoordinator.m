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

@property (nonatomic) CMFormatDescriptionRef autioTrackSourceFormatDescription;
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



@end
