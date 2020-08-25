//
//  LongLegVertexAttriArrayBuffer.h
//  OpenGL ES大长腿1
//
//  Created by 吴闯 on 2020/8/25.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
NS_ASSUME_NONNULL_BEGIN
//glEnableVertexAttribArray(GLKVertexAttribPosition);
//glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLVertex), NULL+offsetof(GLVertex, positionCoord));
//
//glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
//glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLVertex), NULL+offsetof(GLVertex, textureCoord));
//
//glDrawArrays(GL_TRIANGLE_STRIP, 0, kVerticesCount);
@interface LongLegVertexAttriArrayBuffer : NSObject
-(id)initWithAttribStride:(GLsizei)stride
         numberOfVertices:(GLsizei)count
                     data:(const GLvoid *)data
                    usage:(GLenum)usage;
-(void)updateAttribStride:(GLsizei)stride
         numberOfVertices:(GLsizei)count
                     data:(const GLvoid *)data
                    usage:(GLenum)usage;
-(void)prepareToDrawWithAttrib:(GLuint)index
            numberofCordinates:(GLint)count
                  attribOffset:(GLsizeiptr)offset
                  shouldEnable:(BOOL)shouldEnable;
-(void)drawArrayWithMode:(GLenum)mode
        startVertexIndex:(GLint)first
        numberOfVertices:(GLsizei)count;
@end

NS_ASSUME_NONNULL_END
