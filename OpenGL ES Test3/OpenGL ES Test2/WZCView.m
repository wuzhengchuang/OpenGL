//
//  WZCView.m
//  OpenGL ES Test2
//
//  Created by 吴闯 on 2020/8/2.
//  Copyright © 2020 吴闯. All rights reserved.
//
#import <OpenGLES/ES2/gl.h>
#import "WZCView.h"
@interface WZCView ()
//在iOS和tvOS上绘制OpenGL ES内容的图层，继承与CALayer
//核心动画->特殊图层一种
/*
 思路：
 1.创建图层
 2.创建上下文
 3.清空缓存区
 4.设置RenderBuffer
 5.设置FrameBuffer
 6.开始绘制
 */
@property(nonatomic,strong)CAEAGLLayer *myEagLayer;
@property(nonatomic,strong)EAGLContext *myContext;
@property(nonatomic,assign)GLuint myColorRenderBuffer;
@property(nonatomic,assign)GLuint myColorFrameBuffer;
@property(nonatomic,assign)GLuint myPrograme;
@end

@implementation WZCView

-(void)layoutSubviews{
    //1.
    [self setUpLayer];
    [self setUpContext];
    [self setUpRenderBuffer];
    [self setUpFrameBuffer];
    [self renderLayer];
}
+ (Class)layerClass{
    return [CAEAGLLayer class];
}
//6.开始绘制
-(void)renderLayer{
    //1.
    glClearColor(0.3, 0.45, 0.5, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    //2.
    CGFloat scale =[[UIScreen mainScreen]scale];
    glViewport(self.frame.origin.x*scale, self.frame.origin.y*scale, self.frame.size.width*scale, self.frame.size.height*scale);
    //3.读取片元着色器/顶点着色器
    NSString *vertFile=[[NSBundle mainBundle]pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fragFile=[[NSBundle mainBundle]pathForResource:@"shaderf" ofType:@"fsh"];
    self.myPrograme = [self loaderShaders:vertFile withFrag:fragFile];
    //5.program 的连接
    glLinkProgram(self.myPrograme);
    GLint linkStatus;
    //获取链接状态
    glGetProgramiv(self.myPrograme, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        NSLog(@"链接失败");
        GLchar infolog[512];
        glGetProgramInfoLog(self.myPrograme, sizeof(infolog), 0, &infolog[0]);
        NSString *message=[NSString stringWithUTF8String:infolog];
        NSLog(@"Program Link Error:%@",message);
        return;
    }
    //6.
    glUseProgram(self.myPrograme);
    //7.准备顶点数据/纹理坐标
    //2个三角形构成
    GLfloat attArr[]={
        0.5f,-0.5f,-1.0f, 1.0f,0.f,
        -0.5f,0.5f,-1.0f, 0.0f,1.f,
        -0.5f,-0.5f,-1.0f, 0.0f,0.f,
        
        0.5f,0.5f,-1.0f, 1.0f,0.f,
        0.5f,-0.5f,-1.0f, 0.0f,1.f,
        0.5f,-0.5f,-1.0f, 1.0f,0.f,
    };
    //8.顶点->顶点缓存区
    GLuint attrBuffer;
    glGenBuffers(1, &attrBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attArr), attArr, GL_DYNAMIC_DRAW);
    //9.打开通道
    //1.获取顶点数据通道ID
    GLuint position = glGetAttribLocation(self.myPrograme, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, false, sizeof(GLfloat)*5, NULL);
    //2.获取纹理数据通道ID
    GLuint textCoord = glGetAttribLocation(self.myPrograme, "textCoord");
    glEnableVertexAttribArray(textCoord);
    glVertexAttribPointer(textCoord, 2, GL_FLOAT, false, sizeof(GLfloat)*5, NULL+3);
    //10.加载纹理
    [self setUpTexture:@"1.jpeg"];
    //11.
    GLint location = glGetUniformLocation(self.myPrograme, "colorMap");
    glUniform1i(location, 0);
    //12.
    glDrawArrays(GL_TRIANGLES, 0, 6);
    //13
    [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
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
    CGContextDrawImage(spriteContext, rect, spriteImage);
    CGContextRelease(spriteContext);
    
    //纹理
//    glGenTextures(1, 0);
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
//5.创建帧缓存区
-(void)setUpFrameBuffer{
    //1.
    GLuint buffer;
    //2.
    glGenFramebuffers(1, &buffer);
    self.myColorFrameBuffer=buffer;
    //3.
    glBindFramebuffer(GL_FRAMEBUFFER, self.myColorFrameBuffer);
    //4.
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.myColorRenderBuffer);
    
}
//4.创建渲染缓冲区
-(void)setUpRenderBuffer{
    //1.定义bufferID
    GLuint buffer;
    glGenRenderbuffers(1, &buffer);
    self.myColorRenderBuffer=buffer;
    //2.
    glBindRenderbuffer(GL_RENDERBUFFER, self.myColorRenderBuffer);
    //3.
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEagLayer];
}
//3.清空缓存区
-(void)deleteRenderAndFrameBuffer{
    //1.Frame Buffer Object : FBO;
    //2.render buffer可以分为三个类别：颜色缓存区，深度缓存区，模板缓存区
    glDeleteBuffers(1, &_myColorRenderBuffer);
    self.myColorRenderBuffer = 0;
    glDeleteBuffers(1, &_myColorFrameBuffer);
    self.myColorFrameBuffer = 0;
    
}
//2.设置上下文
-(void)setUpContext{
    //1.
    EAGLContext *context=[[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    //2.
    if (!context) {
        NSLog(@"create context failed");
        return;
    }
    //3.设置当前context
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"setCurrentContext failed");
        return;
    }
    self.myContext=context;
}
//1.设置图层
-(void)setUpLayer{
    //1.创建图层
    self.myEagLayer=(CAEAGLLayer *)self.layer;
    //2.
    [self setContentScaleFactor:[[UIScreen mainScreen]scale]];
    /*
     kEAGLDrawablePropertyRetainedBacking:绘图表面完成之后是否保留绘制内容
     kEAGLDrawablePropertyColorFormat
     */
    //3.
    self.myEagLayer.drawableProperties=@{kEAGLDrawablePropertyRetainedBacking:@false,kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8};
}
#pragma mark --shader
-(GLuint)loaderShaders:(NSString *)vert withFrag:(NSString *)frag{
    //1.定义顶点着色器/片元着色器对象
    GLuint verShader,fragShader;
    //2.program
    GLuint program=glCreateProgram();
    //3.编译顶点着色器，片元着色器
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:vert];
    //4.编译好的程序附着到shader
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    //5.删除着色器
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    return program;
}
-(void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    //1.读取路径
    NSString *content=[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source=[content UTF8String];
    //2.创建对应类型的shader
    *shader=glCreateShader(type);
    //3.将着色器的源码附着到着色器对象上
    glShaderSource(*shader, 1, &source, NULL);
    //4.编译
    glCompileShader(*shader);
}
@end
