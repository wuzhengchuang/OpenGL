//
//  ViewController.m
//  OpenGL ES Test2
//
//  Created by 吴闯 on 2020/7/30.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
typedef struct {
    GLKVector3 positionCoord;//顶点坐标
    GLKVector2 textureCoord;//纹理坐标
    GLKVector3 normal;//法线
}ZBVertex;
static NSInteger const kCoordCount=36;

@interface ViewController ()<GLKViewDelegate>
{
    EAGLContext *context;
    GLKBaseEffect *effect;
    CADisplayLink *displayLink;
}
@property(nonatomic,strong)GLKView *glkView;
@property(nonatomic,assign)ZBVertex *vertex;
@property(nonatomic,strong)CADisplayLink *displayLink;
@property(nonatomic,assign)NSInteger angle;
@property (nonatomic, assign) GLuint vertexBuffer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor blackColor];
    [self setUpConfig];
    [self setUpVertex];
    [self setUpTexure];
    displayLink=[CADisplayLink displayLinkWithTarget:self selector:@selector(refreshPage)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
-(void)refreshPage{
    self.angle=(self.angle+5)%360;
    effect.transform.modelviewMatrix=GLKMatrix4MakeRotation(GLKMathDegreesToRadians(self.angle), 0.3, 1, 0.7);
    [self.glkView display];
}
-(void)setUpConfig{
    context=[[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context) {
        NSLog(@"创建上下文失败");
    }
    [EAGLContext setCurrentContext:context];
    self.glkView=(GLKView *)self.view;
    self.glkView.delegate=self;
    self.glkView.context=context;
    self.glkView.drawableColorFormat=GLKViewDrawableColorFormatSRGBA8888;
    self.glkView.drawableDepthFormat=GLKViewDrawableDepthFormat24;
    glDepthRangef(1, 0);
//    glClearColor(1, 1, 1, 1);
}
-(void)setUpVertex{
    self.vertex=malloc(sizeof(ZBVertex)*kCoordCount);
    // 前面
    self.vertex[0] = (ZBVertex){{-0.5, 0.5, 0.5}, {0, 1}, {0, 0, 1}};
    self.vertex[1] = (ZBVertex){{-0.5, -0.5, 0.5}, {0, 0}, {0, 0, 1}};
    self.vertex[2] = (ZBVertex){{0.5, 0.5, 0.5}, {1, 1}, {0, 0, 1}};
    self.vertex[3] = (ZBVertex){{-0.5, -0.5, 0.5}, {0, 0}, {0, 0, 1}};
    self.vertex[4] = (ZBVertex){{0.5, 0.5, 0.5}, {1, 1}, {0, 0, 1}};
    self.vertex[5] = (ZBVertex){{0.5, -0.5, 0.5}, {1, 0}, {0, 0, 1}};
    
    // 上面
    self.vertex[6] = (ZBVertex){{0.5, 0.5, 0.5}, {1, 1}, {0, 1, 0}};
    self.vertex[7] = (ZBVertex){{-0.5, 0.5, 0.5}, {0, 1}, {0, 1, 0}};
    self.vertex[8] = (ZBVertex){{0.5, 0.5, -0.5}, {1, 0}, {0, 1, 0}};
    self.vertex[9] = (ZBVertex){{-0.5, 0.5, 0.5}, {0, 1}, {0, 1, 0}};
    self.vertex[10] = (ZBVertex){{0.5, 0.5, -0.5}, {1, 0}, {0, 1, 0}};
    self.vertex[11] = (ZBVertex){{-0.5, 0.5, -0.5}, {0, 0}, {0, 1, 0}};
    
    // 下面
    self.vertex[12] = (ZBVertex){{0.5, -0.5, 0.5}, {1, 1}, {0, -1, 0}};
    self.vertex[13] = (ZBVertex){{-0.5, -0.5, 0.5}, {0, 1}, {0, -1, 0}};
    self.vertex[14] = (ZBVertex){{0.5, -0.5, -0.5}, {1, 0}, {0, -1, 0}};
    self.vertex[15] = (ZBVertex){{-0.5, -0.5, 0.5}, {0, 1}, {0, -1, 0}};
    self.vertex[16] = (ZBVertex){{0.5, -0.5, -0.5}, {1, 0}, {0, -1, 0}};
    self.vertex[17] = (ZBVertex){{-0.5, -0.5, -0.5}, {0, 0}, {0, -1, 0}};
    
    // 左面
    self.vertex[18] = (ZBVertex){{-0.5, 0.5, 0.5}, {1, 1}, {-1, 0, 0}};
    self.vertex[19] = (ZBVertex){{-0.5, -0.5, 0.5}, {0, 1}, {-1, 0, 0}};
    self.vertex[20] = (ZBVertex){{-0.5, 0.5, -0.5}, {1, 0}, {-1, 0, 0}};
    self.vertex[21] = (ZBVertex){{-0.5, -0.5, 0.5}, {0, 1}, {-1, 0, 0}};
    self.vertex[22] = (ZBVertex){{-0.5, 0.5, -0.5}, {1, 0}, {-1, 0, 0}};
    self.vertex[23] = (ZBVertex){{-0.5, -0.5, -0.5}, {0, 0}, {-1, 0, 0}};
    
    // 右面
    self.vertex[24] = (ZBVertex){{0.5, 0.5, 0.5}, {1, 1}, {1, 0, 0}};
    self.vertex[25] = (ZBVertex){{0.5, -0.5, 0.5}, {0, 1}, {1, 0, 0}};
    self.vertex[26] = (ZBVertex){{0.5, 0.5, -0.5}, {1, 0}, {1, 0, 0}};
    self.vertex[27] = (ZBVertex){{0.5, -0.5, 0.5}, {0, 1}, {1, 0, 0}};
    self.vertex[28] = (ZBVertex){{0.5, 0.5, -0.5}, {1, 0}, {1, 0, 0}};
    self.vertex[29] = (ZBVertex){{0.5, -0.5, -0.5}, {0, 0}, {1, 0, 0}};
    
    // 后面
    self.vertex[30] = (ZBVertex){{-0.5, 0.5, -0.5}, {0, 1}, {0, 0, -1}};
    self.vertex[31] = (ZBVertex){{-0.5, -0.5, -0.5}, {0, 0}, {0, 0, -1}};
    self.vertex[32] = (ZBVertex){{0.5, 0.5, -0.5}, {1, 1}, {0, 0, -1}};
    self.vertex[33] = (ZBVertex){{-0.5, -0.5, -0.5}, {0, 0}, {0, 0, -1}};
    self.vertex[34] = (ZBVertex){{0.5, 0.5, -0.5}, {1, 1}, {0, 0, -1}};
    self.vertex[35] = (ZBVertex){{0.5, -0.5, -0.5}, {1, 0}, {0, 0, -1}};
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(ZBVertex)*kCoordCount, _vertex, GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, false, sizeof(ZBVertex), NULL+offsetof(ZBVertex, positionCoord));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, false, sizeof(ZBVertex), NULL+offsetof(ZBVertex, textureCoord));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, false, sizeof(ZBVertex), NULL+offsetof(ZBVertex, normal));
}
-(void)setUpTexure{
   NSString *path = [[NSBundle mainBundle]pathForResource:@"meinv" ofType:@"jpg"];
    GLKTextureInfo *textureInfo=[GLKTextureLoader textureWithContentsOfFile:path options:@{GLKTextureLoaderOriginBottomLeft:@(1)} error:nil];
    effect = [[GLKBaseEffect alloc]init];
    effect.texture2d0.enabled=GL_TRUE;
    effect.texture2d0.name=textureInfo.name;
    effect.light0.enabled=YES;
    effect.light0.diffuseColor=GLKVector4Make(1, 1, 1, 1);
    effect.light0.position=GLKVector4Make(-0.5, -0.5, 5, 1);
}
#pragma mark GLKViewDelegate
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glEnable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    [effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, kCoordCount);
}
- (void)dealloc {
    
    if ([EAGLContext currentContext] == self.glkView.context) {
        [EAGLContext setCurrentContext:nil];
    }
    if (_vertex) {
        free(_vertex);
        _vertex = nil;
    }
    
    if (_vertexBuffer) {
        glDeleteBuffers(1, &_vertexBuffer);
        _vertexBuffer = 0;
    }
    
    //displayLink 失效
    [self.displayLink invalidate];
}
@end
