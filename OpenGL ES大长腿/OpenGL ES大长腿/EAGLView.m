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
@interface EAGLView ()
@property(nonatomic,strong)CAEAGLLayer *eagLayer;
@property(nonatomic,strong)EAGLContext *eaglContext;
@property(nonatomic,assign)GLuint renderbuffer;
@property(nonatomic,assign)GLuint framebuffer;
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
@end
