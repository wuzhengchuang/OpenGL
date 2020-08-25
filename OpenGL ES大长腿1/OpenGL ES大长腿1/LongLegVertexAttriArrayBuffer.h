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

@interface LongLegVertexAttriArrayBuffer : NSObject
-(id)initWithAttribStride:(GLsizei)stride
         numberOfVertices:(GLsizei)count
                     data:(const GLvoid *)data
                    usage:(GLenum)usage;
@end

NS_ASSUME_NONNULL_END
