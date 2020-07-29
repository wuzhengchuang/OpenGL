//
//  ViewController.m
//  OpenGL ES
//
//  Created by 吴闯 on 2020/7/29.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
@interface ViewController ()
{
    EAGLContext *context;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    context=[[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!context) {
        NSLog(@"Create ES Context Failed");
    }
    [EAGLContext setCurrentContext:context];
    GLKView *view=(GLKView *)self.view;
    view.context=context;
    glClearColor(1.0, 0, 0, 1.0);
}
#pragma mark -GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClear(GL_COLOR_BUFFER_BIT);
}
@end
