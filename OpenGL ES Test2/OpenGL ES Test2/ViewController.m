//
//  ViewController.m
//  OpenGL ES Test2
//
//  Created by 吴闯 on 2020/8/1.
//  Copyright © 2020 吴闯. All rights reserved.
//
//顶点片元着色器->文件->空->vsh/fsh
//vsh/fsh->内容编译和链接->
//vsh/fsh->区分.
//string -> GPUImage 框架 着色器 NSString ->
//1.不建议直接使用NSString
//2.不建议大家写中文注释->出现错误BUG。错误提示信息。
//3.在GLSL 不会写特别多注释-
#import "ViewController.h"
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/ES2/gl.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    glCompileShader(<#GLuint shader#>)
    glCreateProgram()
    glDeleteProgram(<#GLuint program#>)
    
/*
 glCreateShader(<#GLenum type#>);
 type - 创建着色器的类型，GL_VERTEX_SHADER|GL_FRAGMENT_SHADER
 返回值 - 是指向新着色器对象的句柄。可以调用glDeleteShader(<#GLuint shader#>)删除
 
 glDeleteShader(GLuint shader)
 shader - 要删除的着色器对象句柄
 
 glShaderSource(<#GLuint shader#>, <#GLsizei count#>, <#const GLchar *const *string#>, <#const GLint *length#>)
 shader - 指向着色器对象的句柄
 count - 着色器源字符串的数量，着色器可以由多个源字符串组成，但是每个着色器只有一个main函数
 string - 指向保存数量的count的着色器源字符串的数组指针
 length - 指向保存每个着色器字符串大小且元素数量为count的整数数组指针
 
 glCompileShader(<#GLuint shader#>)
 shader - 需要编译的着色器对象句柄
 
 glGetShaderiv(<#GLuint shader#>, <#GLenum pname#>, <#GLint *params#>)
 shader - 需要编译的着色器对象句柄
 pname - 获取的信息参数，可以为 GL_COMPILE_STATUS|GL_DELETE_STATUS|GL_INFO_LOG_LENGTH|GL_SHADER_SOURCE_LENGTH|GL_SHADER_TYPE
 params - 指向查询结果的整数存储位置的指针
 
 glGetShaderInfoLog(<#GLuint shader#>, <#GLsizei bufsize#>, <#GLsizei *length#>, <#GLchar *infolog#>)
 shader - 需要获取信息日志的着色器对象的句柄
 bufsize - 保存信息日志的缓存区大小
 length - 写入的信息日志的长度（减去null终止符）；如果不需要知道长度，这个参数可以传入Null
 infoLog -指向保存信息日志的字符缓冲区的指针。
 
 GLuint glCreateProgram (void)
 创建一个程序对象
 返回值：返回一个执行新程序对象的句柄
 
 void glDeleteProgram (GLuint program)
 program - 指向需要删除的程序对象句柄
 
 着色器与程序连接/附着
 void glAttachShader(GLuint program, GLuint shader)
 program - 指向程序对象句柄
 shader - 指向程序连接的着色器对象的句柄
 
 断开连接
 glDetachShader(GLuint program, GLuint shader)
 program - 指向程序对象的句柄
 shader - 指向程序断开连接的着色器对象的句柄
 
 glLinkProgram(GLuint program)
 program - 指向程序对象的句柄
 
 链接程序之后，需要检查链接是否成功，你可以使用glGetProgramiv(GLuint program, GLenum pname, GLint *params)检查链接状态
 void glGetProgramiv(GLuint program, GLenum pname, GLint *params)
 program - 需要获取信息的程序对象的句柄
 pname - 获取信息的参数
 
 glGetProgramInfoLog(GLuint program, GLsizei bufsize, GLsizei *length, GLchar *infolog)
 
 glUseProgram(GLuint program)
 */
glUseProgram(GLuint program)
}


@end
