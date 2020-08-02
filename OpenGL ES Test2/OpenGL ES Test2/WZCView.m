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
@property(nonatomic,strong)CAEAGLLayer *myEagLayer;
@property(nonatomic,strong)EAGLContext *myContext;
@property(nonatomic,assign)GLuint myColorRenderBuffer;
@property(nonatomic,assign)GLuint myColorFrameBuffer;
@property(nonatomic,assign)GLuint myPrograme;
@end

@implementation WZCView

-(void)layoutSubviews{
    
}
+ (Class)layerClass{
    return [CAEAGLLayer class];
}

@end
