//
//  WZCViewController.m
//  OpenGL ES 索引绘图
//
//  Created by 吴闯 on 2020/8/4.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import "WZCViewController.h"

@interface WZCViewController ()
@property(nonatomic,strong)EAGLContext *eaglContext;
@property(nonatomic,strong)GLKBaseEffect *effect;
@end

@implementation WZCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpContext];
    [self render];
    
}
-(void)setUpContext{
    _eaglContext=[[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
       if (_eaglContext==nil) {
           NSLog(@"EAGLContext 创建失败！");
           return;
       }
       [EAGLContext setCurrentContext:_eaglContext];
       GLKView *view=(GLKView *)self.view;
       view.context=_eaglContext;
       view.drawableColorFormat=GLKViewDrawableColorFormatRGBA8888;
       view.drawableDepthFormat=GLKViewDrawableDepthFormat24;
       view.drawableMultisample=GLKViewDrawableMultisample4X;
       glEnable(GL_DEPTH_TEST);
}
-(void)render{
    GLfloat verts[]={
        -0.5f,0.5f,0.0f,   1.0f,0.0f,1.0f,
        0.5f,0.5f,0.0f,    1.0f,0.0f,1.0f,
        -0.5f,-0.5f,0.0f,  1.0f,1.0f,1.0f,
        0.5f,-0.5f,0.0f,   1.0f,1.0f,1.0f,
        0.f,0.f,1.0f,      0.0f,1.0f,0.0f,
    };
    GLuint indices[]={
        0,3,2,
        0,1,3,
        0,2,4,
        0,4,1,
        2,3,4,
        1,4,3,
    };
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(verts), verts, GL_DYNAMIC_DRAW);
    
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*6, (GLfloat *)NULL);
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*6, (GLfloat *)NULL+3);
    self.effect=[[GLKBaseEffect alloc]init];
    CGSize size = self.view.bounds.size;
    float aspect = fabsf(size.width/size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), aspect, 0.1, 100.f);
    self.effect.transform.projectionMatrix=projectionMatrix;
//    GLKMatrix4 viewModelMatrix =
}
-(void)update{
    
}
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(1.0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
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
