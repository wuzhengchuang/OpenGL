//
//  EAGLView.m
//  OpenGL ES 滤镜1
//
//  Created by 吴闯 on 2020/8/8.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import "EAGLView.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
@interface EAGLView ()
@property(nonatomic,strong)CAEAGLLayer *eagLayer;
@property(nonatomic,strong)EAGLContext *eaglContext;
@property(nonatomic,assign)GLuint colorRenderBuffer;
@property(nonatomic,assign)GLuint colorFrameBuffer;
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
+ (Class)layerClass{
    return [CAEAGLLayer class];
}
-(void)render{
    glClearColor(1, 0, 0, 1);
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
@end
