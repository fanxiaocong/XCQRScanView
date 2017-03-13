//
//  ViewController.m
//  XCQRCodeScanfViewExample
//
//  Created by 樊小聪 on 2017/3/10.
//  Copyright © 2017年 樊小聪. All rights reserved.
//

#import "ViewController.h"

#import "UIApplication+XCExtension.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    if ([[UIApplication sharedApplication] canUsePhotoAlbum])
//    {
//        NSLog(@"可以打开");
//    }
//    else
//    {
//        NSLog(@"不可以打开");
//    }
    
    [[UIApplication sharedApplication] vibrate];
}


@end
