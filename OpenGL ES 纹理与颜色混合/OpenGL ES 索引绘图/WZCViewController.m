//
//  WZCViewController.m
//  OpenGL ES 索引绘图
//
//  Created by 吴闯 on 2020/8/4.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import "WZCViewController.h"
#import "EAGLView.h"
@interface WZCViewController ()
@property(nonatomic,strong)EAGLView *eaglView;
@end

@implementation WZCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.eaglView=(EAGLView *)self.view;
    NSLog(@"%@",self.view);
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
