attribute vec4 position;
attribute vec2 textureCoord;
varying vec2 varyTextureCoord;
void main(void){
    varyTextureCoord = textureCoord;
    gl_Position = position;
}
