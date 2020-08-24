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
typedef struct {
    GLKVector3 positionCoord;
    GLKVector2 textureCoord;
}GLVertex;
@interface ViewController ()<GLKViewDelegate>
@property (weak, nonatomic) IBOutlet GLKView *glkView;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKBaseEffect *effect;
@property (nonatomic, assign) GLVertex *vertexs;
@property (nonatomic, assign) GLuint dataBuffer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initData];
    [self initTexture];
}
-(void)initUI{
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
-(void)initData{
    self.vertexs=(GLVertex *)malloc(sizeof(GLVertex)*4);
    self.vertexs[0].positionCoord=GLKVector3Make(-1.f, 1.f, 0.f);
    self.vertexs[0].textureCoord=GLKVector2Make(0.f, 1.f);
    self.vertexs[1].positionCoord=GLKVector3Make(1.f, 1.f, 0.f);
    self.vertexs[1].textureCoord=GLKVector2Make(1.f, 1.f);
    self.vertexs[2].positionCoord=GLKVector3Make(1.f, -1.f, 0.f);
    self.vertexs[2].textureCoord=GLKVector2Make(1.f, 0.f);
    self.vertexs[3].positionCoord=GLKVector3Make(-1.f, -1.f, 0.f);
    self.vertexs[3].textureCoord=GLKVector2Make(0.f, 0.f);
    glGenBuffers(1, &_dataBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, self.dataBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLVertex)*4, self.vertexs, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLVertex),NULL+offsetof(GLVertex, positionCoord));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLVertex),NULL+offsetof(GLVertex, textureCoord));
}
-(void)initTexture{
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"1" ofType:@"jpg"];
    GLKTextureInfo *textureInfo =[GLKTextureLoader textureWithContentsOfFile:filePath options:@{GLKTextureLoaderOriginBottomLeft:@(1)} error:NULL];
    self.effect=[[GLKBaseEffect alloc]init];
    self.effect.texture2d0.enabled=GL_TRUE;
    self.effect.texture2d0.name=textureInfo.name;
}
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(1.f, 0.f, 0.f, 1.f);
    glClear(GL_COLOR_BUFFER_BIT);
    glBindBuffer(GL_ARRAY_BUFFER, self.dataBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLVertex)*4, self.vertexs, GL_STATIC_DRAW);
    [self.effect prepareToDraw];
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    self.vertexs[0].positionCoord
  self.vertexs[0].positionCoord =  GLKVector3MultiplyScalar(self.vertexs[0].positionCoord, 0.5);
    [self.glkView display];
}
@end
