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
@interface GLSLView ()
@property(nonatomic,strong)CAEAGLLayer *eagLayer;
@property(nonatomic,strong)EAGLContext *context;
@end

@implementation GLSLView
+(Class)layerClass{
    return [CAEAGLLayer class];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    [self initLayer];
    [self initContext];
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
    }
}
@end
