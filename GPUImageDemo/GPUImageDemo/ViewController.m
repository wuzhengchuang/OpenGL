//
//  ViewController.m
//  GPUImageDemo
//
//  Created by 吴闯 on 2020/8/28.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage/GPUImage.h>
#import <Photos/Photos.h>
@interface ViewController ()
@property(nonatomic,strong)GPUImageStillCamera *mCamera;
@property(nonatomic,strong)GPUImageFilter *mFilter;
@property(nonatomic,strong)GPUImageView *mGPUImageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addFilterCamera];
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake((self.view.bounds.size.width-80)*0.5, self.view.bounds.size.height-60, 80, 40)];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.backgroundColor=[UIColor redColor];
    [btn setTitle:@"拍照" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
}
- (void)addFilterCamera{
    GPUImageStillCamera *camera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
//    [camera rotateCamera];
    camera.outputImageOrientation = UIDeviceOrientationPortrait;
    _mCamera=camera;
    _mFilter = [[GPUImageGrayscaleFilter alloc]init];
    _mGPUImageView = [[GPUImageView alloc]initWithFrame:self.view.bounds];
    [_mCamera addTarget:_mFilter];
    [_mFilter addTarget:_mGPUImageView];
    [self.view addSubview:_mGPUImageView];
    [_mCamera startCameraCapture];
}
- (void)takePhoto{
    [_mCamera capturePhotoAsJPEGProcessedUpToFilter:_mFilter withCompletionHandler:^(NSData *processedJPEG, NSError *error) {
        [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
            [[PHAssetCreationRequest creationRequestForAsset]addResourceWithType:PHAssetResourceTypePhoto data:processedJPEG options:nil];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
        }];
    }];
}
@end
