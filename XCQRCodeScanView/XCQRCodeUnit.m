//
//  XCQRCodeUnit.m
//  XCQRCodeScanfViewExample
//
//  Created by 樊小聪 on 2018/8/9.
//  Copyright © 2018年 樊小聪. All rights reserved.
//

#import "XCQRCodeUnit.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/PHPhotoLibrary.h>


@implementation XCQRCodeUnit

/**
 *  相册是否可用
 */
+ (BOOL)isAvailablePhoto
{
    PHAuthorizationStatus authorStatus = [PHPhotoLibrary authorizationStatus];
    if (authorStatus == PHAuthorizationStatusDenied)
    {
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *message = [NSString stringWithFormat:@"请到手机系统的\n【设置】->【隐私】->【照片】\n对%@开启相册的访问权限", appName];
        [self showError:message title:@"相册读取权限未开启"];
        return NO;
    }
    
    return YES;
}


+ (BOOL)isAvaliableCamera
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        
        /// 用户是否允许摄像头使用
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if (authorizationStatus == AVAuthorizationStatusRestricted ||
            authorizationStatus == AVAuthorizationStatusDenied)
        {
            NSString *message = [NSString stringWithFormat:@"请到手机系统的\n【设置】->【隐私】->【相机】\n对%@开启相机的访问权限", appName];
            [self showError:message title:@"相机权限未开启"];
            return NO;
        }
        
        return  YES;
    }
    
    [self showError:@"你的设备不支持此功能" title:@"提示"];
    return NO;
}

+ (UIImage *)compressImage:(UIImage *)image
{
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (imageWidth <= screenWidth && imageHeight <= screenHeight) {
        return image;
    }
    CGFloat max = MAX(imageWidth, imageHeight);
    CGFloat scale = max / (screenHeight * 2.0);
    CGSize size = CGSizeMake(imageWidth / scale, imageHeight / scale);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)imageNamed:(NSString *)imageName
{
    NSInteger scale = [UIScreen mainScreen].scale;
    
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSString *bundleName =  @"resource.bundle";
    NSString *imagePath  = [currentBundle pathForResource: [NSString stringWithFormat:@"%@@%zdx", imageName, scale] ofType:@"png" inDirectory:bundleName];
    
    return [UIImage imageWithContentsOfFile:imagePath];
}

#pragma mark - 🔒 👀 Privite Method 👀

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
+ (void)showError:(NSString *)error title:(NSString *)title
{
    /// 弹出 警告框
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:error delegate:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了", nil];
    [alertView show];
}
#pragma clang diagnostic pop

@end
