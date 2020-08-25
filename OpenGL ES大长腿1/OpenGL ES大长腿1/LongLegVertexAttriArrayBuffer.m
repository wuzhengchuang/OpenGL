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
@end
