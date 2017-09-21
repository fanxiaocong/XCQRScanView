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


#import "XCQRCodeScanfView.h"

#import "UIView+XCExtension.h"

#import <AVFoundation/AVFoundation.h>


#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
#define SELF_WIDTH      self.bounds.size.width
#define SELF_HEIGHT     self.bounds.size.height

#define SCANF_WH        (200/320.0) * SELF_WIDTH


@interface XCQRCodeScanfView () <AVCaptureMetadataOutputObjectsDelegate>

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


@implementation XCQRCodeScanfView

#pragma mark - 👀 Init Method 👀 💤

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        // 设置默认参数
        [self setupDefaults];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        // 设置默认参数
        [self setupDefaults];
    }
    
    return self;
}

// 设置默认参数
- (void)setupDefaults
{
    /*⏰ ----- 创建扫描的区域视图 ----- ⏰*/
    UIImageView *scanfImgView = [[UIImageView alloc] init];
    scanfImgView.size = CGSizeMake(SCANF_WH, SCANF_WH);
    scanfImgView.centerX = SELF_WIDTH * 0.5;
    scanfImgView.centerY = SELF_HEIGHT * 0.4;
    scanfImgView.backgroundColor = [UIColor clearColor];
    scanfImgView.image = [UIImage imageNamed:@"resource.bundle/QRImage.png"];
    self.scanfImgView = scanfImgView;
    [self addSubview:scanfImgView];
    
    
    /*⏰ ----- 创建扫描移动的线条 ----- ⏰*/
    CGFloat marginLine = 2;
    CGFloat lineH = 3.f;
    CGFloat lineW = SELF_WIDTH - marginLine * 2;
    CGFloat lineX = scanfImgView.left + marginLine;
    CGFloat lineY = scanfImgView.top + marginLine;
    UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(lineX, lineY, lineW, lineH)];
    lineImgView.image = [UIImage imageNamed:@"resource.bundle/QRLine.png"];
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
    CGFloat bottomH = topViewH;
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
    UILabel *placeholderLabel = [UILabel alloc];
    placeholderLabel.width  = SCANF_WH;
    placeholderLabel.height = 30;
    placeholderLabel.centerX = SELF_WIDTH * 0.5;
    placeholderLabel.top = scanfImgView.bottom + 30;
    [self addSubview:placeholderLabel];
    
    
    /*⏰ ----- 闪光灯按钮 ----- ⏰*/
    UIButton *lightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    lightButton.frame = CGRectMake(40, 40, 40, 40);
    [lightButton setImage:[UIImage imageNamed:@"resource.bundle/ocr_flash-off.png"] forState:UIControlStateNormal];
    [lightButton setImage:[UIImage imageNamed:@"resource.bundle/ocr_flash-on.png"] forState:UIControlStateSelected];
    [lightButton addTarget:self action:@selector(didClickLightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    /*⏰ ----- 创建设备对象 ----- ⏰*/
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input  = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:NULL];
    
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [self.output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    //设置扫描有效区域(上、左、下、右)
    CGFloat insetsTop    = scanfImgView.top / SCREEN_HEIGHT;
    CGFloat insetsLeft   = scanfImgView.left / SCREEN_WIDTH;
    CGFloat insetsBottom = scanfImgView.width / SCREEN_HEIGHT;
    CGFloat insetsRight  = scanfImgView.height / SCREEN_WIDTH;
    [self.output setRectOfInterest:CGRectMake(insetsTop, insetsLeft, insetsBottom, insetsRight)];
    
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([self.session canAddInput:self.input])
    {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.output])
    {
        [self.session addOutput:self.output];
    }
    
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
    
    /// 当扫描线条的 Y 坐标， 超过边界值
    if ((self.lineImgView.top < upLimitY) ||
        (self.lineImgView.top > downLimitY))
    {
        offsetY = -offsetY;
    }
    
    self.lineImgView.top += offsetY;
}

/**
  点击了 闪光灯按钮
 */
- (void)didClickLightButtonAction
{
    self.lightButton.selected = !self.lightButton.isSelected;
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
    if (self.lineTimer && self.lineTimer.isValid)
    {
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
    [self.device unlockForConfiguration];
    
    if (isOn)
    {
        // 开启闪光灯
        [self.device setTorchMode:AVCaptureTorchModeOn];
    }
    else
    {
        // 关闭闪光灯
        [self.device setTorchMode:AVCaptureTorchModeOff];
    }
}

#pragma mark - 🔓 👀 Public Method 👀

/** 👀 开始扫描 👀 */
- (void)startScanf
{
    if (self.session)
    {
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
    if ([metadataObjects count])
    {
        // 停止扫描
        [self stopScanf];
        
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
        
        // 二维码扫描的结果
        stringValue = metadataObject.stringValue;
        isSuccess = YES;
    }
    
    // 回调
    if (self.completionHandle)
    {
        self.completionHandle(stringValue, isSuccess);
    }
}

@end


