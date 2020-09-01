//
//  ViewController.m
//  MoudleTestDemo
//
//  Created by 吴闯 on 2020/8/31.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import "ViewController.h"
#import "UIColor+Hex.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *color = [UIColor colorWithRGBHex:0xEE0000];
    self.view.backgroundColor=color;
}


@end
