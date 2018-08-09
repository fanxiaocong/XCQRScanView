//
//  XCQRCodeUnit.h
//  XCQRCodeScanfViewExample
//
//  Created by 樊小聪 on 2018/8/9.
//  Copyright © 2018年 樊小聪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XCQRCodeUnit : NSObject

/**
 *  相册是否可用
 */
+ (BOOL)isAvailablePhoto;

/**
 *  相机是否可用
 */
+ (BOOL)isAvaliableCamera;

/**
 *  压缩图片
 */
+ (UIImage *)compressImage:(UIImage *)image;

/**
 *  加载图片资讯
 */
+ (UIImage *)imageNamed:(NSString *)imageName;

@end
