//
//  AssertWriterCoordinator.h
//  视频录制
//
//  Created by snqu-ios on 16/5/31.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

@protocol AssetWriterCoordinatorDelegate;

@interface AssertWriterCoordinator : NSObject

-(instancetype)initWithURL:(NSURL *)url;
-(void)addVideoTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formateDescription settings:(NSDictionary *)videoSettings;
-(void)addAudioTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formateDescription settings:(NSDictionary *)audioSettings;

-(void)setDelegate:(id<AssetWriterCoordinatorDelegate>) delegate callbackQueue:(dispatch_queue_t)delegateCallbackQueue;

-(void)prepareToRecord;
-(void)appendVideoSampleBuffer:(CMSampleBufferRef) sampleBuffer;
-(void)appendAudioSampleBuffer:(CMSampleBufferRef) sampleBuffer;
-(void)finishRecording;


@end

@protocol AssetWriterCoordinatorDelegate <NSObject>

-(void)writerCoordinatorDidFinishPreparing:(AssertWriterCoordinator *)coordinator;
-(void)writerCoordinator:(AssertWriterCoordinator *)coordinator didFailWithError:(NSError *)error;
-(void)writerCoordinatorDidFinishRecording:(AssertWriterCoordinator *)coordinator;

@end
