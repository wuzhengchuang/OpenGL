attribute vec4 position;
attribute vec2 textCoord;
varying vec2 varyTextureCoord;
void main(void){
    varyTextureCoord = textCoord;
    gl_Position = position;
}
