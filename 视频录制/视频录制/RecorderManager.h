//
//  RecorderManager.h
//  视频录制
//
//  Created by snqu-ios on 16/5/27.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RecorderManager : NSObject

@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

+(instancetype)sharedInstance;


-(void)startRecord;
-(void)stopRecord;

@end
