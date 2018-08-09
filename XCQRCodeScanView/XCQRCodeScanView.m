//
//  XCQRCodeScanfView.m
//  XCQRCodeScanfViewExample
//
//  Created by 樊小聪 on 2017/3/10.
//  Copyright © 2017年 樊小聪. All rights reserved.
//


/*
 *  备注：二维码扫描视图 🐾
 */


#import "XCQRCodeScanView.h"
#import "XCQRCodeButton.h"
#import "UIView+XCQRCode.h"
#import "XCQRCodeUnit.h"

#import <AVFoundation/AVFoundation.h>
#import <Photos/PHPhotoLibrary.h>


#define SELF_WIDTH      self.bounds.size.width
#define SELF_HEIGHT     self.bounds.size.height

#define SCANF_WH        (200/320.0) * SELF_WIDTH


@interface XCQRCodeScanView () <AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureDeviceInput *input;
@property (strong, nonatomic) AVCaptureMetadataOutput *output;
@property (strong, nonatomic) AVCaptureSession *session;
@property (weak,nonatomic) AVCaptureVideoPreviewLayer *preview;

@property (weak, nonatomic) UIImageView *scanfImgView;
@property (weak, nonatomic) UIImageView *lineImgView;
@property (strong, nonatomic) NSTimer *lineTimer;

/** 👀 闪光灯按钮 👀 */
@property (weak, nonatomic) UIButton *lightButton;

@end


@implementation XCQRCodeScanView
{
    BOOL _isMoveUp; /// 是否是向上移动
}

#pragma mark - 👀 Init Method 👀 💤

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        // 设置默认参数
        [self setupDefaults];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // 设置默认参数
        [self setupDefaults];
    }
    
    return self;
}

// 设置默认参数
- (void)setupDefaults
{
    /// 没有相机的访问权限，则直接返回
    if (![XCQRCodeUnit isAvaliableCamera]) {
        [self removeFromSuperview];
        return;
    }
    
    /*⏰ ----- 创建扫描的区域视图 ----- ⏰*/
    UIImageView *scanfImgView = [[UIImageView alloc] init];
    scanfImgView.size = CGSizeMake(SCANF_WH, SCANF_WH);
    scanfImgView.centerX = SELF_WIDTH * 0.5;
    scanfImgView.centerY = SELF_HEIGHT * 0.4;
    scanfImgView.backgroundColor = [UIColor clearColor];
    scanfImgView.image = [XCQRCodeUnit imageNamed:@"QRImage"];
    self.scanfImgView = scanfImgView;
    [self addSubview:scanfImgView];
    
    
    /*⏰ ----- 创建扫描移动的线条 ----- ⏰*/
    CGFloat marginLine = 2;
    CGFloat lineH = 3.f;
    CGFloat lineW = SCANF_WH - marginLine * 2;
    CGFloat lineX = scanfImgView.left + marginLine;
    CGFloat lineY = scanfImgView.top + marginLine;
    UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(lineX, lineY, lineW, lineH)];
    lineImgView.image = [XCQRCodeUnit imageNamed:@"QRLine"];
    self.lineImgView = lineImgView;
    [self addSubview:lineImgView];
    
    
    /*⏰ ----- 背景蒙板视图 ----- ⏰*/
    
    /// 上部背景
    CGFloat topViewX = 0;
    CGFloat topViewY = 0;
    CGFloat topViewW = SELF_WIDTH;
    CGFloat topViewH = scanfImgView.top;
    [self addBackgroundViewWithFrame:CGRectMake(topViewX, topViewY, topViewW, topViewH)];
    
    /// 下部背景
    CGFloat bottomX = topViewY;
    CGFloat bottomY = scanfImgView.bottom;
    CGFloat bottomW = topViewW;
    CGFloat bottomH = SELF_HEIGHT - bottomY;
    [self addBackgroundViewWithFrame:CGRectMake(bottomX, bottomY, bottomW, bottomH)];
    
    /// 左部背景
    CGFloat leftViewX = topViewX;
    CGFloat leftViewY = topViewH;
    CGFloat leftViewW = scanfImgView.left;
    CGFloat leftViewH = scanfImgView.bottom - topViewH;
    [self addBackgroundViewWithFrame:CGRectMake(leftViewX, leftViewY, leftViewW, leftViewH)];
    
    /// 右部背景
    CGFloat rightViewW = leftViewW;
    CGFloat rightViewH = leftViewH;
    CGFloat rightViewX = scanfImgView.right;
    CGFloat rightViewY = leftViewY;
    [self addBackgroundViewWithFrame:CGRectMake(rightViewX, rightViewY, rightViewW, rightViewH)];

    
    /*⏰ ----- 创建底部说明视图 ----- ⏰*/
    UILabel *placeholderLabel = [[UILabel alloc] init];
    placeholderLabel.width  = SELF_WIDTH - 50;
    placeholderLabel.height = 30;
    placeholderLabel.centerX = SELF_WIDTH * 0.5;
    placeholderLabel.top = scanfImgView.bottom + 30;
    placeholderLabel.font = [UIFont systemFontOfSize:13.0];
    placeholderLabel.layer.cornerRadius = placeholderLabel.height * 0.5;
    placeholderLabel.layer.backgroundColor = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5] CGColor];
    placeholderLabel.textColor = [UIColor whiteColor];
    placeholderLabel.textAlignment = NSTextAlignmentCenter;
    placeholderLabel.text = @"将二维码/条形码放入扫描框中，即可自动识别";
    [self addSubview:placeholderLabel];
    
    
    /// 底部按钮
    CGFloat bottomButtonMargin = 30;
    CGFloat bottomButtonWH = 50;
    CGFloat bottomButtonY = SELF_HEIGHT - bottomButtonWH - bottomButtonMargin;
    
    /*⏰ ----- 相册按钮 ----- ⏰*/
    CGFloat photoButtonX = bottomButtonMargin;
    XCQRCodeButton *photoButton = [XCQRCodeButton buttonWithType:UIButtonTypeCustom];
    photoButton.frame = CGRectMake(photoButtonX, bottomButtonY, bottomButtonWH, bottomButtonWH);
    [photoButton setImage:[XCQRCodeUnit imageNamed:@"icon_picture"] forState:UIControlStateNormal];
    [photoButton addTarget:self action:@selector(didClickPhotoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:photoButton];
    
    /*⏰ ----- 闪光灯按钮 ----- ⏰*/
    CGFloat lightButtonX = SELF_WIDTH - bottomButtonWH - bottomButtonMargin;
    XCQRCodeButton *lightButton = [XCQRCodeButton buttonWithType:UIButtonTypeCustom];
    lightButton.frame = CGRectMake(lightButtonX, bottomButtonY, bottomButtonWH, bottomButtonWH);
    [lightButton setImage:[XCQRCodeUnit imageNamed:@"ocr_flash-off"] forState:UIControlStateNormal];
    [lightButton setImage:[XCQRCodeUnit imageNamed:@"ocr_flash-on"] forState:UIControlStateSelected];
    [lightButton addTarget:self action:@selector(didClickLightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    self.lightButton = lightButton;
    [self addSubview:lightButton];

    
    /*⏰ ----- 创建设备对象 ----- ⏰*/
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input  = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:NULL];
    
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //设置扫描有效区域(上、左、下、右)
    CGFloat insetsTop    = scanfImgView.top / SELF_HEIGHT;
    CGFloat insetsLeft   = scanfImgView.left / SELF_WIDTH;
    CGFloat insetsBottom = scanfImgView.width / SELF_HEIGHT;
    CGFloat insetsRight  = scanfImgView.height / SELF_WIDTH;
    [self.output setRectOfInterest:CGRectMake(insetsTop, insetsLeft, insetsBottom, insetsRight)];
    
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    
    /// 支持 二维码、条形码
    [self.output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,
                                          AVMetadataObjectTypeEAN13Code,
                                          AVMetadataObjectTypeEAN8Code,
                                          AVMetadataObjectTypeCode128Code]];
    
    /// Preview
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = self.layer.bounds;
    [self.layer insertSublayer:self.preview atIndex:0];
    
    /// 开始扫描
    [self startScanf];
}

#pragma mark - 🎬 👀 Action Method 👀

/**
    移动 扫描的线;
 */
- (void)moveLine
{
    CGFloat offsetY    = 1;
    CGFloat lineMargin = 2;
    
    /// 扫描线顶部的 Y 坐标
    CGFloat upLimitY = self.scanfImgView.top + lineMargin;
    
    /// 扫描线底部的 Y 坐标
    CGFloat downLimitY = self.scanfImgView.bottom - lineMargin - self.lineImgView.height * 0.5;
    
    /// 判断扫描线条的 Y 坐标的边界值
    if (_isMoveUp) { // 向上移动
        offsetY = -offsetY;
        if (self.lineImgView.top < upLimitY) {
            _isMoveUp = NO;
        } else {
            _isMoveUp = YES;
        }
    } else {    // 向下移动
        if (self.lineImgView.top > downLimitY) {
            _isMoveUp = YES;
        } else {
            _isMoveUp = NO;
        }
    }
    
    self.lineImgView.top += offsetY;
}

/**
  点击了 闪光灯按钮
 */
- (void)didClickLightButtonAction
{
    self.lightButton.selected = !self.lightButton.isSelected;
    [self operateLight:self.lightButton.isSelected];
}

/**
 *  点击了相册按钮的回调
 */
- (void)didClickPhotoButtonAction
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
}

#pragma mark - 🔒 👀 Privite Method 👀

/**
    创建半透明背景视图
 */
- (void)addBackgroundViewWithFrame:(CGRect)frame
{
    UIView *backgroundView = [[UIView alloc] initWithFrame:frame];
    
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = .6f;
    
    [self addSubview:backgroundView];
}

/**
    移除定时器
 */
- (void)removeTimer
{
    if (self.lineTimer && self.lineTimer.isValid) {
        [self.lineTimer invalidate];
        self.lineTimer = nil;
    }
}


/**
 操作 闪光灯

 @param isOn 是否打开
 */
- (void)operateLight:(BOOL)isOn
{
    [self.device lockForConfiguration:NULL];
    
    if (isOn) {
        // 开启闪光灯
        [self.device setTorchMode:AVCaptureTorchModeOn];
    } else {
        // 关闭闪光灯
        [self.device setTorchMode:AVCaptureTorchModeOff];
    }
    
    [self.device unlockForConfiguration];
}

#pragma mark - 🔓 👀 Public Method 👀

/** 👀 开始扫描 👀 */
- (void)startScanf
{
    if (self.session) {
        [self.session startRunning];
        [self removeTimer];
        
        /*⏰ ----- 此处让 扫描的线 每 0.01 秒移动一次 ----- ⏰*/
        self.lineTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(moveLine) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.lineTimer forMode:NSRunLoopCommonModes];
        self.lineImgView.hidden = NO;
    }
}

/** 👀 结束扫描 👀 */
- (void)stopScanf
{
    self.lineImgView.hidden = YES;

    // 关闭闪光灯
    self.lightButton.selected = NO;
    [self operateLight:NO];
    
    [self.session stopRunning];
    [self removeTimer];
}

#pragma mark - 💉 👀 AVCaptureMetadataOutputObjectsDelegate 👀

// 扫描完成后的回调方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    // 扫描结果
    NSString *stringValue;
    BOOL isSuccess = NO;
    
    // 扫描成功
    if ([metadataObjects count]) {
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
        
        // 二维码扫描的结果
        stringValue = metadataObject.stringValue;
        isSuccess = YES;
    }
    
    // 回调
    if (self.completionHandle) {
        self.completionHandle(self, stringValue, isSuccess);
    }
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];

    __block UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    /// 压缩图片
    image = [XCQRCodeUnit compressImage:image];
    
    //系统自带识别方法
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh }];
    
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    
    BOOL isSuccess = NO;
    NSString *stringValue;

    if (features.count) {
        CIQRCodeFeature *feature = features.firstObject;
        stringValue = feature.messageString;
        isSuccess = YES;
    }

    if (self.completionHandle) {
        self.completionHandle(self, stringValue, isSuccess);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end


