//
//  ViewController.m
//  OpenGL ES 图片分屏
//
//  Created by 吴闯 on 2020/8/10.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "FilterBar.h"
typedef struct {
    GLKVector3 positionCoord;
    GLKVector2 textureCoord;
}SenceVertex;
@interface ViewController ()<FilterBarDelegate>
@property(nonatomic,strong)EAGLContext *context;
@property(nonatomic,assign)SenceVertex *vertices;
@property(nonatomic,assign)GLuint textureID;
@property(nonatomic,assign)GLsizei drawableWidth;
@property(nonatomic,assign)GLsizei drawableHeight;
@property(nonatomic,assign)GLuint vertexBuffer;
@property(nonatomic,strong)CADisplayLink *displayLink;
@property(nonatomic,assign)int startTimeInterval;
@property(nonatomic,assign)GLuint program;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpFilterBar];
    [self filterInit];
    [self startFilerAnimation];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}
- (void)setUpFilterBar{
    CGFloat filterBarWidth = [[UIScreen mainScreen]bounds].size.width;
    CGFloat filterBarHeight = 100;
    CGFloat filterBarY = [[UIScreen mainScreen]bounds].size.height-filterBarHeight;
    FilterBar *filterBar = [[FilterBar alloc]initWithFrame:CGRectMake(0, filterBarY, filterBarWidth, filterBarHeight)];
    filterBar.delegate=self;
    [self.view addSubview:filterBar];
    NSArray *dataSource = @[@"无"];
    filterBar.itemList=dataSource;
}
- (void)filterInit{
    self.context=[[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context) {
        NSLog(@"EAGLContext创建失败");
        return;
    }
    if (![EAGLContext setCurrentContext:self.context]) {
        NSLog(@"EAGLContext设置失败");
        return;
    }
    self.vertices=calloc(4, sizeof(SenceVertex));
    self.vertices[0]=(SenceVertex){{-1,1,0},{0,1}};
    self.vertices[1]=(SenceVertex){{-1,-1,0},{0,0}};
    self.vertices[2]=(SenceVertex){{1,1,0},{1,1}};
    self.vertices[3]=(SenceVertex){{1,-1,0},{1,0}};
    
    CAEAGLLayer *eagLayer=[[CAEAGLLayer alloc]init];
    eagLayer.frame=CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width);
    [eagLayer setContentsScale:[[UIScreen mainScreen]scale]];
    [self.view.layer addSublayer:eagLayer];
    
    [self bindRenderLayer:eagLayer];
    
    self.textureID = [self createTextureWithImage:[UIImage imageNamed:@"timg.jpeg"]];
    
    glViewport(0, 0, self.drawableWidth, self.drawableHeight);
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(SenceVertex)*4, self.vertices, GL_STATIC_DRAW);
    [self setUpNormalShaerProgram];
    self.vertexBuffer=vertexBuffer;
}
-(void)startFilerAnimation{
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
    self.startTimeInterval = 0;
    self.displayLink=[CADisplayLink displayLinkWithTarget:self selector:@selector(timeAction)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
- (void)timeAction{
    if (self.startTimeInterval == 0) {
        self.startTimeInterval = self.displayLink.timestamp;
    }
    glUseProgram(self.program);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    CGFloat currentTime = self.displayLink.timestamp-self.startTimeInterval;
    GLuint time =glGetUniformLocation(self.program, "time");
    glUniform1f(time, currentTime);
    
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(1, 1, 1, 1);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}
- (void)setUpNormalShaerProgram{
    [self setUpNormalShaerProgram:@"Normal"];
}
- (void)setUpNormalShaerProgram:(NSString *)name{
    GLuint program = [self programWithShaderName:name];
    glUseProgram(program);
    GLuint positionSlot = glGetAttribLocation(program, "position");
    GLuint textureCoordSlot = glGetAttribLocation(program, "textureCoord");
    GLuint textureSlot =  glGetUniformLocation(program, "samplerTexture");
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.textureID);
    glUniform1i(textureSlot, 0);
    
    glEnableVertexAttribArray(positionSlot);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL+offsetof(SenceVertex, positionCoord));
    glEnableVertexAttribArray(textureCoordSlot);
    glVertexAttribPointer(textureCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL+offsetof(SenceVertex, textureCoord));
    self.program=program;
}
-(GLuint)programWithShaderName:(NSString *)name{
    GLuint vertSharder=[self compileShaderWithName:name type:GL_VERTEX_SHADER];
    GLuint fragSharder=[self compileShaderWithName:name type:GL_FRAGMENT_SHADER];
    GLuint program = glCreateProgram();
    glAttachShader(program, vertSharder);
    glAttachShader(program, fragSharder);
    glLinkProgram(program);
    GLint linkSuccess;
    glGetProgramiv(program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        NSLog(@"连接失败");
        exit(1);
    }
    glDetachShader(program, vertSharder);
    glDeleteShader(vertSharder);
    glDetachShader(program, fragSharder);
    glDeleteShader(fragSharder);
    return program;
}
-(GLuint)compileShaderWithName:(NSString *)name type:(GLenum)type{
    NSString *shaderPath=[[NSBundle mainBundle]pathForResource:name ofType:type==GL_VERTEX_SHADER?@"vsh":@"fsh"];
   NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = [shaderString UTF8String];
    GLuint shader = glCreateShader(type);
    int length=(int)shaderString.length;
    glShaderSource(shader, 1, &source, &length);
    glCompileShader(shader);
    return shader;
}
- (GLuint)createTextureWithImage:(UIImage *)image{
    CGImageRef newImage=image.CGImage;
    GLuint width = (GLuint)CGImageGetWidth(newImage);
    GLuint height = (GLuint)CGImageGetWidth(newImage);
    CGRect rect = CGRectMake(0, 0, width, height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    GLbyte *data = malloc(4*width*height);
    CGContextRef context = CGBitmapContextCreate(data, width, height, 8, width*4, colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, newImage);
    
    GLuint textures;
    glGenTextures(1, &textures);
    glBindTexture(GL_TEXTURE_2D, textures);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glBindTexture(GL_TEXTURE_2D, textures);
    CGContextRelease(context);
    free(data);
    return textures;
}
- (void)bindRenderLayer:(CALayer <EAGLDrawable>*)layer{
    GLuint renderbuffers;
    GLuint framebuffers;
    glGenRenderbuffers(1, &renderbuffers);
    glBindRenderbuffer(GL_RENDERBUFFER, renderbuffers);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    glGenFramebuffers(1, &framebuffers);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffers);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderbuffers);
}
#pragma mark getter
-(GLint)drawableWidth{
    GLint backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    return backingWidth;
}
-(GLint)drawableHeight{
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    return backingHeight;
}
#pragma mark FilterBarDelegate
- (void)filterBar:(FilterBar *)filterBar didScrollToIndex:(NSUInteger)index{
    
}
- (void)dealloc{
    if ([EAGLContext currentContext]==self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    if (_vertexBuffer) {
        glDeleteBuffers(1, &_vertexBuffer);
        _vertexBuffer = 0;
    }
    if (_vertices) {
        free(_vertices);
        _vertices = nil;
    }
}
@end
