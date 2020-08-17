//
//  EAGLView.m
//  OpenGL ES 滤镜1
//
//  Created by 吴闯 on 2020/8/8.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import "EAGLView.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
typedef struct {
    GLKVector3 position;
    GLKVector2 textureCoord;
}ScnceVertex;
@interface EAGLView ()
{
    CADisplayLink *displayLink;
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
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeClick)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
float startTimeInterval=0.0;
-(void)timeClick{
    if (startTimeInterval == 0.0) {
        startTimeInterval = displayLink.timestamp;
    }
    glUseProgram(self.program);
    glBindBuffer(GL_ARRAY_BUFFER, self.vertBuffer);

    GLuint time = glGetUniformLocation(self.program, "time");
    glUniform1f(time, displayLink.timestamp-startTimeInterval);
    glClearColor(1, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [self.eaglContext presentRenderbuffer:GL_RENDERBUFFER];
}
+ (Class)layerClass{
    return [CAEAGLLayer class];
}
-(void)render{
    glClearColor(1, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    CGFloat scale = [[UIScreen mainScreen]scale];
    CGRect rect = self.frame;
    glViewport(rect.origin.x*scale, rect.origin.y*scale, rect.size.width*scale, rect.size.height*scale);
    NSString *vertPath = [[NSBundle mainBundle]pathForResource:@"Glitch" ofType:@"vsh"];
    NSString *fragPath = [[NSBundle mainBundle]pathForResource:@"Glitch" ofType:@"fsh"];
    self.program = [self loadShaders:vertPath frag:fragPath];
    
    ScnceVertex verts[]={
        {{-1.f,1.f,0.0f,},{0.f,1.f,}},
        {{-1.f,-1.f,0.0f,},{0.f,0.f,}},
        {{1.f,1.f,0.0f,},{1.f,1.f,}},
        {{1.f,-1.f,0.0f,},{1.f,0.f,}},
    };
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(verts), verts, GL_DYNAMIC_DRAW);
    self.vertBuffer=buffer;
    
    GLuint position = glGetAttribLocation(self.program, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(ScnceVertex), NULL + offsetof(ScnceVertex, position));
    
    GLuint textCoord = glGetAttribLocation(self.program, "textCoord");
    glEnableVertexAttribArray(textCoord);
    glVertexAttribPointer(textCoord, 2, GL_FLOAT, GL_FALSE, sizeof(ScnceVertex),NULL + offsetof(ScnceVertex, textureCoord));
    
    [self setUpTexture:@"timg.jpeg"];
    GLuint colorMap = glGetUniformLocation(self.program, "colorMap");
    glUniform1i(colorMap, 0);
    GLuint TexSize = glGetUniformLocation(self.program, "TexSize");
    CGSize size = [self getSizeImage:@"timg.jpeg"];
    glUniform2f(TexSize, size.width, size.height);
    glEnable(GL_DEPTH_TEST);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [self.eaglContext presentRenderbuffer:GL_RENDERBUFFER];
}
-(CGSize)getSizeImage:(NSString *)imageName{
    CGImageRef spriteImage = [UIImage imageNamed:imageName].CGImage;
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    return CGSizeMake(width, height);
}
-(GLuint)setUpTexture:(NSString *)imageName{
    CGImageRef spriteImage = [UIImage imageNamed:imageName].CGImage;
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    GLubyte *spriteData = calloc(width*height*4, sizeof(GLubyte));
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    CGRect rect = CGRectMake(0, 0, width, height);
    //翻转图片
    CGContextTranslateCTM(spriteContext, rect.origin.x, rect.origin.y);
    CGContextTranslateCTM(spriteContext, 0, height);
    CGContextScaleCTM(spriteContext, 1, -1);
    CGContextTranslateCTM(spriteContext, -1.0*rect.origin.x, -1.0*rect.origin.y);
    CGContextDrawImage(spriteContext, rect, spriteImage);
    CGContextRelease(spriteContext);
    
    GLuint texture;
    glGenTextures(1, &texture);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    //设置纹理属性
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    float fw=width,fh=height;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    free(spriteData);
    return texture;
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
    if (_colorRenderBuffer!=0) {
        glDeleteRenderbuffers(1, &_colorRenderBuffer);
        _colorRenderBuffer=0;
    }
    if (_colorFrameBuffer!=0) {
        glDeleteFramebuffers(1, &_colorFrameBuffer);
        _colorFrameBuffer=0;
    }
}
-(void)setUpContext{
    EAGLContext *context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context) {
        NSLog(@"EAGLContext 创建失败");
        return;
    }
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"setCurrentContext 设置失败");
        return;
    }
    self.eaglContext=context;
}
-(void)setUpLayer{
    self.eagLayer=(CAEAGLLayer *)self.layer;
    [self setContentScaleFactor:[[UIScreen mainScreen]scale]];
    self.eagLayer.drawableProperties=@{kEAGLDrawablePropertyRetainedBacking:@NO,kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8};
}
-(GLuint)loadShaders:(NSString *)vertFile frag:(NSString *)fragFile{
    GLuint vertShader,fragShader;
    GLuint program =  glCreateProgram();
    [self compile:vertFile shader:&vertShader type:GL_VERTEX_SHADER];
    [self compile:fragFile shader:&fragShader type:GL_FRAGMENT_SHADER];
    glAttachShader(program, vertShader);
    glAttachShader(program, fragShader);
    glLinkProgram(program);
    GLint params;
    glGetProgramiv(program, GL_LINK_STATUS, &params);
    if (params == GL_FALSE) {
        NSLog(@"链接失败");
        exit(1);
    }
    glUseProgram(program);
    glDetachShader(program, vertShader);
    glDeleteShader(vertShader);
    vertShader=0;
    glDetachShader(program, fragShader);
    glDeleteShader(fragShader);
    fragShader=0;
    return program;
}
-(void)compile:(NSString *)filePath shader:(GLuint *)shader type:(GLenum)type{
    NSString *shaderContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source=(GLchar *)[shaderContent UTF8String];
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
}
@end
