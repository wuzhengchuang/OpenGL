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
GLfloat blockSize=0.1;
GLfloat centerVerts[]={
    -blockSize,-blockSize,0,
    blockSize,-blockSize,0,
    blockSize,blockSize,0,
    -blockSize,blockSize,0,
};
GLfloat offX=0;
GLfloat offY=0;
GLfloat step=0.05;
//窗口大小改变时接受新的宽度和高度，其中0,0代表窗口中视口的左下角坐标，w，h代表像素
void ChangeSize(int w,int h) {
    glViewport(0, 0, w*2, h*2);
    
}

//为程序作一次性的设置
void SetupRC() {
    glClearColor(1, 1, 1, 1);
    shaderManager.InitializeStockShaders();
    triangleBatch.Begin(GL_TRIANGLE_FAN, 4);
    triangleBatch.CopyVertexData3f(centerVerts);
    triangleBatch.End();
}

//开始渲染
void RenderScene(void) {
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    M3DMatrix44f matrix;
    m3dTranslationMatrix44(matrix, offX, offY, 0);
    GLfloat vRed[] = {1,0,0,0.5};
    shaderManager.UseStockShader(GLT_SHADER_FLAT,matrix,vRed);
    glTranslated(offX, offY, 0);
    triangleBatch.Draw();
    
    M3DMatrix44f topLeft;
    m3dTranslationMatrix44(topLeft, -0.5, 0.5, 0);
    GLfloat vGreen[] = {0,1,0,0.5};
    shaderManager.UseStockShader(GLT_SHADER_FLAT,topLeft,vGreen);
    glTranslated(-0.5, 0.5, 0);
    triangleBatch.Draw();
    
    M3DMatrix44f topRight;
    m3dTranslationMatrix44(topRight, 0.5, 0.5, 0);
    GLfloat vBlue[] = {0,0,1,0.5};
    shaderManager.UseStockShader(GLT_SHADER_FLAT,topRight,vBlue);
    glTranslated(0.5, 0.5, 0);
    triangleBatch.Draw();
    
    M3DMatrix44f bottomRight;
    m3dTranslationMatrix44(bottomRight, 0.5, -0.5, 0);
    GLfloat vOther[] = {0.3,0.5,0.2,0.5};
    shaderManager.UseStockShader(GLT_SHADER_FLAT,bottomRight,vOther);
    glTranslated(0.5, -0.5, 0);
    triangleBatch.Draw();
    
    M3DMatrix44f bottomLeft;
    m3dTranslationMatrix44(bottomLeft, -0.5, -0.5, 0);
    GLfloat vOther1[] = {0.3,0.1,0.2,0.5};
    shaderManager.UseStockShader(GLT_SHADER_FLAT,bottomLeft,vOther1);
    glTranslated(-0.5, -0.5, 0);
    triangleBatch.Draw();
    glutSwapBuffers();
    glDisable(GL_BLEND);
}
//键盘移动
void SpecialKeyboard(int key,int x,int y){
    switch (key) {
        case GLUT_KEY_UP:
            offY+=step;
            break;
        case GLUT_KEY_DOWN:
            offY-=step;
        break;
        case GLUT_KEY_LEFT:
            offX-=step;
        break;
        case GLUT_KEY_RIGHT:
            offX+=step;
        break;
        default:
            break;
    }
    glutPostRedisplay();
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
    glutSpecialFunc(SpecialKeyboard);
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
