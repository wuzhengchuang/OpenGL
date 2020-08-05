//
//  UIColor+RGBA.m
//  OpenGL ES 索引绘图
//
//  Created by 吴闯 on 2020/8/4.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import "UIColor+RGBA.h"

@implementation UIColor (RGBA)
void UIColorToRGBA(UIColor *color,RGBA *rgba){
    
    const CGFloat * colors = CGColorGetComponents(color.CGColor);
    rgba->red=colors[0];
    rgba->green=colors[1];
    rgba->blue=colors[2];
    rgba->alpa=colors[3];
}
@end
