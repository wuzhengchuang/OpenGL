//
//  GLProgramHelper.m
//  OpenGL ES大长腿1
//
//  Created by 吴闯 on 2020/8/24.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import "GLProgramHelper.h"

@implementation GLProgramHelper
+(GLuint)programWithShaderName:(NSString *)shaderName{
    GLuint vertexShader,fragShader;
    GLuint program = glCreateProgram();
    vertexShader = [self compile:shaderName type:GL_VERTEX_SHADER];
    fragShader = [self compile:shaderName type:GL_FRAGMENT_SHADER];
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragShader);
    glLinkProgram(program);
    GLint linkScuess;
    glGetProgramiv(program, GL_LINK_STATUS, &linkScuess);
    if (linkScuess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(program, sizeof(messages), 0, messages);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSAssert(NO, @"program链接失败：%@",messageString);
        exit(1);
    }
    return program;
}
+(GLuint)compile:(NSString *)shaderName type:(GLenum)type{
   NSString *path = [[NSBundle mainBundle]pathForResource:shaderName ofType:type==GL_VERTEX_SHADER?@"vsh":@"fsh"];
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSAssert(NO, @"读取shader失败!");
        exit(1);
    }
    const char *shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    GLuint shader = glCreateShader(type);
    glShaderSource(shader, 1, &shaderStringUTF8, &shaderStringLength);
    glCompileShader(shader);
    GLint compileSuccess;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shader, sizeof(messages), 0, messages);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSAssert(NO, @"shader编译失败：%@",messageString);
        exit(1);
    }
    return shader;
}
@end
