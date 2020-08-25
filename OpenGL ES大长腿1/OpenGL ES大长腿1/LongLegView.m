//
//  LongLegView.m
//  OpenGL ES大长腿1
//
//  Created by 吴闯 on 2020/8/25.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import "LongLegView.h"
#import "GLSLTypes.h"
#import "LongLegVertexAttriArrayBuffer.h"
// 初始纹理高度占控件高度的比例
static CGFloat const kDefaultOriginTextureHeight = 0.7f;
static NSInteger const kVerticesCount = 8;
@interface LongLegView ()<GLKViewDelegate>
//当前图片Size;
@property (nonatomic, assign) CGSize currentImageSize;
@property (nonatomic, assign) CGFloat currentTextureWidth;
@property(nonatomic,strong)GLKBaseEffect *baseEffect;
@property(nonatomic,assign)GLVertex *vertices;
@property(nonatomic,strong)LongLegVertexAttriArrayBuffer *vertexAttribArrayBuffer;
@end

@implementation LongLegView
-(void)dealloc{
    
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder{
    if (self=[super initWithCoder:coder]) {
        [self commonInit];
    }
    return self;
}
#pragma mark - Public
- (void)updateImage:(UIImage *)image{
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:@{GLKTextureLoaderOriginBottomLeft:@(1)} error:nil];
    self.baseEffect = [[GLKBaseEffect alloc]init];
    self.baseEffect.texture2d0.enabled=YES;
    self.baseEffect.texture2d0.name=textureInfo.name;
    self.currentImageSize=image.size;
    //计算出图片宽度和view宽度一致时，高度占view高度的比例
    CGFloat ratio = (self.currentImageSize.height/self.currentImageSize.width)*(self.bounds.size.width/self.bounds.size.height);
    CGFloat textureHeiht = MIN(ratio, kDefaultOriginTextureHeight);
    self.currentTextureWidth = textureHeiht/ratio;
    [self calculateOriginTextureCoordWithTextureSize:self.currentImageSize startY:0 endY:0 newHeight:0];
}
#pragma mark - Private
- (void)commonInit{
    self.context=[[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context) {
        NSAssert(NO, @"创建EAGLContext失败");
        exit(1);
    }
    self.delegate = self;
    if (![EAGLContext setCurrentContext:self.context]) {
        NSAssert(NO, @"设置EAGLContext失败");
        exit(1);
    }
    self.vertices=(GLVertex *)malloc(sizeof(GLVertex)*kVerticesCount);
    glClearColor(1.f, 1.f, 1.f, 1.f);
    self.vertexAttribArrayBuffer=[[LongLegVertexAttriArrayBuffer alloc]initWithAttribStride:sizeof(GLVertex) numberOfVertices:kVerticesCount data:self.vertices usage:GL_DYNAMIC_DRAW];
    
}
-(void)calculateOriginTextureCoordWithTextureSize:(CGSize)size startY:(CGFloat)startY endY:(CGFloat)endY newHeight:(CGFloat)newHeight{
    NSLog(@"%lf,%lf",size.width,size.height);
    //1. 计算拉伸后的宽高比;
    CGFloat ratio = (size.height / size.width) *
    (self.bounds.size.width / self.bounds.size.height);
    //2. 宽度=纹理本身宽度;
    CGFloat textureWidth = self.currentTextureWidth;
    //3. 高度=纹理高度*radio(宽高比)
    CGFloat textureHeight = textureWidth * ratio;
    NSLog(@"%f,%f,%f,%f",newHeight,endY,startY,textureHeight);
    //4. 拉伸量 (newHeight - (endY-startY)) * 纹理高度;
    CGFloat delta = (newHeight - (endY -  startY)) * textureHeight;
    //5. 判断纹理高度+拉伸量是否超出最大值1
    if (textureHeight + delta >= 1) {
        delta = 1 - textureHeight;
        newHeight = delta / textureHeight + (endY -  startY);
    }
    //左上角
    GLKVector3 pointLT = GLKVector3Make(-textureWidth, textureHeight+delta, 0);
    //右上角
    GLKVector3 pointRT = GLKVector3Make(textureWidth, textureHeight+delta, 0);
    //左下角
    GLKVector3 pointLB = GLKVector3Make(-textureWidth, -(textureHeight+delta), 0);
    //右下角
    GLKVector3 pointRB = GLKVector3Make(textureWidth, -(textureHeight+delta), 0);
    //
}
#pragma mark - GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
}
@end
