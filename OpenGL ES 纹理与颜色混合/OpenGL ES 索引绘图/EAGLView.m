//
//  EAGLView.m
//  OpenGL ES 索引绘图
//
//  Created by 吴闯 on 2020/8/4.
//  Copyright © 2020 吴闯. All rights reserved.
//
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "EAGLView.h"
#import "GLESMath.h"
@interface EAGLView ()
{
    float xDegree;
    float yDegree;
    float zDegree;
    BOOL bX;
    BOOL bY;
    BOOL bZ;
    NSTimer* myTimer;
}
@property(nonatomic,strong)CAEAGLLayer *eagLayer;
@property(nonatomic,strong)EAGLContext *eaglContext;
@property(nonatomic,assign)GLuint colorRenderBuffer;
@property(nonatomic,assign)GLuint colorFrameBuffer;
@property(nonatomic,assign)GLuint program;
@property(nonatomic,assign)GLuint vertBuffer;
@end

@implementation EAGLView
- (void)layoutSubviews{
    [self setUpLayer];
    [self setUpContext];
    [self deleteBuffer];
    [self setUpRenderBuffer];
    [self setUpFrameBuffer];
    [self render];
}
-(void)render{
    glClearColor(0, 0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    CGFloat scale = [[UIScreen mainScreen]scale];
    CGRect rect = self.frame;
    glViewport(rect.origin.x*scale, rect.origin.y*scale, rect.size.width*scale, rect.size.height*scale);
    NSString * vertFile = [[NSBundle mainBundle]pathForResource:@"sharderv" ofType:@"glsl"];
    NSString * fragFile = [[NSBundle mainBundle]pathForResource:@"sharderf" ofType:@"glsl"];
    if (self.program) {
        glDeleteProgram(self.program);
        self.program=0;
    }
    self.program = [self loaderShaders:vertFile frag:fragFile];
    glLinkProgram(self.program);
    GLint result;
    glGetProgramiv(self.program, GL_LINK_STATUS, &result);
    if (result == GL_FALSE) {
        NSLog(@"链接程序失败");
        exit(1);
    }
    glUseProgram(self.program);

    GLfloat verts[]={
        -0.5f,0.5f,0.0f,   1.0f,0.0f,1.0f,   0.f,1.f,
        0.5f,0.5f,0.0f,    1.0f,0.0f,1.0f,   1.f,1.f,
        -0.5f,-0.5f,0.0f,  1.0f,1.0f,1.0f,   0.f,0.f,
        0.5f,-0.5f,0.0f,   1.0f,1.0f,1.0f,   1.f,0.f,
        0.f,0.f,1.0f,      0.0f,1.0f,0.0f,   0.5,0.5,
    };
    
    GLuint indices[]={
        0,3,2,
        0,1,3,
        0,2,4,
        0,4,1,
        2,3,4,
        1,4,3,
    };
    if (self.vertBuffer == 0) {
        glGenBuffers(1, &_vertBuffer);
    }
    glGenBuffers(1, &_vertBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(verts), &verts, GL_DYNAMIC_DRAW);

    GLint position = glGetAttribLocation(self.program, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat *)NULL);

    GLint positionColor = glGetAttribLocation(self.program, "positionColor");
    glEnableVertexAttribArray(positionColor);
    glVertexAttribPointer(positionColor, 3, GL_FLOAT, false, sizeof(GLfloat)*8, (GLfloat *)NULL+3);
    
    GLint textCoord = glGetAttribLocation(self.program, "textCoord");
    glEnableVertexAttribArray(textCoord);
    glVertexAttribPointer(textCoord, 2, GL_FLOAT, false, sizeof(GLfloat)*8, (GLfloat *)NULL+6);
    
    [self setUpTexture:@"timg.jpeg"];
    
    GLint alpha = glGetUniformLocation(self.program, "alpha");
    glUniform1f(alpha, 0.5);
    GLint colorMap = glGetUniformLocation(self.program, "colorMap");
    glUniform1i(colorMap, 0);
    //mvp

    GLint projectionMatrix = glGetUniformLocation(self.program, "projectionMatrix");
    GLint modelViewMatrix = glGetUniformLocation(self.program, "modelViewMatrix");

    float width =self.frame.size.width;
    float height =self.frame.size.height;
    //4*4投影矩阵
    KSMatrix4 _projectionMatrix;
    ksMatrixLoadIdentity(&_projectionMatrix);
    float aspect = width/height;
    ksPerspective(&_projectionMatrix, 30.f, aspect, 5.0f, 20.0f);
    glUniformMatrix4fv(projectionMatrix, 1, GL_FALSE, (GLfloat *)&_projectionMatrix.m[0][0]);
    //4*4模型视图矩阵
    KSMatrix4 _modelViewMatrix;
    ksMatrixLoadIdentity(&_modelViewMatrix);
    ksTranslate(&_modelViewMatrix, 0, 0, -10.f);
    //旋转XYZ
    KSMatrix4 _rotationMatrix;
    ksMatrixLoadIdentity(&_rotationMatrix);
    ksRotate(&_rotationMatrix, xDegree, 1.0, 0.0, 0.0);
    ksRotate(&_rotationMatrix, yDegree, 0.0, 1.0, 0.0);
    ksRotate(&_rotationMatrix, zDegree, 0.0, 0.0, 1.0);
    //投影矩阵
    ksMatrixMultiply(&_modelViewMatrix, &_rotationMatrix, &_modelViewMatrix);
    glUniformMatrix4fv(modelViewMatrix, 1, GL_FALSE, (GLfloat *)&_modelViewMatrix.m[0][0]);
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
    //索引绘图
    glDrawElements(GL_TRIANGLES, sizeof(indices)/sizeof(indices[0]), GL_UNSIGNED_INT,indices);
    [self.eaglContext presentRenderbuffer:GL_RENDERBUFFER];
}
-(void)setUpFrameBuffer{
    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    self.colorFrameBuffer=frameBuffer;
    glBindFramebuffer(GL_FRAMEBUFFER, self.colorFrameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.colorRenderBuffer);
}
-(void)setUpRenderBuffer{
    GLuint renderBuffer;
    glGenRenderbuffers(1, &renderBuffer);
    self.colorRenderBuffer=renderBuffer;
    glBindRenderbuffer(GL_RENDERBUFFER, self.colorRenderBuffer);
    [self.eaglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eagLayer];
}
-(void)deleteBuffer{
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer=0;
    glDeleteFramebuffers(1, &_colorFrameBuffer);
    _colorFrameBuffer=0;
}
-(void)setUpContext{
    EAGLContext *context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context) {
        NSLog(@"创建EAGLContext失败~~~");
        return;
    }
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"setCurrentContext失败~~~");
        return;
    }
    self.eaglContext=context;
}
-(void)setUpLayer{
    self.eagLayer=(CAEAGLLayer *)self.layer;
    [self setContentScaleFactor:[[UIScreen mainScreen]scale]];
    self.eagLayer.opaque = YES;
    /*
     kEAGLDrawablePropertyRetainedBacking:绘图表面完成之后是否保留绘制内容
     kEAGLDrawablePropertyColorFormat
     */
    //3.
    self.eagLayer.drawableProperties=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}
+(Class)layerClass{
    return [CAEAGLLayer class];
}
#pragma mark 加载纹理文件
-(GLuint)loaderShaders:(NSString *)vert frag:(NSString *)frag{
    GLuint vertShader,fragShader;
    GLuint program = glCreateProgram();
    [self compileShader:&vertShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    glAttachShader(program, vertShader);
    glAttachShader(program, fragShader);
    glDeleteShader(vertShader);
    glDeleteShader(fragShader);
    return program;
}
-(void)compileShader:(GLuint*)shader type:(GLenum)type file:(NSString *)file{
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:NULL];
    const GLchar *source = (GLchar *)[content UTF8String];
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}
- (IBAction)XClick:(id)sender {
    //开启定时器
    if (!myTimer) {
        myTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reDegree) userInfo:nil repeats:YES];
    }
    //更新的是X还是Y
    bX = !bX;
}
- (IBAction)YClick:(id)sender {
    //开启定时器
       if (!myTimer) {
           myTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reDegree) userInfo:nil repeats:YES];
       }
       //更新的是X还是Y
       bY = !bY;
}
- (IBAction)ZClick:(id)sender {
    //开启定时器
    if (!myTimer) {
        myTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(reDegree) userInfo:nil repeats:YES];
    }
    //更新的是X还是Y
    bZ = !bZ;
}
-(void)reDegree
{
    //如果停止X轴旋转，X = 0则度数就停留在暂停前的度数.
    //更新度数
    xDegree += bX * 5;
    yDegree += bY * 5;
    zDegree += bZ * 5;
    //重新渲染
    [self render];
    
}
-(GLuint)setUpTexture:(NSString *)fileName{
    //1.纹理解压缩
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image ~");
        exit(1);
    }
    //2.
    /*
     参数1：data，指向要渲染的绘制图像的内存地址
     参数2：width，bitmap的宽度，单位为像素
     参数3：height,bitmap的宽度，单位为像素
     参数4：bitPerComponent,内存中像素的每个组件的位数，比如32位RGBA，就设置为8
     参数5：bytesPerRow，bitmap的每一行的内存所占的比特数
     参数6：colorSpace，bitmap上使用的颜色空间 kCGImageAlphaPremultipliedLast:RGBA
     */
    
    size_t width= CGImageGetWidth(spriteImage);
    size_t height =CGImageGetHeight(spriteImage);
    GLubyte *spriteData = (GLubyte *)calloc(width*height*4, sizeof(GLubyte));
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGRect rect = CGRectMake(0, 0, width, height);
    //翻转图片
    CGContextTranslateCTM(spriteContext, rect.origin.x, rect.origin.y);
    CGContextTranslateCTM(spriteContext, 0, height);
    CGContextScaleCTM(spriteContext, 1, -1);
    CGContextTranslateCTM(spriteContext, -1.0*rect.origin.x, -1.0*rect.origin.y);
    CGContextDrawImage(spriteContext, rect, spriteImage);
    CGContextRelease(spriteContext);
    
    //纹理
//    glGenTextures(1, 0);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, 0);
    //设置纹理属性
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    float fw=width,fh=height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    free(spriteData);
    return 0;
}
@end
