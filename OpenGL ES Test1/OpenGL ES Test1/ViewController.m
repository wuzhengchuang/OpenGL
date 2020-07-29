//
//  ViewController.m
//  OpenGL ES Test1
//
//  Created by 吴闯 on 2020/7/29.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    EAGLContext *context;
    GLKBaseEffect *effect;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpConfig];
    [self setUpVertexData];
    
}
-(void)setUpConfig{
    context=[[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!context) {
        NSLog(@"EAGLContext Create Failed");
    }
    [EAGLContext setCurrentContext:context];
    GLKView *view=(GLKView *)self.view;
    view.context=context;
    view.drawableColorFormat=GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat=GLKViewDrawableDepthFormat24;
    glClearColor(1, 0, 0, 1);
}
-(void)setUpVertexData{
    //前面3个顶点数据（xyz）后面2个纹理坐标（st）
    GLfloat vertexData[] ={
        0.5,-0.5,0.0,  1.0,0.f,
        0.5,0.5,0.0,  1.0,1.f,
        -0.5,0.5,0.0,  0.0,1.f,
        
        0.5,-0.5,0.0,  1.0,0.f,
        -0.5,0.5,0.0,  0.0,1.f,
        -0.5,-0.5,0.0,  0.0,0.f,
    };
    GLuint bufferID;
    glGenBuffers(1, &bufferID);
    glBindBuffer(GL_ARRAY_BUFFER, bufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexData), vertexData, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, false, sizeof(GLfloat)*5, (GLfloat *)NULL +0);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, false, sizeof(GLfloat)*5, (GLfloat *)NULL +3);
}
-(void)setUpTexure{
    
}
#pragma mark
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClear(GL_COLOR_BUFFER_BIT);
}

@end
