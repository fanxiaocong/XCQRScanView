//
//  XCQRCodeScanfView.h
//  XCQRCodeScanfViewExample
//
//  Created by 樊小聪 on 2017/3/10.
//  Copyright © 2017年 樊小聪. All rights reserved.
//

/*
 *  备注：二维码扫描视图 🐾
 */

#import <UIKit/UIKit.h>

@interface XCQRCodeScanfView : UIView

/** 👀 扫描完成的回调 👀 */
@property (copy, nonatomic) void(^completionHandle)(NSString *result, BOOL isSuccess);


/** 👀 开始扫描 👀 */
- (void)startScanf;

/** 👀 结束扫描 👀 */
- (void)stopScanf;


@end
