//
//  WZCViewController.m
//  OpenGL ES Test2
//
//  Created by 吴闯 on 2020/8/2.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import "WZCViewController.h"
#import "WZCView.h"
@interface WZCViewController ()
@property(nonatomic,strong)WZCView *wzcView;
@end

@implementation WZCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.wzcView=(WZCView *)self.view;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
