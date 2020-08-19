//
//  EAGLView.m
//  OpenGL ES大长腿
//
//  Created by 吴闯 on 2020/8/18.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import "EAGLView.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>
typedef struct {
    GLKVector3 position;//顶点数据
    GLKVector2 textureCoord;//纹理
}GLVertex;
@interface EAGLView ()
@property(nonatomic,strong)CAEAGLLayer *eagLayer;
@property(nonatomic,strong)EAGLContext *eaglContext;
@property(nonatomic,assign)GLuint renderbuffer;
@property(nonatomic,assign)GLuint framebuffer;
@property(nonatomic,assign)GLuint vertBuffer;
@property(nonatomic,assign)GLuint program;
@end

@implementation EAGLView
-(void)layoutSubviews{
    [self setUpLayer];
    [self setUpContext];
    [self deleteRenderAndFrameBuffers];
    [self setUpRenderBuffer];
    [self setUpFrameBuffer];
    [self render];
}
+(Class)layerClass{
    return [CAEAGLLayer class];
}
-(void)render{
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    CGFloat scale = [[UIScreen mainScreen]scale];
    CGRect rect = self.frame;
    glViewport(0, 0, rect.size.width * scale, rect.size.height * scale);
    
    CGFloat aspect = 1.0;
    GLVertex verts[]={
        {{-aspect,aspect,0.0f,},{0.f,1.f,}},
        {{-aspect,-aspect,0.0f,},{0.f,0.f,}},
        {{aspect,aspect,0.0f,},{1.f,1.f,}},
        {{aspect,-aspect,0.0f,},{1.f,0.f,}},
    };
    GLuint vertBuffer;
    glGenBuffers(1, &vertBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(verts), verts, GL_DYNAMIC_DRAW);
    self.vertBuffer=vertBuffer;
    
    self.program = [self loadShaders:@"Normal"];
    
    GLuint position = glGetAttribLocation(self.program, "position");
    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLVertex), NULL+offsetof(GLVertex, position));
    glUniform1i(self.program, position);
    
    GLuint textureCoord = glGetAttribLocation(self.program, "textureCoord");
    glEnableVertexAttribArray(textureCoord);
    glVertexAttribPointer(textureCoord, 2, GL_FLOAT, GL_FALSE, sizeof(GLVertex), NULL+offsetof(GLVertex, textureCoord));
    glUniform1i(self.program, position);
    
    [self setUpTexture:@"timg.jpeg"];
    GLuint colorMap = glGetUniformLocation(self.program, "colorMap");
    glUniform1i(self.program, colorMap);
    glEnable(GL_DEPTH_TEST);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [self.eaglContext presentRenderbuffer:GL_RENDERBUFFER];
}
-(float)imageAspect:(NSString *)imageName{
    CGImageRef spriteImage = [UIImage imageNamed:imageName].CGImage;
    float width = (float)CGImageGetWidth(spriteImage);
    float height = (float)CGImageGetHeight(spriteImage);
    return width/height;
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
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    self.framebuffer=frameBuffer;
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.renderbuffer);
}
-(void)setUpRenderBuffer{
    GLuint renderbuffer;
    glGenRenderbuffers(1, &renderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);
    self.renderbuffer=renderbuffer;
    [self.eaglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eagLayer];
}
-(void)deleteRenderAndFrameBuffers{
    if (self.renderbuffer) {
        glDeleteRenderbuffers(1, &_renderbuffer);
        self.renderbuffer = 0;
    }
    if (self.framebuffer) {
        glDeleteFramebuffers(1, &_framebuffer);
        _framebuffer = 0;
    }
}
-(void)setUpContext{
    EAGLContext *context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context) {
        NSLog(@"创建context失败！");
        return;
    }
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"设置EAGLContext失败！");
        return;
    }
    self.eaglContext = context;
}
-(void)setUpLayer{
    self.eagLayer=(CAEAGLLayer *)self.layer;
    CGFloat scale = [[UIScreen mainScreen]scale];
    [self setContentScaleFactor:scale];
    self.eagLayer.drawableProperties=@{kEAGLDrawablePropertyRetainedBacking:@NO,kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8};
}
#pragma mark 链接程序字符串
- (GLuint)loadShaders:(NSString *)name{
    GLuint program = glCreateProgram();
    GLuint vertShader,fragShader;
    [self compile:&vertShader name:name type:GL_VERTEX_SHADER];
    [self compile:&fragShader name:name type:GL_FRAGMENT_SHADER];
    glAttachShader(program, vertShader);
    glAttachShader(program, fragShader);
    glLinkProgram(program);
    GLint linkStatus;
    glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        NSLog(@"链接程序失败！");
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
- (BOOL)compile:(GLuint *)shader name:(NSString *)name type:(GLenum)type {
    NSString *path=[[NSBundle mainBundle]pathForResource:name ofType:type==GL_VERTEX_SHADER?@"vsh":@"fsh"];
    const GLchar * source = [[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]UTF8String];
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    GLint compileStatus;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &compileStatus);
    if (compileStatus == GL_FALSE) {
        NSLog(@"着色器编译失败！");
        exit(1);
    }
    return YES;
}
@end
