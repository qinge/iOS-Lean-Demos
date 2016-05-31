//
//  RecodingViewController.h
//  视频录制
//
//  Created by snqu-ios on 16/5/27.
//  Copyright © 2016年 snqu-ios. All rights reserved.
//

#import <UIKit/UIKit.h>

// Pipleline: 管道
typedef NS_ENUM(NSInteger, PiplelineMode){
    PiplelineModeMoveFileOutput = 0,
    PipelineModeAssetWriter
};

@interface RecodingViewController : UIViewController

@property (nonatomic, assign) PiplelineMode mode;

@end
