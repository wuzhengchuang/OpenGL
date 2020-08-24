//
//  GLProgramHelper.h
//  OpenGL ES大长腿1
//
//  Created by 吴闯 on 2020/8/24.
//  Copyright © 2020 吴闯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
NS_ASSUME_NONNULL_BEGIN

@interface GLProgramHelper : NSObject
+(GLuint)programWithShaderName:(NSString *)shaderName;
@end

NS_ASSUME_NONNULL_END
