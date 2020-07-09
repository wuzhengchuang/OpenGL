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
#include "GLFrame.h"
#include "math3d.h"
#include "GLFrustum.h"
#include "GLMatrixStack.h"
#include "GLGeometryTransform.h"
GLShaderManager shaderManager;
GLFrustum viewFrustum;
GLMatrixStack modelViewMatrix;//变换
GLMatrixStack projectionMatrix;//投影矩阵
GLGeometryTransform transformPipeline;

GLFrame objectFrame;
GLFrame cameraFrame;

GLBatch pointBatch;
GLBatch lineBatch;
GLBatch lineStripBatch;
GLBatch lineLoopBatch;
GLBatch triangleBatch;
GLBatch triangleStripBatch;
GLBatch triangleFanBatch;

GLfloat vGreen[] = {0.0f,1.0f,0.0f,1.0f};
GLfloat vBlack[] = {0.0f,0.0f,0.0f,1.0f};
GLfloat vertexs[] ={
    -0.1,-0.1,0,
    0.1,0.1,0,
    -0.1,0.1,0,
};
int nStep = 0;
//为程序作一次性的设置
void SetupRC() {
    glClearColor(0.7f, 0.7f, 0.7f, 1.0f);
    shaderManager.InitializeStockShaders();
    //投影变换（矩阵）.移动变换（矩阵），变换管道->快速去矩阵相乘->遍历
//    shaderManager.UseStockShader(GLT_SHADER_FLAT, ...)
    transformPipeline.SetMatrixStacks(modelViewMatrix, projectionMatrix);
    cameraFrame.MoveForward(-15.0f);
    GLfloat vCoast[9] = {
        3,3,0,
        0,3,0,
        3,0,0
    };
    pointBatch.Begin(GL_POINTS, 3);
    pointBatch.CopyVertexData3f(vCoast);
    pointBatch.End();
    
    lineBatch.Begin(GL_LINES, 3);
    lineBatch.CopyVertexData3f(vCoast);
    lineBatch.End();
    
    //通过线段的形式
      lineStripBatch.Begin(GL_LINE_STRIP, 3);
      lineStripBatch.CopyVertexData3f(vCoast);
      lineStripBatch.End();
    
    lineLoopBatch.Begin(GL_LINE_LOOP, 3);
    lineLoopBatch.CopyVertexData3f(vCoast);
    lineLoopBatch.End();
    
    GLfloat vPyramid[12][3] = {
        -2.0f,0.0f,-2.0f,
        2.0f,0.0f,-2.0f,
        0.0f,4.0f,0.0f,
        
        2.0f,0.0f,-2.0f,
        2.0f,0.0f,2.0f,
        0.0f,4.0f,0.0f,
        
        2.0f,0.0f,2.0f,
        -2.0f,0.0f,2.0f,
        0.0f,4.0f,0.0f,
        
        -2.0f,0.0f,2.0f,
        -2.0f,0.0f,-2.0f,
        0.0f,4.0f,0.0f,
    };
    triangleBatch.Begin(GL_TRIANGLES, 12);
    triangleBatch.CopyVertexData3f(vPyramid);
    triangleBatch.End();
    
    // 三角形扇形--六边形
    GLfloat vPoints[100][3];
    int nVerts = 0;
    //半径
    GLfloat r = 3.0f;
    //原点(x,y,z) = (0,0,0);
    vPoints[nVerts][0] = 0.0f;
    vPoints[nVerts][1] = 0.0f;
    vPoints[nVerts][2] = 0.0f;
    
    
    //M3D_2PI 就是2Pi 的意思，就一个圆的意思。 绘制圆形
    for(GLfloat angle = 0; angle < M3D_2PI; angle += M3D_2PI / 6.0f) {
        
        //数组下标自增（每自增1次就表示一个顶点）
        nVerts++;
        /*
         弧长=半径*角度,这里的角度是弧度制,不是平时的角度制
         既然知道了cos值,那么角度=arccos,求一个反三角函数就行了
         */
        //x点坐标 cos(angle) * 半径
        vPoints[nVerts][0] = float(cos(angle)) * r;
        //y点坐标 sin(angle) * 半径
        vPoints[nVerts][1] = float(sin(angle)) * r;
        //z点的坐标
        vPoints[nVerts][2] = -0.5f;
    }
    
    // 结束扇形 前面一共绘制7个顶点（包括圆心）
    //添加闭合的终点
    //课程添加演示：屏蔽177-180行代码，并把绘制节点改为7.则三角形扇形是无法闭合的。
    nVerts++;
    vPoints[nVerts][0] = r;
    vPoints[nVerts][1] = 0;
    vPoints[nVerts][2] = 0.0f;
    
    // 加载！
    //GL_TRIANGLE_FAN 以一个圆心为中心呈扇形排列，共用相邻顶点的一组三角形
    triangleFanBatch.Begin(GL_TRIANGLE_FAN, 8);
    triangleFanBatch.CopyVertexData3f(vPoints);
    triangleFanBatch.End();
    //三角形条带，一个小环或圆柱段
    //顶点下标
    int iCounter = 0;
    //半径
    GLfloat radius = 3.0f;
    //从0度~360度，以0.3弧度为步长
    for(GLfloat angle = 0.0f; angle <= (2.0f*M3D_PI); angle += 0.3f)
    {
        //或许圆形的顶点的X,Y
        GLfloat x = radius * sin(angle);
        GLfloat y = radius * cos(angle);
        
        //绘制2个三角形（他们的x,y顶点一样，只是z点不一样）
        vPoints[iCounter][0] = x;
        vPoints[iCounter][1] = y;
        vPoints[iCounter][2] = -0.5;
        iCounter++;
        
        vPoints[iCounter][0] = x;
        vPoints[iCounter][1] = y;
        vPoints[iCounter][2] = 0.5;
        iCounter++;
    }
    
    // 关闭循环
    printf("三角形带的顶点数：%d\n",iCounter);
    //结束循环，在循环位置生成2个三角形
    vPoints[iCounter][0] = vPoints[0][0];
    vPoints[iCounter][1] = vPoints[0][1];
    vPoints[iCounter][2] = -0.5;
    iCounter++;
    
    vPoints[iCounter][0] = vPoints[1][0];
    vPoints[iCounter][1] = vPoints[1][1];
    vPoints[iCounter][2] = 0.5;
    iCounter++;
    
    // GL_TRIANGLE_STRIP 共用一个条带（strip）上的顶点的一组三角形
    triangleStripBatch.Begin(GL_TRIANGLE_STRIP, iCounter);
    triangleStripBatch.CopyVertexData3f(vPoints);
    triangleStripBatch.End();
}
//窗口大小改变时接受新的宽度和高度，其中0,0代表窗口中视口的左下角坐标，w，h代表像素
void ChangeSize(int w,int h) {
    glViewport(0, 0, w*2, h*2);
    viewFrustum.SetPerspective(35.0f, float(w)/float(h), 1.0f, 500.0f);
    projectionMatrix.LoadMatrix(viewFrustum.GetProjectionMatrix());
    //初始化单元矩阵
    modelViewMatrix.LoadIdentity();
}
void DrawWireFramed(GLBatch *pBatch){
    /*------------画绿色部分----------------*/
    /* GLShaderManager 中的Uniform 值——平面着色器
     参数1：平面着色器
     参数2：运行为几何图形变换指定一个 4 * 4变换矩阵
          --transformPipeline 变换管线（指定了2个矩阵堆栈）
     参数3：颜色值
    */
    shaderManager.UseStockShader(GLT_SHADER_FLAT, transformPipeline.GetModelViewProjectionMatrix(), vGreen);
    pBatch->Draw();
    
    /*-----------边框部分-------------------*/
    /*
        glEnable(GLenum mode); 用于启用各种功能。功能由参数决定
        参数列表：http://blog.csdn.net/augusdi/article/details/23747081
        注意：glEnable() 不能写在glBegin() 和 glEnd()中间
        GL_POLYGON_OFFSET_LINE  根据函数glPolygonOffset的设置，启用线的深度偏移
        GL_LINE_SMOOTH          执行后，过虑线点的锯齿
        GL_BLEND                启用颜色混合。例如实现半透明效果
        GL_DEPTH_TEST           启用深度测试 根据坐标的远近自动隐藏被遮住的图形（材料
     
     
        glDisable(GLenum mode); 用于关闭指定的功能 功能由参数决定
     
     */
    
    //画黑色边框
    glPolygonOffset(-1.0f, -1.0f);// 偏移深度，在同一位置要绘制填充和边线，会产生z冲突，所以要偏移
    glEnable(GL_POLYGON_OFFSET_LINE);
    
    // 画反锯齿，让黑边好看些
    glEnable(GL_LINE_SMOOTH);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //绘制线框几何黑色版 三种模式，实心，边框，点，可以作用在正面，背面，或者两面
    //通过调用glPolygonMode将多边形正面或者背面设为线框模式，实现线框渲染
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    //设置线条宽度
    glLineWidth(2.5f);
    
    /* GLShaderManager 中的Uniform 值——平面着色器
     参数1：平面着色器
     参数2：运行为几何图形变换指定一个 4 * 4变换矩阵
         --transformPipeline.GetModelViewProjectionMatrix() 获取的
          GetMatrix函数就可以获得矩阵堆栈顶部的值
     参数3：颜色值（黑色）
     */
    
    shaderManager.UseStockShader(GLT_SHADER_FLAT, transformPipeline.GetModelViewProjectionMatrix(), vBlack);
    pBatch->Draw();

    // 复原原本的设置
    //通过调用glPolygonMode将多边形正面或者背面设为全部填充模式
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    glDisable(GL_POLYGON_OFFSET_LINE);
    glLineWidth(1.0f);
    glDisable(GL_BLEND);
    glDisable(GL_LINE_SMOOTH);
    
    
}
//开始渲染
void RenderScene(void) {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT |GL_STENCIL_BUFFER_BIT);
    modelViewMatrix.PushMatrix();
    M3DMatrix44f mCamera;
    cameraFrame.GetCameraMatrix(mCamera);
    modelViewMatrix.MultMatrix(mCamera);
    M3DMatrix44f mObjectFrame;
    objectFrame.GetMatrix(mObjectFrame);
    //矩阵相乘->模型视图矩阵
    modelViewMatrix.MultMatrix(objectFrame);
    //模型视图矩阵（观察者矩阵，物体变换矩阵）投影矩阵 mvp
    shaderManager.UseStockShader(GLT_SHADER_FLAT,transformPipeline.GetModelViewProjectionMatrix(),vBlack);
    switch (nStep) {
        case 0:
            glPointSize(10.0f);
            pointBatch.Draw();
            glPointSize(1.0f);
            break;
        case 1:
            glLineWidth(10.0f);
            lineBatch.Draw();
            glLineWidth(1.0f);
            break;
        case 2:
            glLineWidth(10.0f);
            lineStripBatch.Draw();
            glLineWidth(1.0f);
            break;
        case 3:
             glLineWidth(10.0f);
                       lineLoopBatch.Draw();
                       glLineWidth(1.0f);
            break;
        case 4:
             DrawWireFramed(&triangleBatch);
            break;
        case 5:
            DrawWireFramed(&triangleStripBatch);
            break;
        case 6:
            DrawWireFramed(&triangleFanBatch);
            break;
        default:
            break;
    }
    modelViewMatrix.PopMatrix();
    glutSwapBuffers();
}
//键盘按钮
void KeyPress(unsigned char key, int x, int y){
    if (key == 32) {
        nStep++;
        if (nStep>6) {
            nStep=0;
        }
    }
    switch (nStep) {
        case 0:
            glPointSize(4.0f);
            pointBatch.Draw();
            glPointSize(1.0f);
            glutSetWindowTitle("GL_POINTS");
            break;
        case 1:
            glutSetWindowTitle("GL_LINES");
            break;
        case 2:
            glutSetWindowTitle("GL_LINE_STRIP");
            break;
        case 3:
            glutSetWindowTitle("GL_LINE_LOOP");
            break;
        case 4:
            glutSetWindowTitle("GL_TRIANGLES");
            break;
        case 5:
            glutSetWindowTitle("GL_TRIANGLE_STRIP");
            break;
        case 6:
            glutSetWindowTitle("GL_TRIANGLE_FAN");
            break;
        default:
            break;
    }
    glutPostRedisplay();
}
//特殊键位
void SpecialKey(int key, int x, int y){
    if (key == GLUT_KEY_UP) {
        objectFrame.RotateWorld(m3dDegToRad(-5.0f), 1.0f, 0.0f, 0.0f);
    }
    if (key == GLUT_KEY_DOWN) {
        objectFrame.RotateWorld(m3dDegToRad(5.0f), 1.0f, 0.0f, 0.0f);
    }
    if (key == GLUT_KEY_LEFT) {
        objectFrame.RotateWorld(m3dDegToRad(-5.0f), 0.0f, 1.0f, 0.0f);
    }
    if (key == GLUT_KEY_RIGHT) {
        objectFrame.RotateWorld(m3dDegToRad(5.0f), 0.0f, 1.0f, 0.0f);
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
    
    glutCreateWindow("GL_Points");
    //注册回调函数
    glutReshapeFunc(ChangeSize);
    glutDisplayFunc(RenderScene);
    glutKeyboardFunc(KeyPress);
    glutSpecialFunc(SpecialKey);
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
