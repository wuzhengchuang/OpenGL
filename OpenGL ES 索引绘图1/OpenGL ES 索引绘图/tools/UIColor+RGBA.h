//
//  UIColor+RGBA.h
//  OpenGL ES 索引绘图
//
//  Created by 吴闯 on 2020/8/4.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef struct {
    float red;
    float green;
    float blue;
    float alpa;
}RGBA;
@interface UIColor (RGBA)
void UIColorToRGBA(UIColor *color,RGBA *rgba);
@end

NS_ASSUME_NONNULL_END
