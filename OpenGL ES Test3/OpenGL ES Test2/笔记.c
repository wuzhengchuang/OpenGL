/*
 3种数据修饰类型
 uniform，attribute，varying
 uniform ->传递到顶点和片元着色器变量
 gluniform...
 顶点和片元着色器->把传进的uniform作为常量使用
 uniform -> 客户端 ->顶点/片元着色器
 顶点/片元着色器 进行一样的声明 ->都传进
 用途：视图矩阵，投影矩阵，投影视图矩阵
 uniform mat4 viewProMatrix;
 glUniform...
 
 attribute :特点->客户端->顶点着色器
 修饰什么数据：顶点，纹理坐标，颜色，法线->坐标颜色有关
 glVertex...
 
 纹理坐标->二维
 
 attribute vec4 position;
 attribute vec4 color;
 attribute vec2 texCoord;
 
 纹理坐标->传递
 attribute间接传递片元着色器
 varying 修饰符
 
 
 */
