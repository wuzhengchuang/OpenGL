//
//  ViewController.m
//  OpenGL ES大长腿1
//
//  Created by 吴闯 on 2020/8/24.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
@interface ViewController ()<GLKViewDelegate>
@property (weak, nonatomic) IBOutlet GLKView *glkView;
@property (nonatomic, strong) EAGLContext *context;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context) {
        NSLog(@"EAGLContext创建失败!");
        return;
    }
    if (![EAGLContext setCurrentContext:self.context]) {
        NSLog(@"设置EAGLContext失败!");
        return;
    }
    self.glkView.delegate=self;
    self.glkView.context=self.context;
    self.glkView.drawableColorFormat=GLKViewDrawableColorFormatRGBA8888;
    self.glkView.drawableDepthFormat=GLKViewDrawableDepthFormat24;
    self.glkView.drawableStencilFormat=GLKViewDrawableStencilFormat8;
}
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
}

@end
