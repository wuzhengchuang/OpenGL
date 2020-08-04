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
#import "UIColor+RGBA.h"
@interface EAGLView ()
@property(nonatomic,strong)CAEAGLLayer *eagLayer;
@property(nonatomic,strong)EAGLContext *eaglContext;
@property(nonatomic,assign)GLuint colorRenderBuffer;
@property(nonatomic,assign)GLuint colorFrameBuffer;
@property(nonatomic,assign)GLuint program;
@end

@implementation EAGLView
- (void)layoutSubviews{
    [self setUpLayer];
    [self setUpContext];
    [self deleteBuffer];
    [self setUpRenderBuffer];
    [self setUpFrameBuffer];
    [self renderLayer];
}
+(Class)layerClass{
    return [CAEAGLLayer class];
}
-(void)renderLayer{
    RGBA rgba;
    UIColorToRGBA(self.backgroundColor, &rgba);
//    glClearColor(rgba.red, rgba.green, rgba.blue, rgba.alpa);
    glClearColor(1.0, 0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    CGFloat scale = [[UIScreen mainScreen]scale];
    CGRect rect = self.frame;
    glViewport(rect.origin.x*scale, rect.origin.y*scale, rect.size.width*scale, rect.size.height*scale);
    [self.eaglContext presentRenderbuffer:GL_RENDERBUFFER];
}
-(void)setUpFrameBuffer{
    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    self.colorFrameBuffer=frameBuffer;
    glBindFramebuffer(GL_FRAMEBUFFER, self.colorFrameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_FRAMEBUFFER, self.colorRenderBuffer);
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
    if (![EAGLContext setCurrentContext:self.eaglContext]) {
        NSLog(@"setCurrentContext失败~~~");
        return;
    }
    self.eaglContext=context;
}
-(void)setUpLayer{
    self.eagLayer=(CAEAGLLayer *)self.layer;
    [self setContentScaleFactor:[[UIScreen mainScreen]scale]];
    /*
     kEAGLDrawablePropertyRetainedBacking:绘图表面完成之后是否保留绘制内容
     kEAGLDrawablePropertyColorFormat
     */
    //3.
    self.eagLayer.drawableProperties=@{kEAGLDrawablePropertyRetainedBacking:@false,kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8};
}

#pragma mark 加载纹理文件

@end
