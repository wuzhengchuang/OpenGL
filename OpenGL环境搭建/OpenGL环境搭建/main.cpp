//
//  main.cpp
//  OpenGL环境搭建
//
//  Created by 吴闯 on 2020/7/3.
//  Copyright © 2020 吴闯. All rights reserved.
//

#include "GLShaderManager.h"
#include "GLTools.h"
#include <glut/glut.h>

GLBatch triangleBatch;

GLShaderManager shaderManager;

GLfloat blockSize = 0.1f;
GLfloat vVerts[] = {
    -blockSize,-blockSize,0.0f,
    blockSize,-blockSize,0.0f,
    blockSize,blockSize,0.0f,
    -blockSize,blockSize,0.0f,
};
//窗口大小改变时接受新的宽度和高度，其中0,0代表窗口中视口的左下角坐标，w，h代表像素
void ChangeSize(int w,int h) {
    printf("%d,%d\n",w,h);
    glViewport(0, 0, w, h);
}

//为程序作一次性的设置
void SetupRC() {
    glClearColor(0, 1, 1, 1);
    
    
    shaderManager.InitializeStockShaders();
    triangleBatch.Begin(GL_TRIANGLE_FAN, 4);
    triangleBatch.CopyVertexData3f(vVerts);
    triangleBatch.End();
}

//开始渲染
void RenderScene(void) {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    GLfloat vRed[] = {1,0,0,1};
    shaderManager.UseStockShader(GLT_SHADER_IDENTITY,vRed);
    triangleBatch.Draw();
    glutSwapBuffers();
}
void SpecialKeys(unsigned char key,int x,int y){
    //根据相对顶点D，计算出ABCD每个顶点坐标值
    GLfloat stepSize = 0.025f;
    GLfloat blockX = vVerts[9];
    GLfloat blockY = vVerts[10];
    switch (key) {
        case 'w'://上
            {
                blockY+=stepSize;
                blockY = (blockY>1.0?1.0:blockY);
            }
            break;
        case 's'://下
            {
                blockY-=stepSize;
                blockY = ((blockY-blockSize*2)<-1.0?-1.0+blockSize*2:blockY);
            }
            break;
        case 'a'://左a
            {
                blockX-=stepSize;
                blockX = (blockX<-1.0?-1.0:blockX);
            }
        break;
        case 'd'://右
            {
                blockX+=stepSize;
                blockX = ((blockX+blockSize*2)>1.0?1.0-blockSize*2:blockX);
            }
        break;
        default:
            break;
    }
    
    vVerts[0]=blockX;
    vVerts[1]=blockY-blockSize*2;
    
    vVerts[3]=blockX+blockSize*2;
    vVerts[4]=blockY-blockSize*2;
    
    vVerts[6]=blockX+blockSize*2;
    vVerts[7]=blockY;
    
    vVerts[9]=blockX;
    vVerts[10]=blockY;
    triangleBatch.CopyVertexData3f(vVerts);
    glutPostRedisplay();
}
void CloseWindow(){
    printf("关闭窗口\n");
    glutDestroyWindow(glutGetWindow());
//    exit(0);
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
    glutKeyboardFunc(SpecialKeys);
//    glutWMCloseFunc(CloseWindow);
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
