//
//  ViewController.m
//  XCQRCodeScanfViewExample
//
//  Created by 樊小聪 on 2017/3/10.
//  Copyright © 2017年 樊小聪. All rights reserved.
//


#import "ViewController.h"
#import "XCQRCodeScanView.h"


@interface ViewController ()

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XCQRCodeScanView *view = [[XCQRCodeScanView alloc] initWithFrame:self.view.bounds];
    [view startScanf];
    view.completionHandle = ^(XCQRCodeScanView *scanView, NSString *result, BOOL isSuccess) {
        if (isSuccess) {
            NSLog(@"识别成功---信息：%@", result);
        } else {
            NSLog(@"识别失败");
        }
        [scanView stopScanf];
    };
    [self.view addSubview:view];
}



@end
