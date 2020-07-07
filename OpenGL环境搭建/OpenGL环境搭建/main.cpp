//
//  main.cpp
//  OpenGL环境搭建
//
//  Created by 吴闯 on 2020/7/3.
//  Copyright © 2020 吴闯. All rights reserved.
//  搭建XCode环境OpenGL
//  导入include，libGLTools.a,导入GLUT.framework,OpenGL.framework
//  header search path 设置include路径，直接拉进去就可以

#include "GLShaderManager.h"
#include "GLTools.h"
#include <glut/glut.h>

GLBatch triangleBatch;

GLShaderManager shaderManager;

//窗口大小改变时接受新的宽度和高度，其中0,0代表窗口中视口的左下角坐标，w，h代表像素
void ChangeSize(int w,int h) {
   
}

//为程序作一次性的设置
void SetupRC() {
    
}

//开始渲染
void RenderScene(void) {
    
}
int main(int argc,char* argv[]) {
    //设置当前工作目录，针对MAC OS X
    gltSetWorkingDirectory(argv[0]);
    //初始化GLUT库
    glutInit(&argc, argv);
    /*初始化双缓冲窗口，其中标志GLUT_DOUBLE、GLUT_RGBA、GLUT_DEPTH、GLUT_STENCIL分别指
     双缓冲窗口、RGBA颜色模式、深度测试、模板缓冲区*/
    glutInitDisplayMode(GLUT_DOUBLE|GLUT_RGBA|GLUT_DEPTH|GLUT_STENCIL);
    
    //GLUT窗口大小，标题窗口
    glutInitWindowSize(500,500);
    
    glutCreateWindow("Triangle");
    //注册回调函数
    glutReshapeFunc(ChangeSize);
    glutDisplayFunc(RenderScene);
    //驱动程序的初始化中没有出现任何问题。
    GLenum err = glewInit();
    
    if(GLEW_OK != err) {
        fprintf(stderr,"glew error:%s\n",glewGetErrorString(err));
        return 1;
    }
    
    //调用SetupRC
    SetupRC();
    glutMainLoop();
    return 0;
}
