//
//  LongLegView.h
//  OpenGL ES大长腿1
//
//  Created by 吴闯 on 2020/8/25.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import <GLKit/GLKit.h>
@class LongLegView;
NS_ASSUME_NONNULL_BEGIN
@protocol LongLegViewViewDelegate <NSObject>

//代理方法(SpringView拉伸区域修改)
- (void)springViewStretchAreaDidChanged:(LongLegView *)springView;

@end
@interface LongLegView : GLKView
@property (nonatomic, weak) id <LongLegViewViewDelegate> springDelegate;
@property (nonatomic, assign,readonly)BOOL hasChange;
/**
 将区域拉伸或压缩为某个高度
 @param startY 开始的纵坐标位置（相对于纹理）
 @param endY 结束的纵坐标位置（相对于纹理）
 @param newHeight 新的高度（相对于纹理）
 */
- (void)stretchingFromStartY:(CGFloat)startY
                      toEndY:(CGFloat)endY
               withNewHeight:(CGFloat)newHeight;
- (void)updateImage:(UIImage *)image;
- (void)updateTexture;
- (CGFloat)textureTopY;
- (CGFloat)textureBottomY;
- (CGFloat)stretchAreaTopY;
- (CGFloat)stretchAreaBottomY;
- (CGFloat)textureHeight;
@end

NS_ASSUME_NONNULL_END
