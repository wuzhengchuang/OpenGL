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
@property (nonatomic, assign)CGFloat currentTextureStartY;
@property (nonatomic, assign)CGFloat currentTextureEndY;
@property (nonatomic, assign)CGFloat currentNewHeight;
@property (nonatomic, assign)BOOL hasChange;
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
    self.hasChange=YES;
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
    [self.vertexAttribArrayBuffer updateAttribStride:sizeof(GLVertex) numberOfVertices:kVerticesCount data:_vertices usage:GL_DYNAMIC_DRAW];
    [self display];
}
- (void)updateTexture{
    
}
/**
 将区域拉伸或压缩为某个高度
 @param startY 开始的纵坐标位置（相对于纹理）
 @param endY 结束的纵坐标位置（相对于纹理）
 @param newHeight 新的中间区域高度（相对于纹理）
 */
- (void)stretchingFromStartY:(CGFloat)startY
                      toEndY:(CGFloat)endY
               withNewHeight:(CGFloat)newHeight {
    
    self.hasChange = YES;
    [self calculateOriginTextureCoordWithTextureSize:self.currentImageSize startY:startY endY:endY newHeight:newHeight];
    [self.vertexAttribArrayBuffer updateAttribStride:sizeof(GLVertex) numberOfVertices:kVerticesCount data:self.vertices usage:GL_STATIC_DRAW];
    [self display];
    if(self.springDelegate && [self.springDelegate respondsToSelector:@selector(springViewStretchAreaDidChanged:)])
    {
        [self.springDelegate springViewStretchAreaDidChanged:self];
        
    }
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
    //中间矩形区域的顶点
    //0.7 - 2*0.7*0.25
    GLfloat tempStartYCoord = textureHeight*(1 - 2 * startY);
    GLfloat tempEndYCoord = textureHeight*(1 - 2 * endY);
    CGFloat startYCoord = MIN(tempStartYCoord, textureHeight);
    CGFloat endYCoord = MIN(tempEndYCoord, textureHeight);
    GLKVector3 centerPointLT = GLKVector3Make(-textureWidth, startYCoord+delta, 0);
    GLKVector3 centerPointRT = GLKVector3Make(textureWidth, startYCoord+delta, 0);
    GLKVector3 centerPointLB = GLKVector3Make(-textureWidth, endYCoord-delta, 0);
    GLKVector3 centerPointRB = GLKVector3Make(textureWidth, endYCoord-delta, 0);
    self.vertices[0].positionCoord = pointRT;
    self.vertices[0].textureCoord = GLKVector2Make(1, 1);
    
    self.vertices[1].positionCoord = pointLT;
    self.vertices[1].textureCoord = GLKVector2Make(0, 1);
    
    self.vertices[2].positionCoord = centerPointRT;
    self.vertices[2].textureCoord = GLKVector2Make(1, 1-startY);
    
    self.vertices[3].positionCoord = centerPointLT;
    self.vertices[3].textureCoord = GLKVector2Make(0, 1-startY);
    
    self.vertices[4].positionCoord = centerPointRB;
    self.vertices[4].textureCoord = GLKVector2Make(1, 1-endY);
    
    self.vertices[5].positionCoord = centerPointLB;
    self.vertices[5].textureCoord = GLKVector2Make(0, 1-endY);
    
    self.vertices[6].positionCoord = pointRB;
    self.vertices[6].textureCoord = GLKVector2Make(1, 0);
    
    self.vertices[7].positionCoord = pointLB;
    self.vertices[7].textureCoord = GLKVector2Make(0, 0);
    
    self.currentTextureStartY = startY;
    self.currentTextureEndY = endY;
    self.currentNewHeight = newHeight;
}
#pragma mark - GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(1.f, 1.f, 1.f, 1.f);
    glClear(GL_COLOR_BUFFER_BIT);
    [self.baseEffect prepareToDraw];
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLVertex), NULL+offsetof(GLVertex, positionCoord));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLVertex), NULL+offsetof(GLVertex, textureCoord));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, kVerticesCount);
    
}
#pragma mark-set/get方法
// 纹理顶部的纵坐标 0～1
- (CGFloat)textureTopY {
    //(1-vertices[0].顶点坐标的Y值)/2
    CGFloat textureTopYValue = (1 - self.vertices[0].positionCoord.y) / 2;
    return textureTopYValue;
}

// 纹理底部的纵坐标 0～1
- (CGFloat)textureBottomY {
    //(1-vertices[7].顶点坐标的Y值)/2
    CGFloat textureBottomYValue = (1 - self.vertices[7].positionCoord.y) / 2;
    return textureBottomYValue;
}

// 可伸缩区域顶部的纵坐标 0～1
- (CGFloat)stretchAreaTopY {
    CGFloat stretchAreaTopYValue = (1 - self.vertices[2].positionCoord.y) / 2;
    return stretchAreaTopYValue;
}
// 可伸缩区域底部的纵坐标 0～1
- (CGFloat)stretchAreaBottomY {
    CGFloat stretchAreaBottomYValue = (1 - self.vertices[5].positionCoord.y) / 2;
    return stretchAreaBottomYValue;
}
// 纹理高度 0～1
- (CGFloat)textureHeight {
    CGFloat textureHeightValue = self.textureBottomY - self.textureTopY;
    return textureHeightValue;
}
// 根据当前屏幕的尺寸，返回新的图片尺寸
- (CGSize)newImageSize {
    //新图片的尺寸 = 当前图片的高 * (当前图片高度 - (当前纹理EndY - 当前纹理Star))+1;
    CGFloat newImageHeight = self.currentImageSize.height * ((self.currentNewHeight - (self.currentTextureEndY - self.currentTextureStartY)) + 1);
    
    return CGSizeMake(self.currentImageSize.width, newImageHeight);
}
@end
