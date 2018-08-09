//
//  UIView+XCQRCode.h
//  XCQRCodeScanfViewExample
//
//  Created by 樊小聪 on 2018/8/8.
//  Copyright © 2018年 樊小聪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (XCQRCode)

/** frame.origin.x */
@property (nonatomic) CGFloat left;

/** frame.origin.y */
@property (nonatomic) CGFloat top;

/** frame.origin.x + frame.size.width */
@property (nonatomic) CGFloat right;

/** frame.origin.y + frame.size.height */
@property (nonatomic) CGFloat bottom;

/** frame.size.width */
@property (nonatomic) CGFloat width;

/** frame.size.height */
@property (nonatomic) CGFloat height;

/** center.x */
@property (nonatomic) CGFloat centerX;

/** center.y */
@property (nonatomic) CGFloat centerY;

/** frame.origin */
@property (nonatomic) CGPoint origin;

/** frame.origin.size */
@property (nonatomic) CGSize size;

@end
