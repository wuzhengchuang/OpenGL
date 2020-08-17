attribute vec4 position;
attribute vec2 textCoord;
varying vec2 varyTextCoord;
void main(void){
    varyTextCoord = textCoord;
    vec4 temp = position;
    gl_Position = temp;
}
