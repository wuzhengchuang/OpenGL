attribute vec4 position;
attribute vec2 textCoord;
varying vec2 varyTextCoord;
void main(){
    varyTextCoord = textCoord;
    gl_Position = position;
}
