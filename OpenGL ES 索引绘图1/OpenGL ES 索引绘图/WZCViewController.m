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
@property(nonatomic,assign)float xDegree;
@property(nonatomic,assign)float yDegree;
@property(nonatomic,assign)float zDegree;
@property(nonatomic,assign)BOOL bX;
@property(nonatomic,assign)BOOL bY;
@property(nonatomic,assign)BOOL bZ;
@property(nonatomic,assign)int count;
@end

@implementation WZCViewController
{
    dispatch_source_t timer;
}
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
       
       GLKView *view=(GLKView *)self.view;
       view.context=_eaglContext;
       view.drawableColorFormat=GLKViewDrawableColorFormatRGBA8888;
       view.drawableDepthFormat=GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:_eaglContext];
//       view.drawableMultisample=GLKViewDrawableMultisample4X;
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
    self.count=sizeof(indices)/sizeof(GLuint);
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(verts), verts, GL_DYNAMIC_DRAW);
    
    GLuint index;
    glGenBuffers(1, &index);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, index);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_DYNAMIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*6, NULL);
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*6, (GLfloat *)NULL+3);
    self.effect=[[GLKBaseEffect alloc]init];
    CGSize size = self.view.bounds.size;
    float aspect = fabsf(size.width/size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), aspect, 0.1, 100.f);
    projectionMatrix = GLKMatrix4Scale(projectionMatrix, 1.0f, 1.0f, 1.0f);
    self.effect.transform.projectionMatrix=projectionMatrix;
    GLKMatrix4 modelViewMatrix=GLKMatrix4Identity;
    GLKMatrix4Translate(modelViewMatrix, 0, 0, -2);
    self.effect.transform.modelviewMatrix=modelViewMatrix;
    double seconds = 0.1;
     timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        self.xDegree+=0.1f*self.bX;
        self.yDegree+=0.1f*self.bY;
        self.zDegree+=0.1f*self.bZ;
    });
    dispatch_resume(timer);
}
-(void)update{
    GLKMatrix4 modelViewMatrix=GLKMatrix4Identity;
    modelViewMatrix=GLKMatrix4Translate(modelViewMatrix, 0, 0, -2.5);
    modelViewMatrix=GLKMatrix4Rotate(modelViewMatrix, self.xDegree, 1.0, 0, 0);
      modelViewMatrix=  GLKMatrix4Rotate(modelViewMatrix, self.yDegree, 0.0, 1.0, 0);
      modelViewMatrix=  GLKMatrix4Rotate(modelViewMatrix, self.zDegree, 0.0, 0, 1.0);
    self.effect.transform.modelviewMatrix=modelViewMatrix;
}
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    [self.effect prepareToDraw];
    glDrawElements(GL_TRIANGLES, self.count, GL_UNSIGNED_INT, 0);
}
- (IBAction)XClick:(id)sender {
    //更新的是X还是Y
    self.bX = !self.bX;
}
- (IBAction)YClick:(id)sender {
       //更新的是X还是Y
       self.bY = !self.bY;
}
- (IBAction)ZClick:(id)sender {
    //更新的是X还是Y
    self.bZ = !self.bZ;
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
