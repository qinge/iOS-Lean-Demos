//
//  CaptureSessionCoordinator.h
//  视频录制
//
//  Created by snqu-ios on 16/5/31.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


// coordinator: 协调者

@protocol CaptureSessionCoordinatorDelegate;

@interface CaptureSessionCoordinator : NSObject

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *cameraDevice;
@property (nonatomic, strong) dispatch_queue_t delegateCallbackQueue;
@property (nonatomic, weak) id<CaptureSessionCoordinatorDelegate> delegate;

-(void)setDeledate:(id<CaptureSessionCoordinatorDelegate>) delegate callbackQueue:(dispatch_queue_t)delegateCallbackQueue;

-(BOOL)addInput:(AVCaptureDeviceInput *)input toCaptureSession:(AVCaptureSession *)captureSession;
-(BOOL)addOutput:(AVCaptureOutput *)output toCaptureSession:(AVCaptureSession *)captureSession;

/**
 *  开始预览
 */
-(void)startRunning;

/**
 *  结束预览
 */
-(void)stopRunning;


/**
 *  开始录制 由子类具体实现
 */
-(void)startRecording;

/**
 *  结束录制 由子类具体实现
 */
-(void)stopRecording;

/**
 *  预览 layer  若要实现预览时候添加滤镜功能需要使用 GLKView // http://objccn.io/issue-21-3/
 *
 *  @return
 */
-(AVCaptureVideoPreviewLayer *)previewLayer;



@end


@protocol CaptureSessionCoordinatorDelegate <NSObject>

@required

-(void)coordinatorDidBeginRecording:(CaptureSessionCoordinator *)coordinator;
-(void)coordinator:(CaptureSessionCoordinator *)coordinator didFinishRecordingToOutputFileURL:(NSURL *)outputFileURL error:(NSError *)error;

@end





