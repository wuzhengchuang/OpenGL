attribute vec4 positionCoord;
attribute vec2 textureCoord;
varying vec2 varyTextureCoord;
void main(void){
    varyTextureCoord = textureCoord;
    gl_Position = positionCoord;
}
