//
//  LongLegVertexAttriArrayBuffer.m
//  OpenGL ES大长腿1
//
//  Created by 吴闯 on 2020/8/25.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import "LongLegVertexAttriArrayBuffer.h"

@interface LongLegVertexAttriArrayBuffer ()
@property(nonatomic,assign)GLuint glName;
@property(nonatomic,assign)GLsizeiptr bufferSizeBytes;
@property(nonatomic,assign)GLsizei stride;
@end

@implementation LongLegVertexAttriArrayBuffer
-(void)dealloc{
    if (_glName!=0) {
        glDeleteBuffers(1, &_glName);
        _glName = 0;
    }
}
-(id)initWithAttribStride:(GLsizei)stride
         numberOfVertices:(GLsizei)count
                     data:(const GLvoid *)data
                    usage:(GLenum)usage {
    if (self = [super init]) {
        _stride = stride;
        _bufferSizeBytes = stride * count;
        glGenBuffers(1, &_glName);
        glBindBuffer(GL_ARRAY_BUFFER, _glName);
        glBufferData(GL_ARRAY_BUFFER, _bufferSizeBytes, data, usage);
    }
    return self;
}
-(void)updateAttribStride:(GLsizei)stride
         numberOfVertices:(GLsizei)count
                     data:(const GLvoid *)data
                    usage:(GLenum)usage{
    _stride = stride;
    _bufferSizeBytes = stride * count;
    glBindBuffer(GL_ARRAY_BUFFER, _glName);
    glBufferData(GL_ARRAY_BUFFER, _bufferSizeBytes, data, GL_DYNAMIC_DRAW);
}
-(void)prepareToDrawWithAttrib:(GLuint)index
            numberofCordinates:(GLint)count
                  attribOffset:(GLsizeiptr)offset
                  shouldEnable:(BOOL)shouldEnable{
    if (shouldEnable) {
        glEnableVertexAttribArray(index);
    }
    glVertexAttribPointer(index, count, GL_FLOAT, GL_FALSE, _stride, NULL+offset);
}
-(void)drawArrayWithMode:(GLenum)mode
        startVertexIndex:(GLint)first
        numberOfVertices:(GLsizei)count{
    glDrawArrays(mode, first, count);
}
@end
