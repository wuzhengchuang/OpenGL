//
//  GLSLView.m
//  OpenGL ES大长腿1
//
//  Created by 吴闯 on 2020/8/24.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import "GLSLView.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "GLSLTypes.h"
#import "GLProgramHelper.h"
@interface GLSLView ()
@property(nonatomic,strong)CAEAGLLayer *eagLayer;
@property(nonatomic,strong)EAGLContext *eaglContext;
@property(nonatomic,assign)GLuint frameBuffer;
@property(nonatomic,assign)GLuint renderBuffer;
@property (nonatomic, assign) GLVertex *vertexs;
@property (nonatomic, assign) GLuint dataBuffer;
@property (nonatomic, assign) GLuint program;
@end

@implementation GLSLView
+(Class)layerClass{
    return [CAEAGLLayer class];
}
-(void)layoutSubviews{
    [self initLayer];
    [self initContext];
    [self deleteBuffers];
    [self initRenderBuffer];
    [self initFrameBuffer];
    [self initData];
    [self initProgram];
    [self render];
}
-(void)initLayer{
    self.eagLayer=(CAEAGLLayer *)self.layer;
    CGFloat scale = [[UIScreen mainScreen]scale];
    [self setContentScaleFactor:scale];
    self.eagLayer.drawableProperties=@{kEAGLDrawablePropertyRetainedBacking:@NO,kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8};
}
-(void)initContext{
    EAGLContext *context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context) {
        NSAssert(NO, @"EAGLContext创建失败！");
        exit(1);
    }
    if (![EAGLContext setCurrentContext:context]) {
        NSAssert(NO, @"EAGLContext设置失败！");
        exit(1);
    }
    self.eaglContext=context;
}
-(void)initRenderBuffer{
    GLuint renderbuffer;
    glGenRenderbuffers(1, &renderbuffer);
    self.renderBuffer=renderbuffer;
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [self.eaglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eagLayer];
    
}
-(void)initFrameBuffer{
    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    self.frameBuffer=frameBuffer;
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.renderBuffer);
}
-(void)deleteBuffers{
    if (_renderBuffer!=0) {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer=0;
    }
    if (_frameBuffer!=0) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer=0;
    }
}
-(void)initData{
    self.vertexs=(GLVertex *)malloc(sizeof(GLVertex)*4);
    self.vertexs[0].positionCoord=GLKVector3Make(-1.f, 1.f, 0.f);
    self.vertexs[0].textureCoord=GLKVector2Make(0.f, 1.f);
    self.vertexs[1].positionCoord=GLKVector3Make(-1.f, -1.f, 0.f);
    self.vertexs[1].textureCoord=GLKVector2Make(0.f, 0.f);
    self.vertexs[2].positionCoord=GLKVector3Make(1.f, 1.f, 0.f);
    self.vertexs[2].textureCoord=GLKVector2Make(1.f, 1.f);
    self.vertexs[3].positionCoord=GLKVector3Make(1.f, -1.f, 0.f);
    self.vertexs[3].textureCoord=GLKVector2Make(1.f, 0.f);
    glGenBuffers(1, &_dataBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, self.dataBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLVertex)*4, self.vertexs, GL_DYNAMIC_DRAW);
}
-(void)initProgram{
    self.program = [GLProgramHelper programWithShaderName:@"Normal"];
    glUseProgram(self.program);
}
-(void)render{
    glClearColor(1.f, 0.f, 0.f, 1.f);
    glClear(GL_COLOR_BUFFER_BIT);
    CGFloat scale = [[UIScreen mainScreen]scale];
    CGRect rect = self.frame;
    glViewport(rect.origin.x*scale, rect.origin.y*scale, rect.size.width*scale, rect.size.height*scale);
    GLuint positionCoord = glGetAttribLocation(self.program, "positionCoord");
    glEnableVertexAttribArray(positionCoord);
    glVertexAttribPointer(positionCoord, 3, GL_FLOAT, GL_FALSE, sizeof(GLVertex), NULL+offsetof(GLVertex, positionCoord));
    GLuint textureCoord = glGetAttribLocation(self.program, "textureCoord");
    glEnableVertexAttribArray(textureCoord);
    glVertexAttribPointer(textureCoord, 2, GL_FLOAT, GL_FALSE, sizeof(GLVertex), NULL+offsetof(GLVertex, textureCoord));
    GLuint colorMap = glGetAttribLocation(self.program, "colorMap");
    [self setUpTexture:@"1.jpg"];
    glUniform1i(colorMap, 0);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [self.eaglContext presentRenderbuffer:GL_RENDERBUFFER];
//    glFramebufferTexture2D(<#GLenum target#>, <#GLenum attachment#>, <#GLenum textarget#>, <#GLuint texture#>, <#GLint level#>)
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
@end
